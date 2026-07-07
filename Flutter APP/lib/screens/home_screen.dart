import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import 'video_call_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
        title: const Text('AI客服'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Icon(
              Icons.support_agent,
              size: 80,
              color: Colors.blue,
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
                  backgroundColor: Colors.blue,
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
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const CircularProgressIndicator(color: Colors.blue),
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