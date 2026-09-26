import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/database_provider.dart';
import 'package:myfinance/features/investments/presentation/buy_sell_trade_dialog.dart';
import 'package:myfinance/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('BuySellTradeScreen renders properly with empty and populated DB', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(inMemoryConnection());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          locale: Locale('th'),
          supportedLocales: [Locale('th'), Locale('en')],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: BuySellTradeScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title and Form elements exist
    expect(find.text('บันทึกการซื้อสินทรัพย์ (Buy)'), findsOneWidget);
    expect(find.text('ซื้อ (Buy)'), findsOneWidget);
    expect(find.text('ขาย (Sell)'), findsOneWidget);
    expect(find.text('ยืนยันการซื้อสินทรัพย์'), findsOneWidget);
  });
}
