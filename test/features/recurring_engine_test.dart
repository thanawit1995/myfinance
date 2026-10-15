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

    test('Early posting: Posting before scheduled date advances nextRunDate and prevents duplicate on scheduled day', () {
      // Rule scheduled for Oct 10th
      final scheduledDate = DateTime(2026, 10, 10);

      // User posts early on Oct 3rd for the Oct 10th cycle
      // Next run date advances to Nov 10th
      final nextRunDate = RecurringEngine.computeNextRunDate(
        frequency: 'monthly',
        intervalUnits: 1,
        fromDate: scheduledDate,
        dayOfMonth: 10,
      );
      expect(nextRunDate, equals(DateTime(2026, 11, 10)));

      // When Oct 10th actually arrives:
      final dueDatesOnOct10 = RecurringEngine.calculateDueDates(
        nextRunDate: nextRunDate, // now Nov 10th
        frequency: 'monthly',
        intervalUnits: 1,
        lastPostedDate: scheduledDate, // recorded as Oct 10th
        now: DateTime(2026, 10, 10, 12, 0),
      );

      // On Oct 10th, since nextRunDate is Nov 10th, dueDates is empty (cycle skipped as desired!)
      expect(dueDatesOnOct10, isEmpty);
    });

    test('Strict day-of-month alignment: Rule for 25th does NOT trigger when today is 15th even if nextRunDate is 15th', () {
      // Simulates the exact bug: nextRunDate was set to Oct 15th, today is Oct 15th, but dayOfMonth is 25th
      final dueDatesOnOct15 = RecurringEngine.calculateDueDates(
        nextRunDate: DateTime(2026, 10, 15),
        frequency: 'monthly',
        intervalUnits: 1,
        dayOfMonth: 25,
        now: DateTime(2026, 10, 15, 18, 0),
      );

      // Must be empty! It is NOT the 25th yet!
      expect(dueDatesOnOct15, isEmpty);

      // When Oct 25th actually arrives:
      final dueDatesOnOct25 = RecurringEngine.calculateDueDates(
        nextRunDate: DateTime(2026, 10, 15),
        frequency: 'monthly',
        intervalUnits: 1,
        dayOfMonth: 25,
        now: DateTime(2026, 10, 25, 10, 0),
      );

      // Must trigger exactly on Oct 25th!
      expect(dueDatesOnOct25.length, equals(1));
      expect(dueDatesOnOct25.first.day, equals(25));
      expect(dueDatesOnOct25.first.month, equals(10));
    });

    test('getUpcomingRunDate correctly selects upcoming occurrence in current month or next month', () {
      final now = DateTime(2026, 10, 15);

      // Day 25 is later this month -> returns Oct 25th
      final upcoming25 = RecurringEngine.getUpcomingRunDate(
        fromDate: now,
        frequency: 'monthly',
        intervalUnits: 1,
        dayOfMonth: 25,
      );
      expect(upcoming25.year, equals(2026));
      expect(upcoming25.month, equals(10));
      expect(upcoming25.day, equals(25));

      // Day 10 has already passed this month -> returns Nov 10th
      final upcoming10 = RecurringEngine.getUpcomingRunDate(
        fromDate: now,
        frequency: 'monthly',
        intervalUnits: 1,
        dayOfMonth: 10,
      );
      expect(upcoming10.year, equals(2026));
      expect(upcoming10.month, equals(11));
      expect(upcoming10.day, equals(10));

      // Day 31 for February -> clamps to Feb 28th
      final febFrom = DateTime(2026, 2, 1);
      final upcomingFeb31 = RecurringEngine.getUpcomingRunDate(
        fromDate: febFrom,
        frequency: 'monthly',
        intervalUnits: 1,
        dayOfMonth: 31,
      );
      expect(upcomingFeb31.year, equals(2026));
      expect(upcomingFeb31.month, equals(2));
      expect(upcomingFeb31.day, equals(28));
    });
  });
}
