import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/database_provider.dart';
import 'package:myfinance/core/security/auth_provider.dart';
import 'package:myfinance/core/security/auth_service.dart';
import 'package:myfinance/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App renders VAULT MainShell with Master Budget and FAB + Add flow', (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    final db = AppDatabase.forTesting(inMemoryConnection());
    final auth = AuthService(secureStorage: const FlutterSecureStorage());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: const MyFinanceApp(),
      ),
    );

    await tester.pumpAndSettle();

    // 1. Verify VAULT Brand and Master Budget Hero Card
    expect(find.text('VAULT'), findsAtLeastNWidgets(1));
    expect(find.text('MASTER BUDGET'), findsOneWidget);

    // 2. Verify 5 Bottom Navigation Destinations exist
    expect(find.text('หน้าแรก'), findsOneWidget);
    expect(find.text('การเงิน'), findsOneWidget);
    expect(find.text('การลงทุน'), findsOneWidget);
    expect(find.text('แผนการเงิน'), findsOneWidget);
    expect(find.text('เพิ่มเติม'), findsOneWidget);

    // 3. Verify FAB "+ Add" exists
    final addFab = find.text('เพิ่ม');
    expect(addFab, findsOneWidget);

    // Tap FAB "+ Add"
    await tester.tap(addFab);
    await tester.pumpAndSettle();

    // 4. Verify Bottom Sheet opens with 4 core options
    expect(find.text('รายจ่าย'), findsOneWidget);
    expect(find.text('รายรับ'), findsOneWidget);
    expect(find.text('โอนเงิน'), findsOneWidget);
    expect(find.text('ซื้อขายหุ้น'), findsOneWidget);

    // 5. Tap 'รายจ่าย' to open Quick Add
    await tester.tap(find.text('รายจ่าย'));
    await tester.pumpAndSettle();

    expect(find.text('บันทึกด่วน (3 แตะ)'), findsOneWidget);

    // Close quick add sheet
    Navigator.of(tester.element(find.text('บันทึกด่วน (3 แตะ)'))).pop();
    await tester.pumpAndSettle();

    // 6. Switch to Money tab (default subtab: Transactions)
    await tester.tap(find.text('การเงิน'));
    await tester.pumpAndSettle();
    // In Money -> Transactions, FAB '+ Add' should be visible
    expect(find.text('เพิ่ม'), findsOneWidget);

    // Switch to Money -> Accounts subtab
    await tester.tap(find.text('บัญชี (Accounts)'));
    await tester.pumpAndSettle();
    // In Accounts, Main FAB must be hidden (Accounts has its own button)
    expect(find.text('เพิ่ม'), findsNothing);

    // Switch to Money -> Budget subtab
    await tester.tap(find.text('งบประมาณ & โครงการ'));
    await tester.pumpAndSettle();
    // In Budget, Main FAB must be hidden
    expect(find.text('เพิ่ม'), findsNothing);

    // 7. Switch to Invest tab
    await tester.tap(find.text('การลงทุน'));
    await tester.pumpAndSettle();

    // In Invest tab, MainShell's Add FAB must be hidden
    expect(find.text('เพิ่ม'), findsNothing);
    // And PortfolioScreen's 'ซื้อ / ขาย' button must be visible
    expect(find.text('ซื้อ / ขาย'), findsOneWidget);

    // 8. Switch to Plan tab
    await tester.tap(find.text('แผนการเงิน'));
    await tester.pumpAndSettle();
    expect(find.text('เพิ่ม'), findsNothing);

    // 9. Switch to More/Settings tab
    await tester.tap(find.text('เพิ่มเติม'));
    await tester.pumpAndSettle();
    expect(find.text('เพิ่ม'), findsNothing);

    // 10. Switch back to Home tab
    await tester.tap(find.text('หน้าแรก'));
    await tester.pumpAndSettle();
    expect(find.text('เพิ่ม'), findsOneWidget);

    await db.close();
  });

  testWidgets('Switching to Lumi theme updates design to Sunny Bloom', (WidgetTester tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({'app_theme_style': 'lumi'});

    final db = AppDatabase.forTesting(inMemoryConnection());
    final auth = AuthService(secureStorage: const FlutterSecureStorage());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: const MyFinanceApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Lumi greeting and Sunny Bloom header
    final hour = DateTime.now().hour;
    final expectedGreeting = hour < 12 ? 'สวัสดีตอนเช้า ☀️' : (hour < 18 ? 'สวัสดีตอนบ่าย 🌤️' : 'สวัสดีตอนเย็น 🌙');
    expect(find.text(expectedGreeting), findsOneWidget);
    expect(find.text('เงินที่ใช้ได้ในเดือนนี้ 🌸'), findsOneWidget);
    expect(find.text('เพิ่ม'), findsOneWidget);

    await db.close();
  });
}

