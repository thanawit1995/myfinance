import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
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

  Future<void> _processDueRules(bool isThai) async {
    final dao = ref.read(recurringTransactionsDaoProvider);
    final count = await dao.processDueRules();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            count > 0
                ? (isThai
                    ? 'ประมวลผลสำเร็จ: ทำรายการอัตโนมัติแล้ว $count รายการ'
                    : 'Processed $count recurring transaction(s)')
                : (isThai
                    ? 'ไม่มีรายการที่ถึงกำหนดรอบในขณะนี้'
                    : 'No rules due for processing'),
          ),
          backgroundColor: count > 0 ? Colors.green.shade700 : Colors.blueGrey,
        ),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isThai ? 'รายการอัตโนมัติ (Recurring)' : 'Recurring Rules',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.2),
          maxLines: 2,
          softWrap: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: isThai ? 'ตรวจสอบและทำรายการที่ถึงกำหนด' : 'Process due rules',
            onPressed: () => _processDueRules(isThai),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: const Icon(Icons.repeat), text: isThai ? 'กฎที่บันทึกไว้' : 'Saved Rules'),
            Tab(icon: const Icon(Icons.calendar_month_outlined), text: isThai ? 'พยากรณ์ 30 วัน' : '30-Day Forecast'),
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

class _RulesListTab extends ConsumerStatefulWidget {
  final VoidCallback onChanged;

  const _RulesListTab({required this.onChanged});

  @override
  ConsumerState<_RulesListTab> createState() => _RulesListTabState();
}

class _RulesListTabState extends ConsumerState<_RulesListTab> {
  String _selectedType = 'all'; // 'all', 'expense', 'income', 'transfer'

  Widget _buildFilterChip(String type, String label, int count, BuildContext context) {
    final isSelected = _selectedType == type;
    final accent = VaultTheme.accent(context);

    return ChoiceChip(
      label: Text(
        '$label ($count)',
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : VaultTheme.primaryText(context),
        ),
      ),
      selected: isSelected,
      selectedColor: accent,
      backgroundColor: VaultTheme.surface(context),
      side: BorderSide(
        color: isSelected ? accent : VaultTheme.border(context),
        width: 1,
      ),
      visualDensity: VisualDensity.compact,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedType = type);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dao = ref.watch(recurringTransactionsDaoProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
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
          return Center(child: Text('${isThai ? "เกิดข้อผิดพลาด: " : "Error: "}${snapshot.error}'));
        }

        final rules = snapshot.data![0] as List<RecurringRule>;
        final accounts = snapshot.data![1] as List<Account>;
        final accountsMap = {for (final a in accounts) a.id: a};

