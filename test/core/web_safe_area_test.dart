import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/utils/web_safe_area.dart';

void main() {
  group('WebSafeArea Unit Tests', () {
    test('Stub getWebSafeAreaBottom returns 0.0 on VM', () {
      final bottom = getWebSafeAreaBottom();
      expect(bottom, equals(0.0));
    });

    test('Stub getWebSafeAreaTop returns 0.0 on VM', () {
      final top = getWebSafeAreaTop();
      expect(top, equals(0.0));
    });
  });
}
