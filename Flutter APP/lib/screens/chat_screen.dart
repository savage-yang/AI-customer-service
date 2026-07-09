import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'video_support_screen.dart';
import 'profile_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();
  final List<QuickQuestion> quickQuestions = const [
    QuickQuestion(
      badge: '退款',
      title: '退款进度查询',
      subtitle: '1-3 个工作日到账说明',
      prompt: '我想查询退款什么时候到账。',
    ),
    QuickQuestion(
      badge: '物流',
      title: '订单物流查询',
      subtitle: '查看配送节点和预计送达',
      prompt: '我想查看订单现在配送到哪里了。',
    ),
    QuickQuestion(
      badge: '账号',
      title: '账号登录异常',
      subtitle: '验证码、密码、风控问题',
      prompt: '我的账号登录失败，想看看怎么处理。',
    ),
    QuickQuestion(
      badge: '会员',
      title: '会员权益说明',
      subtitle: '折扣、积分、专属服务',
      prompt: '我想了解会员包含哪些权益。',
    ),
  ];

  int selectedIndex = 0;
  String pageTitle = '退款进度查询';
  String welcomeTitle = '欢迎来到智能客服中心';
  String welcomeText = '你可以直接输入问题，也可以点击上方常见问题卡片，快速发起客服咨询。';
  String inputPlaceholder = '请输入你的问题...';

  void selectQuestion(int index) {
    setState(() {
      selectedIndex = index;
      pageTitle = quickQuestions[index].title;
    });
  }

  void createNewChat() {
    Provider.of<ChatProvider>(context, listen: false).clearMessages();
    setState(() {
      selectedIndex = -1;
      pageTitle = '新建对话';
      welcomeTitle = '开始一段新的客服会话';
      welcomeText = '你可以直接输入问题，或选择上方推荐咨询入口，快速进入常见客服场景。';
      inputPlaceholder = '请输入你的问题...';
      _inputController.clear();
    });
  }

  void handleSend() {
    final text = _inputController.text.trim();
    if (text.isNotEmpty) {
      Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
      _inputController.clear();
      setState(() {
        inputPlaceholder = '请输入你的问题...';
      });
    }
  }

  void handleQuickQuestion(QuickQuestion question) {
    Provider.of<ChatProvider>(context, listen: false).sendMessage(question.prompt);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(chatProvider),
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
                const SizedBox(height: 16),
                _buildWelcomeCard(),
                const SizedBox(height: 16),
                Expanded(child: _buildMessageList(chatProvider)),
                const SizedBox(height: 12),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: chatProvider.messages.isEmpty
                      ? _buildSuggestionPanel()
                      : const SizedBox.shrink(),
                ),
                const SizedBox(height: 12),
                _buildComposer(chatProvider),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Builder(
              builder: (context) => GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.menu, color: Color(0xFF5664FF), size: 18),
                      SizedBox(width: 6),
                      Text(
                        '历史对话',
                        style: TextStyle(
                          color: Color(0xFF5664FF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _navigateToProfile,
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
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person_outline, color: Color(0xFF5664FF), size: 16),
                    SizedBox(width: 6),
                    Text(
                      '我的',
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
        ),
      ],
    );
  }

  void _navigateToVideoSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VideoSupportScreen()),
    );
  }

  void _navigateToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  Widget _buildSuggestionPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x1A5664FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145F6FFF),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '猜你想问',
                style: TextStyle(
                  color: Color(0xFF161B2F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = quickQuestions[index];
                final active = selectedIndex == index;
                return InkWell(
                  onTap: () {
                    selectQuestion(index);
                    handleQuickQuestion(item);
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xFF5664FF)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: active
                            ? const Color(0xFF5664FF)
                            : const Color(0x225664FF),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            color: active ? Colors.white : const Color(0xFF5664FF),
                            fontSize: 14,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: active ? Colors.white : const Color(0xFF5664FF),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5664FF), Color(0xFF7D82FF), Color(0xFFA8ADFF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            welcomeTitle,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            welcomeText,
            style: TextStyle(
              color: Colors.white.withOpacity(0.84),
              fontSize: 15,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    final messages = chatProvider.messages;

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final message = messages[index];
        return Align(
          alignment: message['fromUser'] ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 280),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: message['fromUser'] ? null : Colors.white,
              gradient: message['fromUser']
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5F6FFF), Color(0xFF7A7CFF)],
                    )
                  : null,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(message['fromUser'] ? 22 : 10),
                topRight: Radius.circular(message['fromUser'] ? 10 : 22),
                bottomLeft: const Radius.circular(22),
                bottomRight: const Radius.circular(22),
              ),
              border: Border.all(
                color: message['fromUser'] ? Colors.transparent : const Color(0x145664FF),
              ),
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
                if (!message['fromUser']) ...[
                  const Text(
                    '智能客服',
                    style: TextStyle(
                      color: Color(0xFF4250E8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message['content'],
                  style: TextStyle(
                    color: message['fromUser'] ? Colors.white : const Color(0xFF161B2F),
                    height: 1.65,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildComposer(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x225C6680)),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _navigateToVideoSupport,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF3DC882),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x333DC882),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.video_call, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: createNewChat,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x225664FF)),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: Color(0xFF5664FF), size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF8F9FE), Color(0xFFF1F4FF)],
                ),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _inputController,
                decoration: InputDecoration(
                  hintText: inputPlaceholder,
                  border: InputBorder.none,
                  hintStyle: const TextStyle(
                    color: Color(0xFF8B93AA),
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(
                  color: Color(0xFF161B2F),
                  fontSize: 15,
                ),
                onSubmitted: (_) => handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFFF8478), Color(0xFFFF9E74)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33FF8478),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: chatProvider.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : GestureDetector(
                    onTap: handleSend,
                    child: const Text(
                      '发送',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(ChatProvider chatProvider) {
    return Drawer(
      width: 320,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '历史对话',
                      style: TextStyle(
                        color: Color(0xFF161B2F),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${chatProvider.sessions.length} 个对话',
                      style: const TextStyle(
                        color: Color(0xFF9AA3BA),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: chatProvider.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final session = chatProvider.sessions[index];
                    final isActive = session['session_id'] == chatProvider.sessionId;
                    return InkWell(
                      onTap: () {
                        chatProvider.loadHistory(session['session_id']);
                        Navigator.pop(context);
                        setState(() {
                          selectedIndex = -1;
                          pageTitle = '历史对话';
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFEEF2FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF5664FF)
                                : Colors.transparent,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isActive
                                    ? const Color(0xFF5664FF)
                                    : const Color(0xFFF0F2FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.chat_bubble_outline,
                                color: isActive ? Colors.white : const Color(0xFF5664FF),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session['preview'] ?? '新对话',
                                    style: TextStyle(
                                      color: const Color(0xFF161B2F),
                                      fontSize: 15,
                                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(session['updated_at']),
                                    style: const TextStyle(
                                      color: Color(0xFF9AA3BA),
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await chatProvider.deleteSession(session['session_id']);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Color(0xFFD1D5DB),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  createNewChat();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5664FF),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x335664FF),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '新建对话',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
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
    );
  }

  String _formatTime(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${date.month}月${date.day}日';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}

class QuickQuestion {
  final String badge;
  final String title;
  final String subtitle;
  final String prompt;

  const QuickQuestion({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.prompt,
  });
}