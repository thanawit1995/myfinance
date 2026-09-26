import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../transactions/presentation/transaction_list_screen.dart';
import '../../accounts/presentation/accounts_screen.dart';
import '../../budget/presentation/budget_screen.dart';

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

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          (l10n?.money ?? 'MONEY').toUpperCase(),
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: accentColor,
          labelColor: accentColor,
          unselectedLabelColor: VaultTheme.secondaryText(context),
          indicatorSize: TabBarIndicatorSize.tab,
          tabAlignment: TabAlignment.fill,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          labelStyle: const TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
          tabs: [
            Tab(text: l10n?.transactions ?? 'Transactions'),
            Tab(text: l10n?.accounts ?? 'Accounts'),
            Tab(text: l10n?.budgetTab ?? 'Budget'),
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
