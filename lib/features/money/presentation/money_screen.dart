import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../transactions/presentation/transaction_list_screen.dart';
import '../../accounts/presentation/accounts_screen.dart';
import '../../budget/presentation/budget_screen.dart';
import '../../summary/presentation/monthly_summary_screen.dart';

class MoneyScreen extends ConsumerStatefulWidget {
  final int initialTabIndex;
  final ValueChanged<int>? onTabChanged;

  const MoneyScreen({
    super.key,
    this.initialTabIndex = 0,
    this.onTabChanged,
  });

  @override
  ConsumerState<MoneyScreen> createState() => _MoneyScreenState();
}

class _MoneyScreenState extends ConsumerState<MoneyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int? _lastReportedIndex;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialTabIndex.clamp(0, 2);
    _lastReportedIndex = initial;
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initial,
    );
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.index != _lastReportedIndex) {
      _lastReportedIndex = _tabController.index;
      widget.onTabChanged?.call(_tabController.index);
    }
  }

  @override
  void didUpdateWidget(MoneyScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTabIndex != widget.initialTabIndex) {
      final newIndex = widget.initialTabIndex.clamp(0, 2);
      _lastReportedIndex = newIndex;
      _tabController.animateTo(newIndex);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = VaultTheme.accent(context);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          'MONEY',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'สรุปภาพรวมรายเดือน',
            color: VaultTheme.secondaryText(context),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: accentColor,
          unselectedLabelColor: VaultTheme.secondaryText(context),
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'รายการ (Transactions)'),
            Tab(text: 'บัญชี (Accounts)'),
            Tab(text: 'งบประมาณ & โครงการ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          TransactionListScreen(),
          AccountsScreen(),
          BudgetScreen(),
        ],
      ),
    );
  }
}
