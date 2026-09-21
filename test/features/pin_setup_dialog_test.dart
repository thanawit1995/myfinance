import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinance/core/security/auth_provider.dart';
import 'package:myfinance/core/security/auth_service.dart';
import 'package:myfinance/core/widgets/pin_setup_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthService authService;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});

    authService = AuthService(
      secureStorage: const FlutterSecureStorage(),
    );
  });

  Widget createTestWidget({required bool isChanging}) {
    return ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(authService),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PinSetupDialog.show(context, isChanging: isChanging),
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (int i = 0; i < pin.length; i++) {
      final digit = pin[i];
      await tester.tap(find.widgetWithText(OutlinedButton, digit));
      await tester.pumpAndSettle();
    }
  }

  group('PinSetupDialog Tests', () {
    testWidgets('New PIN setup flow: enter new -> confirm matching -> succeeds', (tester) async {
      await tester.pumpWidget(createTestWidget(isChanging: false));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Step 1: Setting new PIN directly
      expect(find.text('ตั้งรหัส PIN 6 หลัก'), findsOneWidget);
      expect(find.text('ยกเลิก'), findsOneWidget);

      // Enter new PIN: 123456
      await enterPin(tester, '123456');

      // Step 2: Confirm new PIN
      expect(find.text('ยืนยันรหัส PIN ใหม่'), findsOneWidget);

      // Enter matching PIN: 123456
      await enterPin(tester, '123456');

      // Dialog should be closed and PIN configured
      expect(find.byType(PinSetupDialog), findsNothing);
      expect(await authService.isPinConfigured(), isTrue);
      expect(await authService.verifyPin('123456'), isTrue);
    });

    testWidgets('Change PIN flow: requires old PIN first, fails on wrong old PIN, succeeds on correct', (tester) async {
      // Set existing PIN
      await authService.setPin('111111');

      await tester.pumpWidget(createTestWidget(isChanging: true));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Step 0: Requires old PIN
      expect(find.text('ใส่รหัส PIN เดิม'), findsOneWidget);

      // Enter wrong old PIN: 999999
      await enterPin(tester, '999999');
      expect(find.text('รหัส PIN เดิมไม่ถูกต้อง กรุณาลองใหม่อีกครั้ง'), findsOneWidget);
      expect(find.text('ใส่รหัส PIN เดิม'), findsOneWidget);

      // Enter correct old PIN: 111111
      await enterPin(tester, '111111');

      // Transitions to Step 1: Enter new PIN
      expect(find.text('ตั้งรหัส PIN ใหม่'), findsOneWidget);

      // Enter new PIN: 222222
      await enterPin(tester, '222222');

      // Transitions to Step 2: Confirm new PIN
      expect(find.text('ยืนยันรหัส PIN ใหม่'), findsOneWidget);

      // Enter mismatched PIN: 333333
      await enterPin(tester, '333333');
      expect(find.text('รหัส PIN ไม่ตรงกัน กรุณาตั้งรหัสใหม่อีกครั้ง'), findsOneWidget);

      // Must re-enter new PIN: 222222
      await enterPin(tester, '222222');
      expect(find.text('ยืนยันรหัส PIN ใหม่'), findsOneWidget);

      // Confirm matching: 222222
      await enterPin(tester, '222222');

      // Dialog closed and new PIN active
      expect(find.byType(PinSetupDialog), findsNothing);
      expect(await authService.verifyPin('111111'), isFalse);
      expect(await authService.verifyPin('222222'), isTrue);
    });

    testWidgets('Cancel button dismisses dialog at any step without changing PIN', (tester) async {
      await authService.setPin('111111');

      await tester.pumpWidget(createTestWidget(isChanging: true));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('ใส่รหัส PIN เดิม'), findsOneWidget);

      // Tap Cancel button
      await tester.tap(find.text('ยกเลิก'));
      await tester.pumpAndSettle();

      expect(find.byType(PinSetupDialog), findsNothing);
      expect(await authService.verifyPin('111111'), isTrue);
    });

    testWidgets('Close icon button dismisses dialog at any step', (tester) async {
      await tester.pumpWidget(createTestWidget(isChanging: false));
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(PinSetupDialog), findsOneWidget);

      // Tap Close icon button
      await tester.tap(find.byTooltip('ยกเลิก'));
      await tester.pumpAndSettle();

      expect(find.byType(PinSetupDialog), findsNothing);
      expect(await authService.isPinConfigured(), isFalse);
    });
  });
}
