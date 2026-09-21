import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import 'recurring_rule_dialog.dart';

class RecurringRulesScreen extends ConsumerStatefulWidget {
  const RecurringRulesScreen({super.key});

  @override
  ConsumerState<RecurringRulesScreen> createState() => _RecurringRulesScreenState();
}

class _RecurringRulesScreenState extends ConsumerState<RecurringRulesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  void _refresh() {
    setState(() {});
  }

  Future<void> _processDueRules() async {
    final dao = ref.read(recurringTransactionsDaoProvider);
    final count = await dao.processDueRules();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? 'ประมวลผลสำเร็จ: ทำรายการอัตโนมัติแล้ว $count รายการ'
                : 'ไม่มีรายการที่ถึงกำหนดรอบในขณะนี้',
          ),
          backgroundColor: count > 0 ? Colors.green.shade700 : Colors.blueGrey,
        ),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('รายการอัตโนมัติ (Recurring)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'ตรวจสอบและทำรายการที่ถึงกำหนด',
            onPressed: _processDueRules,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.repeat), text: 'กฎที่บันทึกไว้'),
            Tab(icon: Icon(Icons.calendar_month_outlined), text: 'พยากรณ์ 30 วันล่วงหน้า'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RulesListTab(onChanged: _refresh),
          _ProjectionTab(onChanged: _refresh),
        ],
      ),
    );
  }
}

class _RulesListTab extends ConsumerWidget {
  final VoidCallback onChanged;

