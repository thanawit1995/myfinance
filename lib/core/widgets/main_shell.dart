import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import '../security/auth_provider.dart';
import '../theme/app_theme_style.dart';
import '../theme/vault_theme.dart';
import 'pin_lock_dialog.dart';
import '../../features/home/presentation/vault_home_screen.dart';
import '../../features/money/presentation/money_screen.dart';
import '../../features/investments/presentation/portfolio_screen.dart';
import '../../features/plan/presentation/plan_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/transactions/presentation/quick_add_screen.dart';
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

class _MainShellState extends ConsumerState<MainShell> with WidgetsBindingObserver {
  int _currentIndex = 0;
  int _moneyInitialTabIndex = 0;
  int _moneyActiveSubTab = 0;
  DateTime? _pausedTime;
  DateTime? _lastBackPressTime;
  bool _isPromptingUnlock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Check PIN / Biometrics on app launch and process recurring rules
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _checkAppLockOnStartup();

      try {
        await ref.read(recurringTransactionsDaoProvider).processDueRules();
      } catch (e) {
        debugPrint('Error processing recurring rules: $e');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      _checkResumeLock();
    }
  }

  Future<void> _checkAppLockOnStartup() async {
    final auth = ref.read(authServiceProvider);
    final isPinLockOn = await auth.isPinLockEnabled();
    if (isPinLockOn && !auth.isSessionUnlocked && mounted) {
      await _promptAppUnlock(canCancel: false);
    }
  }

  Future<void> _checkResumeLock() async {
    final auth = ref.read(authServiceProvider);
    final isPinLockOn = await auth.isPinLockEnabled();
    if (!isPinLockOn) return;

    if (_pausedTime != null) {
      final timeoutMinutes = await auth.getSessionTimeoutMinutes();
      final elapsed = DateTime.now().difference(_pausedTime!);
      if (elapsed.inMinutes >= timeoutMinutes) {
        auth.lockSession();
      }
    }

    if (!auth.isSessionUnlocked && mounted) {
      await _promptAppUnlock(canCancel: false);
    }
  }

  Future<void> _promptAppUnlock({bool canCancel = true}) async {
    if (_isPromptingUnlock) return;
    _isPromptingUnlock = true;
    try {
      final auth = ref.read(authServiceProvider);
      // 1. Try Biometrics first if enabled
      final isBioEnabled = await auth.isBiometricsEnabled();
      if (isBioEnabled) {
        final success = await auth.authenticateBiometric();
        if (success) {
          if (mounted) setState(() {});
          return;
        }
      }

      // 2. Fall back to PIN dialog
      if (!auth.isSessionUnlocked && mounted) {
        await PinLockDialog.show(context, canCancel: canCancel);
      }
    } finally {
      _isPromptingUnlock = false;
      if (mounted) setState(() {});
    }
  }

  Future<void> _onTabSelected(int index, {int moneyTabIndex = 0}) async {
    final auth = ref.read(authServiceProvider);
    final isPinLockOn = await auth.isPinLockEnabled();

    if (isPinLockOn && !auth.isSessionUnlocked) {
      if (!mounted) return;
      await _promptAppUnlock(canCancel: false);
      if (!auth.isSessionUnlocked) {
        return;
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

    final isLumi = VaultTheme.isLumi(context);

    final screens = [
      VaultHomeScreen(
        onNavigateToMoney: () => _onTabSelected(1, moneyTabIndex: 0),
        onNavigateToInvest: () => _onTabSelected(2),
        onNavigateToBudget: () => _onTabSelected(1, moneyTabIndex: 2),
        onNavigateToCreditCards: () => _onTabSelected(1, moneyTabIndex: 1),
        onNavigateToPlan: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PlanScreen()),
          );
        },
        onOpenSettings: () => _onTabSelected(3),
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
      SettingsScreen(
        currentLocale: widget.currentLocale,
        onLocaleChanged: widget.onLocaleChanged,
        currentThemeMode: widget.currentThemeMode,
        onThemeModeChanged: widget.onThemeModeChanged,
        currentThemeStyle: widget.currentThemeStyle,
        onThemeStyleChanged: widget.onThemeStyleChanged,
      ),
    ];

    final bgCol = VaultTheme.background(context);
    final overlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: bgCol,
      systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    );

    final Widget shellLayout;

    if (isWide) {
      // Desktop layout with NavigationRail
      shellLayout = AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          backgroundColor: VaultTheme.background(context),
          body: Row(
            children: [
              NavigationRail(
                minWidth: isLumi ? 92 : 76,
                backgroundColor: isLumi ? (isDark ? VaultTheme.surface(context) : const Color(0xFFFFF9F5)) : VaultTheme.surface(context),
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabSelected,
                labelType: NavigationRailLabelType.all,
                indicatorColor: isLumi
                    ? (isDark ? const Color(0xFFFF75A9).withValues(alpha: 0.25) : const Color(0xFFFFE5F2))
                    : accentCol.withValues(alpha: 0.15),
                indicatorShape: isLumi
                    ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))
                    : null,
                selectedIconTheme: IconThemeData(
                  color: isLumi ? (isDark ? const Color(0xFFFF75A9) : const Color(0xFFFF5B9A)) : accentCol,
                ),
                unselectedIconTheme: IconThemeData(
                  color: isLumi ? (isDark ? const Color(0xFFBDB2C4) : const Color(0xFF87767F)) : VaultTheme.secondaryText(context),
                ),
                selectedLabelTextStyle: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  color: isLumi ? (isDark ? const Color(0xFFFF75A9) : const Color(0xFFFF5B9A)) : accentCol,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  color: isLumi ? (isDark ? const Color(0xFFBDB2C4) : const Color(0xFF87767F)) : VaultTheme.secondaryText(context),
                  fontSize: 12,
                ),
                leading: Padding(
                  padding: EdgeInsets.symmetric(vertical: isLumi ? 14 : 18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isLumi
                                ? const Color(0xFFFF5B9A).withValues(alpha: 0.35)
                                : accentCol.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_logo.png',
                            width: 42,
                            height: 42,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Icon(
                              isLumi ? Icons.favorite_rounded : Icons.all_inclusive_rounded,
                              color: isLumi ? const Color(0xFFFF5B9A) : accentCol,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'OURS',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: isLumi ? 13 : 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: isLumi ? 0.8 : 1.5,
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
                      const SizedBox(height: 12),
                      IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: isLumi ? const Color(0xFFFF5B9A) : accentCol,
                          foregroundColor: Colors.white,
                        ),
                        tooltip: l10n?.quickAddKeypad ?? 'Quick Add',
                        icon: const Icon(Icons.add, size: 20),
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const QuickAddScreen(initialType: 'expense'),
                            ),
                          );
                          if (mounted) setState(() {});
                        },
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
                    icon: const Icon(Icons.more_horiz_rounded),
                    selectedIcon: const Icon(Icons.more_horiz_rounded),
                    label: Text(l10n?.more ?? 'More'),
                  ),
                ],
              ),
              VerticalDivider(thickness: 0.75, width: 1, color: VaultTheme.border(context)),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentIndex),
                    child: screens[_currentIndex],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Mobile layout with Center Quick Add Button
      shellLayout = AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Scaffold(
          backgroundColor: VaultTheme.background(context),
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey<int>(_currentIndex),
              child: screens[_currentIndex],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: VaultTheme.surface(context),
              border: Border(top: BorderSide(color: VaultTheme.border(context), width: 0.75)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 60,
                child: Row(
                  children: [
                    _buildNavItem(
                      context,
                      icon: Icons.home_outlined,
                      selectedIcon: Icons.home_rounded,
                      label: l10n?.home ?? 'Home',
                      isSelected: _currentIndex == 0,
                      onTap: () => _onTabSelected(0),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.account_balance_wallet_outlined,
                      selectedIcon: Icons.account_balance_wallet_rounded,
                      label: l10n?.money ?? 'Money',
                      isSelected: _currentIndex == 1,
                      onTap: () => _onTabSelected(1),
                    ),
                    Expanded(
                      child: Center(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const QuickAddScreen(initialType: 'expense'),
                                ),
                              );
                              if (mounted) setState(() {});
                            },
                            borderRadius: BorderRadius.circular(24),
                            child: Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: isLumi ? const Color(0xFFFF5B9A) : accentCol,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isLumi ? const Color(0xFFFF5B9A) : accentCol).withValues(alpha: 0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.show_chart_rounded,
                      selectedIcon: Icons.show_chart_rounded,
                      label: l10n?.invest ?? 'Invest',
                      isSelected: _currentIndex == 2,
                      onTap: () => _onTabSelected(2),
                    ),
                    _buildNavItem(
                      context,
                      icon: Icons.more_horiz_rounded,
                      selectedIcon: Icons.more_horiz_rounded,
                      label: l10n?.more ?? 'More',
                      isSelected: _currentIndex == 3,
                      onTap: () => _onTabSelected(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

  final isThai = widget.currentLocale.languageCode == 'th';

  return PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (didPop) return;
      final now = DateTime.now();
      if (_lastBackPressTime == null || now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
        _lastBackPressTime = now;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isThai ? 'ปัดหรือกดย้อนกลับอีกครั้งเพื่อออกจากแอป' : 'Press or swipe back again to exit',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        SystemNavigator.pop();
      }
    },
    child: shellLayout,
  );
}

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentCol = VaultTheme.accent(context);
    final isLumi = VaultTheme.isLumi(context);
    final activeColor = isLumi ? const Color(0xFFFF5B9A) : accentCol;
    final inactiveColor = VaultTheme.secondaryText(context);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        splashColor: activeColor.withValues(alpha: 0.1),
        highlightColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
              decoration: BoxDecoration(
                color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                size: 22,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                color: isSelected ? activeColor : inactiveColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
