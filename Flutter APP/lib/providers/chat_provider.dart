import 'package:flutter/cupertino.dart';

import '../services/chat_service.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();

  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = false;
  String _sessionId = '';
  List<Map<String, dynamic>> _sessions = [];
  List<Map<String, dynamic>> _afterSalesRecords = [];
  final Set<String> _resolvedTickets = {};
  final Map<String, String> _ticketToSession = {};
  final Map<String, String> _ticketToVideo = {};

  List<Map<String, dynamic>> get messages => _messages;
  bool get isLoading => _isLoading;
  String get sessionId => _sessionId;
  List<Map<String, dynamic>> get sessions => _sessions;
  List<Map<String, dynamic>> get afterSalesRecords => _afterSalesRecords;
  Set<String> get resolvedTickets => _resolvedTickets;
  Map<String, String> get ticketToSession => _ticketToSession;
  Map<String, String> get ticketToVideo => _ticketToVideo;

  ChatService get service => _chatService;

  ChatProvider() {
    _loadMockData();
  }

  static const String _mockSession1 = 'mock_session_refund';
  static const String _mockSession2 = 'mock_session_device';
  static const String _mockSession3 = 'mock_session_draft';

  static const String _ticketDeviceStuck = 'RP20250709001';

  static final Map<String, List<Map<String, dynamic>>> _mockSessions = {
    _mockSession1: [
      {'sender': '', 'content': '你好', 'fromUser': true},
      {
        'sender': '智能客服',
        'content': '你好，我是 AIVA 智能客服，很高兴为你服务。请问有什么可以帮到你？',
        'fromUser': false,
      },
      {
        'sender': '',
        'content': '我想查询一下我的订单退款进度，已经过了三天还没到账',
        'fromUser': true,
      },
      {
        'sender': '智能客服',
        'content':
            '关于你的退款问题，我来帮你查询。通常退款会在 1-3 个工作日内原路退回你的支付账户。如果你使用的是银行卡支付，到账时间可能会稍有延迟。建议你先确认一下退款是否已经发起，可以查看订单详情中的退款状态。',
        'fromUser': false,
      },
      {
        'sender': '',
        'content': '你的回答还没有解决我的问题，我想找人工客服',
        'fromUser': true,
      },
      {
        'sender': '智能客服',
        'content':
            '很抱歉我的回答还没有帮到你。如果你需要进一步帮助，可以选择以下方式联系人工客服：\n\n视频客服：点击页面右下方的绿色视频按钮，系统会为你接通在线客服人员进行面对面视频沟通。\n\n电话客服：拨打服务热线 400-123-4567，我们的客服人员会在第一时间为你提供帮助。\n\n请问你需要我帮你转接吗？',
        'fromUser': false,
      },
    ],
    _mockSession2: [
      {'sender': '', 'content': 'X1 Pro 机器卡死了', 'fromUser': true},
      {
        'sender': '智能客服',
        'content': 'create_repair_ticket',
        'type': 'create_ticket',
        'ticketNo': _ticketDeviceStuck,
        'product': '智能洗地机 X1 Pro',
        'issue': '设备卡死，系统运行异常',
        'fromUser': false,
      },
      {
        'sender': '智能客服',
        'content': 'analysis_after_ticket',
        'type': 'analysis',
        'ticketNo': _ticketDeviceStuck,
        'fromUser': false,
      },
      {
        'sender': '智能客服',
        'content': '是否解决了您的问题？',
        'type': 'feedback',
        'ticketNo': _ticketDeviceStuck,
        'fromUser': false,
      },
    ],
    _mockSession3: [],
  };

  void _loadMockData() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _sessions = [
      {'session_id': _mockSession1, 'preview': '你好...', 'updated_at': now},
      {
        'session_id': _mockSession2,
        'preview': 'X1 Pro 机器卡死了...',
        'updated_at': now - 3600000,
      },
      {
        'session_id': _mockSession3,
        'preview': '未开始对话',
        'updated_at': now - 7200000,
        'isDraft': true,
      },
    ];

    _afterSalesRecords = [
      {
        'title': '智能洗地机 X1 Pro - 设备卡死',
        'ticketNo': _ticketDeviceStuck,
        'type': '维修',
        'status': '已完成',
        'date': '2025-07-09',
        'desc': '设备卡死，系统运行异常',
      },
      {
        'title': '扫地机器人 R7 - 滚轮异响',
        'ticketNo': 'AS20250612001',
        'type': '维修',
        'status': '处理中',
        'date': '2025-06-12',
        'desc': '滚轮运转时出现异响，视频指导清理毛发',
        'videoId': 'VH20250612001',
      },
      {
        'title': '智能洗地机 X1 Pro - 污水箱异味',
        'ticketNo': 'AS20250328001',
        'type': '咨询',
        'status': '已完成',
        'date': '2025-03-28',
        'desc': '污水箱异味处理，视频指导深度清洁',
        'videoId': 'VH20250328002',
      },
    ];

    _ticketToSession[_ticketDeviceStuck] = _mockSession2;
    _ticketToVideo['AS20250612001'] = 'VH20250612001';
    _ticketToVideo['AS20250328001'] = 'VH20250328002';
    _resolvedTickets.add(_ticketDeviceStuck);
    _loadMockSession(_mockSession1);
  }

  void createRepairTicket(String ticketNo, String product, String issue) {
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final newRecord = {
      'title': '$product - ${issue.length > 10 ? issue.substring(0, 10) : issue}',
      'ticketNo': ticketNo,
      'type': '维修',
      'status': '待处理',
      'date': dateStr,
      'desc': issue,
    };
    _afterSalesRecords.insert(0, newRecord);
    notifyListeners();
  }

  void markTicketResolved(String ticketNo) {
    _resolvedTickets.add(ticketNo);
    final idx = _afterSalesRecords.indexWhere((r) => r['ticketNo'] == ticketNo);
    if (idx >= 0) {
      _afterSalesRecords[idx]['status'] = '已完成';
    }
    notifyListeners();
  }

  void _loadMockSession(String sessionId) {
    _sessionId = sessionId;
    _messages = List<Map<String, dynamic>>.from(
      (_mockSessions[sessionId] ?? []).map((m) => Map<String, dynamic>.from(m)),
    );
  }

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
    _loadMockData();
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
      addAssistantMessage('抱歉，服务暂时不可用，请稍后再试。错误信息：$e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHistory(String sessionId) async {
    if (_mockSessions.containsKey(sessionId)) {
      _loadMockSession(sessionId);
      notifyListeners();
      return;
    }

    final history = await _chatService.getHistory(sessionId);
    _messages.clear();
    for (final msg in history) {
      addMessage(msg['content'], msg['role'] == 'user');
    }
    _sessionId = sessionId;
    notifyListeners();
  }

  void _updateSessionList() {
    if (_sessionId.isEmpty || _messages.isEmpty) {
      return;
    }

    final existingIndex =
        _sessions.indexWhere((s) => s['session_id'] == _sessionId);
    final firstContent = _messages.first['content'] as String? ?? '';
    final preview = firstContent.length > 20
        ? '${firstContent.substring(0, 20)}...'
        : firstContent;

    final newSession = {
      'session_id': _sessionId,
      'preview': preview,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };

    if (existingIndex >= 0) {
      _sessions[existingIndex] = {
        ..._sessions[existingIndex],
        ...newSession,
        'isDraft': false,
      };
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
