import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/video_provider.dart';
import 'video_call_screen.dart';
import 'video_history_screen.dart';

class VideoSupportScreen extends StatefulWidget {
  const VideoSupportScreen({super.key});

  @override
  State<VideoSupportScreen> createState() => _VideoSupportScreenState();
}

class _VideoSupportScreenState extends State<VideoSupportScreen> {
  final _nameController = TextEditingController(text: 'Luna Chen');
  final _snController = TextEditingController(text: 'SN-2024-0815-AX91');
  final _issueController =
      TextEditingController(text: '机器启动后反复报错，底座无法回充。');

  bool _isConnecting = false;
  bool _isWaiting = false;
  String _statusMessage = '';
  StreamSubscription? _messageSubscription;
  StreamSubscription? _errorSubscription;

  static const Color _textPrimary = Color(0xFFECF3FF);
  static const Color _textMuted = Color(0xFFB8C7DE);
  static const Color _stroke = Color(0x2EFFFFFF);
  static const Color _panel = Color(0xDD18253A);
  static const Color _panelSoft = Color(0xC022314A);
  static const Color _accent = Color(0xFF75F6D1);

  BoxDecoration _glassCard({
    Gradient? gradient,
    Color color = _panel,
    BorderRadius? radius,
    Border? border,
  }) {
    return BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: radius ?? BorderRadius.circular(24),
      border: border ?? Border.all(color: _stroke),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 28,
          offset: Offset(0, 16),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    final service =
        Provider.of<VideoServiceProvider>(context, listen: false).service;

    _messageSubscription = service.onMessage.listen((message) {
      switch (message['type']) {
        case 'init':
          setState(() {
            _isConnecting = false;
            _statusMessage = '已连接到客服系统';
          });
          break;
        case 'call_created':
          setState(() {
            _isWaiting = true;
            _statusMessage = '专家在线匹配中';
          });
          break;
        case 'agent_joined':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const VideoCallScreen()),
          );
          break;
        case 'call_rejected':
          setState(() {
            _isWaiting = false;
            _statusMessage = '本次接入请求已被取消';
          });
          break;
        case 'call_canceled':
          setState(() {
            _isWaiting = false;
            _statusMessage = '请求已取消';
          });
          break;
      }
    });

    _errorSubscription = service.onError.listen((error) {
      setState(() {
        _isConnecting = false;
        _isWaiting = false;
        _statusMessage = error;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: const Color(0xFFFF8478),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  Future<void> _connectAndCall() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入你的姓名'),
          backgroundColor: const Color(0xFFFF8478),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    final hasPermission = await _requestPermissions();
    if (!hasPermission) {
      setState(() {
        _statusMessage = '请授予摄像头和麦克风权限';
      });
      return;
    }

    setState(() {
      _isConnecting = true;
      _statusMessage = '正在连接...';
    });

    try {
      final service =
          Provider.of<VideoServiceProvider>(context, listen: false).service;
      await service.connect(AppConfig.videoServerUrl);
      await service.createCall(
        _nameController.text,
        issue: _issueController.text,
        sn: _snController.text,
      );
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _isWaiting = false;
        _statusMessage = '连接失败：$e';
      });
    }
  }

  Future<void> _cancelCall() async {
    final service =
        Provider.of<VideoServiceProvider>(context, listen: false).service;
    await service.cancelCall();
    setState(() {
      _isWaiting = false;
      _statusMessage = '';
    });
  }

  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoHistoryScreen()),
    );
  }

  Future<bool> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      return true;
    }

    if (cameraStatus.isDenied || microphoneStatus.isDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('需要摄像头和麦克风权限才能进行视频通话'),
          backgroundColor: const Color(0xFFFF8478),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }

    if (cameraStatus.isPermanentlyDenied ||
        microphoneStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('权限已被永久拒绝，请在系统设置中开启'),
          backgroundColor: const Color(0xFFFF8478),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: '去设置',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 12),
                        _buildTitleCard(),
                        const SizedBox(height: 20),
                        _buildHeroCard(),
                        const SizedBox(height: 14),
                        if (!_isWaiting) _buildInputCard() else _buildWaitingCard(),
                        if (_statusMessage.isNotEmpty &&
                            !_isConnecting &&
                            !_isWaiting)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              _statusMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _statusMessage.contains('失败')
                                    ? const Color(0xFFFF8478)
                                    : const Color(0xFF3DC882),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (!_isWaiting) _buildCallButton(),
              ],
            ),
          ),
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
            decoration: _glassCard(
              color: _panelSoft,
              radius: BorderRadius.circular(999),
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
        GestureDetector(
          onTap: _navigateToHistory,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: _glassCard(
              color: _panelSoft,
              radius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: _accent, size: 16),
                SizedBox(width: 6),
                Text(
                  '会议历史',
                  style: TextStyle(
                    color: _textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _glassCard(
        color: const Color(0xEE22324B),
        radius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x409AB9D4)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '实时专家协助',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Video Support',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 16,
            height: 16,
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
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: _glassCard(
        color: const Color(0xE8233652),
        radius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x3D9AB9D4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF305564),
              borderRadius: BorderRadius.all(Radius.circular(999)),
              boxShadow: [
                BoxShadow(
                  color: _accent.withValues(alpha: 0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                'Live Assistance',
                style: TextStyle(
                  color: _accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          SizedBox(height: 22),
          Text(
            '面对面协助，解决复杂售后问题',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              height: 1.12,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: 18),
          Text(
            '适合设备异常、安装指导、清洁维修、功能排障等需要专家实时介入的场景。',
            style: TextStyle(
              color: Color(0xFF9DAEC9),
              fontSize: 17,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glassCard(
        color: _panelSoft,
        radius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFieldLabel('你的姓名'),
          const SizedBox(height: 8),
          _buildFieldShell(_nameController, minLines: 1, maxLines: 1),
          const SizedBox(height: 14),
          _buildFieldLabel('设备 SN'),
          const SizedBox(height: 8),
          _buildFieldShell(_snController, minLines: 1, maxLines: 1),
          const SizedBox(height: 14),
          _buildFieldLabel('问题描述'),
          const SizedBox(height: 8),
          _buildFieldShell(_issueController, minLines: 3, maxLines: 4),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _textMuted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildFieldShell(
    TextEditingController controller, {
    required int minLines,
    required int maxLines,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
        boxShadow: const [
          BoxShadow(
            color: Color(0x123E7BFF),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        minLines: minLines,
        maxLines: maxLines,
        decoration: const InputDecoration(
          isCollapsed: true,
          border: InputBorder.none,
        ),
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: _glassCard(
        color: _panelSoft,
        radius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '专家在线匹配中',
                  style: TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                _statusMessage.isEmpty ? '00:36' : '00:36',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 180,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '已为你匹配“清洁电器高级工程师”，预计 1 分钟内接入。',
            style: TextStyle(
              color: _textMuted,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: _cancelCall,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0x33FF8478),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0x66FF8478)),
              ),
              alignment: Alignment.center,
              child: const Text(
                '取消请求',
                style: TextStyle(
                  color: Color(0xFFFF8478),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _connectAndCall,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5571A7FF),
              blurRadius: 26,
              offset: Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                '发起视频支持',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _errorSubscription?.cancel();
    _nameController.dispose();
    _snController.dispose();
    _issueController.dispose();
    super.dispose();
  }
}
