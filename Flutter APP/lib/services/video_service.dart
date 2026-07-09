import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VideoService {
  WebSocketChannel? _channel;
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;

  MediaStream? get localStream => _localStream;
  MediaStream? get remoteStream => _remoteStream;

  String? roomId;
  String? username;
  bool isConnected = false;
  bool isCalling = false;
  bool isMuted = false;
  bool isVideoOn = true;

  final _onStateChanged = StreamController<bool>.broadcast();
  Stream<bool> get onStateChanged => _onStateChanged.stream;

  final _onMessage = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get onMessage => _onMessage.stream;

  final _onError = StreamController<String>.broadcast();
  Stream<String> get onError => _onError.stream;

  Future<void> connect(String serverUrl, {String role = 'user'}) async {
    if (_channel != null) {
      await disconnect();
    }

    final completer = Completer<void>();

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://${serverUrl}/ws/video'),
      );

      _channel?.stream.listen(
        (message) {
          try {
            final data = jsonDecode(message) as Map<String, dynamic>;
            _onMessage.add(data);

            switch (data['type']) {
              case 'init':
                isConnected = true;
                if (!completer.isCompleted) {
                  completer.complete();
                }
                break;
              case 'call_created':
                roomId = data['room_id'] as String?;
                break;
              case 'agent_joined':
                _createPeerConnection();
                break;
              case 'offer':
                _handleOffer(data['offer']);
                break;
              case 'answer':
                _handleAnswer(data['answer']);
                break;
              case 'ice_candidate':
                _handleIceCandidate(data['candidate']);
                break;
              case 'call_ended':
              case 'call_rejected':
                endCall();
                break;
            }
            _onStateChanged.add(true);
          } catch (e) {
            _onError.add('消息解析错误: $e');
          }
        },
        onError: (error) {
          _onError.add('WebSocket错误: $error');
          isConnected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('WebSocket连接错误: $error'));
          }
          _onStateChanged.add(true);
        },
        onDone: () {
          isConnected = false;
          if (!completer.isCompleted) {
            completer.completeError(Exception('WebSocket连接已关闭'));
          }
          _onStateChanged.add(true);
        },
      );

      _channel?.sink.add(jsonEncode({'type': 'join', 'role': role}));

      await completer.future.timeout(const Duration(seconds: 10));
    } catch (e) {
      print('WebSocket connect error: $e');
      _onError.add('WebSocket连接失败: $e');
      rethrow;
    }
  }

  Future<void> createCall(String name, {String issue = '', String sn = ''}) async {
    if (!isConnected || _channel == null) {
      throw Exception('WebSocket未连接');
    }
    username = name;
    _channel?.sink.add(jsonEncode({
      'type': 'create_call',
      'username': name,
      'issue': issue,
      'sn': sn,
    }));
  }

  Future<void> cancelCall() async {
    if (_channel != null && roomId != null) {
      _channel?.sink.add(jsonEncode({
        'type': 'cancel_call',
        'room_id': roomId,
      }));
    }
    roomId = null;
  }

  Future<void> endCall() async {
    _channel?.sink.add(jsonEncode({
      'type': 'end_call',
      'room_id': roomId,
    }));
    await _disposePeerConnection();
    await _stopLocalStream();
    isCalling = false;
    roomId = null;
    _onStateChanged.add(true);
  }

  Future<void> _createPeerConnection() async {
    try {
      final configuration = {
        'iceServers': [
          {'urls': 'stun:stun.l.google.com:19302'},
cc          {'urls': 'stun:stun1.l.google.com:19302'},
          {'urls': 'stun:stun2.l.google.com:19302'},
        ]
      };

      _peerConnection = await createPeerConnection(configuration);

      _peerConnection?.onIceCandidate = (candidate) {
        _channel?.sink.add(jsonEncode({
          'type': 'ice_candidate',
          'room_id': roomId,
          'candidate': candidate.toMap(),
        }));
      };

      _peerConnection?.onTrack = (event) {
        _remoteStream = event.streams.first;
        isCalling = true;
        _onStateChanged.add(true);
      };

      await _startLocalStream();
      if (_localStream != null) {
        _localStream!.getTracks().forEach((track) {
          _peerConnection?.addTrack(track, _localStream!);
        });
      }

      final offer = await _peerConnection!.createOffer();
      await _peerConnection!.setLocalDescription(offer);

      _channel?.sink.add(jsonEncode({
        'type': 'offer',
        'room_id': roomId,
        'offer': offer.toMap(),
      }));
    } catch (e) {
      print('创建PeerConnection失败: $e');
    }
  }

  Future<void> _handleOffer(dynamic offer) async {
    try {
      await _createPeerConnection();
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      _channel?.sink.add(jsonEncode({
        'type': 'answer',
        'room_id': roomId,
        'answer': answer.toMap(),
      }));
    } catch (e) {
      print('处理Offer失败: $e');
    }
  }

  Future<void> _handleAnswer(dynamic answer) async {
    try {
      await _peerConnection?.setRemoteDescription(
        RTCSessionDescription(answer['sdp'], answer['type']),
      );
    } catch (e) {
      print('处理Answer失败: $e');
    }
  }

  Future<void> _handleIceCandidate(dynamic candidate) async {
    try {
      if (candidate != null) {
        await _peerConnection?.addCandidate(
          RTCIceCandidate(candidate['candidate'], candidate['sdpMid'], candidate['sdpMLineIndex']),
        );
      }
    } catch (e) {
      print('处理ICE候选失败: $e');
    }
  }

  Future<void> _startLocalStream() async {
    try {
      _localStream = await navigator.mediaDevices.getUserMedia({
        'video': true,
        'audio': true,
      });
    } catch (e) {
      print('获取本地媒体流失败: $e');
    }
  }

  Future<void> _stopLocalStream() async {
    _localStream?.getTracks().forEach((track) => track.stop());
    _localStream = null;
  }

  Future<void> _disposePeerConnection() async {
    await _peerConnection?.close();
    _peerConnection = null;
    _remoteStream = null;
  }

  void toggleMute() {
    if (_localStream != null) {
      isMuted = !isMuted;
      _localStream!.getAudioTracks().forEach((track) {
        track.enabled = !isMuted;
      });
      _onStateChanged.add(true);
    }
  }

  void toggleVideo() {
    if (_localStream != null) {
      isVideoOn = !isVideoOn;
      _localStream!.getVideoTracks().forEach((track) {
        track.enabled = isVideoOn;
      });
      _onStateChanged.add(true);
    }
  }

  Future<void> disconnect() async {
    await _disposePeerConnection();
    await _stopLocalStream();
    await _channel?.sink.close();
    _channel = null;
    isConnected = false;
    isCalling = false;
    roomId = null;
    _onStateChanged.add(true);
  }
}