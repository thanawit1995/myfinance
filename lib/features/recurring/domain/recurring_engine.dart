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

  /// Clamps a day of month to the valid range for that month (e.g. Feb 31 -> Feb 28/29).
  static int clampDayToMonth(int year, int month, int targetDay) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    return targetDay > daysInMonth ? daysInMonth : (targetDay < 1 ? 1 : targetDay);
  }

  /// Aligns a given date to its exact scheduled calendar occurrence according to [frequency] and [dayOfMonth].
  /// For 'monthly' and 'yearly': returns a DateTime with the clamped [dayOfMonth] in [date]'s month.
  /// For 'daily' or 'weekly': returns [date].
  static DateTime alignToScheduledDay({
    required DateTime date,
    required String frequency,
    int? dayOfMonth,
  }) {
    if (dayOfMonth == null) return date;

    switch (frequency.toLowerCase()) {
      case 'monthly':
      case 'yearly':
        final clamped = clampDayToMonth(date.year, date.month, dayOfMonth);
        return DateTime(date.year, date.month, clamped, date.hour, date.minute, date.second);
      default:
        return date;
    }
  }

  /// Calculates the next upcoming scheduled date on or strictly after [fromDate].
  /// If the occurrence in [fromDate]'s current cycle is already past, advances to the next cycle.
  static DateTime getUpcomingRunDate({
    required DateTime fromDate,
    required String frequency,
    required int intervalUnits,
    int? dayOfMonth,
  }) {
    final interval = intervalUnits > 0 ? intervalUnits : 1;
    final aligned = alignToScheduledDay(
      date: fromDate,
      frequency: frequency,
      dayOfMonth: dayOfMonth,
    );

    switch (frequency.toLowerCase()) {
      case 'monthly':
        final targetDay = dayOfMonth ?? fromDate.day;
        final clampedThisMonth = clampDayToMonth(fromDate.year, fromDate.month, targetDay);
        final thisMonthOccurrence = DateTime(
          fromDate.year,
          fromDate.month,
          clampedThisMonth,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );

        final todayStart = DateTime(fromDate.year, fromDate.month, fromDate.day);
        final occStart = DateTime(thisMonthOccurrence.year, thisMonthOccurrence.month, thisMonthOccurrence.day);

        if (!occStart.isBefore(todayStart)) {
          return thisMonthOccurrence;
        }

        return computeNextRunDate(
          frequency: 'monthly',
          intervalUnits: interval,
          fromDate: thisMonthOccurrence,
          dayOfMonth: dayOfMonth,
        );

      case 'yearly':
        final targetDay = dayOfMonth ?? fromDate.day;
        final clampedThisYear = clampDayToMonth(fromDate.year, fromDate.month, targetDay);
        final thisYearOccurrence = DateTime(
          fromDate.year,
          fromDate.month,
          clampedThisYear,
          fromDate.hour,
          fromDate.minute,
          fromDate.second,
        );

        final todayStartYear = DateTime(fromDate.year, fromDate.month, fromDate.day);
        final occStartYear = DateTime(thisYearOccurrence.year, thisYearOccurrence.month, thisYearOccurrence.day);

        if (!occStartYear.isBefore(todayStartYear)) {
          return thisYearOccurrence;
        }

        return computeNextRunDate(
          frequency: 'yearly',
          intervalUnits: interval,
          fromDate: thisYearOccurrence,
          dayOfMonth: dayOfMonth,
        );

      default:
        return aligned;
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
    var current = alignToScheduledDay(
      date: nextRunDate,
      frequency: frequency,
      dayOfMonth: dayOfMonth,
    );
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
    var current = alignToScheduledDay(
      date: nextRunDate,
      frequency: frequency,
      dayOfMonth: dayOfMonth,
    );
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
