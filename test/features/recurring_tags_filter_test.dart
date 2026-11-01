import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Recurring Tags Filter Tests', () {
    test('Transaction list cleans recurring tags correctly', () {
      final sampleTags = [
        'recurring_early_posted',
        'recurring_auto',
        'recurring_manual_confirmed',
        'recurring_something_else',
        'ค่าไฟ',
        'project:p1',
        'policy:pol1',
        'deduction:d1',
        'investment_buy:asset1',
        'historical_settle',
        'debt_payment:loan1',
        'อาหาร',
      ];

      final cleanTags = sampleTags
          .map((t) => t.trim())
          .where((t) =>
              !t.startsWith('project:') &&
              !t.startsWith('policy:') &&
              !t.startsWith('deduction:') &&
              !t.startsWith('investment_buy:') &&
              !t.startsWith('investment_sell:') &&
              !t.startsWith('investment_income:') &&
              !t.startsWith('recurring') &&
              !t.startsWith('historical_settle') &&
              !t.startsWith('account_deleted:') &&
              !t.startsWith('debt_payment:'))
          .toList();

      expect(cleanTags, equals(['ค่าไฟ', 'อาหาร']));
      expect(cleanTags.contains('recurring_early_posted'), isFalse);
      expect(cleanTags.contains('recurring_auto'), isFalse);
      expect(cleanTags.contains('recurring_manual_confirmed'), isFalse);
    });

    test('Edit dialog separates recurring tags into system tags', () {
      final rawTag = 'recurring_early_posted, recurring_auto, ค่าใช้จ่ายประจำ, project:proj-123';
      final allTags = rawTag.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      final userTags = <String>[];
      final systemTags = <String>[];

      for (final t in allTags) {
        if (t.startsWith('project:') ||
            t.startsWith('policy:') ||
            t.startsWith('deduction:') ||
            t.startsWith('investment_buy:') ||
            t.startsWith('investment_sell:') ||
            t.startsWith('investment_income:') ||
            t.startsWith('recurring') ||
            t.startsWith('historical_settle') ||
            t.startsWith('account_deleted:') ||
            t.startsWith('debt_payment:') ||
            t.startsWith('รายได้ ') ||
            t.startsWith('รายได้รอบ ')) {
          if (!t.startsWith('รายได้ ') && !t.startsWith('รายได้รอบ ')) {
            systemTags.add(t);
          }
        } else {
          userTags.add(t);
        }
      }

      expect(userTags, equals(['ค่าใช้จ่ายประจำ']));
      expect(systemTags, contains('recurring_early_posted'));
      expect(systemTags, contains('recurring_auto'));
      expect(systemTags, contains('project:proj-123'));
    });
  });
}
