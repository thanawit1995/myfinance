import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import '../security/auth_provider.dart';
import '../theme/app_theme_style.dart';
import '../theme/vault_theme.dart';
import 'pin_lock_dialog.dart';
import 'vault_add_sheet.dart';
import '../../features/home/presentation/vault_home_screen.dart';
import '../../features/money/presentation/money_screen.dart';
import '../../features/investments/presentation/portfolio_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../l10n/app_localizations.dart';

class MainShell extends ConsumerStatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppThemeStyle currentThemeStyle;
  final ValueChanged<AppThemeStyle>? onThemeStyleChanged;

  const MainShell({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.currentThemeStyle = AppThemeStyle.vault,
    this.onThemeStyleChanged,
  });

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _currentIndex = 0;
  int _moneyInitialTabIndex = 0;
  int _moneyActiveSubTab = 0;

  @override
  void initState() {
    super.initState();
    // Process recurring transactions due on app launch in the background
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(recurringTransactionsDaoProvider).processDueRules();
      } catch (e) {
        debugPrint('Error processing recurring rules: $e');
      }
    });
  }

  Future<void> _onTabSelected(int index, {int moneyTabIndex = 0}) async {
    // Tab 0 (Home) is accessible; other tabs require PIN if lock is enabled
    final isProtected = index != 0;

    if (isProtected) {
      final auth = ref.read(authServiceProvider);
      final isPinLockOn = await auth.isPinLockEnabled();

      if (isPinLockOn && !auth.isSessionUnlocked) {
        if (!mounted) return;
        final unlocked = await PinLockDialog.show(context);
        if (!unlocked) {
          // Did not unlock, stay on current tab
          return;
        }
      }
    }

    setState(() {
      _currentIndex = index;
      if (index == 1) {
        _moneyInitialTabIndex = moneyTabIndex;
        _moneyActiveSubTab = moneyTabIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= 720;
    final l10n = AppLocalizations.of(context);
    final accentCol = VaultTheme.accent(context);
    final isDark = VaultTheme.isDark(context);

    final screens = [
      VaultHomeScreen(
        onNavigateToMoney: () => _onTabSelected(1, moneyTabIndex: 0),
        onNavigateToInvest: () => _onTabSelected(2),
        onNavigateToBudget: () => _onTabSelected(1, moneyTabIndex: 2),
        onNavigateToCreditCards: () => _onTabSelected(1, moneyTabIndex: 1),
        onNavigateToPlan: () => _onTabSelected(3),
        onOpenSettings: () => _onTabSelected(4),
      ),
      MoneyScreen(
        initialTabIndex: _moneyInitialTabIndex,
        onTabChanged: (subIndex) {
          if (_moneyActiveSubTab != subIndex) {
            setState(() {
              _moneyActiveSubTab = subIndex;
            });
          }
        },
      ),
      const PortfolioScreen(),
      const PlanScreen(),
      SettingsScreen(
        currentLocale: widget.currentLocale,
        onLocaleChanged: widget.onLocaleChanged,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeStyle: widget.currentThemeStyle,
        onThemeStyleChanged: widget.onThemeStyleChanged,
      ),
    ];

    // ซ่อนปุ่มบันทึกรายรับ-จ่ายออกจากทุกด้าน ให้แสดงเฉพาะในหน้า Home และ Money-Transactions (2 หน้าเท่านั้น)
    final showFab = _currentIndex == 0 || (_currentIndex == 1 && _moneyActiveSubTab == 0);
    final isLumi = VaultTheme.isLumi(context);

    final fab = showFab
        ? FloatingActionButton.extended(
            onPressed: () => VaultAddSheet.show(context),
            backgroundColor: isLumi ? const Color(0xFFFF5B9A) : accentCol,
            foregroundColor: isLumi ? Colors.white : (isDark ? const Color(0xFF111315) : Colors.white),
            elevation: isLumi ? 3 : 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLumi ? 20 : 14)),
            icon: const Icon(Icons.add, size: 20),
            label: Text(
              l10n?.add ?? 'Add',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          )
        : null;

    if (isWide) {
      // Desktop layout with NavigationRail
      return Scaffold(
        backgroundColor: VaultTheme.background(context),
        floatingActionButton: fab,
        body: Row(
          children: [
            NavigationRail(
              minWidth: isLumi ? 92 : 72,
              backgroundColor: isLumi ? const Color(0xFFFFF9F5) : VaultTheme.surface(context),
              selectedIndex: _currentIndex,
              onDestinationSelected: _onTabSelected,
              labelType: NavigationRailLabelType.all,
              indicatorColor: isLumi ? const Color(0xFFFFE5F2) : accentCol.withValues(alpha: 0.15),
              indicatorShape: isLumi
                  ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                  : null,
              selectedIconTheme: IconThemeData(
                color: isLumi ? const Color(0xFFFF5B9A) : accentCol,
              ),
              unselectedIconTheme: IconThemeData(
                color: isLumi ? const Color(0xFF87767F) : VaultTheme.secondaryText(context),
              ),
              selectedLabelTextStyle: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                color: isLumi ? const Color(0xFFFF5B9A) : accentCol,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
              unselectedLabelTextStyle: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                color: isLumi ? const Color(0xFF87767F) : VaultTheme.secondaryText(context),
                fontSize: 12,
              ),
              leading: Padding(
                padding: EdgeInsets.symmetric(vertical: isLumi ? 14 : 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLumi) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF0F5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFFF5B9A).withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/lumi_mascot.png',
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Icon(
                              Icons.favorite_rounded,
                              color: Color(0xFFFF5B9A),
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    Text(
                      'JP Money',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: isLumi ? 13 : 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: isLumi ? 0.5 : 1.5,
                        color: VaultTheme.primaryText(context),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: isLumi
                            ? const Color(0xFFFF5B9A).withValues(alpha: 0.15)
                            : accentCol.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isLumi ? 'LUMI' : 'VAULT',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: isLumi ? const Color(0xFFFF5B9A) : accentCol,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home_outlined),
                  selectedIcon: const Icon(Icons.home_rounded),
                  label: Text(l10n?.home ?? 'Home'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: const Icon(Icons.account_balance_wallet_rounded),
                  label: Text(l10n?.money ?? 'Money'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.show_chart_rounded),
                  selectedIcon: const Icon(Icons.show_chart_rounded),
                  label: Text(l10n?.invest ?? 'Invest'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.architecture_rounded),
                  selectedIcon: const Icon(Icons.architecture_rounded),
                  label: Text(l10n?.plan ?? 'Plan'),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.more_horiz_rounded),
                  selectedIcon: const Icon(Icons.more_horiz_rounded),
                  label: Text(l10n?.more ?? 'More'),
                ),
              ],
            ),
            VerticalDivider(thickness: 0.75, width: 1, color: VaultTheme.border(context)),
            Expanded(child: screens[_currentIndex]),
          ],
        ),
      );
    } else {
      // Mobile layout with 5-destination NavigationBar
      return Scaffold(
        backgroundColor: VaultTheme.background(context),
        body: screens[_currentIndex],
        floatingActionButton: fab,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: VaultTheme.border(context), width: 0.75)),
          ),
          child: NavigationBar(
            backgroundColor: VaultTheme.surface(context),
            surfaceTintColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: _onTabSelected,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            indicatorColor: accentCol.withValues(alpha: 0.15),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded, color: accentCol),
                label: l10n?.home ?? 'Home',
              ),
              NavigationDestination(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: accentCol),
                label: l10n?.money ?? 'Money',
              ),
              NavigationDestination(
                icon: const Icon(Icons.show_chart_rounded),
                selectedIcon: Icon(Icons.show_chart_rounded, color: accentCol),
                label: l10n?.invest ?? 'Invest',
              ),
              NavigationDestination(
                icon: const Icon(Icons.architecture_rounded),
                selectedIcon: Icon(Icons.architecture_rounded, color: accentCol),
                label: l10n?.plan ?? 'Plan',
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz_rounded),
                selectedIcon: Icon(Icons.more_horiz_rounded, color: accentCol),
                label: l10n?.more ?? 'More',
              ),
            ],
          ),
        ),
      );
    }
  }
}
