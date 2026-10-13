import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/theme/lumi_theme.dart';
import 'package:myfinance/core/theme/vault_theme.dart';
import 'package:myfinance/core/widgets/budget_progress_bar.dart';
import 'package:myfinance/features/home/presentation/widgets/lumi/budget_hero_card.dart';
import 'package:myfinance/l10n/app_localizations.dart';

void main() {
  group('Home Budget Bar Integration Tests', () {
    testWidgets('BudgetHeroCard in Lumi mode renders BudgetProgressBar with trailing percentage badge', (tester) async {
      tester.view.physicalSize = const Size(390, 844); // Mobile screen size (OPPO Find X9 ratio)
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

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
            supportedLocales: const [Locale('th'), Locale('en')],
            locale: const Locale('th'),
            home: Scaffold(
              body: BudgetHeroCard(
                remainingSatang: 1550000,
                totalBudgetSatang: 2500000,
                totalExpenseSatang: 950000, // 38%
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify BudgetProgressBar is rendered with trailing percentage badge 38%
      expect(find.byType(BudgetProgressBar), findsOneWidget);
      expect(find.text('38%'), findsOneWidget);
      expect(find.text('ความคืบหน้าการใช้เงิน'), findsOneWidget);
    });

    testWidgets('BudgetHeroCard in Lumi Dark mode renders BudgetProgressBar with opaque badge', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: LumiTheme.darkTheme,
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
                remainingSatang: 350000,
                totalBudgetSatang: 2500000,
                totalExpenseSatang: 2150000, // 86% (Warning)
                onTap: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgressBar), findsOneWidget);
      expect(find.text('86%'), findsOneWidget);
    });

    testWidgets('BudgetProgressBar renders correctly in VAULT theme styling', (tester) async {
      tester.view.physicalSize = const Size(1280, 800); // Desktop PC view
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          theme: VaultTheme.darkTheme,
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 350,
                child: BudgetProgressBar(
                  spentSatang: 1200000,
                  limitSatang: 2000000, // 60%
                  height: 10.0,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(BudgetProgressBar), findsOneWidget);
      expect(find.text('60%'), findsOneWidget);
    });
  });
}
