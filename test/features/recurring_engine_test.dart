import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/features/recurring/domain/recurring_engine.dart';

void main() {
  group('Recurring Engine - Next Run Date, Month-End Clamping & Idempotency Tests', () {
    test('Daily and Weekly next run date progression', () {
      final start = DateTime(2026, 3, 10, 8, 0);

      final nextDay = RecurringEngine.computeNextRunDate(
        frequency: 'daily',
        intervalUnits: 1,
        fromDate: start,
      );
      expect(nextDay, equals(DateTime(2026, 3, 11, 8, 0)));

      final nextWeek = RecurringEngine.computeNextRunDate(
        frequency: 'weekly',
        intervalUnits: 2, // every 2 weeks
        fromDate: start,
      );
      expect(nextWeek, equals(DateTime(2026, 3, 24, 8, 0)));
    });

    test('Monthly 31st rule correctly clamps to last day of February and 30-day months', () {
      // Starting on Jan 31st with anchor dayOfMonth = 31
      final jan31 = DateTime(2026, 1, 31);

      // Next month is Feb (non-leap 2026 -> 28 days)
      final feb = RecurringEngine.computeNextRunDate(
        frequency: 'monthly',
        intervalUnits: 1,
        fromDate: jan31,
        dayOfMonth: 31,
      );
      expect(feb.year, equals(2026));
      expect(feb.month, equals(2));
      expect(feb.day, equals(28));

      // Month after Feb is March -> back to 31 days
      final mar = RecurringEngine.computeNextRunDate(
        frequency: 'monthly',
        intervalUnits: 1,
        fromDate: feb,
        dayOfMonth: 31,
      );
      expect(mar.year, equals(2026));
      expect(mar.month, equals(3));
      expect(mar.day, equals(31));

      // Month after March is April -> 30 days
      final apr = RecurringEngine.computeNextRunDate(
        frequency: 'monthly',
        intervalUnits: 1,
        fromDate: mar,
        dayOfMonth: 31,
      );
      expect(apr.year, equals(2026));
      expect(apr.month, equals(4));
      expect(apr.day, equals(30));
    });

    test('Idempotency: Same local calendar date check prevents duplicate posting', () {
      final now1 = DateTime(2026, 5, 15, 9, 30);
      final now2 = DateTime(2026, 5, 15, 21, 45); // 12 hours later on same day
      final tomorrow = DateTime(2026, 5, 16, 9, 0);

      expect(RecurringEngine.isSameLocalDate(now1, now2), isTrue);
      expect(RecurringEngine.isSameLocalDate(now1, tomorrow), isFalse);

      // Simulating calculateDueDates when already posted on the same day
      final dueDates = RecurringEngine.calculateDueDates(
        nextRunDate: DateTime(2026, 5, 15),
        frequency: 'daily',
        intervalUnits: 1,
        lastPostedDate: DateTime(2026, 5, 15, 8, 0), // already posted this morning
        now: now2,
      );

      // Should be empty (no duplicate posting on same calendar day)
      expect(dueDates, isEmpty);
    });

    test('Catch-up posting generates all missed occurrences when app was closed for 3 days', () {
      final missedFrom = DateTime(2026, 4, 10);
      final openedAppOn = DateTime(2026, 4, 13, 14, 0);

      final dueDates = RecurringEngine.calculateDueDates(
        nextRunDate: missedFrom,
        frequency: 'daily',
        intervalUnits: 1,
        lastPostedDate: DateTime(2026, 4, 9),
        now: openedAppOn,
      );

      // Should catch up April 10, 11, 12, 13 (4 occurrences)
      expect(dueDates.length, equals(4));
      expect(dueDates[0].day, equals(10));
      expect(dueDates[1].day, equals(11));
      expect(dueDates[2].day, equals(12));
      expect(dueDates[3].day, equals(13));
    });
  });
}
