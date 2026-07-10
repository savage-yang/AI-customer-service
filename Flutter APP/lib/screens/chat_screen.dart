import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/chat_provider.dart';
import 'profile_screen.dart';
import 'video_support_screen.dart';

class ChatScreen extends StatefulWidget {
  final String? initialSessionId;

  const ChatScreen({super.key, this.initialSessionId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _inputController = TextEditingController();

  final List<QuickQuestion> quickQuestions = const [
    QuickQuestion(
      badge: '退款',
      title: '退款进度',
      subtitle: '1-3 个工作日到账说明',
      prompt: '我想查询退款什么时候到账。',
    ),
    QuickQuestion(
      badge: '物流',
      title: '物流查询',
      subtitle: '查看配送节点和预计送达',
      prompt: '我想看看订单现在配送到哪里了。',
    ),
    QuickQuestion(
      badge: '设备',
      title: '设备异常',
      subtitle: '故障诊断、报错排查、维修建议',
      prompt: '我的设备出现异常报错，帮我看看怎么处理。',
    ),
    QuickQuestion(
      badge: '会员',
      title: '会员权益',
      subtitle: '折扣、积分、专属服务说明',
      prompt: '我想了解会员包含哪些权益。',
    ),
  ];

  static const Color _textPrimary = Color(0xFFECF3FF);
  static const Color _textMuted = Color(0xFFB8C7DE);
  static const Color _panel = Color(0xDD18253A);
  static const Color _panelSoft = Color(0xC022314A);
  static const Color _stroke = Color(0x2EFFFFFF);
  static const Color _accent = Color(0xFF75F6D1);
  static const Color _accentBlue = Color(0xFF71A7FF);

  int selectedIndex = -1;
  bool _showWelcomeCard = true;

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialSessionId != null) {
        Provider.of<ChatProvider>(context, listen: false)
            .loadHistory(widget.initialSessionId!);
      }
    });
  }

  void _selectQuestion(int index) {
    setState(() {
      selectedIndex = index;
    });
    Provider.of<ChatProvider>(context, listen: false)
        .sendMessage(quickQuestions[index].prompt);
  }

  void _createNewChat() {
    Provider.of<ChatProvider>(context, listen: false).clearMessages();
    _inputController.clear();
    setState(() {
      selectedIndex = -1;
      _showWelcomeCard = true;
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      return;
    }
    Provider.of<ChatProvider>(context, listen: false).sendMessage(text);
    _inputController.clear();
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
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 12),
                      _buildTitleCard(),
                      if (_showWelcomeCard) ...[
                        const SizedBox(height: 16),
                        _buildWelcomeCard(),
                      ],
                      const SizedBox(height: 14),
                      if (chatProvider.messages.isEmpty) ...[
                        _buildSuggestionPanel(),
                        const SizedBox(height: 14),
                      ],
                      _buildMessageList(chatProvider),
                    ],
                  ),
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

  Widget _buildTopBar() {
    return Row(
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: _glassCard(
                color: _panelSoft,
                radius: BorderRadius.circular(999),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu, color: _accentBlue, size: 18),
                  SizedBox(width: 6),
                  Text(
                    '历史对话',
                    style: TextStyle(
                      color: _textPrimary,
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
            decoration: _glassCard(
              color: _panelSoft,
              radius: BorderRadius.circular(999),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person_outline, color: _accent, size: 16),
                SizedBox(width: 6),
                Text(
                  '我的',
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
                  '智能客服中枢',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'AI Support',
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF496684),
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x333D6B8E), Color(0x665B84A8)],
              ),
              border: Border.all(color: const Color(0x3D9AB9D4)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2A71A7FF),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const Text(
              'L9',
              style: TextStyle(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 18, 10, 22),
      decoration: _glassCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF31406A), Color(0xFF6274FF), Color(0xFF7FB6FF)],
        ),
        radius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x2675F6D1),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'Priority Care',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  '欢迎回来，今天想解决什么问题？',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showWelcomeCard = false;
                  });
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'AI 先帮你诊断，复杂问题再一键转视频专家。',
            style: TextStyle(
              color: Color(0xDDECF3FF),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionPanel() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: _glassCard(
        color: _panelSoft,
        radius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '猜你想问',
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: quickQuestions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.55,
            ),
            itemBuilder: (context, index) {
              final item = quickQuestions[index];
              final active = selectedIndex == index;
              return InkWell(
                onTap: () => _selectQuestion(index),
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF5664FF)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: active ? const Color(0xFF5664FF) : _stroke,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? Colors.white : _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: active ? Colors.white : _accentBlue,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(ChatProvider chatProvider) {
    final messages = chatProvider.messages;

    if (messages.isEmpty) {
      return const SizedBox.shrink();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final message = messages[index];
        final isUser = message['fromUser'] as bool;
        final type = message['type'] as String?;

        if (type == 'create_ticket') {
          return _buildCreateTicketCard(message, chatProvider);
        }
        if (type == 'feedback') {
          return _buildFeedbackCard(message, chatProvider);
        }
        if (type == 'analysis') {
          final ticketNo = message['ticketNo'] as String;
          final hasRecord = chatProvider.afterSalesRecords
              .any((record) => record['ticketNo'] == ticketNo);
          if (!hasRecord) {
            return const SizedBox.shrink();
          }
          const analysisContent = '''
关于设备卡死的问题，我来帮你分析：

【原因分析】
1. 后台运行过多，导致系统资源占用过高
2. 存储空间不足，影响设备正常运转
3. 近期安装的软件存在兼容冲突
4. 系统文件异常或更新中断

【修复步骤】
1. 长按电源键 10 秒强制重启设备
2. 重启后清理后台运行应用
3. 进入设置 > 存储，释放不必要的空间
4. 卸载近期安装的可疑应用
5. 如果仍未解决，建议备份数据后恢复出厂设置
''';
          return _buildAssistantBubble(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AIVA',
                  style: TextStyle(
                    color: _accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMessageContent(analysisContent, false),
              ],
            ),
          );
        }

        if (isUser) {
          return Align(
            alignment: Alignment.centerRight,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 290),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(10),
                  bottomLeft: Radius.circular(22),
                  bottomRight: Radius.circular(22),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A3A436D),
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: _buildMessageContent(message['content'] as String, true),
            ),
          );
        }

        return _buildAssistantBubble(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AIVA',
                style: TextStyle(
                  color: _accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              _buildMessageContent(message['content'] as String, false),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAssistantBubble({required Widget child}) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        padding: const EdgeInsets.all(16),
        decoration: _glassCard(
          color: const Color(0x99132138),
          radius: const BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(22),
            bottomLeft: Radius.circular(22),
            bottomRight: Radius.circular(22),
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildCreateTicketCard(
    Map<String, dynamic> message,
    ChatProvider chatProvider,
  ) {
    final ticketNo = message['ticketNo'] as String;
    final product = message['product'] as String;
    final issue = message['issue'] as String;
    final created = chatProvider.afterSalesRecords
        .any((record) => record['ticketNo'] == ticketNo);

    return _buildAssistantBubble(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AIVA',
            style: TextStyle(
              color: _accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '已识别为设备异常，我可以为你生成售后工单。',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _stroke),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.build_rounded,
                    color: _accentBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product,
                        style: const TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        issue,
                        style: const TextStyle(
                          color: _textMuted,
                          fontSize: 12,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!created)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      chatProvider.createRepairTicket(ticketNo, product, issue);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '创建工单',
                        style: TextStyle(
                          color: Color(0xFF041320),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _stroke),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '暂不创建',
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x3375F6D1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.task_alt, color: _accent, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '工单已创建：$ticketNo',
                      style: const TextStyle(
                        color: _accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(
    Map<String, dynamic> message,
    ChatProvider chatProvider,
  ) {
    final ticketNo = message['ticketNo'] as String;
    final resolved = chatProvider.resolvedTickets.contains(ticketNo);

    return _buildAssistantBubble(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AIVA',
            style: TextStyle(
              color: _accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '是否已经解决你的问题？',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 12),
          if (!resolved)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => chatProvider.markTicketResolved(ticketNo),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0x3375F6D1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0x4475F6D1)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, color: _accent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '已解决',
                            style: TextStyle(
                              color: _accent,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: _stroke),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.thumb_down_alt_outlined,
                            color: _textMuted, size: 16),
                        SizedBox(width: 6),
                        Text(
                          '未解决',
                          style: TextStyle(
                            color: _textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0x3375F6D1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle_outline, color: _accent, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '已为你标记为解决，感谢反馈。',
                      style: TextStyle(
                        color: _accent,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(String content, bool isUser) {
    if (isUser) {
      return Text(
        content,
        style: const TextStyle(
          color: Colors.white,
          height: 1.65,
          fontSize: 15,
        ),
      );
    }

    final lines = content.split('\n');
    final widgets = <Widget>[];
    final textBuffer = <String>[];
    final listBuffer = <String>[];
    String? listTitle;

    void flushText() {
      if (textBuffer.isEmpty) {
        return;
      }
      final text = textBuffer.join('\n').trim();
      if (text.isNotEmpty) {
        widgets.add(_buildTextBlock(text));
      }
      textBuffer.clear();
    }

    void flushList() {
      if (listTitle == null || listBuffer.isEmpty) {
        return;
      }
      widgets.add(_buildListCard(listTitle!, List<String>.from(listBuffer)));
      listTitle = null;
      listBuffer.clear();
    }

    for (final line in lines) {
      final trimmed = line.trim();
      final isServiceLine =
          trimmed.contains('视频客服') || trimmed.contains('电话客服');
      final isSectionTitle = trimmed.startsWith('【') && trimmed.endsWith('】');
      final isListItem = RegExp(r'^\d+\.\s+').hasMatch(trimmed);

      if (isServiceLine) {
        flushText();
        flushList();
        widgets.add(_buildServiceCard(trimmed));
      } else if (isSectionTitle) {
        flushText();
        flushList();
        listTitle = trimmed.substring(1, trimmed.length - 1);
      } else if (listTitle != null && isListItem) {
        listBuffer.add(trimmed);
      } else if (listTitle != null && trimmed.isNotEmpty) {
        listBuffer.add(trimmed);
      } else if (listTitle != null && trimmed.isEmpty) {
        flushList();
      } else {
        if (listTitle != null) {
          flushList();
        }
        textBuffer.add(line);
      }
    }

    flushText();
    flushList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildTextBlock(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _textPrimary,
          height: 1.65,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildListCard(String title, List<String> items) {
    final isCause = title.contains('原因');
    final accentColor =
        isCause ? const Color(0xFFFFB36B) : const Color(0xFF71A7FF);
    final iconData = isCause ? Icons.search_rounded : Icons.handyman_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Icon(iconData, color: accentColor, size: 16),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...items.asMap().entries.map((entry) {
            final item = entry.value.replaceFirst(RegExp(r'^\d+\.\s*'), '');
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildServiceCard(String text) {
    final isVideo = text.contains('视频客服');
    final title = isVideo ? '视频客服' : '电话客服';
    final desc = text
        .replaceFirst(RegExp(r'^.*?客服[:：]?\s*'), '')
        .replaceAll('📴', '')
        .replaceAll('📓', '')
        .trim();
    final phoneMatch = RegExp(r'[\d-]{7,}').firstMatch(desc);
    final phoneNumber = phoneMatch?.group(0)?.replaceAll('-', '');

    final card = Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: _glassCard(
        color: _panelSoft,
        radius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isVideo ? const Color(0xFF2ECF92) : const Color(0xFF71A7FF),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Icon(
              isVideo ? Icons.videocam_rounded : Icons.call_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: _textMuted, size: 18),
        ],
      ),
    );

    return GestureDetector(
      onTap: () {
        if (isVideo) {
          _navigateToVideoSupport();
        } else if (phoneNumber != null) {
          _launchPhoneCall(phoneNumber);
        }
      },
      child: card,
    );
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildComposer(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _glassCard(
        color: _panel,
        radius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _createNewChat,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _stroke),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.add, color: _accent, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _navigateToVideoSupport,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF2ECF92),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x662ECF92),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.videocam_rounded,
                  color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: _panelSoft,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _stroke),
              ),
              alignment: Alignment.centerLeft,
              child: TextField(
                controller: _inputController,
                decoration: const InputDecoration(
                  hintText: '输入你的问题，或发送设备型号 / SN',
                  border: InputBorder.none,
                  hintStyle: TextStyle(
                    color: _textMuted,
                    fontSize: 15,
                  ),
                ),
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: chatProvider.isLoading ? null : _handleSend,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4471A7FF),
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
                  : const Text(
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
      backgroundColor: const Color(0xFF11203A),
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
              const Padding(
                padding: EdgeInsets.only(left: 8, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '历史对话',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Recent Sessions',
                      style: TextStyle(
                        color: _textMuted,
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
                    final isActive =
                        session['session_id'] == chatProvider.sessionId;
                    return InkWell(
                      onTap: () {
                        chatProvider.loadHistory(session['session_id'] as String);
                        Navigator.pop(context);
                        setState(() {
                          selectedIndex = -1;
                        });
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white.withValues(alpha: 0.09)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isActive ? const Color(0xFF5664FF) : _stroke,
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
                                    : Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session['preview'] as String? ?? '新对话',
                                    style: const TextStyle(
                                      color: _textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatTime(session['updated_at'] as int?),
                                    style: const TextStyle(
                                      color: _textMuted,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () async {
                                await chatProvider
                                    .deleteSession(session['session_id'] as String);
                              },
                              icon: const Icon(
                                Icons.delete_outline,
                                color: _textMuted,
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
                  _createNewChat();
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
    if (timestamp == null) {
      return '';
    }

    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 0) {
      return '${date.month}月${date.day}日';
    }
    if (diff.inHours > 0) {
      return '${diff.inHours} 小时前';
    }
    if (diff.inMinutes > 0) {
      return '${diff.inMinutes} 分钟前';
    }
    return '刚刚';
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
