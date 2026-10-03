import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../transactions/presentation/edit_transaction_dialog.dart';

class AccountDetailScreen extends ConsumerStatefulWidget {
  final Account account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  ConsumerState<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends ConsumerState<AccountDetailScreen> {
  late String _accountName;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTimeRange? _customDateRange;
  bool _isCustomRange = false;

  @override
  void initState() {
    super.initState();
    _accountName = widget.account.name;
  }

  DateTime get _startDate {
    if (_isCustomRange && _customDateRange != null) {
      return DateTime(_customDateRange!.start.year, _customDateRange!.start.month, _customDateRange!.start.day);
    }
    return DateTime(_selectedMonth.year, _selectedMonth.month, 1);
  }

  DateTime get _endDate {
    if (_isCustomRange && _customDateRange != null) {
      return DateTime(_customDateRange!.end.year, _customDateRange!.end.month, _customDateRange!.end.day, 23, 59, 59);
    }
    return DateTime(
      _selectedMonth.month == 12 ? _selectedMonth.year + 1 : _selectedMonth.year,
      _selectedMonth.month == 12 ? 1 : _selectedMonth.month + 1,
      0,
      23,
      59,
      59,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accDao = ref.watch(accountsDaoProvider);
    final txDao = ref.watch(transactionsDaoProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Scaffold(
      appBar: AppBar(
        title: Text(_accountName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: isThai ? 'แก้ไขชื่อบัญชี' : 'Edit account name',
            onPressed: () => _editAccountName(isThai),
          ),
          IconButton(
            icon: Icon(widget.account.isActive ? Icons.archive_outlined : Icons.unarchive_outlined),
            tooltip: widget.account.isActive
                ? (isThai ? 'ปิดการใช้งานบัญชี' : 'Deactivate account')
                : (isThai ? 'เปิดการใช้งานบัญชี' : 'Activate account'),
            onPressed: () => _toggleActive(isThai),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            tooltip: isThai ? 'ลบบัญชีนี้ (ย้ายไปถังขยะ)' : 'Delete account (Move to Trash)',
            onPressed: () => _confirmDeleteAccount(isThai),
          ),
        ],
      ),
      body: Column(
        children: [
          // Balance Card
          FutureBuilder<({int nativeBalanceSatang, int thbEquivalentSatang, Decimal fxRate})>(
            future: accDao.getAccountBalanceBreakdown(widget.account.id),
            builder: (context, snapshot) {
              final data = snapshot.data;
              final balance = data?.nativeBalanceSatang ?? 0;
              final thbEquivalent = data?.thbEquivalentSatang ?? 0;
              final fxRate = data?.fxRate;
              final isUsd = widget.account.currencyCode == 'USD';
              final symbol = isUsd ? r'$' : '฿';
              final money = Money(balance);

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isThai ? 'ยอดคงเหลือปัจจุบัน' : 'Current Balance', style: theme.textTheme.titleSmall),
                    const SizedBox(height: 6),
                    Text(
                      money.format(symbol: symbol),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    if (isUsd && fxRate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        '≈ ${Money(thbEquivalent).format(symbol: '฿')} (${isThai ? "อัตราแลกเปลี่ยน" : "FX Rate"} ${fxRate.toStringAsFixed(2)} ฿/\$)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${isThai ? "สกุลเงิน" : "Currency"}: ${widget.account.currencyCode} · ${widget.account.isDomestic ? (isThai ? 'ในประเทศ' : 'Domestic') : (isThai ? 'ต่างประเทศ' : 'Offshore')}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              );
            },
          ),

          // Period Selector Bar (Item 6)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    tooltip: isThai ? 'เดือนก่อนหน้า' : 'Previous month',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() {
                        _isCustomRange = false;
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
                      });
                    },
                  ),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        final picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2035),
                          initialDateRange: _customDateRange ?? DateTimeRange(start: _startDate, end: _endDate),
                        );
                        if (picked != null) {
                          setState(() {
                            _isCustomRange = true;
                            _customDateRange = picked;
                          });
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isCustomRange ? Icons.date_range_rounded : Icons.calendar_month_rounded,
                                  size: 15,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  _isCustomRange
                                      ? '${DateFormat('d/M/y').format(_customDateRange!.start)} - ${DateFormat('d/M/y').format(_customDateRange!.end)}'
                                      : DateFormat('MMMM yyyy', isThai ? 'th' : 'en_US').format(_selectedMonth),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    tooltip: isThai ? 'เดือนถัดไป' : 'Next month',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      setState(() {
                        _isCustomRange = false;
                        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
                      });
                    },
                  ),
                  if (_isCustomRange || _selectedMonth.year != DateTime.now().year || _selectedMonth.month != DateTime.now().month)
                    IconButton(
                      icon: const Icon(Icons.today_rounded, size: 19),
                      tooltip: isThai ? 'กลับมาเดือนปัจจุบัน' : 'Back to current month',
                      visualDensity: VisualDensity.compact,
                      onPressed: () {
                        setState(() {
                          _isCustomRange = false;
                          _customDateRange = null;
                          _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
                        });
                      },
                    ),
                ],
              ),
            ),
          ),

          // Transaction History List filtered by period (Item 6)
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: txDao.searchTransactions(
                accountId: widget.account.id,
                startDate: _startDate,
                endDate: _endDate,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = snapshot.data ?? [];

                // Calculate in/out for selected period
                int totalInflow = 0;
                int totalOutflow = 0;
                for (final t in transactions) {
                  final isExpense = t.sourceAccountId == widget.account.id && t.transactionType != 'income';
                  if (isExpense) {
                    totalOutflow += t.amountThbSatang;
                  } else {
                    totalInflow += t.amountThbSatang;
                  }
                }

                return Column(
                  children: [
                    // Period summary badges
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${isThai ? "รายการทั้งหมด" : "Total"}: ${transactions.length} ${isThai ? "รายการ" : "items"}',
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '+${Money(totalInflow).format(symbol: '฿')}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '-${Money(totalOutflow).format(symbol: '฿')}',
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.red),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    Expanded(
                      child: transactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calendar_today_outlined, size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    isThai ? 'ไม่มีรายการในเดือนนี้ / ช่วงเวลาที่เลือก' : 'No transactions in this period',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: transactions.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final tx = transactions[index];
                                final isExpense = tx.sourceAccountId == widget.account.id && tx.transactionType != 'income';
                                final money = Money(tx.amountThbSatang);
                                final color = isExpense ? Colors.red.shade700 : Colors.green.shade700;

                                final fallbackTitle = isExpense
                                    ? (isThai ? 'รายจ่าย/โอนออก' : 'Expense / Outflow')
                                    : (isThai ? 'รายรับ/โอนเข้า' : 'Income / Inflow');

                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    tx.note?.isNotEmpty == true ? tx.note! : fallbackTitle,
                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                                  ),
                                  subtitle: Text(
                                    DateFormat('d MMM yyyy, HH:mm').format(tx.transactionDate),
                                    style: const TextStyle(fontSize: 11.5),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        isExpense ? '-${money.format(symbol: '฿')}' : '+${money.format(symbol: '฿')}',
                                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      Icon(Icons.edit_outlined, size: 15, color: Colors.grey.shade400),
                                    ],
                                  ),
                                  onTap: () async {
                                    final changed = await EditTransactionDialog.show(context, tx);
                                    if (changed == true && mounted) {
                                      setState(() {});
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(bool isThai) async {
    final accDao = ref.read(accountsDaoProvider);
    if (widget.account.isActive) {
      await accDao.deactivateAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ปิดการใช้งานบัญชีแล้ว (ยอดเงินจะไม่นับรวมในทรัพย์สินรวม)'
                : 'Account deactivated (excluded from total assets)'),
          ),
        );
        Navigator.of(context).pop();
      }
    } else {
      await accDao.activateAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'เปิดการใช้งานบัญชีเรียบร้อยแล้ว' : 'Account activated successfully')),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _confirmDeleteAccount(bool isThai) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ลบบัญชี' : 'Delete Account'),
        content: Text(
          isThai
              ? 'คุณต้องการลบบัญชี "${widget.account.name}" ใช่หรือไม่?\n\nบัญชีและรายการธุรกรรมทั้งหมดจะถูกย้ายไปที่ "ถังขยะ" ในหน้าตั้งค่า และสามารถกู้คืนได้ภายใน 30 วัน'
              : 'Delete account "${widget.account.name}"?\n\nThe account and its transactions will be moved to "Trash Bin" in Settings and can be restored within 30 days.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบบัญชี (ย้ายลงถังขยะ)' : 'Delete (Move to Trash)'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(accountsDaoProvider).softDeleteAccount(widget.account.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai
                ? 'ย้ายบัญชี "${widget.account.name}" ไปที่ถังขยะเรียบร้อยแล้ว'
                : 'Account "${widget.account.name}" moved to Trash Bin'),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _editAccountName(bool isThai) async {
    final controller = TextEditingController(text: _accountName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'แก้ไขชื่อบัญชี' : 'Edit Account Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: isThai ? 'ชื่อบัญชี' : 'Account Name',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final trimmed = controller.text.trim();
              if (trimmed.isNotEmpty) {
                Navigator.of(ctx).pop(trimmed);
              }
            },
            child: Text(isThai ? 'บันทึก' : 'Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty && newName != _accountName) {
      await ref.read(accountsDaoProvider).updateAccountName(widget.account.id, newName);
      if (mounted) {
        setState(() {
          _accountName = newName;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 5),
            content: Text(isThai
                ? 'แก้ไขชื่อบัญชีเป็น "$newName" สำเร็จ'
                : 'Account name updated to "$newName"'),
          ),
        );
      }
    }
  }
}

