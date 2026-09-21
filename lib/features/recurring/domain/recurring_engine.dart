/// Pure business logic for recurring transactions calculation,
/// next date progression, leap year & month-end handling, and idempotency.
class RecurringEngine {
  /// Computes the next run date based on frequency, interval, and anchor day of month.
  /// Handles months with fewer days (28, 29, 30) by clamping to the last day of the month.
  static DateTime computeNextRunDate({
    required String frequency,
    required int intervalUnits,
    required DateTime fromDate,
    int? dayOfMonth,
  }) {
    final interval = intervalUnits > 0 ? intervalUnits : 1;

    switch (frequency.toLowerCase()) {
      case 'daily':
        return fromDate.add(Duration(days: interval));

      case 'weekly':
        return fromDate.add(Duration(days: 7 * interval));

      case 'monthly':
        final totalMonths = fromDate.month + interval;
        final newYear = fromDate.year + ((totalMonths - 1) ~/ 12);
        final newMonth = ((totalMonths - 1) % 12) + 1;

        final targetDay = dayOfMonth ?? fromDate.day;
        final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
        final clampedDay = targetDay > daysInNewMonth ? daysInNewMonth : targetDay;

        return DateTime(newYear, newMonth, clampedDay, fromDate.hour, fromDate.minute, fromDate.second);

      case 'yearly':
        final newYear = fromDate.year + interval;
        final targetMonth = fromDate.month;
        final targetDay = dayOfMonth ?? fromDate.day;

        final daysInTargetMonth = DateTime(newYear, targetMonth + 1, 0).day;
        final clampedDay = targetDay > daysInTargetMonth ? daysInTargetMonth : targetDay;

        return DateTime(newYear, targetMonth, clampedDay, fromDate.hour, fromDate.minute, fromDate.second);

      default:
        return fromDate.add(Duration(days: interval));
    }
  }

  /// Checks if two dates fall on the same calendar day in the device's local timezone.
  static bool isSameLocalDate(DateTime a, DateTime b) {
    final aLocal = a.toLocal();
    final bLocal = b.toLocal();
    return aLocal.year == bLocal.year && aLocal.month == bLocal.month && aLocal.day == bLocal.day;
  }

  /// Calculates all due dates from [nextRunDate] up to [now] that have not yet posted.
  /// Caps at [maxCatchUp] (default 60) for safety.
  static List<DateTime> calculateDueDates({
    required DateTime nextRunDate,
    required String frequency,
    required int intervalUnits,
    int? dayOfMonth,
    DateTime? endDate,
    DateTime? lastPostedDate,
    required DateTime now,
    int maxCatchUp = 60,
  }) {
    final dueDates = <DateTime>[];
    var current = nextRunDate;
    int count = 0;

    while (current.isBefore(now) || isSameLocalDate(current, now)) {
      if (endDate != null && current.isAfter(endDate)) {
        break;
      }

      // If already posted on this exact local day, do not duplicate
      final alreadyPosted = lastPostedDate != null && isSameLocalDate(lastPostedDate, current);
      if (!alreadyPosted) {
        dueDates.add(current);
      }

      current = computeNextRunDate(
        frequency: frequency,
        intervalUnits: intervalUnits,
        fromDate: current,
        dayOfMonth: dayOfMonth,
      );

      count++;
      if (count >= maxCatchUp) break;
    }

    return dueDates;
  }

  /// Generates upcoming projected occurrence dates for the next [windowDays].
  static List<DateTime> projectUpcomingDates({
    required DateTime nextRunDate,
    required String frequency,
    required int intervalUnits,
    int? dayOfMonth,
    DateTime? endDate,
    int windowDays = 30,
  }) {
    final projections = <DateTime>[];
    final limit = DateTime.now().add(Duration(days: windowDays));
    var current = nextRunDate;
    int count = 0;

    while (current.isBefore(limit) && count < 100) {
      if (endDate != null && current.isAfter(endDate)) {
        break;
      }
      projections.add(current);
      current = computeNextRunDate(
        frequency: frequency,
        intervalUnits: intervalUnits,
        fromDate: current,
        dayOfMonth: dayOfMonth,
      );
      count++;
    }

    return projections;
  }
}