  const _RulesListTab({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(recurringTransactionsDaoProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return FutureBuilder(
      future: Future.wait([
        dao.getAllRules(),
        ref.read(accountsDaoProvider).getActiveAccounts(),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final rules = snapshot.data![0] as List<RecurringRule>;
        final accounts = snapshot.data![1] as List<Account>;
        final accountsMap = {for (final a in accounts) a.id: a};

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await RecurringRuleDialog.show(context);
              if (created == true) onChanged();
            },
            icon: const Icon(Icons.add),
            label: const Text('สร้างกฎใหม่'),
          ),
          body: rules.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.repeat_on_outlined, size: 64, color: Colors.blue.shade300),
                      const SizedBox(height: 12),
                      const Text(
                        'ยังไม่มีกฎรายการอัตโนมัติ',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'สร้างกฎเพื่อช่วยบันทึกรายรับรายจ่ายประจำอัตโนมัติ เช่น เงินเดือน ค่าเช่า หรือค่าน้ำไฟ',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rules.length + 1,
                  itemBuilder: (context, index) {
                    if (index == rules.length) {
                      return const SizedBox(height: 80);
                    }

                    final rule = rules[index];
                    final isDue = !rule.nextRunDate.isAfter(today);
                    final sourceAcc = accountsMap[rule.sourceAccountId];
                    final destAcc = rule.destinationAccountId != null ? accountsMap[rule.destinationAccountId] : null;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header: Type + Status Badges + Toggle
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(rule.transactionType).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getTypeLabel(rule.transactionType),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: _getTypeColor(rule.transactionType),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: rule.autoPost ? Colors.green.shade50 : Colors.amber.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    rule.autoPost ? 'Auto-Post' : 'รอยืนยัน',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                      color: rule.autoPost ? Colors.green.shade800 : Colors.brown.shade800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Switch(
                                  value: rule.isActive,
                                  onChanged: (val) async {
                                    await dao.toggleActive(rule.id, val);
                                    onChanged();
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Title & Amount
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    rule.title,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  Money(rule.amountSatang).format(symbol: '฿'),
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: _getTypeColor(rule.transactionType),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Frequency and Account info
                            Text(
                              'ความถี่: ${_formatFrequency(rule)}',
                              style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                            ),
                            if (sourceAcc != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                rule.transactionType == 'transfer' && destAcc != null
                                    ? 'โอนจาก: ${sourceAcc.name} → ${destAcc.name}'
                                    : 'บัญชี: ${sourceAcc.name}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                            const Divider(height: 18),

                            // Next run date and actions
                            Row(
                              children: [
                                Icon(
                                  Icons.event,
                                  size: 15,
                                  color: isDue ? Colors.red.shade600 : Colors.blueGrey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'รอบถัดไป: ${DateFormat('dd/MM/yyyy').format(rule.nextRunDate)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isDue ? FontWeight.bold : FontWeight.normal,
                                    color: isDue ? Colors.red.shade700 : Colors.grey.shade800,
                                  ),
                                ),
                                const Spacer(),
                                if (isDue && !rule.autoPost && rule.isActive)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilledButton.tonal(
                                      style: FilledButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        textStyle: const TextStyle(fontSize: 11),
                                      ),
                                      onPressed: () async {
                                        await dao.postSingleOccurrence(rule.id, rule.nextRunDate);
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('บันทึกรายการ "${rule.title}" เรียบร้อยแล้ว')),
                                          );
                                        }
                                        onChanged();
                                      },
                                      child: const Text('ยืนยันทำรายการ'),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  onPressed: () async {
                                    final edited = await RecurringRuleDialog.show(context, rule: rule);
                                    if (edited == true) onChanged();
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('ยืนยันลบกฎ'),
                                        content: Text('คุณต้องการลบ "${rule.title}" หรือไม่?'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                          FilledButton(
                                            style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () => Navigator.of(ctx).pop(true),
                                            child: const Text('ลบ'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await dao.deleteRule(rule.id);
                                      onChanged();
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'income':
        return Colors.green.shade700;
      case 'expense':
        return Colors.red.shade700;
      case 'transfer':
        return Colors.blue.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'income':
        return 'รายรับ';
      case 'expense':
        return 'รายจ่าย';
      case 'transfer':
        return 'โอนเงิน';
      default:
        return type;
    }
  }

  String _formatFrequency(RecurringRule rule) {
    final interval = rule.intervalUnits > 1 ? 'ทุกๆ ${rule.intervalUnits} ' : 'ทุก';
    switch (rule.frequency) {
      case 'daily':
        return '$intervalวัน';
      case 'weekly':
        return '$intervalสัปดาห์';
      case 'monthly':
        final dayStr = rule.dayOfMonth != null ? ' (วันที่ ${rule.dayOfMonth})' : '';
        return '$intervalเดือน$dayStr';
      case 'yearly':
        return '$intervalปี';
      default:
        return rule.frequency;
    }
  }
}

class _ProjectionTab extends ConsumerWidget {
  final VoidCallback onChanged;

  const _ProjectionTab({required this.onChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dao = ref.watch(recurringTransactionsDaoProvider);
    final theme = Theme.of(context);

    return FutureBuilder(
      future: dao.getUpcoming30Days(windowDays: 30),
      builder: (context, AsyncSnapshot<List<({RecurringRule rule, DateTime projectedDate})>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }

        final items = snapshot.data ?? [];

        int projectedIncomeSatang = 0;
        int projectedExpenseSatang = 0;

        for (final item in items) {
          if (item.rule.transactionType == 'income') {
            projectedIncomeSatang += item.rule.amountSatang;
          } else if (item.rule.transactionType == 'expense') {
            projectedExpenseSatang += item.rule.amountSatang;
          }
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Forecast Summary Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ประมาณการกระแสเงินสด 30 วันข้างหน้า',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          '${items.length} รายการ',
                          style: TextStyle(fontSize: 12, color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            const Text('คาดว่าจะรับ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              Money(projectedIncomeSatang).format(symbol: '฿'),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green.shade700),
                            ),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.grey.shade300),
                        Column(
                          children: [
                            const Text('คาดว่าจะจ่าย', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              Money(projectedExpenseSatang).format(symbol: '฿'),
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                            ),
                          ],
                        ),
                        Container(height: 30, width: 1, color: Colors.grey.shade300),
                        Column(
                          children: [
                            const Text('สุทธิ', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              Money(projectedIncomeSatang - projectedExpenseSatang).format(symbol: '฿'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: (projectedIncomeSatang - projectedExpenseSatang) >= 0 ? Colors.green.shade800 : Colors.red.shade800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text('ไม่มีรายการที่คาดว่าจะเกิดขึ้นใน 30 วันข้างหน้า', style: TextStyle(color: Colors.grey.shade600)),
                ),
              )
            else
              ...items.map((item) {
                final isIncome = item.rule.transactionType == 'income';
                final isExpense = item.rule.transactionType == 'expense';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome
                          ? Colors.green.shade50
                          : (isExpense ? Colors.red.shade50 : Colors.blue.shade50),
                      child: Icon(
                        isIncome ? Icons.arrow_downward : (isExpense ? Icons.arrow_upward : Icons.swap_horiz),
                        color: isIncome
                            ? Colors.green.shade700
                            : (isExpense ? Colors.red.shade700 : Colors.blue.shade700),
                        size: 20,
                      ),
                    ),
                    title: Text(item.rule.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: Text(
                      'กำหนด: ${DateFormat('dd/MM/yyyy').format(item.projectedDate)} (${item.rule.autoPost ? 'Auto-Post' : 'รอยืนยัน'})',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    trailing: Text(
                      Money(item.rule.amountSatang).format(symbol: '฿'),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isIncome
                            ? Colors.green.shade700
                            : (isExpense ? Colors.red.shade700 : theme.colorScheme.onSurface),
                      ),
                    ),
                  ),
                );
              }),
            const SizedBox(height: 60),
          ],
        );
      },
    );
  }
}
