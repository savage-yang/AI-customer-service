import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 我的产品（Mock 数据）
  final List<Map<String, dynamic>> _products = const [
    {
      'name': '智能洗地机 X1 Pro',
      'sn': 'SN-2024-0815-AX91',
      'status': '正常',
      'statusType': 'normal',
      'purchaseDate': '2024-08-15',
      'warranty': '保修至 2026-08-15',
    },
    {
      'name': '扫地机器人 R7',
      'sn': 'SN-2024-0302-BR22',
      'status': '维修中',
      'statusType': 'repairing',
      'purchaseDate': '2024-03-02',
      'warranty': '保修至 2026-03-02',
    },
    {
      'name': '无线吸尘器 V12',
      'sn': 'SN-2023-0510-CC78',
      'status': '已过保',
      'statusType': 'expired',
      'purchaseDate': '2023-05-10',
      'warranty': '保修已过期',
    },
  ];

  // 销售记录
  final List<Map<String, dynamic>> _salesRecords = const [
    {
      'title': '智能洗地机 X1 Pro',
      'orderNo': 'SO20240815001',
      'amount': '¥2,999',
      'date': '2024-08-15',
      'channel': '官方商城',
    },
    {
      'title': '扫地机器人 R7',
      'orderNo': 'SO20240302001',
      'amount': '¥1,899',
      'date': '2024-03-02',
      'channel': '京东旗舰店',
    },
    {
      'title': '无线吸尘器 V12',
      'orderNo': 'SO20230510001',
      'amount': '¥1,299',
      'date': '2023-05-10',
      'channel': '天猫旗舰店',
    },
  ];

  // 维修记录
  final List<Map<String, dynamic>> _repairRecords = const [
    {
      'title': '扫地机器人 R7 - 滚轮异响',
      'ticketNo': 'RP20250612003',
      'status': '维修中',
      'date': '2025-06-12',
      'desc': '滚轮运转时出现异响，已寄回检修',
    },
    {
      'title': '智能洗地机 X1 Pro - 滤网更换',
      'ticketNo': 'RP20241201001',
      'status': '已完成',
      'date': '2024-12-01',
      'desc': 'HEPA 滤网老化，上门更换完成',
    },
  ];

  // 售后记录
  final List<Map<String, dynamic>> _serviceRecords = const [
    {
      'title': '智能洗地机 X1 Pro - 退款咨询',
      'ticketNo': 'AS20250108002',
      'status': '已解决',
      'date': '2025-01-08',
      'desc': '咨询配件退款进度，已到账',
    },
    {
      'title': '无线吸尘器 V12 - 电池续航',
      'ticketNo': 'AS20240920001',
      'status': '已解决',
      'date': '2024-09-20',
      'desc': '续航时间缩短，客服指导重置电池',
    },
    {
      'title': '扫地机器人 R7 - 地图丢失',
      'ticketNo': 'AS20240415001',
      'status': '已解决',
      'date': '2024-04-15',
      'desc': '建图丢失，远程协助重新建图',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 8),
                    _buildUserCard(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('我的产品', Icons.inventory_2_outlined),
                    const SizedBox(height: 12),
                    ..._products.map((p) => _buildProductCard(p)),
                    const SizedBox(height: 24),
                    _buildSectionTitle('历史记录', Icons.history),
                    const SizedBox(height: 12),
                    _buildHistoryTabs(),
                  ],
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
            '我的',
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

  Widget _buildUserCard() {
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
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '尊享会员',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'VIP 黄金会员',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('${_products.length}', '持有产品'),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem('${_repairRecords.length}', '维修记录'),
                Container(
                  width: 1,
                  height: 28,
                  color: Colors.white.withOpacity(0.3),
                ),
                _buildStatItem('${_serviceRecords.length}', '售后记录'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    final statusConfig = _getStatusConfig(product['statusType'] as String);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.devices,
                  color: Color(0xFF5664FF),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['name'] as String,
                      style: const TextStyle(
                        color: Color(0xFF161B2F),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product['sn'] as String,
                      style: const TextStyle(
                        color: Color(0xFF9AA3BA),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusConfig['bgColor'],
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product['status'] as String,
                  style: TextStyle(
                    color: statusConfig['textColor'],
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: Color(0xFF9AA3BA),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '购买于 ${product['purchaseDate']}',
                  style: const TextStyle(
                    color: Color(0xFF6B7390),
                    fontSize: 13,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.shield_outlined,
                  color: statusConfig['textColor'],
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  product['warranty'] as String,
                  style: TextStyle(
                    color: statusConfig['textColor'],
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String type) {
    switch (type) {
      case 'normal':
        return {
          'bgColor': const Color(0xFFE8F8EF),
          'textColor': const Color(0xFF3DC882),
        };
      case 'repairing':
        return {
          'bgColor': const Color(0xFFFFF1E6),
          'textColor': const Color(0xFFFF8478),
        };
      case 'expired':
        return {
          'bgColor': const Color(0xFFF1F2F6),
          'textColor': const Color(0xFF9AA3BA),
        };
      default:
        return {
          'bgColor': const Color(0xFFEEF2FF),
          'textColor': const Color(0xFF5664FF),
        };
    }
  }

  Widget _buildHistoryTabs() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F2F6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A3A436D),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: const Color(0xFF5664FF),
            unselectedLabelColor: const Color(0xFF9AA3BA),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: '销售'),
              Tab(text: '维修'),
              Tab(text: '售后'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            final List<Map<String, dynamic>> records;
            switch (_tabController.index) {
              case 0:
                records = _salesRecords;
                break;
              case 1:
                records = _repairRecords;
                break;
              default:
                records = _serviceRecords;
            }
            return Column(
              children: records
                  .map((r) => _buildRecordCard(r, _tabController.index))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRecordCard(Map<String, dynamic> record, int tabType) {
    final isFinished =
        record['status'] == '已完成' || record['status'] == '已解决';
    final statusColor =
        isFinished ? const Color(0xFF3DC882) : const Color(0xFFFF8478);
    final statusBg =
        isFinished ? const Color(0xFFE8F8EF) : const Color(0xFFFFF1E6);

    IconData leadingIcon;
    switch (tabType) {
      case 0:
        leadingIcon = Icons.shopping_bag_outlined;
        break;
      case 1:
        leadingIcon = Icons.build_outlined;
        break;
      default:
        leadingIcon = Icons.support_agent;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(
              leadingIcon,
              color: const Color(0xFF5664FF),
              size: 22,
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
                        record['title'] as String,
                        style: const TextStyle(
                          color: Color(0xFF161B2F),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (record['status'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          record['status'] as String,
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
                if (record['desc'] != null)
                  Text(
                    record['desc'] as String,
                    style: const TextStyle(
                      color: Color(0xFF6B7390),
                      fontSize: 13,
                      height: 1.5,
                    ),
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
                        record['ticketNo'] ?? record['orderNo'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF9AA3BA),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (record['amount'] != null)
                        Text(
                          record['amount'] as String,
                          style: const TextStyle(
                            color: Color(0xFF5664FF),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        )
                      else if (record['channel'] != null)
                        Text(
                          record['channel'] as String,
                          style: const TextStyle(
                            color: Color(0xFF9AA3BA),
                            fontSize: 12,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        record['date'] as String,
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
    );
  }
}
