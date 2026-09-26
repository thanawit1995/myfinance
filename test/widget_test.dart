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

    // 2. Verify Bottom Navigation Destinations exist (Home, Money, Invest, More)
    expect(find.text('หน้าแรก'), findsOneWidget);
    expect(find.text('การเงิน'), findsOneWidget);
    expect(find.text('การลงทุน'), findsOneWidget);
    expect(find.text('เพิ่มเติม'), findsOneWidget);

    // 3. Verify Center Quick Add button (+) exists in bottom bar
    final addCenterBtn = find.byIcon(Icons.add);
    expect(addCenterBtn, findsAtLeastNWidgets(1));

    // Tap center Quick Add button (+)
    await tester.tap(addCenterBtn.first);
    await tester.pumpAndSettle();

    // 4. Verify Quick Add screen opens directly (with expense mode)
    expect(find.text('บันทึกด่วน'), findsOneWidget);

    // Close quick add screen
    Navigator.of(tester.element(find.text('บันทึกด่วน'))).pop();
    await tester.pumpAndSettle();

    // 5. Switch to Money tab (default subtab: Transactions)
    await tester.tap(find.text('การเงิน'));
    await tester.pumpAndSettle();

    // Switch to Money -> Accounts subtab
    await tester.tap(find.text('บัญชี'));
    await tester.pumpAndSettle();

    // Switch to Money -> Budget subtab
    await tester.tap(find.text('งบประมาณ'));
    await tester.pumpAndSettle();

    // 6. Switch to Invest tab
    await tester.tap(find.text('การลงทุน'));
    await tester.pumpAndSettle();

    // In Invest tab, verify holdings tab is present and floating 'ซื้อ / ขาย' button is removed
    expect(find.text('สินทรัพย์ที่ถือครอง'), findsOneWidget);
    expect(find.text('ซื้อ / ขาย'), findsNothing);

    // 7. Switch to More/Settings tab
    await tester.tap(find.text('เพิ่มเติม'));
    await tester.pumpAndSettle();

    // 8. Switch back to Home tab
    await tester.tap(find.text('หน้าแรก'));
    await tester.pumpAndSettle();

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

    // Verify center Quick Add button exists in Lumi theme
    expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));

    await db.close();
  });
}

