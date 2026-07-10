import 'dart:async';

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
  static const Color _textPrimary = Color(0xFFECF3FF);
  static const Color _stroke = Color(0x1FFFFFFF);
  static const Color _accent = Color(0xFF75F6D1);
  static const Color _danger = Color(0xFFFF8478);

  late VideoService _service;
  late RTCVideoRenderer _remoteRenderer;
  late RTCVideoRenderer _localRenderer;
  StreamSubscription? _messageSubscription;
  StreamSubscription? _stateChangedSubscription;

  @override
  void initState() {
    super.initState();
    _service = Provider.of<VideoServiceProvider>(context, listen: false).service;
    _initRenderers();
    _messageSubscription = _service.onMessage.listen((message) {
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

    _stateChangedSubscription = _service.onStateChanged.listen((_) {
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
    _messageSubscription?.cancel();
    _stateChangedSubscription?.cancel();
    _remoteRenderer.dispose();
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1628),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E1930),
                      Color(0xFF11203A),
                      Color(0xFF0A1324),
                    ],
                  ),
                ),
                child: RTCVideoView(
                  _remoteRenderer,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                ),
              ),
            ),
            Positioned(
              top: 72,
              right: 28,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xAA75F6D1),
                      blurRadius: 26,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: _buildTopBar(),
            ),
            Positioned(
              top: 100,
              right: 16,
              child: _buildLocalVideo(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControlBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0x99132138),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _stroke),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new, size: 14, color: _textPrimary),
                SizedBox(width: 4),
                Text(
                  '返回',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0x99132138),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _stroke),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _accent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '正在通话中',
                style: TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLocalVideo() {
    return Container(
      width: 110,
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0x339AB9D4),
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: RTCVideoView(
        _localRenderer,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
        mirror: true,
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            const Color(0xFF050B16).withValues(alpha: 0.84),
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _service.isMuted ? Icons.mic_off : Icons.mic,
            label: _service.isMuted ? '已静音' : '麦克风',
            isActive: !_service.isMuted,
            onTap: _service.toggleMute,
          ),
          _buildEndCallButton(),
          _buildControlButton(
            icon: _service.isVideoOn ? Icons.videocam : Icons.videocam_off,
            label: _service.isVideoOn ? '摄像头' : '已关闭',
            isActive: _service.isVideoOn,
            onTap: _service.toggleVideo,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? Colors.white.withValues(alpha: 0.14)
                  : _danger.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: isActive
                    ? const Color(0x339AB9D4)
                    : _danger.withValues(alpha: 0.35),
              ),
            ),
            child: Icon(
              icon,
              color: isActive ? _textPrimary : _danger,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? _textPrimary : _danger,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: () async {
        await _service.endCall();
        Navigator.pop(context);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8478), Color(0xFFE76D68)],
              ),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x44FF8478),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.call_end,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '挂断',
            style: TextStyle(
              color: _danger,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
