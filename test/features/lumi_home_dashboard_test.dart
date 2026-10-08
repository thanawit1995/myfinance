import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/theme/lumi_theme.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/budget_hero_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/credit_card_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/financial_overview_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/lumi_desktop_layout.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/lumi_tip_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/portfolio_card.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/recent_activity_card.dart';
import 'package:myfinance/features/budget/presentation/widgets/expense_trend_projection_chart.dart';
import 'package:myfinance/l10n/app_localizations.dart';

void main() {
  testWidgets('LumiDesktopLayout renders all 6 core cards in 2-column desktop layout', (tester) async {
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
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: LumiTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('th'),
            Locale('en'),
          ],
          locale: const Locale('th'),
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
    ));

    await tester.pumpAndSettle();

    // Verify all 6 distinct Lumi cards render
    expect(find.byType(BudgetHeroCard), findsOneWidget);
    expect(find.text('เงินที่ใช้ได้ในเดือนนี้'), findsOneWidget);

    expect(find.byType(LumiTipCard), findsOneWidget);
    expect(find.text('คำแนะนำจาก Lumi 💡'), findsOneWidget);
    expect(find.text('ใช้เงินได้เฉลี่ยวันละ ฿850 จนถึงสิ้นเดือน'), findsOneWidget);

    expect(find.byType(ExpenseTrendProjectionCard), findsOneWidget);
    expect(find.text('แนวโน้มรายจ่าย'), findsOneWidget);

    expect(find.byType(FinancialOverviewCard), findsOneWidget);
    expect(find.text('ภาพรวมสถานะการเงิน'), findsOneWidget);

    expect(find.byType(PortfolioCard), findsOneWidget);
    expect(find.text('พอร์ตการลงทุน'), findsOneWidget);

    expect(find.byType(CreditCardCard), findsOneWidget);
    expect(find.text('บัตรเครดิต'), findsOneWidget);

    expect(find.byType(RecentActivityCard), findsOneWidget);
    expect(find.text('บันทึกรายการล่าสุด'), findsOneWidget);

    // Test interactivity: Tap budget card
    await tester.tap(find.byType(BudgetHeroCard));
    expect(budgetTapped, isTrue);

    // Test interactivity: Tap view monthly summary via Expense Trend chart
    await tester.tap(find.text('แนวโน้มรายจ่าย'));
    expect(summaryTapped, isTrue);
  });

  group('BudgetHeroCard Mascot Dynamic Emotion Tests', () {
    Widget buildCard({
      required int remainingSatang,
      required int totalBudgetSatang,
      required int totalExpenseSatang,
    }) {
      return ProviderScope(
        child: MaterialApp(
          theme: LumiTheme.lightTheme,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('th')],
          locale: const Locale('th'),
          home: Scaffold(
            body: BudgetHeroCard(
              remainingSatang: remainingSatang,
              totalBudgetSatang: totalBudgetSatang,
              totalExpenseSatang: totalExpenseSatang,
              onTap: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('displays Smile mascot when remaining budget > 20%', (tester) async {
      // 5,000 THB remaining out of 10,000 THB (50% remaining)
      await tester.pumpWidget(buildCard(
        remainingSatang: 500000,
        totalBudgetSatang: 1000000,
        totalExpenseSatang: 500000,
      ));
      await tester.pumpAndSettle();

      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/lumi_mascot_smile.png',
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('displays Warning mascot when remaining budget <= 20%', (tester) async {
      // 1,500 THB remaining out of 10,000 THB (15% remaining)
      await tester.pumpWidget(buildCard(
        remainingSatang: 150000,
        totalBudgetSatang: 1000000,
        totalExpenseSatang: 850000,
      ));
      await tester.pumpAndSettle();

      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/lumi_mascot_warning.png',
      );
      expect(imageFinder, findsOneWidget);
    });

    testWidgets('displays Shock mascot when over budget (remaining < 0)', (tester) async {
      // -500 THB remaining out of 10,000 THB (overspent)
      await tester.pumpWidget(buildCard(
        remainingSatang: -50000,
        totalBudgetSatang: 1000000,
        totalExpenseSatang: 1050000,
      ));
      await tester.pumpAndSettle();

      final imageFinder = find.byWidgetPredicate(
        (widget) => widget is Image && widget.image is AssetImage && (widget.image as AssetImage).assetName == 'assets/images/lumi_mascot_shock.png',
      );
      expect(imageFinder, findsOneWidget);
    });
  });
}