        final filteredRules = rules.where((r) {
          if (_selectedType == 'all') return true;
          return r.transactionType == _selectedType;
        }).toList();

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () async {
              final created = await RecurringRuleDialog.show(context);
              if (created == true) widget.onChanged();
            },
            icon: const Icon(Icons.add),
            label: Text(isThai ? 'สร้างกฎใหม่' : 'New Rule'),
          ),
          body: Column(
            children: [
              // Filter chips
              if (rules.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', isThai ? 'ทั้งหมด' : 'All', rules.length, context),
                        const SizedBox(width: 8),
                        _buildFilterChip('expense', isThai ? 'รายจ่าย' : 'Expenses',
                            rules.where((r) => r.transactionType == 'expense').length, context),
                        const SizedBox(width: 8),
                        _buildFilterChip('income', isThai ? 'รายรับ' : 'Income',
                            rules.where((r) => r.transactionType == 'income').length, context),
                        const SizedBox(width: 8),
                        _buildFilterChip('transfer', isThai ? 'โอนเงิน' : 'Transfers',
                            rules.where((r) => r.transactionType == 'transfer').length, context),
                      ],
                    ),
                  ),
                ),

              // Rules list or empty
              Expanded(
                child: rules.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(32),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.repeat_on_outlined, size: 64, color: Colors.blue.shade300),
                            const SizedBox(height: 12),
                            Text(
                              isThai ? 'ยังไม่มีกฎรายการอัตโนมัติ' : 'No Recurring Rules Yet',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isThai
                                  ? 'สร้างกฎเพื่อช่วยบันทึกรายรับรายจ่ายประจำอัตโนมัติ เช่น เงินเดือน ค่าเช่า หรือค่าน้ำไฟ'
                                  : 'Create rules to automate recurring income, expenses, or transfers.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : filteredRules.isEmpty
                        ? Center(
                            child: Text(
                              isThai ? 'ไม่พบรายการในหมวดนี้' : 'No rules found in this category',
                              style: TextStyle(color: VaultTheme.secondaryText(context)),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            itemCount: filteredRules.length + 1,
                            itemBuilder: (context, index) {
                              if (index == filteredRules.length) {
                                return const SizedBox(height: 80);
                              }

                              final rule = filteredRules[index];
                              final isDue = !rule.nextRunDate.isAfter(today);
                              final sourceAcc = accountsMap[rule.sourceAccountId];
                              final destAcc = rule.destinationAccountId != null
                                  ? accountsMap[rule.destinationAccountId]
                                  : null;

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: VaultTheme.border(context), width: 0.75),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () async {
                                    final edited = await RecurringRuleDialog.show(context, rule: rule);
                                    if (edited == true) widget.onChanged();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    child: Row(
                                      children: [
                                        // Type Icon Avatar
                                        CircleAvatar(
                                          radius: 17,
                                          backgroundColor: _getTypeColor(rule.transactionType).withValues(alpha: 0.12),
                                          child: Icon(
                                            rule.transactionType == 'income'
                                                ? Icons.arrow_downward_rounded
                                                : (rule.transactionType == 'expense'
                                                    ? Icons.arrow_upward_rounded
                                                    : Icons.swap_horiz_rounded),
                                            size: 17,
                                            color: _getTypeColor(rule.transactionType),
                                          ),
                                        ),
                                        const SizedBox(width: 10),

                                        // Title & Info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      rule.title,
                                                      style: TextStyle(
                                                        fontFamily: VaultTheme.fontFamily,
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.bold,
                                                        color: VaultTheme.primaryText(context),
                                                      ),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                    decoration: BoxDecoration(
                                                      color: rule.autoPost
                                                          ? (VaultTheme.isDark(context)
                                                              ? Colors.green.withValues(alpha: 0.25)
                                                              : Colors.green.withValues(alpha: 0.12))
                                                          : (VaultTheme.isDark(context)
                                                              ? Colors.amber.withValues(alpha: 0.25)
                                                              : Colors.amber.withValues(alpha: 0.18)),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Text(
                                                      rule.autoPost ? 'Auto' : (isThai ? 'รอยืนยัน' : 'Manual'),
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w600,
                                                        color: rule.autoPost
                                                            ? (VaultTheme.isDark(context)
                                                                ? Colors.greenAccent
                                                                : Colors.green.shade800)
                                                            : (VaultTheme.isDark(context)
                                                                ? Colors.amber.shade300
                                                                : Colors.brown.shade800),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${_formatFrequency(rule, isThai)} • ${isThai ? "รอบถัดไป: " : "Next: "}${DateFormat('d MMM', isThai ? 'th' : 'en_US').format(rule.nextRunDate)}'
                                                '${sourceAcc != null ? " • ${rule.transactionType == 'transfer' && destAcc != null ? '${sourceAcc.name} → ${destAcc.name}' : sourceAcc.name}" : ""}',
                                                style: TextStyle(
                                                  fontFamily: VaultTheme.fontFamily,
                                                  fontSize: 11.5,
                                                  color: isDue ? Colors.red.shade700 : VaultTheme.secondaryText(context),
                                                  fontWeight: isDue ? FontWeight.w600 : FontWeight.normal,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Amount & Switch / Options
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              Money(rule.amountSatang).format(symbol: '฿'),
                                              style: VaultTheme.tabular(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.bold,
                                                color: _getTypeColor(rule.transactionType),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (isDue && !rule.autoPost && rule.isActive) ...[
                                                  SizedBox(
                                                    height: 24,
                                                    child: FilledButton.tonal(
                                                      style: FilledButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                      ),
                                                      onPressed: () async {
                                                        await dao.postSingleOccurrence(rule.id, rule.nextRunDate);
                                                        if (context.mounted) {
                                                          ScaffoldMessenger.of(context).showSnackBar(
                                                            SnackBar(
                                                              content: Text(isThai
                                                                  ? 'บันทึกรายการ "${rule.title}" เรียบร้อยแล้ว'
                                                                  : 'Recorded "${rule.title}"'),
                                                            ),
                                                          );
                                                        }
                                                        widget.onChanged();
                                                      },
                                                      child: Text(
                                                        isThai ? 'ทำรายการ' : 'Post',
                                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 2),
                                                ],
                                                Transform.scale(
                                                  scale: 0.72,
                                                  alignment: Alignment.centerRight,
                                                  child: Switch(
                                                    value: rule.isActive,
                                                    onChanged: (val) async {
                                                      await dao.toggleActive(rule.id, val);
                                                      widget.onChanged();
                                                    },
                                                  ),
                                                ),
                                                PopupMenuButton<String>(
                                                  icon: Icon(Icons.more_vert, size: 16, color: VaultTheme.secondaryText(context)),
                                                  padding: EdgeInsets.zero,
                                                  constraints: const BoxConstraints(),
                                                  tooltip: isThai ? 'ตัวเลือก' : 'Options',
                                                  onSelected: (action) async {
                                                    if (action == 'edit') {
                                                      final edited = await RecurringRuleDialog.show(context, rule: rule);
                                                      if (edited == true) widget.onChanged();
                                                    } else if (action == 'delete') {
                                                      final confirm = await showDialog<bool>(
                                                        context: context,
                                                        builder: (ctx) => AlertDialog(
                                                          title: Text(isThai ? 'ยืนยันลบกฎ' : 'Delete Rule'),
                                                          content: Text(isThai
                                                              ? 'คุณต้องการลบ "${rule.title}" หรือไม่?'
                                                              : 'Delete rule "${rule.title}"?'),
                                                          actions: [
                                                            TextButton(
                                                              onPressed: () => Navigator.of(ctx).pop(false),
                                                              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
                                                            ),
                                                            FilledButton(
                                                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                                                              onPressed: () => Navigator.of(ctx).pop(true),
                                                              child: Text(isThai ? 'ลบ' : 'Delete'),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                      if (confirm == true) {
                                                        await dao.deleteRule(rule.id);
                                                        widget.onChanged();
                                                      }
                                                    }
                                                  },
                                                  itemBuilder: (ctx) => [
                                                    PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.edit_outlined, size: 16),
                                                          const SizedBox(width: 8),
                                                          Text(isThai ? 'แก้ไข' : 'Edit'),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                                          const SizedBox(width: 8),
                                                          Text(isThai ? 'ลบ' : 'Delete', style: const TextStyle(color: Colors.red)),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
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

  String _formatFrequency(RecurringRule rule, bool isThai) {
    if (isThai) {
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
    } else {
      final interval = rule.intervalUnits > 1 ? 'Every ${rule.intervalUnits} ' : 'Every ';
      switch (rule.frequency) {
        case 'daily':
          return rule.intervalUnits > 1 ? '${interval}days' : 'Daily';
        case 'weekly':
          return rule.intervalUnits > 1 ? '${interval}weeks' : 'Weekly';
        case 'monthly':
          final dayStr = rule.dayOfMonth != null ? ' (Day ${rule.dayOfMonth})' : '';
          return rule.intervalUnits > 1 ? '${interval}months$dayStr' : 'Monthly$dayStr';
        case 'yearly':
          return rule.intervalUnits > 1 ? '${interval}years' : 'Yearly';
        default:
          return rule.frequency;
      }
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
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return FutureBuilder(
      future: dao.getUpcoming30Days(windowDays: 30),
      builder: (context, AsyncSnapshot<List<({RecurringRule rule, DateTime projectedDate})>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${isThai ? "เกิดข้อผิดพลาด: " : "Error: "}${snapshot.error}'));
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
            Container(
              decoration: BoxDecoration(
                color: VaultTheme.surface(context),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: VaultTheme.border(context), width: 0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.insights_rounded, size: 18, color: VaultTheme.accent(context)),
                          const SizedBox(width: 8),
                          Text(
                            isThai ? 'กระแสเงินสด 30 วัน' : '30-Day Cash Flow',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: VaultTheme.primaryText(context),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: VaultTheme.accent(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${items.length} ${isThai ? "รายการ" : "items"}',
                          style: TextStyle(fontSize: 11.5, color: VaultTheme.accent(context), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 20, thickness: 0.6, color: VaultTheme.border(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(isThai ? 'คาดว่าจะรับ' : 'Expected In', style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context))),
                            const SizedBox(height: 3),
                            Text(
                              Money(projectedIncomeSatang).format(symbol: '฿'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VaultTheme.positive(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 30, width: 1, color: VaultTheme.border(context)),
                      Expanded(
                        child: Column(
                          children: [
                            Text(isThai ? 'คาดว่าจะจ่าย' : 'Expected Out', style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context))),
                            const SizedBox(height: 3),
                            Text(
                              Money(projectedExpenseSatang).format(symbol: '฿'),
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: VaultTheme.negative(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(height: 30, width: 1, color: VaultTheme.border(context)),
                      Expanded(
                        child: Column(
                          children: [
                            Text(isThai ? 'สุทธิ' : 'Net', style: TextStyle(fontSize: 11, color: VaultTheme.secondaryText(context))),
                            const SizedBox(height: 3),
                            Text(
                              Money(projectedIncomeSatang - projectedExpenseSatang).format(symbol: '฿'),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: (projectedIncomeSatang - projectedExpenseSatang) >= 0 ? VaultTheme.positive(context) : VaultTheme.negative(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Center(
                  child: Text(
                    isThai
                        ? 'ไม่มีรายการที่คาดว่าจะเกิดขึ้นใน 30 วันข้างหน้า'
                        : 'No upcoming transactions in the next 30 days',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
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
                    title: Text(
                      item.rule.title,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${isThai ? "กำหนด: " : "Due: "}${DateFormat('dd/MM/yyyy').format(item.projectedDate)} (${item.rule.autoPost ? "Auto-Post" : (isThai ? "รอยืนยัน" : "Manual")})',
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
