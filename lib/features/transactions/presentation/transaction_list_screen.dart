import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import 'edit_transaction_dialog.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  const TransactionListScreen({super.key});

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen> {
  final _searchController = TextEditingController();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTimeRange? _selectedDateRange;
  String? _selectedType; // null = ทั้งหมด, 'income', 'expense', 'transfer'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txDao = ref.watch(transactionsDaoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติรายการ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: 'ตัวกรอง',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ค้นหาบันทึกย่อ หรือ tag...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                isDense: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),

          // Type filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _typeChip(label: 'ทั้งหมด', value: null, icon: Icons.list_alt_rounded),
                  const SizedBox(width: 8),
                  _typeChip(label: 'รายรับ', value: 'income', icon: Icons.arrow_downward_rounded, color: Colors.green),
                  const SizedBox(width: 8),
                  _typeChip(label: 'รายจ่าย', value: 'expense', icon: Icons.arrow_upward_rounded, color: Colors.red),
                  const SizedBox(width: 8),
                  _typeChip(label: 'โอนเงิน', value: 'transfer', icon: Icons.swap_horiz_rounded, color: Colors.blueGrey),
                ],
              ),
            ),
          ),

          // Active filter chips
          if (_selectedAccountId != null || _selectedCategoryId != null || _selectedDateRange != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children: [
                  if (_selectedDateRange != null)
                    Chip(
                      label: Text('${DateFormat('d/M').format(_selectedDateRange!.start)} - ${DateFormat('d/M').format(_selectedDateRange!.end)}'),
                      onDeleted: () => setState(() => _selectedDateRange = null),
                    ),
                  if (_selectedAccountId != null)
                    Chip(
                      label: const Text('บัญชีที่เลือก'),
                      onDeleted: () => setState(() => _selectedAccountId = null),
                    ),
                  if (_selectedCategoryId != null)
                    Chip(
                      label: const Text('หมวดหมู่ที่เลือก'),
                      onDeleted: () => setState(() => _selectedCategoryId = null),
                    ),
                ],
              ),
            ),

          // Transaction list
          Expanded(
            child: FutureBuilder<List<Transaction>>(
              future: txDao.searchTransactions(
                query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                startDate: _selectedDateRange?.start,
                endDate: _selectedDateRange?.end.add(const Duration(days: 1)),
                accountId: _selectedAccountId,
                categoryId: _selectedCategoryId,
                transactionType: _selectedType,
                excludeInvestments: false,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
                }

                final transactions = snapshot.data ?? [];
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text('ไม่พบรายการที่ตรงกับเงื่อนไข', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  );
                }

                // Group transactions by date
                final grouped = <DateTime, List<Transaction>>{};
                for (final tx in transactions) {
                  final d = DateTime(tx.transactionDate.year, tx.transactionDate.month, tx.transactionDate.day);
                  grouped.putIfAbsent(d, () => []).add(tx);
                }
                final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, dateIndex) {
                    final date = sortedDates[dateIndex];
                    final dayTxs = grouped[date]!;

                    int dailyNetSatang = dayTxs.fold(0, (sum, tx) {
                      if (tx.transactionType == 'income') return sum + tx.amountThbSatang;
                      if (tx.transactionType == 'expense') return sum - tx.amountThbSatang;
                      return sum;
                    });

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDateHeader(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (dailyNetSatang != 0)
                                Text(
                                  '${dailyNetSatang > 0 ? '+' : ''}${Money(dailyNetSatang).format(symbol: '฿')}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: dailyNetSatang >= 0
                                        ? AppTheme.incomeColor(context)
                                        : AppTheme.expenseColor(context),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: dayTxs.length,
                            separatorBuilder: (_, _) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final tx = dayTxs[index];
                              return _buildTransactionTile(context, tx);
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip({
    required String label,
    required String? value,
    required IconData icon,
    Color? color,
  }) {
    final isSelected = _selectedType == value;
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: isSelected ? Colors.white : chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isSelected ? Colors.white : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedType = value),
      showCheckmark: false,
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      side: BorderSide(color: chipColor.withValues(alpha: isSelected ? 1.0 : 0.4), width: isSelected ? 1.5 : 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return 'วันนี้';
    if (date == yesterday) return 'เมื่อวานนี้';
    return DateFormat('d MMMM yyyy', 'th_TH').format(date);
  }

  Widget _buildTransactionTile(BuildContext context, Transaction tx) {
    final theme = Theme.of(context);
    final isExpense = tx.transactionType == 'expense';
    final isIncome = tx.transactionType == 'income';

    final money = Money(tx.amountThbSatang);

    final color = isExpense
        ? AppTheme.expenseColor(context)
        : (isIncome ? AppTheme.incomeColor(context) : AppTheme.transferColor(context));
    final icon = isExpense
        ? Icons.arrow_upward_rounded
        : (isIncome ? Icons.arrow_downward_rounded : Icons.swap_horiz_rounded);

    final timeStr = DateFormat('HH:mm').format(tx.transactionDate);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      title: Text(
        tx.note?.isNotEmpty == true ? tx.note! : (isExpense ? 'รายจ่าย' : (isIncome ? 'รายรับ' : 'โอนเงิน')),
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        timeStr,
        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            isExpense ? '-${money.format(symbol: '฿')}' : (isIncome ? '+${money.format(symbol: '฿')}' : money.format(symbol: '฿')),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
          ),
          if (tx.feeThbSatang > 0)
            Text(
              'ค่าธรรมเนียม: ${Money(tx.feeThbSatang).format(symbol: '฿')}',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
      onTap: () async {
        final changed = await EditTransactionDialog.show(context, tx);
        if (changed == true && mounted) {
          setState(() {});
        }
      },
      onLongPress: () => _confirmDelete(tx),
    );
  }

  Future<void> _confirmDelete(Transaction tx) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบรายการ'),
        content: const Text('คุณต้องการลบรายการนี้ใช่หรือไม่? (การลบจะถูกบันทึกลง Audit Log)'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ลบรายการ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionsDaoProvider).softDeleteTransaction(tx.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ลบรายการเรียบร้อยแล้ว')),
        );
        setState(() {});
      }
    }
  }

  Future<void> _showFilterDialog() async {
    final accounts = await ref.read(accountsDaoProvider).getActiveAccounts();
    final categories = await ref.read(categoriesDaoProvider).getActiveCategories();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (bottomSheetCtx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ตัวกรองข้อมูล', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // Date range picker
                  ListTile(
                    leading: const Icon(Icons.date_range),
                    title: Text(
                      _selectedDateRange == null
                          ? 'เลือกช่วงวันที่'
                          : '${DateFormat('d/M/y').format(_selectedDateRange!.start)} - ${DateFormat('d/M/y').format(_selectedDateRange!.end)}',
                    ),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        initialDateRange: _selectedDateRange,
                      );
                      if (picked != null) {
                        setModalState(() => _selectedDateRange = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),

                  // Account dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'กรองตามบัญชี', border: OutlineInputBorder()),
                    initialValue: _selectedAccountId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('ทุกบัญชี')),
                      ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                    ],
                    onChanged: (val) => setModalState(() => _selectedAccountId = val),
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'กรองตามหมวดหมู่', border: OutlineInputBorder()),
                    initialValue: _selectedCategoryId,
                    items: [
                      const DropdownMenuItem(value: null, child: Text('ทุกหมวดหมู่')),
                      ...categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.nameTh))),
                    ],
                    onChanged: (val) => setModalState(() => _selectedCategoryId = val),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedDateRange = null;
                              _selectedAccountId = null;
                              _selectedCategoryId = null;
                            });
                            setState(() => _selectedType = null);
                          },
                          child: const Text('ล้างตัวกรองทั้งหมด'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {});
                          },
                          child: const Text('นำไปใช้'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
