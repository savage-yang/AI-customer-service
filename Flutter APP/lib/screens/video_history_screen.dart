import 'package:flutter/material.dart';

class VideoHistoryScreen extends StatefulWidget {
  const VideoHistoryScreen({super.key});

  @override
  State<VideoHistoryScreen> createState() => _VideoHistoryScreenState();
}

class _VideoHistoryScreenState extends State<VideoHistoryScreen> {
  final List<Map<String, dynamic>> _historyList = [
    {
      'id': 'VH20250612001',
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
        'problem': '用户反馈扫地机器人 R7 在清扫过程中右侧主滚轮出现明显异响，尤其在转向和经过地毯时声音较大。',
        'diagnosis': '客服通过视频指导用户拆开主刷模组检查，发现右侧滚轮轴承处缠绕了大量头发，导致轴承摩擦异响。',
        'solution': [
          '指导用户使用清理工具清除缠绕的头发',
          '演示主刷模组正确拆卸和安装方法',
          '建议每周清理一次主刷，防止毛发缠绕',
          '如清理后仍有异响，可申请售后更换轴承组件',
        ],
        'result': '用户自行清理后异响消失，问题解决，无需返厂维修。',
      },
    },
    {
      'id': 'VH20250328002',
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
        'problem': '用户反映洗地机使用约半年后，污水箱产生明显异味，即使每次用完清水冲洗也无法消除。',
        'diagnosis': '客服判断为污水箱管道和滤网长期积留污水残留，滋生细菌导致异味。',
        'solution': [
          '演示污水箱深度清洁步骤：清水 + 中性洗涤剂浸泡30分钟',
          '指导拆卸滤网组件单独刷洗',
          '介绍每月用白醋兑水浸泡消毒的方法',
          '建议每次使用后开盖晾干，避免密闭滋生细菌',
        ],
        'result': '用户按方法深度清洁后异味消除，后续保持良好清洁习惯。',
      },
    },
    {
      'id': 'VH20241201003',
      'product': '智能洗地机 X1 Pro',
      'sn': 'SN-2024-0815-AX91',
      'issue': '滤网更换指导',
      'agent': '王师傅（技术支持）',
      'date': '2024-12-01',
      'time': '16:00 - 16:12',
      'duration': '12分钟',
      'status': '已完成',
      'statusType': 'done',
      'summary': {
        'problem': '用户收到新的 HEPA 滤网配件，不知道如何更换，担心拆坏机器。',
        'diagnosis': '属于正常耗材更换指导，无故障问题。',
        'solution': [
          '视频演示滤网舱盖打开方式',
          '指导旧滤网取出和新滤网安装方向',
          '强调滤网不可水洗，需定期更换（建议3-6个月）',
          '告知滤网可在官方商城购买，提供配件型号',
        ],
        'result': '用户成功完成滤网更换，对服务表示满意。',
      },
    },
    {
      'id': 'VH20240915004',
      'product': '无线吸尘器 V12',
      'sn': 'SN-2023-0510-CC78',
      'issue': '电池续航明显下降',
      'agent': '赵客服（售后专员）',
      'date': '2024-09-15',
      'time': '09:20 - 09:45',
      'duration': '25分钟',
      'status': '已过保',
      'statusType': 'expired',
      'summary': {
        'problem': '用户反馈吸尘器使用一年多后，续航从原来的40分钟降到15分钟左右，影响使用体验。',
        'diagnosis': '电池属于消耗品，经过约500次充放电循环后容量自然衰减至约60%，属于正常老化。',
        'solution': [
          '指导用户进行电池校准操作（充满后连续放电至自动关机）',
          '介绍电池保养技巧：避免长期满电存放',
          '提供付费更换电池的报价和流程（已过保）',
          '建议日常使用中档吸力，延长电池寿命',
        ],
        'result': '用户选择自行购买电池更换，客服提供了更换视频教程链接。',
      },
    },
    {
      'id': 'VH20240720005',
      'product': '扫地机器人 R7',
      'sn': 'SN-2024-0302-BR22',
      'issue': '建图失败排查',
      'agent': '张工（高级工程师）',
      'date': '2024-07-20',
      'time': '20:00 - 20:35',
      'duration': '35分钟',
      'status': '已完成',
      'statusType': 'done',
      'summary': {
        'problem': '用户新购扫地机器人，首次建图总是失败，机器人走几步就停下来报建图错误。',
        'diagnosis': '通过视频排查，发现用户家中光线较暗，且地面有较多反光瓷砖，影响激光雷达建图精度。',
        'solution': [
          '指导用户开启建图模式时打开主灯保证环境亮度',
          '演示在APP中调整建图精度设置',
          '建议先从一个房间开始建图，逐步扩展到全屋',
          '远程协助重置机器人并重新建图',
        ],
        'result': '调整设置后成功完成全屋建图，用户确认正常使用。',
      },
    },
  ];

  final Set<String> _expandedIds = {};

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
              Color(0xFFF8F9FF),
              Color(0xFFF6F7FB),
              Color(0xFFEEF2FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _historyList.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildStatCard(),
                          const SizedBox(height: 16),
                          _buildSectionTitle('全部记录', Icons.video_library_outlined),
                          const SizedBox(height: 12),
                        ],
                      );
                    }
                    final item = _historyList[index - 1];
                    return _buildHistoryCard(item);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0x225C6680)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A3A436D),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Color(0xFF5664FF),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            '视频历史',
            style: TextStyle(
              color: Color(0xFF161B2F),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard() {
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
          const Text(
            '视频协助记录',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '共 ${_historyList.length} 次视频服务，累计约 ${_totalMinutes()} 分钟',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(Icons.check_circle_outline, '${_doneCount()}', '已完成'),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(Icons.timer_outlined, '${_totalMinutes()}', '总时长(分)'),
              Container(
                width: 1,
                height: 36,
                color: Colors.white.withOpacity(0.2),
              ),
              _buildStatItem(Icons.support_agent_outlined, '3', '客服数'),
            ],
          ),
        ],
      ),
    );
  }

  int _totalMinutes() {
    int total = 0;
    for (var item in _historyList) {
      final dur = item['duration'] as String;
      final match = RegExp(r'(\d+)').firstMatch(dur);
      if (match != null) {
        total += int.parse(match.group(1)!);
      }
    }
    return total;
  }

  int _doneCount() {
    return _historyList.where((e) => e['statusType'] == 'done').length;
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.85), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF5664FF), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF161B2F),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item) {
    final isExpanded = _expandedIds.contains(item['id']);
    final statusConfig = _getStatusConfig(item['statusType'] as String);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0x145664FF)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145F6FFF),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => _toggleExpand(item['id'] as String),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.videocam,
                      color: Color(0xFF5664FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                item['issue'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF161B2F),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: statusConfig['bgColor'],
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item['status'] as String,
                                style: TextStyle(
                                  color: statusConfig['textColor'],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${item['product']} · ${item['sn']}',
                          style: const TextStyle(
                            color: Color(0xFF9AA3BA),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: const Color(0xFF6B7390),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['agent'] as String,
                              style: const TextStyle(
                                color: Color(0xFF6B7390),
                                fontSize: 13,
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              Icons.access_time,
                              color: const Color(0xFF6B7390),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['duration'] as String,
                              style: const TextStyle(
                                color: Color(0xFF6B7390),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FE),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                item['id'] as String,
                                style: const TextStyle(
                                  color: Color(0xFF9AA3BA),
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${item['date']} ${item['time']}'.split(' - ').first,
                                style: const TextStyle(
                                  color: Color(0xFF9AA3BA),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) _buildSummarySection(item),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF5664FF),
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpanded ? '收起 AI 摘要' : '展开 AI 摘要',
                    style: const TextStyle(
                      color: Color(0xFF5664FF),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSummarySection(Map<String, dynamic> item) {
    final summary = item['summary'] as Map<String, dynamic>;
    final solutions = summary['solution'] as List;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FE),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x1A5664FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5664FF), Color(0xFF7D82FF)],
                  ),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI 智能摘要',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryItem(
            icon: Icons.help_outline,
            label: '问题描述',
            content: summary['problem'] as String,
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.search,
            label: '诊断结果',
            content: summary['diagnosis'] as String,
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.tips_and_updates_outlined,
                    color: Color(0xFF5664FF),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '解决方案',
                    style: TextStyle(
                      color: Color(0xFF5664FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...solutions.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6, left: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Color(0xFF5664FF),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.value as String,
                          style: const TextStyle(
                            color: Color(0xFF161B2F),
                            fontSize: 14,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryItem(
            icon: Icons.task_alt,
            label: '处理结果',
            content: summary['result'] as String,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF5664FF), size: 16),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF5664FF),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            content,
            style: const TextStyle(
              color: Color(0xFF161B2F),
              fontSize: 14,
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _getStatusConfig(String type) {
    switch (type) {
      case 'done':
        return {
          'bgColor': const Color(0xFFE8F8EF),
          'textColor': const Color(0xFF3DC882),
        };
      case 'expired':
        return {
          'bgColor': const Color(0xFFF1F2F6),
          'textColor': const Color(0xFF9AA3BA),
        };
      default:
        return {
          'bgColor': const Color(0xFFFFF1E6),
          'textColor': const Color(0xFFFF8478),
        };
    }
  }
}
