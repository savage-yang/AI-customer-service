import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/chat_provider.dart';
import 'chat_screen.dart';
import 'video_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color _textPrimary = Color(0xFFECF3FF);
  static const Color _textMuted = Color(0xFFB8C7DE);
  static const Color _stroke = Color(0x2EFFFFFF);
  static const Color _accent = Color(0xFF75F6D1);
  static const Color _accentBlue = Color(0xFF71A7FF);
  static const Color _warning = Color(0xFFFFB36B);

  final List<Map<String, dynamic>> _products = const [
    {
      'name': 'X1 Pro 智能洗地机',
      'warranty': '保修至 2026.08.15',
      'status': '运行正常',
      'statusType': 'normal',
      'summary': '核心部件状态稳定，当前没有异常工单。',
    },
    {
      'name': 'R7 扫地机器人',
      'warranty': '当前存在售后工单',
      'status': '维修处理中',
      'statusType': 'repairing',
      'summary': '滚轮异响问题已进入专家跟进阶段。',
    },
  ];

  final List<Map<String, dynamic>> _salesRecords = const [
    {
      'title': 'X1 Pro 智能洗地机',
      'orderNo': 'SO20240815001',
      'amount': '¥2,999',
      'date': '2024-08-15',
      'channel': '官方商城',
      'desc': '含安装指导与基础延保服务',
    },
    {
      'title': 'R7 扫地机器人',
      'orderNo': 'SO20240302001',
      'amount': '¥1,899',
      'date': '2024-03-02',
      'channel': '京东旗舰店',
      'desc': '赠送一年耗材礼包',
    },
  ];

  BoxDecoration _glassCard({
    Gradient? gradient,
    Color color = const Color(0xDD18253A),
    BorderRadius? radius,
  }) {
    return BoxDecoration(
      color: gradient == null ? color : null,
      gradient: gradient,
      borderRadius: radius ?? BorderRadius.circular(28),
      border: Border.all(color: _stroke),
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
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          child: Consumer<ChatProvider>(
            builder: (context, chatProvider, _) {
              final latestRecord = chatProvider.afterSalesRecords.isNotEmpty
                  ? chatProvider.afterSalesRecords.first
                  : null;

              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildHeroCard(chatProvider),
                  const SizedBox(height: 14),
                  _buildSectionBlock(
                    title: '我的设备',
                    actionLabel: '查看全部',
                    child: Column(
                      children: _products.map(_buildDeviceCard).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildSectionBlock(
                    title: '最近售后摘要',
                    actionLabel: '进入历史',
                    onActionTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VideoHistoryScreen(),
                        ),
                      );
                    },
                    child: _buildLatestSummaryCard(chatProvider, latestRecord),
                  ),
                  const SizedBox(height: 18),
                  _buildSectionHeader('服务记录'),
                  const SizedBox(height: 12),
                  _buildHistoryTabs(chatProvider),
                ],
              );
            },
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
            width: 46,
            height: 46,
            decoration: _glassCard(
              color: const Color(0xC022314A),
              radius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: _accent,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(ChatProvider chatProvider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(-1.0, -1.0),
          end: Alignment(1.0, 1.0),
          colors: [Color(0xFF22314A), Color(0xFF1A273C), Color(0xFF111B2A)],
          stops: [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0x22B8FFE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1875F6D1),
            blurRadius: 32,
            spreadRadius: 0,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 34,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF26364F), Color(0xFF1A273B)],
                  ),
                  border: Border.all(
                    color: const Color(0x24B8FFE8),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1275F6D1),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Text(
                  'L',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '尊享服务会员',
                      style: TextStyle(
                        color: Color(0xF0ECF3FF),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Luna Chen',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard('03', '已绑定设备'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard(
                  '${chatProvider.afterSalesRecords.length}',
                  '售后记录',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildMetricCard('2.4h', '累计协助'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x2418242F), Color(0x18111A23)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x1FB8FFE8)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1475F6D1),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionBlock({
    required String title,
    required Widget child,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _glassCard(
        color: const Color(0xC022314A),
        radius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              if (actionLabel != null)
                GestureDetector(
                  onTap: onActionTap,
                  child: Text(
                    actionLabel,
                    style: const TextStyle(
                      color: _textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildDeviceCard(Map<String, dynamic> product) {
    final color = _statusColor(product['statusType'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _stroke),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'] as String,
                  style: const TextStyle(
                    color: _textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product['warranty'] as String,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product['summary'] as String,
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              product['status'] as String,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLatestSummaryCard(
    ChatProvider chatProvider,
    Map<String, dynamic>? record,
  ) {
    if (record == null) {
      return const Text(
        '当前还没有售后记录，后续创建工单后会在这里生成服务摘要。',
        style: TextStyle(
          color: _textMuted,
          fontSize: 14,
          height: 1.6,
        ),
      );
    }

    return GestureDetector(
      onTap: () => _openServiceRecord(chatProvider, record),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _stroke),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0x3375F6D1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'AI Summary',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  record['date'] as String? ?? '',
                  style: const TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              record['title'] as String? ?? '最近售后记录',
              style: const TextStyle(
                color: _textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              record['desc'] as String? ?? '',
              style: const TextStyle(
                color: _textMuted,
                fontSize: 14,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTabs(ChatProvider chatProvider) {
    final selectedIndex = _tabController.index;

    return Column(
      children: [
        Container(
          height: 62,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xC022314A),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _stroke),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final segmentWidth = (constraints.maxWidth - 12) / 2;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    left: selectedIndex == 0 ? 0 : segmentWidth,
                    top: 0,
                    child: Container(
                      width: segmentWidth,
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF75F6D1), Color(0xFF71A7FF)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x4471A7FF),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTabButton(
                          label: '销售记录',
                          selected: selectedIndex == 0,
                          onTap: () {
                            setState(() {
                              _tabController.index = 0;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: _buildTabButton(
                          label: '售后记录',
                          selected: selectedIndex == 1,
                          onTap: () {
                            setState(() {
                              _tabController.index = 1;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ...(selectedIndex == 0
                ? _salesRecords
                : chatProvider.afterSalesRecords)
            .map((record) => _buildRecordCard(
                  record,
                  selectedIndex,
                  chatProvider,
                )),
      ],
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.transparent,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF041320) : _textMuted,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordCard(
    Map<String, dynamic> record,
    int tabIndex,
    ChatProvider chatProvider,
  ) {
    final status = record['status'] as String?;
    final isDone = (status ?? '').contains('完成') || (status ?? '').contains('解决');
    final statusColor = isDone ? _accent : _warning;

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: _glassCard(
        color: const Color(0xC022314A),
        radius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record['title'] as String? ?? '',
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      record['desc'] as String? ??
                          record['channel'] as String? ??
                          '',
                      style: const TextStyle(
                        color: _textMuted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              if (status != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildChip(record['orderNo'] as String? ?? record['ticketNo'] as String? ?? ''),
              _buildChip(record['date'] as String? ?? ''),
              if (record['amount'] != null) _buildChip(record['amount'] as String),
              if (record['type'] != null) _buildChip(record['type'] as String),
            ],
          ),
        ],
      ),
    );

    if (tabIndex == 1) {
      return GestureDetector(
        onTap: () => _openServiceRecord(chatProvider, record),
        child: card,
      );
    }
    return card;
  }

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _stroke),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }

  void _openServiceRecord(ChatProvider chatProvider, Map<String, dynamic> record) {
    final ticketNo = record['ticketNo'] as String?;
    if (ticketNo == null) {
      return;
    }

    final videoId = chatProvider.ticketToVideo[ticketNo];
    final sessionId = chatProvider.ticketToSession[ticketNo];

    if (videoId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => VideoHistoryScreen(initialVideoId: videoId),
        ),
      );
      return;
    }

    if (sessionId != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(initialSessionId: sessionId),
        ),
      );
    }
  }

  Color _statusColor(String type) {
    switch (type) {
      case 'normal':
        return _accent;
      case 'repairing':
        return _warning;
      case 'expired':
        return const Color(0xFFB0BDD6);
      default:
        return _accentBlue;
    }
  }
}
