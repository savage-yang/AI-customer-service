import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import 'video_support_screen.dart';

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
      inputPlaceholder = quickQuestions[index].prompt;
      _inputController.text = quickQuestions[index].prompt;
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
    setState(() {
      _inputController.text = question.prompt;
      inputPlaceholder = question.prompt;
    });
    Provider.of<ChatProvider>(context, listen: false).sendMessage(question.prompt);
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

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
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF181A23),
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33252E56),
                        blurRadius: 40,
                        offset: Offset(0, 20),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        const _PhoneStatusBar(),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Color(0xFFFDFDFF), Color(0xFFF5F7FF)],
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildHeader(),
                                  const SizedBox(height: 16),
                                  _buildSuggestionPanel(),
                                  const SizedBox(height: 16),
                                  _buildWelcomeCard(),
                                  const SizedBox(height: 16),
                                  Expanded(child: _buildMessageList(chatProvider)),
                                  const SizedBox(height: 12),
                                  _buildComposer(chatProvider),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
            _pillButton('历史对话'),
            const Spacer(),
            GestureDetector(
              onTap: _navigateToVideoSupport,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3DC882),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x333DC882),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.video_call, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '视频客服',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.74),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AiMark(),
                  SizedBox(width: 8),
                  Text(
                    '客服中',
                    style: TextStyle(
                      color: Color(0xFF4250E8),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '在线客服',
                    style: TextStyle(
                      color: Color(0xFF6A728C),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    pageTitle,
                    style: const TextStyle(
                      color: Color(0xFF161B2F),
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.82),
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OnlineDot(),
                  SizedBox(width: 8),
                  Text(
                    'AI 在线',
                    style: TextStyle(
                      color: Color(0xFF4250E8),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
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

  Widget _buildSuggestionPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0x225C6680)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMART SUGGESTIONS',
                      style: TextStyle(
                        color: Color(0xFF6A728C),
                        fontSize: 12,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '猜你想问',
                      style: TextStyle(
                        color: Color(0xFF161B2F),
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: createNewChat,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF5D6BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('+', style: TextStyle(fontSize: 20, height: 1)),
                    SizedBox(width: 8),
                    Text('新建对话'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            '推荐咨询入口，点击即可快速发起对应问题。',
            style: TextStyle(
              color: Color(0xFF6A728C),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 154,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickQuestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = quickQuestions[index];
                final active = selectedIndex == index;
                return GestureDetector(
                  onTap: () {
                    selectQuestion(index);
                    handleQuickQuestion(item);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 174,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF5E6EFF), Color(0xFF8C83FF)],
                            )
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FF)],
                            ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: active ? Colors.transparent : const Color(0x1A5664FF),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: active
                              ? const Color(0x405F6FFF)
                              : const Color(0x145F6FFF),
                          blurRadius: active ? 24 : 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: active
                                ? Colors.white.withOpacity(0.16)
                                : const Color(0x1F5664FF),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            item.badge,
                            style: TextStyle(
                              color: active ? Colors.white : const Color(0xFF4250E8),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          item.title,
                          style: TextStyle(
                            color: active ? Colors.white : const Color(0xFF161B2F),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.subtitle,
                          style: TextStyle(
                            color: active
                                ? Colors.white.withOpacity(0.82)
                                : const Color(0xFF6A728C),
                            fontSize: 12,
                            height: 1.45,
                          ),
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
          colors: [Color(0xFF232A55), Color(0xFF5664FF), Color(0xFF7D82FF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI ASSISTANT',
            style: TextStyle(
              color: Colors.white.withOpacity(0.72),
              fontSize: 12,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
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
          Expanded(
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
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

  Widget _pillButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF161B2F),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _PhoneStatusBar extends StatelessWidget {
  const _PhoneStatusBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(10, 4, 10, 0),
      child: Row(
        children: [
          Text(
            '9:41',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
          Spacer(),
          _CameraPill(),
          Spacer(),
          Text(
            '100%',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraPill extends StatelessWidget {
  const _CameraPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 118,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF090B11),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class _AiMark extends StatelessWidget {
  const _AiMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5A68FF), Color(0xFF7C89FF)],
        ),
      ),
      alignment: Alignment.center,
      child: const Text(
        'AI',
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: const Color(0xFF3DC882),
        borderRadius: BorderRadius.circular(999),
      ),
    );
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