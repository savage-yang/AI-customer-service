import 'package:flutter/material.dart';

class VideoHistoryScreen extends StatefulWidget {
  final String? initialVideoId;

  const VideoHistoryScreen({super.key, this.initialVideoId});

  @override
  State<VideoHistoryScreen> createState() => _VideoHistoryScreenState();
}

class _VideoHistoryScreenState extends State<VideoHistoryScreen> {
  static const Color _textPrimary = Color(0xFFECF3FF);
  static const Color _textMuted = Color(0xFFB8C7DE);
  static const Color _stroke = Color(0x2EFFFFFF);
  static const Color _accent = Color(0xFF75F6D1);
  static const Color _accentBlue = Color(0xFF71A7FF);

  final List<Map<String, dynamic>> _historyList = [
    {
      'id': 'VH20250612001',
      'ticketNo': 'AS20250612001',
      'product': '扫地机器人 R7',
      'sn': 'SN-2024-0302-BR22',
      'issue': '滚轮异响检修',
      'agent': '张工（高级工程师）',
      'date': '2025-06-12',
      'time': '14:30 - 14:52',
      'duration': '22分钟',
      'status': '已完成',
      'statusType': 'done',
      'summary': {
        'problem': '设备在清扫过程中右侧主滚轮出现明显异响，转向和过门槛时尤为明显。',
        'diagnosis': '视频协助检查后确认滚轮轴承位置缠绕了较多毛发，导致滚轮摩擦异常。',
        'solution': [
          '指导用户使用清洁工具拆下滚轮并去除毛发缠绕。',
          '演示滚轮模块的正确装回方式，避免再次偏位。',
          '建议每周进行一次滚轮清洁，减少耗材积灰。',
          '如再次出现异响，可申请更换滚轮组件。',
        ],
        'result': '用户完成清理后异响消失，问题已解决，无需返厂维修。',
      },
    },
    {
      'id': 'VH20250328002',
      'ticketNo': 'AS20250328001',
      'product': '智能洗地机 X1 Pro',
      'sn': 'SN-2024-0815-AX91',
      'issue': '污水箱异味处理',
      'agent': '李客服（售后专员）',
      'date': '2025-03-28',
      'time': '10:15 - 10:33',
      'duration': '18分钟',
      'status': '已完成',
      'statusType': 'done',
      'summary': {
        'problem': '设备使用半年后污水箱出现持续异味，日常冲洗无法完全消除。',
        'diagnosis': '判断为污水箱管路和滤网长期残留积污，滋生细菌导致异味。',
        'solution': [
          '演示污水箱深度清洁步骤：清水加中性清洁液浸泡 30 分钟。',
          '指导拆卸滤网单独刷洗，并检查密封圈状态。',
          '建议每月使用白醋兑水进行一次消毒除味。',
          '提醒每次使用后保持开盖晾干，避免潮湿积味。',
        ],
        'result': '用户按步骤清洁后异味明显消除，后续按周期维护即可。',
      },
    },
  ];

  final Set<String> _expandedIds = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoId != null) {
      _expandedIds.add(widget.initialVideoId!);
    }
  }

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

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedIds.contains(id)) {
        _expandedIds.remove(id);
      } else {
        _expandedIds.add(id);
      }
    });
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
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _buildHeader(),
              const SizedBox(height: 18),
              _buildTitleCard(),
              const SizedBox(height: 18),
              _buildOverviewCard(),
              const SizedBox(height: 18),
              _buildSectionHeader(),
              const SizedBox(height: 12),
              ..._historyList.map(_buildHistoryCard),
            ],
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
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: _glassCard(
            color: const Color(0xC022314A),
            radius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_outlined, color: _accentBlue, size: 16),
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
      ],
    );
  }

  Widget _buildTitleCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _glassCard(
        color: const Color(0xC022314A),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '服务记录中心',
                  style: TextStyle(
                    color: _textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Video History',
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
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0x3375F6D1), Color(0x4471A7FF)],
              ),
              border: Border.all(color: _stroke),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.history_toggle_off_rounded,
              color: _textPrimary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard() {
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF26364F), Color(0xFF1A273B)],
              ),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0x22B8FFE8)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1275F6D1),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Text(
              'AI Service Archive',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '集中查看每次专家协助的诊断、处理过程与结果。',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              height: 1.1,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '共 ${_historyList.length} 次视频服务，累计 ${_totalMinutes()} 分钟协助时长。',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.88),
              fontSize: 15,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _buildMetricTile('${_historyList.length}', '会议总数')),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile('${_doneCount()}', '已完成')),
              const SizedBox(width: 10),
              Expanded(child: _buildMetricTile('${_totalMinutes()}m', '累计时长')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String value, String label) {
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

  Widget _buildSectionHeader() {
    return const Row(
      children: [
        Text(
          '全部会议记录',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isExpanded = _expandedIds.contains(item['id']);
    final statusColor = _getStatusColor(item['statusType'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: _glassCard(
        color: const Color(0xC022314A),
        radius: BorderRadius.circular(24),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => _toggleExpand(item['id'] as String),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white.withValues(alpha: 0.06),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.videocam_rounded,
                      color: _accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                item['issue'] as String,
                                style: const TextStyle(
                                  color: _textPrimary,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item['status'] as String,
                                style: TextStyle(
                                  color: statusColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['product'] as String,
                          style: const TextStyle(
                            color: _textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildInfoBadge(item['ticketNo'] as String),
                  _buildInfoBadge(item['date'] as String),
                  _buildInfoBadge(item['duration'] as String),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _stroke),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactInfo('设备 SN', item['sn'] as String),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildCompactInfo('服务专家', item['agent'] as String),
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const SizedBox(height: 14),
                _buildSummarySection(item['summary'] as Map<String, dynamic>),
              ],
              const SizedBox(height: 12),
              Center(
                child: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: _accentBlue,
                  size: 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBadge(String text) {
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

  Widget _buildSummarySection(Map<String, dynamic> summary) {
    final solutions = summary['solution'] as List<dynamic>;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0x3375F6D1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'AI 智能摘要',
              style: TextStyle(
                color: _accent,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildSummaryItem('问题描述', summary['problem'] as String),
          const SizedBox(height: 12),
          _buildSummaryItem('诊断结果', summary['diagnosis'] as String),
          const SizedBox(height: 12),
          const Text(
            '解决方案',
            style: TextStyle(
              color: _accentBlue,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...solutions.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0x3371A7FF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: _accentBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value as String,
                      style: const TextStyle(
                        color: _textPrimary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 4),
          _buildSummaryItem('处理结果', summary['result'] as String),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _accentBlue,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: const TextStyle(
            color: _textPrimary,
            fontSize: 14,
            height: 1.65,
          ),
        ),
      ],
    );
  }

  int _totalMinutes() {
    int total = 0;
    for (final item in _historyList) {
      final duration = item['duration'] as String;
      final match = RegExp(r'(\d+)').firstMatch(duration);
      if (match != null) {
        total += int.parse(match.group(1)!);
      }
    }
    return total;
  }

  int _doneCount() {
    return _historyList.where((item) => item['statusType'] == 'done').length;
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case 'done':
        return _accent;
      case 'expired':
        return const Color(0xFFB0BDD6);
      default:
        return const Color(0xFFFFB36B);
    }
  }
}
