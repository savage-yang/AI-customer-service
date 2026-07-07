import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/video_service.dart';

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late VideoService _service;
  late RTCVideoRenderer _remoteRenderer;
  late RTCVideoRenderer _localRenderer;

  @override
  void initState() {
    super.initState();
    _service = Provider.of<VideoServiceProvider>(context, listen: false).service;
    _initRenderers();
    _service.onMessage.listen((message) {
      if (message['type'] == 'call_ended') {
        Navigator.pop(context);
      }
    });
  }

  Future<void> _initRenderers() async {
    _remoteRenderer = RTCVideoRenderer();
    _localRenderer = RTCVideoRenderer();
    await _remoteRenderer.initialize();
    await _localRenderer.initialize();

    if (_service.remoteStream != null) {
      _remoteRenderer.srcObject = _service.remoteStream;
    }
    if (_service.localStream != null) {
      _localRenderer.srcObject = _service.localStream;
    }

    _service.onStateChanged.listen((_) {
      setState(() {
        if (_service.remoteStream != null) {
          _remoteRenderer.srcObject = _service.remoteStream;
        }
        if (_service.localStream != null) {
          _localRenderer.srcObject = _service.localStream;
        }
      });
    });
  }

  @override
  void dispose() {
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.black,
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
            Container(
              color: Colors.black,
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue, width: 2),
                    ),
                    child: RTCVideoView(
                      _localRenderer,
                      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                      mirror: true,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '正在通话中',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            '客服已接入',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _service.toggleMute,
                    icon: Icon(
                      _service.isMuted ? Icons.mic_off : Icons.mic,
                      color: _service.isMuted ? Colors.red : Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    onPressed: _service.toggleVideo,
                    icon: Icon(
                      _service.isVideoOn ? Icons.videocam : Icons.videocam_off,
                      color: _service.isVideoOn ? Colors.white : Colors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 30),
                  IconButton(
                    onPressed: () async {
                      await _service.endCall();
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.call_end,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}