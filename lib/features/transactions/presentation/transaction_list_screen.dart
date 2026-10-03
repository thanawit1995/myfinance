import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/category_name_helper.dart';
import 'edit_transaction_dialog.dart';

class TransactionListScreen extends ConsumerStatefulWidget {
  final String? initialTransactionType; // 'income', 'expense', 'transfer'
  final DateTimeRange? initialDateRange;
  final String? initialCategoryId;
  final String? title;

  const TransactionListScreen({
    super.key,
    this.initialTransactionType,
    this.initialDateRange,
    this.initialCategoryId,
    this.title,
  });

  @override
  ConsumerState<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends ConsumerState<TransactionListScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _searchController = TextEditingController();
  String? _selectedAccountId;
  String? _selectedCategoryId;
  DateTimeRange? _selectedDateRange;
  String? _selectedType; // null = ทั้งหมด, 'income', 'expense', 'transfer'
  bool _isSearchExpanded = false;

  List<Transaction>? _transactions;
  Map<String, Account> _accountsMap = {};
  bool _isLoading = false;
  StreamSubscription? _dbSubscription;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialTransactionType;
    _selectedDateRange = widget.initialDateRange;
    _selectedCategoryId = widget.initialCategoryId;
    _loadTransactions();
    // Silent background sync with database updates
    _dbSubscription = ref.read(transactionsDaoProvider).watchRecentTransactions(limit: 1).listen((_) {
      _silentReloadTransactions();
    });
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (_transactions == null) {
      setState(() => _isLoading = true);
    }
    try {
      final accounts = await ref.read(accountsDaoProvider).getAllAccounts();
      final accountsMap = {for (final a in accounts) a.id: a};
      final list = await ref.read(transactionsDaoProvider).searchTransactions(
        query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end.add(const Duration(days: 1)),
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        transactionType: _selectedType,
        excludeInvestments: false,
      );
      if (mounted) {
        setState(() {
          _accountsMap = accountsMap;
          _transactions = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _silentReloadTransactions() async {
    try {
      final accounts = await ref.read(accountsDaoProvider).getAllAccounts();
      final accountsMap = {for (final a in accounts) a.id: a};
      final list = await ref.read(transactionsDaoProvider).searchTransactions(
        query: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
        startDate: _selectedDateRange?.start,
        endDate: _selectedDateRange?.end.add(const Duration(days: 1)),
        accountId: _selectedAccountId,
        categoryId: _selectedCategoryId,
        transactionType: _selectedType,
        excludeInvestments: false,
      );
      if (mounted) {
        setState(() {
          _accountsMap = accountsMap;
          _transactions = list;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Scaffold(
      appBar: (widget.title != null || canPop)
          ? AppBar(
              title: Text(
                widget.title ?? (isThai ? 'รายการธุรกรรม' : 'Transactions'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )
          : null,
      body: Column(
        children: [
          // Filter Chips + Search & Filter Action Buttons
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _typeChip(label: isThai ? 'ทั้งหมด' : 'All', value: null, icon: Icons.list_alt_rounded),
                        const SizedBox(width: 6),
                        _typeChip(label: isThai ? 'รายรับ' : 'Income', value: 'income', icon: Icons.arrow_downward_rounded, color: Colors.green),
                        const SizedBox(width: 6),
                        _typeChip(label: isThai ? 'รายจ่าย' : 'Expense', value: 'expense', icon: Icons.arrow_upward_rounded, color: Colors.red),
                        const SizedBox(width: 6),
                        _typeChip(label: isThai ? 'โอนเงิน' : 'Transfer', value: 'transfer', icon: Icons.swap_horiz_rounded, color: Colors.blueGrey),
                      ],
                    ),
                  ),
                ),
                // Search button
                IconButton(
                  icon: Icon(
                    _isSearchExpanded ? Icons.close : Icons.search,
                    color: (_isSearchExpanded || _searchController.text.isNotEmpty)
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    size: 21,
                  ),
                  tooltip: isThai ? 'ค้นหา' : 'Search',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      _isSearchExpanded = !_isSearchExpanded;
                      if (!_isSearchExpanded && _searchController.text.isNotEmpty) {
                        _searchController.clear();
                        _loadTransactions();
                      }
                    });
                  },
                ),
                // Filter button
                IconButton(
                  icon: Icon(
                    Icons.filter_list,
                    color: (_selectedAccountId != null || _selectedCategoryId != null || _selectedDateRange != null)
                        ? Theme.of(context).colorScheme.primary
                        : null,
                    size: 21,
                  ),
                  onPressed: _showFilterDialog,
                  tooltip: isThai ? 'ตัวกรอง' : 'Filter',
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),

          // Animated Search Bar (only when expanded or active query)
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: (_isSearchExpanded || _searchController.text.isNotEmpty)
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: isThai ? 'ค้นหาบันทึกย่อ หรือ tag...' : 'Search notes or tags...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadTransactions();
                                },
                              )
                            : null,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: (_) => _loadTransactions(),
                    ),
                  )
                : const SizedBox.shrink(),
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
                      onDeleted: () {
                        setState(() => _selectedDateRange = null);
                        _loadTransactions();
                      },
                    ),
                  if (_selectedAccountId != null)
                    Chip(
                      label: Text(isThai ? 'บัญชีที่เลือก' : 'Selected Account'),
                      onDeleted: () {
                        setState(() => _selectedAccountId = null);
                        _loadTransactions();
                      },
                    ),
                  if (_selectedCategoryId != null)
                    Chip(
                      label: Text(isThai ? 'หมวดหมู่ที่เลือก' : 'Selected Category'),
                      onDeleted: () {
                        setState(() => _selectedCategoryId = null);
                        _loadTransactions();
                      },
                    ),
                ],
              ),
            ),

          // Transaction list
          Expanded(
            child: Builder(
              builder: (context) {
                if (_isLoading && _transactions == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                final transactions = _transactions ?? [];
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          isThai ? 'ไม่พบรายการที่ตรงกับเงื่อนไข' : 'No transactions found',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  );
                }

                // Group transactions by date
                final grouped = <DateTime, List<Transaction>>{};
                for (final tx in transactions) {
                  final localDate = tx.transactionDate.toLocal();
                  final d = DateTime(localDate.year, localDate.month, localDate.day);
                  grouped.putIfAbsent(d, () => []).add(tx);
                }
                final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  key: const PageStorageKey('transaction_list_scroll_key'),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, dateIndex) {
                    final date = sortedDates[dateIndex];
                    final dayTxs = grouped[date]!;

                    int dailyNetSatang = dayTxs.fold(0, (sum, tx) {
                      if (tx.transactionType == 'income') {
                        if (!tx.isCleared) return sum;
                        return sum + tx.amountThbSatang;
                      }
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
                                _formatDateHeader(date, isThai),
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
                              return _buildTransactionTile(context, tx, isThai);
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
      onSelected: (_) {
        setState(() => _selectedType = value);
        _loadTransactions();
      },
      showCheckmark: false,
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.1),
      side: BorderSide(color: chipColor.withValues(alpha: isSelected ? 1.0 : 0.4), width: isSelected ? 1.5 : 1.0),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  String _formatDateHeader(DateTime date, bool isThai) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) return isThai ? 'วันนี้' : 'Today';
    if (date == yesterday) return isThai ? 'เมื่อวานนี้' : 'Yesterday';
    return DateFormat('d MMMM yyyy', isThai ? 'th_TH' : 'en_US').format(date);
  }

  Widget _buildTransactionTile(BuildContext context, Transaction tx, bool isThai) {
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

    final defaultNote = isExpense
        ? (isThai ? 'รายจ่าย' : 'Expense')
        : (isIncome ? (isThai ? 'รายรับ' : 'Income') : (isThai ? 'โอนเงิน' : 'Transfer'));

    final sourceAcc = tx.sourceAccountId != null ? _accountsMap[tx.sourceAccountId] : null;
    final isCredit = sourceAcc?.accountType == 'credit_card';

    Widget? subtitleWidget;
    final List<Widget> subBadges = [];

    // Credit Card badge (Item 5)
    if (isCredit) {
      subBadges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.blue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.credit_card_rounded, size: 11, color: Colors.blue),
              const SizedBox(width: 3),
              Text(
                sourceAcc?.name ?? (isThai ? 'บัตรเครดิต' : 'Credit'),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
        ),
      );
    }

    if (isIncome && !tx.isCleared) {
      subBadges.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tx.workPeriod != null ? 'ค้างรับ (${tx.workPeriod})' : 'ค้างรับ/ตกเบิก',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade900,
            ),
          ),
        ),
      );
    }

    if (subBadges.isNotEmpty) {
      subtitleWidget = Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Wrap(
          spacing: 6,
          runSpacing: 4,
          children: subBadges,
        ),
      );
    }

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
        tx.note?.isNotEmpty == true ? tx.note! : defaultNote,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: subtitleWidget,
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
              '${isThai ? "ค่าธรรมเนียม" : "Fee"}: ${Money(tx.feeThbSatang).format(symbol: '฿')}',
              style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurfaceVariant),
            ),
        ],
      ),
      onTap: () async {
        final changed = await EditTransactionDialog.show(context, tx);
        if (changed == true && mounted) {
          _loadTransactions();
        }
      },
      onLongPress: () => _confirmDelete(tx, isThai),
    );
  }

  Future<void> _confirmDelete(Transaction tx, bool isThai) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ลบรายการ' : 'Delete Transaction'),
        content: Text(isThai
            ? 'คุณต้องการลบรายการนี้ใช่หรือไม่? (การลบจะถูกบันทึกลง Audit Log)'
            : 'Are you sure you want to delete this transaction? (Will be recorded in Audit Log)'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ลบรายการ' : 'Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Optimistic in-place removal: immediate visual update, no spinner, scroll preserved
      setState(() {
        _transactions?.removeWhere((t) => t.id == tx.id);
      });
      await ref.read(transactionsDaoProvider).softDeleteTransaction(tx.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'ลบรายการเรียบร้อยแล้ว' : 'Transaction deleted')),
        );
      }
    }
  }

  Widget _buildModalTypeChip({
    required String label,
    required String? value,
    required bool isSelected,
    required IconData icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    final chipColor = color ?? Theme.of(context).colorScheme.primary;
    return ChoiceChip(
      avatar: Icon(
        icon,
        size: 15,
        color: isSelected ? Colors.white : chipColor,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: chipColor,
      backgroundColor: chipColor.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  Future<void> _showFilterDialog() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
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
            final activeType = _selectedType;

            // Filter categories according to activeType (Item 4)
            final availableCategories = categories.where((c) {
              if (activeType == null) return true;
              if (activeType == 'transfer') return false;
              return c.categoryType == activeType;
            }).toList();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isThai ? 'ตัวกรองข้อมูล' : 'Filter Transactions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),

                  // 1. Transaction Type Selector First! (Item 4)
                  Text(
                    isThai ? '1. เลือกประเภทรายการ' : '1. Transaction Type',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildModalTypeChip(
                          label: isThai ? 'ทั้งหมด' : 'All',
                          value: null,
                          isSelected: _selectedType == null,
                          icon: Icons.list_alt_rounded,
                          onTap: () {
                            setModalState(() {
                              _selectedType = null;
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildModalTypeChip(
                          label: isThai ? 'รายจ่าย' : 'Expense',
                          value: 'expense',
                          isSelected: _selectedType == 'expense',
                          icon: Icons.arrow_upward_rounded,
                          color: Colors.red,
                          onTap: () {
                            setModalState(() {
                              _selectedType = 'expense';
                              if (_selectedCategoryId != null &&
                                  !categories.any((c) => c.id == _selectedCategoryId && c.categoryType == 'expense')) {
                                _selectedCategoryId = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildModalTypeChip(
                          label: isThai ? 'รายรับ' : 'Income',
                          value: 'income',
                          isSelected: _selectedType == 'income',
                          icon: Icons.arrow_downward_rounded,
                          color: Colors.green,
                          onTap: () {
                            setModalState(() {
                              _selectedType = 'income';
                              if (_selectedCategoryId != null &&
                                  !categories.any((c) => c.id == _selectedCategoryId && c.categoryType == 'income')) {
                                _selectedCategoryId = null;
                              }
                            });
                          },
                        ),
                        const SizedBox(width: 6),
                        _buildModalTypeChip(
                          label: isThai ? 'โอนเงิน' : 'Transfer',
                          value: 'transfer',
                          isSelected: _selectedType == 'transfer',
                          icon: Icons.swap_horiz_rounded,
                          color: Colors.blueGrey,
                          onTap: () {
                            setModalState(() {
                              _selectedType = 'transfer';
                              _selectedCategoryId = null;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Category Dropdown filtered by Type! (Item 4)
                  if (activeType == 'transfer')
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                          const SizedBox(width: 8),
                          Text(
                            isThai ? 'รายการโอนเงินไม่มีการจัดหมวดหมู่' : 'Transfers do not have categories',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    )
                  else
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: isThai
                            ? (activeType == 'expense'
                                ? '2. เลือกหมวดหมู่รายจ่าย'
                                : (activeType == 'income' ? '2. เลือกหมวดหมู่รายรับ' : '2. เลือกหมวดหมู่'))
                            : '2. Filter by Category',
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      initialValue: availableCategories.any((c) => c.id == _selectedCategoryId) ? _selectedCategoryId : null,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(isThai
                              ? (activeType == null ? 'ทุกหมวดหมู่' : 'ทุกหมวดในประเภทนี้')
                              : 'All Categories'),
                        ),
                        ...availableCategories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.localizedName(context)))),
                      ],
                      onChanged: (val) => setModalState(() => _selectedCategoryId = val),
                    ),
                  const SizedBox(height: 12),

                  // 3. Account dropdown
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: isThai ? '3. กรองตามบัญชี' : '3. Filter by Account',
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    initialValue: _selectedAccountId,
                    items: [
                      DropdownMenuItem(value: null, child: Text(isThai ? 'ทุกบัญชี' : 'All Accounts')),
                      ...accounts.map((a) => DropdownMenuItem(value: a.id, child: Text(a.name))),
                    ],
                    onChanged: (val) => setModalState(() => _selectedAccountId = val),
                  ),
                  const SizedBox(height: 12),

                  // 4. Date range picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.date_range),
                    title: Text(
                      _selectedDateRange == null
                          ? (isThai ? 'เลือกช่วงวันที่' : 'Select Date Range')
                          : '${DateFormat('d/M/y').format(_selectedDateRange!.start)} - ${DateFormat('d/M/y').format(_selectedDateRange!.end)}',
                    ),
                    trailing: _selectedDateRange != null
                        ? IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setModalState(() => _selectedDateRange = null),
                          )
                        : null,
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
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedDateRange = null;
                              _selectedAccountId = null;
                              _selectedCategoryId = null;
                              _selectedType = null;
                            });
                            setState(() {});
                            _loadTransactions();
                          },
                          child: Text(isThai ? 'ล้างตัวกรองทั้งหมด' : 'Clear Filters'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            setState(() {});
                            _loadTransactions();
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
