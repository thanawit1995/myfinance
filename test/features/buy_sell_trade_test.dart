import 'package:drift/drift.dart' hide Column;
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
    expect(find.text('ยังไม่มีสินทรัพย์ในระบบ'), findsOneWidget);
    await db.close();
  });

  testWidgets('BuySellTradeScreen renders form fields with populated assets and accounts', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(inMemoryConnection());
    final now = DateTime.now();

    // Insert Currency (if not already seeded)
    await db.into(db.currencies).insert(
      CurrenciesCompanion.insert(
        code: 'THB',
        name: 'Thai Baht',
        symbol: '฿',
        isBase: const Value(true),
        createdAt: now,
        updatedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    // Insert Bank Account
    await db.into(db.accounts).insert(
      AccountsCompanion.insert(
        id: 'acc-1',
        name: 'SCB Main',
        accountType: 'bank',
        currencyCode: 'THB',
        isDomestic: true,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Insert Asset
    await db.into(db.assets).insert(
      AssetsCompanion.insert(
        id: 'asset-1',
        symbol: 'SCB',
        name: 'SCB Bank Stock',
        assetType: 'stock',
        currencyCode: 'THB',
        defaultAccountId: 'acc-1',
        createdAt: now,
        updatedAt: now,
      ),
    );

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

    // Form elements should now be visible
    expect(find.text('บันทึกการซื้อสินทรัพย์ (Buy)'), findsOneWidget);
    expect(find.text('SCB - SCB Bank Stock'), findsOneWidget);
    expect(find.text('SCB Main (THB)'), findsOneWidget);
    expect(find.text('จำนวนหน่วย *'), findsOneWidget);
    expect(find.text('ราคา/หน่วย (THB) *'), findsOneWidget);
    expect(find.text('ค่าธรรมเนียม (บาท)'), findsOneWidget);
    expect(find.text('ยืนยันการซื้อสินทรัพย์'), findsOneWidget);

    await db.close();
  });
}
