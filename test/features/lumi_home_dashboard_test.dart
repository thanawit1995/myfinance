import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/theme/lumi_theme.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/budget_hero_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/credit_card_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/financial_overview_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/goals_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/lumi_desktop_layout.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/lumi_tip_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/portfolio_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/recent_activity_card.dart';

void main() {
  testWidgets('LumiDesktopLayout renders all 7 cards in 2-column desktop layout', (tester) async {
    // Set screen size to Desktop (1280 x 900)
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool budgetTapped = false;
    bool summaryTapped = false;

    final dummyBundle = LumiHomeDataBundle(
      netWorthSatang: 35000000,
      momChangePercent: 4.5,
      cashFlowMonthSatang: 1500000,
      totalIncomeSatang: 4500000,
      totalExpenseSatang: 3000000,
      remainingBudgetSatang: 2500000,
      totalBudgetSatang: 5500000,
      portfolioValueSatang: 20000000,
      portfolioReturnPercent: 8.2,
      creditCardCurrentDebtSatang: 1250000,
      creditCardNextCloseText: 'ตัดรอบในอีก 5 วัน',
      recentTransactions: [],
      attentionMessage: 'ใช้เงินได้เฉลี่ยวันละ ฿850 จนถึงสิ้นเดือน',
      attentionIsWarning: false,
      activeProjects: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: LumiTheme.lightTheme,
        home: Scaffold(
          body: LumiDesktopLayout(
            data: dummyBundle,
            headerWidget: const Text('Lumi Header Test'),
            onNavigateToBudget: () => budgetTapped = true,
            onNavigateToMoney: () {},
            onNavigateToInvest: () {},
            onNavigateToCreditCards: () {},
            onNavigateToPlan: () {},
            onViewMonthlySummary: () => summaryTapped = true,
            onAddTransaction: () {},
          ),
        ),
      ),
    );

    await tester.pump();

    // Verify all 7 distinct Lumi cards render
    expect(find.byType(BudgetHeroCard), findsOneWidget);
    expect(find.text('เงินที่ใช้ได้ในเดือนนี้ 🌸'), findsOneWidget);

    expect(find.byType(LumiTipCard), findsOneWidget);
    expect(find.text('คำแนะนำจาก Lumi 💡'), findsOneWidget);
    expect(find.text('ใช้เงินได้เฉลี่ยวันละ ฿850 จนถึงสิ้นเดือน'), findsOneWidget);

    expect(find.byType(FinancialOverviewCard), findsOneWidget);
    expect(find.text('ภาพรวมสถานะการเงิน'), findsOneWidget);
    expect(find.text('ดูรายงานรายเดือน'), findsOneWidget);

    expect(find.byType(GoalsCard), findsOneWidget);
    expect(find.text('เป้าหมายการเงิน'), findsOneWidget);

    expect(find.byType(PortfolioCard), findsOneWidget);
    expect(find.text('พอร์ตการลงทุน'), findsOneWidget);

    expect(find.byType(CreditCardCard), findsOneWidget);
    expect(find.text('บัตรเครดิต'), findsOneWidget);

    expect(find.byType(RecentActivityCard), findsOneWidget);
    expect(find.text('บันทึกรายการล่าสุด'), findsOneWidget);

    // Test interactivity: Tap budget card
    await tester.tap(find.byType(BudgetHeroCard));
    expect(budgetTapped, isTrue);

    // Test interactivity: Tap view monthly summary
    await tester.tap(find.text('ดูรายงานรายเดือน'));
    expect(summaryTapped, isTrue);
  });
}
