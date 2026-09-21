import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myfinance/core/security/auth_service.dart';

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

  group('AuthService - PIN Hashing & Session Tests', () {
    test('Can configure 6-digit PIN and verify it', () async {
      expect(await authService.isPinConfigured(), isFalse);

      // Must be 6 digits
      expect(() => authService.setPin('12345'), throwsArgumentError);
      expect(() => authService.setPin('1234567'), throwsArgumentError);
      expect(() => authService.setPin('abcdef'), throwsArgumentError);

      final success = await authService.setPin('123456');
      expect(success, isTrue);
      expect(await authService.isPinConfigured(), isTrue);

      // Session unlocked immediately upon setup
      expect(authService.isSessionUnlocked, isTrue);

      // Lock session
      authService.lockSession();
      expect(authService.isSessionUnlocked, isFalse);

      // Wrong PIN fails
      final wrong = await authService.verifyPin('999999');
      expect(wrong, isFalse);
      expect(authService.isSessionUnlocked, isFalse);

      // Correct PIN unlocks
      final right = await authService.verifyPin('123456');
      expect(right, isTrue);
      expect(authService.isSessionUnlocked, isTrue);
    });

    test('Can change PIN with old PIN verification', () async {
      await authService.setPin('111111');
      authService.lockSession();

      final failChange = await authService.changePin('000000', '222222');
      expect(failChange, isFalse);

      final successChange = await authService.changePin('111111', '222222');
      expect(successChange, isTrue);

      authService.lockSession();
      expect(await authService.verifyPin('111111'), isFalse);
      expect(await authService.verifyPin('222222'), isTrue);
    });

    test('Can toggle PIN lock and biometrics independently', () async {
      // Initially not configured, lock should be false
      expect(await authService.isPinLockEnabled(), isFalse);

      // Set PIN -> lock becomes enabled automatically
      await authService.setPin('123456');
      expect(await authService.isPinLockEnabled(), isTrue);

      // Disable PIN lock
      await authService.setPinLockEnabled(false);
      expect(await authService.isPinLockEnabled(), isFalse);

      // Re-enable PIN lock
      await authService.setPinLockEnabled(true);
      expect(await authService.isPinLockEnabled(), isTrue);

      // Biometrics toggle
      expect(await authService.isBiometricsEnabled(), isFalse);
      await authService.setBiometricsEnabled(true);
      expect(await authService.isBiometricsEnabled(), isTrue);
      await authService.setBiometricsEnabled(false);
      expect(await authService.isBiometricsEnabled(), isFalse);
    });
  });
}
