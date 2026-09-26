import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/security/web_biometric/web_biometric_helper.dart';

void main() {
  group('WebBiometricService Stub Tests (Non-web runtime)', () {
    test('Stub methods return false and handle calls gracefully without exception', () async {
      expect(await WebBiometricService.isSupported(), isFalse);
      expect(await WebBiometricService.hasRegisteredCredential(), isFalse);
      expect(await WebBiometricService.register(), isFalse);
      expect(await WebBiometricService.authenticate(), isFalse);

      // removeCredential should complete without error
      await expectLater(WebBiometricService.removeCredential(), completes);
    });
  });
}
