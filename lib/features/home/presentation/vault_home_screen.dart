import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/money/money.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/database/daos/investments_dao.dart';
import '../../../../core/widgets/vault_add_sheet.dart';
import '../../summary/presentation/monthly_summary_screen.dart';
import '../../../../l10n/app_localizations.dart';
import 'widgets/lumi/lumi_desktop_layout.dart';

class VaultHomeScreen extends ConsumerWidget {
  final VoidCallback onNavigateToMoney;
  final VoidCallback onNavigateToInvest;
  final VoidCallback onNavigateToBudget;
  final VoidCallback onNavigateToCreditCards;
  final VoidCallback? onNavigateToPlan;
  final VoidCallback onOpenSettings;

  const VaultHomeScreen({
    super.key,
    required this.onNavigateToMoney,
    required this.onNavigateToInvest,
    required this.onNavigateToBudget,
    required this.onNavigateToCreditCards,
    this.onNavigateToPlan,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(transactionsVersionProvider);
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      body: SafeArea(
        child: RefreshIndicator(
          color: VaultTheme.accent(context),
          backgroundColor: VaultTheme.surface(context),
          onRefresh: () async {
            ref.invalidate(accountsDaoProvider);
            ref.invalidate(transactionsDaoProvider);
            ref.invalidate(investmentsDaoProvider);
            ref.invalidate(budgetsDaoProvider);
          },
          child: FutureBuilder<_VaultHomeData>(
            future: _loadHomeData(ref, now, context),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(color: VaultTheme.accent(context)),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snapshot.error}',
                    style: TextStyle(color: VaultTheme.negative(context)),
                  ),
                );
              }

              final data = snapshot.data!;
              final isLumi = VaultTheme.isLumi(context);

              if (isLumi) {
                final bundle = LumiHomeDataBundle(
                  netWorthSatang: data.netWorthSatang,
                  momChangePercent: data.momChangePercent,
                  cashFlowMonthSatang: data.cashFlowMonthSatang,
                  totalIncomeSatang: data.totalIncomeMonthSatang,
                  totalExpenseSatang: data.totalExpenseMonthSatang,
                  remainingBudgetSatang: data.remainingBudgetSatang,
                  totalBudgetSatang: data.totalBudgetMonthSatang,
                  portfolioValueSatang: data.portfolioValueSatang,
                  portfolioReturnPercent: data.portfolioReturnPercent,
                  creditCardCurrentDebtSatang: data.creditCardCurrentDebtSatang,
                  creditCardNextCloseText: data.creditCardNextCloseText,
                  recentTransactions: data.recentTransactions,
                  attentionMessage: data.attentionMessage,
                  attentionIsWarning: data.attentionIsWarning,
                );

                return LumiDesktopLayout(
                  data: bundle,
                  headerWidget: _buildHeader(context, now),
                  onNavigateToBudget: onNavigateToBudget,
                  onNavigateToMoney: onNavigateToMoney,
                  onNavigateToInvest: onNavigateToInvest,
                  onNavigateToCreditCards: onNavigateToCreditCards,
                  onNavigateToPlan: onNavigateToPlan ?? onNavigateToBudget,
                  onViewMonthlySummary: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
                    );
                  },
                  onAddTransaction: () {
                    VaultAddSheet.show(
                      context,
                      onNavigateToTransactions: onNavigateToMoney,
                    );
                  },
                );
              }

              // VAULT Mode: Quiet Luxury single-column dashboard
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                children: [
                  // 1. Header: OURS + เดือนปัจจุบัน + ไอคอนค้นหาและตั้งค่า
                  _buildHeader(context, now),
                  const SizedBox(height: 20),

                  // 2. Master Budget — Hero card เดียวของหน้า
                  _buildMasterBudgetCard(context, data, now),
                  const SizedBox(height: 16),

                  // 3. Today / Attention — แสดงเฉพาะสิ่งที่ต้องตัดสินใจหรือควรรู้
                  _buildAttentionCard(context, data),
                  const SizedBox(height: 20),

                  // 4. Financial Position — Net Worth เด่นคู่กับแนวโน้ม vs last month
                  _buildFinancialPosition(context, data),
                  const SizedBox(height: 16),

                  // 5. Snapshot — แถวเดียว 2 ช่อง: Portfolio และ Credit Card
                  _buildSnapshotRow(context, data),
                  const SizedBox(height: 24),

                  // 6. Recent Activity — แสดง 3 รายการล่าสุดเท่านั้น
                  _buildRecentActivity(context, data),
                  const SizedBox(height: 80), // เว้นพื้นที่สำหรับปุ่มลอย FAB
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // --- 1. Quiet Luxury Header ---
  Widget _buildHeader(BuildContext context, DateTime now) {
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final monthName = isThai
        ? _getThaiMonth(now.month)
        : DateFormat('MMMM').format(now);
    final yearStr = now.year.toString();
    final isLumi = VaultTheme.isLumi(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isLumi)
          Expanded(
            child: Row(
              children: [
                // Avatar badge
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF5C9D).withValues(alpha: 0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFFFD1E3), width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/lumi_cat_crisp.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.pets_rounded,
                        color: Color(0xFFFF5C9D),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        now.hour < 12
                            ? (l10n?.morningGreeting ?? 'Good morning ☀️')
                            : (now.hour < 18
                                ? (l10n?.afternoonGreeting ?? 'Good afternoon 🌤️')
                                : (l10n?.eveningGreeting ?? 'Good evening 🌙')),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'OURS • Lumi • $monthName $yearStr',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 12,
                          color: VaultTheme.secondaryText(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: VaultTheme.accent(context).withValues(alpha: 0.35), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'OURS',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          color: VaultTheme.primaryText(context),
                        ),
                      ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: VaultTheme.accent(context).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'VAULT',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                        color: VaultTheme.accent(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Our money, our journey. • $monthName $yearStr',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 12,
                  letterSpacing: 0.3,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
            ],
          ),
        ],
      ),
        Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.search_rounded,
                size: 22,
                color: VaultTheme.secondaryText(context),
              ),
              onPressed: onNavigateToMoney,
              tooltip: l10n?.searchTransactions ?? 'ค้นหาธุรกรรม',
            ),
            IconButton(
              icon: Icon(
                Icons.tune_rounded,
                size: 22,
                color: VaultTheme.secondaryText(context),
              ),
              onPressed: onOpenSettings,
              tooltip: l10n?.settingsAndSecurity ?? 'การตั้งค่าและระบบความปลอดภัย',
            ),
          ],
        ),
      ],
    );
  }

  // --- 2. Master Budget Hero Card ---
  Widget _buildMasterBudgetCard(BuildContext context, _VaultHomeData data, DateTime now) {
    final l10n = AppLocalizations.of(context);
    final remainingSatang = data.remainingBudgetSatang;
    final totalBudgetSatang = data.totalBudgetMonthSatang;
    final totalExpenseSatang = data.totalExpenseMonthSatang;
    final hasBudget = totalBudgetSatang > 0;

    final percentRemaining = hasBudget
        ? ((remainingSatang / totalBudgetSatang) * 100).clamp(0, 100).toInt()
        : 100;

    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysRemaining = (daysInMonth - now.day).clamp(0, daysInMonth);

    final isWarning = hasBudget && percentRemaining < 20;
    final progressRatio = hasBudget
        ? (totalExpenseSatang / totalBudgetSatang).clamp(0.0, 1.0)
        : 0.0;

    final isLumi = VaultTheme.isLumi(context);
    final ext = VaultTheme.extension(context);
    final cardRadius = isLumi ? 24.0 : 16.0;

    return InkWell(
      onTap: onNavigateToBudget,
      borderRadius: BorderRadius.circular(cardRadius),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: isLumi ? ext?.masterBudgetGradient : null,
          color: isLumi ? null : VaultTheme.surface(context),
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: isLumi
              ? [
                  BoxShadow(
                    color: const Color(0xFFFF5C9D).withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
          border: Border.all(
            color: isWarning
                ? VaultTheme.negative(context).withValues(alpha: 0.4)
                : (isLumi ? const Color(0xFFFF5C9D).withValues(alpha: 0.25) : VaultTheme.border(context)),
            width: isLumi ? 1.0 : 0.75,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isLumi
                        ? (l10n?.availableToSpendLumi ?? 'เงินที่ใช้ได้ในเดือนนี้ 🌸')
                        : (l10n?.masterBudget ?? 'MASTER BUDGET'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: isLumi ? 13 : 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: isLumi ? 0.3 : 1.2,
                      color: isLumi ? const Color(0xFF8A3052) : VaultTheme.secondaryText(context),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  l10n?.daysRemainingInCycle(daysRemaining) ?? '$daysRemaining วันที่เหลือในรอบเดือน',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 12,
                    color: isLumi ? const Color(0xFF8A3052) : VaultTheme.mutedText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (!hasBudget) ...[
              // Friendly state when budget has not been set yet
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.noBudgetSet ?? 'ยังไม่ได้ตั้งงบประมาณเดือนนี้',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isLumi ? const Color(0xFF2B2338) : VaultTheme.primaryText(context),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${l10n?.usedSoFar ?? 'ใช้ไปแล้ว'}: ${Money(totalExpenseSatang).format(symbol: '฿')}',
                          style: TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 13,
                            color: isLumi ? const Color(0xFF8A5C6F) : VaultTheme.secondaryText(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onNavigateToBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLumi ? const Color(0xFFFF5C9D) : VaultTheme.accent(context),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      l10n?.setBudgetAction ?? '+ ตั้งงบประมาณ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ] else if (isLumi) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          alignment: Alignment.centerLeft,
                          fit: BoxFit.scaleDown,
                          child: Text(
                            Money(remainingSatang).format(symbol: '฿'),
                            style: VaultTheme.tabular(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF2B2338),
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n?.fromBudget(Money(totalBudgetSatang).format(symbol: '฿')) ??
                              'จากงบ ${Money(totalBudgetSatang).format(symbol: '฿')}',
                          style: const TextStyle(
                            fontFamily: VaultTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF8A5C6F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      'assets/images/lumi_budget_character.png',
                      width: 95,
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressRatio,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isWarning ? VaultTheme.negative(context) : const Color(0xFFFF5C9D),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${(progressRatio * 100).toInt()}%',
                    style: const TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2B2338),
                    ),
                  ),
                ],
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    Money(remainingSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: VaultTheme.primaryText(context),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.availableToSpendVault ?? 'เหลือให้ใช้ได้',
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.ofTotalMonthlyBudget(percentRemaining) ?? 'เหลือ $percentRemaining% ของงบประมาณรวมทั้งเดือน',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 13,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressRatio,
                  minHeight: 6,
                  backgroundColor: VaultTheme.border(context),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isWarning ? VaultTheme.negative(context) : VaultTheme.accent(context),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n?.usedSoFar ?? 'ใช้ไปแล้ว'} ${Money(totalExpenseSatang).format(symbol: '฿')}',
                    style: VaultTheme.tabular(
                      fontSize: 12,
                      color: VaultTheme.mutedText(context),
                    ),
                  ),
                  Text(
                    '${l10n?.fromTotalBudget ?? 'งบทั้งหมด'} ${Money(totalBudgetSatang).format(symbol: '฿')}',
                    style: VaultTheme.tabular(
                      fontSize: 12,
                      color: VaultTheme.mutedText(context),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- 3. Today / Attention Box ---
  Widget _buildAttentionCard(BuildContext context, _VaultHomeData data) {
    final isLumi = VaultTheme.isLumi(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isLumi ? const Color(0xFFFFF7EF) : VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 18 : 12),
        border: Border.all(
          color: data.attentionIsWarning
              ? VaultTheme.accent(context).withValues(alpha: 0.5)
              : (isLumi ? const Color(0xFFFFD5A5) : VaultTheme.border(context)),
          width: 0.75,
        ),
      ),
      child: Row(
        children: [
          if (isLumi)
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF9E44).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/images/lumi_cat_crisp.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.pets, color: Color(0xFFFF9E44)),
                ),
              ),
            )
          else ...[
            Text(
              data.attentionIsWarning ? '⚠️' : '💡',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Text(
              isLumi
                  ? (data.attentionIsWarning
                      ? data.attentionMessage
                      : (isThai
                          ? 'Lumi Tips: การเงินดีเริ่มต้นจากวันละนิด • ${data.attentionMessage}'
                          : 'Lumi Insight: Small steps to financial freedom • ${data.attentionMessage}'))
                  : data.attentionMessage,
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 13,
                height: 1.35,
                color: VaultTheme.primaryText(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. Financial Position ---
  Widget _buildFinancialPosition(BuildContext context, _VaultHomeData data) {
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final netWorthMoney = Money(data.netWorthSatang);
    final momChangePercent = data.momChangePercent;
    final isMomPositive = momChangePercent >= 0;
    final isLumi = VaultTheme.isLumi(context);
    final isDark = VaultTheme.isDark(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
        border: Border.all(color: VaultTheme.border(context), width: 0.75),
        boxShadow: isLumi && !isDark
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isLumi
                    ? (l10n?.financialOverview ?? 'ภาพรวมการเงิน')
                    : 'FINANCIAL POSITION',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: isLumi ? 14 : 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: isLumi ? 0.2 : 1.2,
                  color: isLumi ? VaultTheme.primaryText(context) : VaultTheme.secondaryText(context),
                ),
              ),
              if (isLumi)
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
                    );
                  },
                  child: Text(
                    '${l10n?.viewAll ?? 'ดูทั้งหมด'} ›',
                    style: const TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5C9D),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Icon(
                      isMomPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 13,
                      color: isMomPositive ? VaultTheme.positive(context) : VaultTheme.negative(context),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '${isMomPositive ? '+' : ''}${momChangePercent.toStringAsFixed(1)}% ${isThai ? 'vs สิ้นเดือนก่อน' : 'vs last month'}',
                      style: VaultTheme.tabular(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isMomPositive ? VaultTheme.positive(context) : VaultTheme.negative(context),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                l10n?.netWorth ?? 'สินทรัพย์สุทธิ',
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 13,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                netWorthMoney.format(symbol: '฿'),
                style: VaultTheme.tabular(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: VaultTheme.primaryText(context),
                ),
              ),
            ],
          ),
          if (isLumi) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isMomPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  size: 14,
                  color: isMomPositive ? const Color(0xFF38B278) : VaultTheme.negative(context),
                ),
                const SizedBox(width: 4),
                Text(
                  '${isMomPositive ? (isThai ? 'เพิ่มขึ้น' : '+') : (isThai ? 'ลดลง' : '-')}${isMomPositive ? '+' : ''}${momChangePercent.toStringAsFixed(1)}% ${isThai ? 'จากเดือนที่แล้ว' : 'vs last month'}',
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isMomPositive ? const Color(0xFF38B278) : VaultTheme.negative(context),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Divider(color: VaultTheme.border(context), height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n?.cashFlow ?? 'กระแสเงินสด'}: ${Money(data.cashFlowMonthSatang).format(symbol: '฿')}',
                style: VaultTheme.tabular(
                  fontSize: 12,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
              Text(
                '${l10n?.portfolio ?? 'พอร์ตลงทุน'}: ${Money(data.portfolioValueSatang).format(symbol: '฿')}',
                style: VaultTheme.tabular(
                  fontSize: 12,
                  color: VaultTheme.secondaryText(context),
                ),
              ),
            ],
          ),
          if (!isLumi) ...[
            const SizedBox(height: 10),
            Divider(color: VaultTheme.border(context), height: 1),
            const SizedBox(height: 8),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const MonthlySummaryScreen()),
                );
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assessment_outlined,
                      size: 15,
                      color: VaultTheme.accent(context),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isThai ? 'ดูรายงานสรุปรายเดือน ›' : 'View Monthly Report ›',
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: VaultTheme.accent(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- 5. Snapshot Row (Portfolio & Credit Card) ---
  Widget _buildSnapshotRow(BuildContext context, _VaultHomeData data) {
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final portReturnPercent = data.portfolioReturnPercent;
    final isPortPositive = portReturnPercent >= 0;
    final isLumi = VaultTheme.isLumi(context);
    final isDark = VaultTheme.isDark(context);

    return Row(
      children: [
        // Portfolio Snapshot
        Expanded(
          child: InkWell(
            onTap: onNavigateToInvest,
            borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLumi
                    ? (isDark ? const Color(0xFF202923) : const Color(0xFFF7FCF5))
                    : VaultTheme.surface(context),
                borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
                border: Border.all(
                  color: isLumi
                      ? (isDark ? const Color(0xFF2C4533) : const Color(0xFFD5F7C4))
                      : VaultTheme.border(context),
                  width: isLumi ? 1.5 : 0.75,
                ),
                boxShadow: isLumi && !isDark
                    ? [
                        BoxShadow(
                          color: const Color(0xFF329F5B).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLumi ? 'พอร์ตการลงทุน 📈' : 'PORTFOLIO',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: isLumi ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: isLumi ? 0.2 : 1.0,
                          color: isLumi ? (isDark ? const Color(0xFF7AE0A4) : const Color(0xFF257845)) : VaultTheme.secondaryText(context),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: VaultTheme.mutedText(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Money(data.portfolioValueSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: VaultTheme.primaryText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isPortPositive ? '+' : ''}${portReturnPercent.toStringAsFixed(1)}% ${isThai ? 'รวม' : 'total'}',
                    style: VaultTheme.tabular(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPortPositive ? VaultTheme.positive(context) : VaultTheme.negative(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Credit Card Snapshot
        Expanded(
          child: InkWell(
            onTap: onNavigateToCreditCards,
            borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isLumi
                    ? (isDark ? const Color(0xFF1B2530) : const Color(0xFFF3F9FF))
                    : VaultTheme.surface(context),
                borderRadius: BorderRadius.circular(isLumi ? 20 : 14),
                border: Border.all(
                  color: isLumi
                      ? (isDark ? const Color(0xFF283F54) : const Color(0xFFBFE9FF))
                      : VaultTheme.border(context),
                  width: isLumi ? 1.5 : 0.75,
                ),
                boxShadow: isLumi && !isDark
                    ? [
                        BoxShadow(
                          color: const Color(0xFF4C9FFF).withValues(alpha: 0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isLumi ? 'บัตรเครดิต 💳' : 'CREDIT CARD',
                        style: TextStyle(
                          fontFamily: VaultTheme.fontFamily,
                          fontSize: isLumi ? 11 : 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: isLumi ? 0.2 : 1.0,
                          color: isLumi ? (isDark ? const Color(0xFF8AC7FF) : const Color(0xFF1E6DB8)) : VaultTheme.secondaryText(context),
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, size: 16, color: VaultTheme.mutedText(context)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Money(data.creditCardCurrentDebtSatang).format(symbol: '฿'),
                    style: VaultTheme.tabular(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: VaultTheme.primaryText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isLumi
                        ? (data.creditCardCurrentDebtSatang > 0
                            ? (l10n?.creditCardPending ?? 'ยอดค้างชำระปัจจุบัน')
                            : (l10n?.creditCardNoDebt ?? 'ไม่มีหนี้ค้างชำระ'))
                        : data.creditCardNextCloseText,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.secondaryText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 6. Recent Activity (3 รายการล่าสุด) ---
  Widget _buildRecentActivity(BuildContext context, _VaultHomeData data) {
    final l10n = AppLocalizations.of(context);
    final isLumi = VaultTheme.isLumi(context);
    final isDark = VaultTheme.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isLumi ? (l10n?.recentActivity ?? 'รายการล่าสุด') : 'RECENT ACTIVITY',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: isLumi ? 14 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: isLumi ? 0.2 : 1.2,
                color: isLumi ? VaultTheme.primaryText(context) : VaultTheme.secondaryText(context),
              ),
            ),
            TextButton(
              onPressed: onNavigateToMoney,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                foregroundColor: isLumi ? const Color(0xFFFF5C9D) : VaultTheme.accent(context),
              ),
              child: Text(
                '${l10n?.viewAll ?? 'ดูทั้งหมด'} →',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (data.recentTransactions.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              l10n?.noTransactionsThisMonth ?? 'ยังไม่มีรายการธุรกรรม',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 13,
                color: VaultTheme.mutedText(context),
              ),
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: VaultTheme.surface(context),
              borderRadius: BorderRadius.circular(isLumi ? 22 : 16),
              border: Border.all(color: VaultTheme.border(context), width: 0.75),
              boxShadow: isLumi && !isDark
                  ? [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: data.recentTransactions.length,
              separatorBuilder: (_, index) => Divider(color: VaultTheme.border(context), height: 1),
              itemBuilder: (context, idx) {
                final tx = data.recentTransactions[idx];
                final isIncome = tx.transactionType == 'income';
                final isExpense = tx.transactionType == 'expense';
                final isTransfer = tx.transactionType == 'transfer';

                final sign = isIncome ? '+' : (isExpense ? '−' : '');
                final amountColor = isIncome
                    ? VaultTheme.positive(context)
                    : (isExpense ? VaultTheme.negative(context) : VaultTheme.accent(context));

                final currency = tx.currencyCode;
                final symbol = currency == 'USD' ? '\$ ' : (currency == 'THB' ? '฿ ' : '$currency ');
                final displayAmount = currency == 'USD'
                    ? tx.amountOriginalSatang / 100.0
                    : tx.amountThbSatang / 100.0;

                final locale = Localizations.localeOf(context).languageCode;
                final dateStr = DateFormat('d MMM', locale).format(tx.transactionDate);

                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: isLumi
                      ? Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isIncome
                                ? const Color(0xFFE8F5EE)
                                : (isExpense ? const Color(0xFFFFECF0) : const Color(0xFFEFF4F9)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward_rounded
                                : (isExpense ? Icons.arrow_upward_rounded : Icons.swap_horiz_rounded),
                            size: 20,
                            color: amountColor,
                          ),
                        )
                      : null,
                  title: Text(
                    tx.note?.isNotEmpty == true
                        ? tx.note!
                        : (isTransfer
                            ? (l10n?.transfer ?? 'โอนเงิน')
                            : (isIncome ? (l10n?.income ?? 'รายรับ') : (l10n?.expense ?? 'รายจ่าย'))),
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: VaultTheme.primaryText(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    dateStr,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.mutedText(context),
                    ),
                  ),
                  trailing: Text(
                    '$sign $symbol${displayAmount.toStringAsFixed(2)}',
                    style: VaultTheme.tabular(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: amountColor,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // --- Data Loader ---
  Future<_VaultHomeData> _loadHomeData(WidgetRef ref, DateTime now, BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final txDao = ref.read(transactionsDaoProvider);
    final accDao = ref.read(accountsDaoProvider);
    final bgDao = ref.read(budgetsDaoProvider);
    final ccDao = ref.read(creditCardDaoProvider);
    final invDao = ref.read(investmentsDaoProvider);
    final healthDao = ref.read(financialHealthDaoProvider);

    // 1. Portfolio (Unrealized profit/loss)
    PortfolioSummary? portSummary;
    try {
      portSummary = await invDao.getPortfolioSummary();
    } catch (_) {}

    final portValue = portSummary?.totalValueThbSatang ?? 0;
    final portCost = portSummary?.totalCostThbSatang ?? 0;
    final portReturnPercent = portCost > 0
        ? ((portValue - portCost) / portCost * 100.0)
        : 0.0;

    // 2. Net worth (Cash + Portfolio with unrealized profit/loss) & accounts
    final netWorth = await accDao.getTotalNetWorthSatang(portfolioValueSatang: portValue);
    final activeAccounts = await accDao.getActiveAccounts();

    // 3. Month transactions
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.month == 12 ? now.year + 1 : now.year, now.month == 12 ? 1 : now.month + 1, 1);
    final monthTx = await txDao.searchTransactions(startDate: startOfMonth, endDate: endOfMonth);

    int totalIncome = 0;
    int totalExpense = 0;
    for (final t in monthTx) {
      if (t.transactionType == 'income') {
        if (!t.isCleared) continue;
        totalIncome += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        totalExpense += (t.amountThbSatang + t.feeThbSatang);
      }
    }
    final cashFlow = totalIncome - totalExpense;

    // 4. Budgets (no fake default limit!)
    final budgets = await bgDao.getBudgetStatusForMonth(now.year, now.month);
    int totalBudget = 0;
    for (final b in budgets) {
      totalBudget += b.limitSatang;
    }
    final remainingBudget = totalBudget > 0 ? (totalBudget - totalExpense).clamp(0, totalBudget) : 0;

    // 5. Credit Cards (Total outstanding debt across all cycles)
    int ccDebt = 0;
    String ccNextClose = isThai ? 'ไม่มีหนี้ค้างชำระ' : 'No balance due';
    bool ccHasWarning = false;
    for (final a in activeAccounts) {
      if (a.accountType == 'credit_card') {
        final summary = await ccDao.getSummary(a.id, now);
        if (summary != null) {
          ccDebt += summary.totalDebtSatang;
          final daysToClose = summary.cycle.daysRemaining;
          if (daysToClose <= 7 && daysToClose >= 0) {
            ccNextClose = isThai ? 'ตัดรอบในอีก $daysToClose วัน' : 'Due in $daysToClose days';
            ccHasWarning = true;
          } else {
            ccNextClose = isThai ? 'ตัดรอบวันที่ ${summary.cycle.statementDay}' : 'Closes on day ${summary.cycle.statementDay}';
          }
        }
      }
    }

    // 6. Recent 3 transactions
    final recent = await txDao.getRecentTransactions(limit: 3);

    // 7. Dynamic Attention Insight
    final savingsPct = totalIncome > 0 ? ((totalIncome - totalExpense) / totalIncome * 100).clamp(0, 100).toInt() : 0;
    String attentionMsg = l10n?.savingsRateStatus(savingsPct) ?? 'อัตราการออมเดือนนี้อยู่ที่ $savingsPct%';
    bool attentionWarn = false;

    if (ccHasWarning && ccDebt > 0) {
      attentionMsg = l10n?.creditCardDueWarning(Money(ccDebt).format(symbol: '฿')) ??
          'บัตรเครดิตจะตัดรอบในอีกไม่กี่วัน ยอดรอตัด ${Money(ccDebt).format(symbol: '฿')}';
      attentionWarn = true;
    } else if (totalBudget > 0 && remainingBudget < (totalBudget * 0.2)) {
      attentionMsg = l10n?.budgetLowWarning ?? 'งบประมาณเดือนนี้เหลือต่ำกว่า 20% แล้ว โปรดระมัดระวังการใช้จ่าย';
      attentionWarn = true;
    } else {
      try {
        final forecast = await healthDao.getRunRateForecast();
        if (forecast.recommendedDailySpendSatang > 0) {
          attentionMsg = l10n?.dailySpendRecommendation(Money(forecast.recommendedDailySpendSatang).format(symbol: '฿')) ??
              'ใช้เงินได้เฉลี่ยวันละ ${Money(forecast.recommendedDailySpendSatang).format(symbol: '฿')} จนถึงสิ้นเดือน';
        }
      } catch (_) {}
    }

    // MoM change
    final priorNetWorth = netWorth - cashFlow;
    final momPercent = priorNetWorth > 0
        ? (cashFlow / priorNetWorth * 100.0)
        : 0.0;

    return _VaultHomeData(
      netWorthSatang: netWorth,
      momChangePercent: momPercent,
      cashFlowMonthSatang: cashFlow,
      totalIncomeMonthSatang: totalIncome,
      totalBudgetMonthSatang: totalBudget,
      totalExpenseMonthSatang: totalExpense,
      remainingBudgetSatang: remainingBudget,
      portfolioValueSatang: portValue,
      portfolioReturnPercent: portReturnPercent,
      creditCardCurrentDebtSatang: ccDebt,
      creditCardNextCloseText: ccNextClose,
      recentTransactions: recent,
      attentionMessage: attentionMsg,
      attentionIsWarning: attentionWarn,
    );
  }

  String _getThaiMonth(int month) {
    const names = [
      'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
      'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
    ];
    return names[(month - 1).clamp(0, 11)];
  }
}

class _VaultHomeData {
  final int netWorthSatang;
  final double momChangePercent;
  final int cashFlowMonthSatang;
  final int totalIncomeMonthSatang;
  final int totalBudgetMonthSatang;
  final int totalExpenseMonthSatang;
  final int remainingBudgetSatang;
  final int portfolioValueSatang;
  final double portfolioReturnPercent;
  final int creditCardCurrentDebtSatang;
  final String creditCardNextCloseText;
  final List<Transaction> recentTransactions;
  final String attentionMessage;
  final bool attentionIsWarning;

  const _VaultHomeData({
    required this.netWorthSatang,
    required this.momChangePercent,
    required this.cashFlowMonthSatang,
    required this.totalIncomeMonthSatang,
    required this.totalBudgetMonthSatang,
    required this.totalExpenseMonthSatang,
    required this.remainingBudgetSatang,
    required this.portfolioValueSatang,
    required this.portfolioReturnPercent,
    required this.creditCardCurrentDebtSatang,
    required this.creditCardNextCloseText,
    required this.recentTransactions,
    required this.attentionMessage,
    required this.attentionIsWarning,
  });
}
