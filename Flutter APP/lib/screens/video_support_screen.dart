import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../services/video_service.dart';

class VideoSupportScreen extends StatefulWidget {
  const VideoSupportScreen({super.key});

  @override
  State<VideoSupportScreen> createState() => _VideoSupportScreenState();
}

class _VideoSupportScreenState extends State<VideoSupportScreen> {
  final _nameController = TextEditingController();
  final _issueController = TextEditingController();
  bool _isConnecting = false;
  bool _isWaiting = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    final service = Provider.of<VideoServiceProvider>(context, listen: false).service;
    service.onMessage.listen((message) {
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
            MaterialPageRoute(builder: (_) => const VideoCallScreen()),
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
  }

  Future<void> _connectAndCall() async {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入您的姓名')),
      );
      return;
    }

    setState(() {
      _isConnecting = true;
      _statusMessage = '正在连接...';
    });

    try {
      final service = Provider.of<VideoServiceProvider>(context, listen: false).service;
      await service.connect('192.168.2.128:8001');
      await service.createCall(_nameController.text, issue: _issueController.text);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('视频客服'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.video_call,
              size: 80,
              color: Color(0xFF5664FF),
            ),
            const SizedBox(height: 20),
            const Text(
              '视频客服服务',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '遇到问题？与客服实时视频沟通',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            if (!_isWaiting) ...[
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '您的姓名',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: '问题描述（选填）',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                  hintText: '请简要描述您的问题',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isConnecting ? null : _connectAndCall,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: const Color(0xFF5664FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: _isConnecting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        '发起视频请求',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF5664FF)),
                    const SizedBox(height: 20),
                    Text(
                      _statusMessage,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _cancelCall,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('取消请求'),
                    ),
                  ],
                ),
              ),
            ],
            if (_statusMessage.isNotEmpty && !_isConnecting && !_isWaiting)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _statusMessage.contains('失败') ? Colors.red : Colors.green,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({super.key});

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  late VideoService _service;

  @override
  void initState() {
    super.initState();
    _service = Provider.of<VideoServiceProvider>(context, listen: false).service;
    _service.onMessage.listen((message) {
      if (message['type'] == 'call_ended') {
        Navigator.pop(context);
      }
    });
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
                child: const Center(
                  child: Text(
                    '等待视频连接...',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.black,
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