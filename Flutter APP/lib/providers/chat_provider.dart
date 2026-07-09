import 'package:flutter/cupertino.dart';
import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _sessionId = '';
  List<Map<String, dynamic>> _sessions = [];

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String get sessionId => _sessionId;
  List<Map<String, dynamic>> get sessions => _sessions;

  ChatService get service => _chatService;

  void addMessage(String content, bool fromUser) {
    _messages.add({
      'sender': fromUser ? '' : '智能客服',
      'content': content,
      'fromUser': fromUser,
    });
    notifyListeners();
  }

  void addAssistantMessage(String content) {
    _messages.add({
      'sender': '智能客服',
      'content': content,
      'fromUser': false,
    });
    notifyListeners();
  }

  void updateLastAssistantMessage(String content) {
    if (_messages.isNotEmpty && !_messages.last['fromUser']) {
      _messages.last['content'] = content;
      notifyListeners();
    }
  }

  void clearMessages() {
    _messages.clear();
    _chatService.resetSession();
    _sessionId = '';
    notifyListeners();
  }

  Future<void> sendMessage(String question) async {
    addMessage(question, true);
    _isLoading = true;
    notifyListeners();

    try {
      await for (final chunk in _chatService.sendMessageStream(question)) {
        final lastMsg = _messages.lastOrNull;
        if (lastMsg != null && !lastMsg['fromUser']) {
          updateLastAssistantMessage(lastMsg['content'] + chunk);
        } else {
          addAssistantMessage(chunk);
        }
      }
      _sessionId = _chatService.sessionId;
      _updateSessionList();
    } catch (e) {
      print('ChatService error: $e');
      addAssistantMessage('抱歉，服务暂时不可用，请稍后再试。错误信息: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String sessionId) async {
    final history = await _chatService.getHistory(sessionId);
    _messages.clear();
    for (final msg in history) {
      addMessage(msg['content'], msg['role'] == 'user');
    }
    _sessionId = sessionId;
    notifyListeners();
  }

  void _updateSessionList() {
    if (_sessionId.isEmpty || _messages.isEmpty) return;

    final existingIndex = _sessions.indexWhere((s) => s['session_id'] == _sessionId);
    final preview = _messages.isNotEmpty ? _messages.first['content'].substring(0, _messages.first['content'].length > 20 ? 20 : _messages.first['content'].length) + '...' : '';
    final newSession = {
      'session_id': _sessionId,
      'preview': preview,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    if (existingIndex >= 0) {
      _sessions[existingIndex] = newSession;
    } else {
      _sessions.insert(0, newSession);
    }

    _sessions.sort((a, b) => b['updated_at'].compareTo(a['updated_at']));
    notifyListeners();
  }

  Future<void> deleteSession(String sessionId) async {
    await _chatService.clearSession(sessionId);
    _sessions.removeWhere((s) => s['session_id'] == sessionId);
    notifyListeners();
  }

  void createNewSession() {
    clearMessages();
  }
}
