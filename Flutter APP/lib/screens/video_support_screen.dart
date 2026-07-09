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
  final _nameController = TextEditingController();
  final _snController = TextEditingController();
  final _issueController = TextEditingController();
  bool _isConnecting = false;
  bool _isWaiting = false;
  String _statusMessage = '';
  StreamSubscription? _messageSubscription;
  StreamSubscription? _errorSubscription;

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    final service = Provider.of<VideoServiceProvider>(context, listen: false).service;
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
            _statusMessage = '正在等待客服接听...';
          });
          break;
        case 'agent_joined':
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => VideoCallScreen()),
          );
          break;
        case 'call_rejected':
          setState(() {
            _isWaiting = false;
            _statusMessage = '客服已拒绝请求';
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('请输入您的姓名'),
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
      final service = Provider.of<VideoServiceProvider>(context, listen: false).service;
      await service.connect(AppConfig.videoServerUrl);
      await service.createCall(_nameController.text, issue: _issueController.text, sn: _snController.text);
    } catch (e) {
      setState(() {
        _isConnecting = false;
        _isWaiting = false;
        _statusMessage = '连接失败: $e';
      });
    }
  }

  Future<void> _cancelCall() async {
    final service = Provider.of<VideoServiceProvider>(context, listen: false).service;
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

    if (cameraStatus.isPermanentlyDenied || microphoneStatus.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('权限已被永久拒绝，请在设置中开启权限'),
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
              Color(0xFFF8F9FF),
              Color(0xFFF6F7FB),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeroCard(),
                        const SizedBox(height: 20),
                        if (!_isWaiting) ...[
                          _buildInputCard(),
                          const SizedBox(height: 24),
                          _buildCallButton(),
                        ] else ...[
                          _buildWaitingCard(),
                        ],
                        if (_statusMessage.isNotEmpty && !_isConnecting && !_isWaiting)
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
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios_new, size: 14, color: Color(0xFF161B2F)),
                SizedBox(width: 4),
                Text(
                  '返回',
                  style: TextStyle(
                    color: Color(0xFF161B2F),
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
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x225C6680)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A3A436D),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.history, color: const Color(0xFF5664FF), size: 16),
                const SizedBox(width: 6),
                const Text(
                  '视频历史',
                  style: TextStyle(
                    color: Color(0xFF5664FF),
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

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF232A55), Color(0xFF5664FF), Color(0xFF7D82FF)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335664FF),
            blurRadius: 30,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text(
            '视频客服服务',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '遇到复杂问题？与客服面对面实时视频沟通，快速解决您的问题。',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildFeatureItem(Icons.security, '安全加密'),
              const SizedBox(width: 16),
              _buildFeatureItem(Icons.speed, '高清流畅'),
              const SizedBox(width: 16),
              _buildFeatureItem(Icons.support_agent, '专业客服'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 14, color: Colors.white),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInputCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x225C6680)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3A436D),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '填写信息',
            style: TextStyle(
              color: Color(0xFF161B2F),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '请填写您的信息，方便客服快速了解您的问题',
            style: TextStyle(
              color: Color(0xFF6A728C),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _nameController,
            label: '您的姓名',
            hint: '请输入您的姓名',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _snController,
            label: 'SN序列号',
            hint: '请输入设备SN序列号',
            icon: Icons.qr_code,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _issueController,
            label: '问题描述（选填）',
            hint: '请简要描述您的问题',
            icon: Icons.description_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6A728C),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF8F9FE), Color(0xFFF1F4FF)],
            ),
            border: Border.all(color: const Color(0x1A5664FF)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: const Color(0xFF5664FF)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  maxLines: maxLines,
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                    hintStyle: const TextStyle(
                      color: Color(0xFF8B93AA),
                      fontSize: 15,
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    color: Color(0xFF161B2F),
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCallButton() {
    return GestureDetector(
      onTap: _isConnecting ? null : _connectAndCall,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3DC882), Color(0xFF2FB873)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x333DC882),
              blurRadius: 20,
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
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.video_call, color: Colors.white, size: 22),
                  SizedBox(width: 10),
                  Text(
                    '发起视频请求',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildWaitingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0x225C6680)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A3A436D),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: Color(0xFF5664FF),
                strokeWidth: 3,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _statusMessage,
            style: const TextStyle(
              color: Color(0xFF161B2F),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '客服正在赶来的路上，请稍等片刻',
            style: TextStyle(
              color: Color(0xFF6A728C),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _cancelCall,
            child: Container(
              width: double.infinity,
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                color: const Color(0xFFFFE8E6),
                border: Border.all(color: const Color(0x33FF8478)),
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
