import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';
import '../../../features/recurring/domain/recurring_engine.dart';

part 'recurring_transactions_dao.g.dart';

@DriftAccessor(tables: [RecurringRules, Transactions, Accounts, Categories, AuditLogs])
class RecurringTransactionsDao extends DatabaseAccessor<AppDatabase> with _$RecurringTransactionsDaoMixin {
  RecurringTransactionsDao(super.db);

  final _uuid = const Uuid();

  Future<List<RecurringRule>> getActiveRules() {
    return (select(recurringRules)
          ..where((r) => r.deletedAt.isNull() & r.isActive.equals(true))
          ..orderBy([(r) => OrderingTerm.asc(r.nextRunDate)]))
        .get();
  }

  Future<List<RecurringRule>> getAllRules() {
    return (select(recurringRules)
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]))
        .get();
  }

  Future<RecurringRule?> getRuleById(String id) {
    return (select(recurringRules)..where((r) => r.id.equals(id) & r.deletedAt.isNull())).getSingleOrNull();
  }

  Future<void> createRule(RecurringRulesCompanion entry) async {
    final now = DateTime.now();
    final companion = entry.copyWith(
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(recurringRules).insert(companion);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'recurring_rules',
        entityId: companion.id.value,
        action: 'CREATE_RECURRING_RULE',
        afterDataJson: Value('{"title": "${companion.title.value}", "freq": "${companion.frequency.value}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateRule(RecurringRulesCompanion entry) async {
    final now = DateTime.now();
    await (update(recurringRules)..where((r) => r.id.equals(entry.id.value))).write(
      entry.copyWith(updatedAt: Value(now)),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'recurring_rules',
        entityId: entry.id.value,
        action: 'UPDATE_RECURRING_RULE',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteRule(String id) async {
    final now = DateTime.now();
    await (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'recurring_rules',
        entityId: id,
        action: 'SOFT_DELETE_RECURRING_RULE',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> toggleActive(String id, bool isActive) async {
    final now = DateTime.now();
    await (update(recurringRules)..where((r) => r.id.equals(id))).write(
      RecurringRulesCompanion(
        isActive: Value(isActive),
        updatedAt: Value(now),
      ),
    );
  }

  /// Processes all due active rules.
  /// If [autoPost] is true: automatically records the transaction.
  /// If [autoPost] is false: leaves pending or records when user confirms.
  /// Idempotency guaranteed: never posts more than once for the same local calendar date.
  Future<int> processDueRules({DateTime? nowOverride}) async {
    final now = nowOverride ?? DateTime.now();
    final active = await getActiveRules();
    int postedCount = 0;

    for (final rule in active) {
      if (!rule.autoPost) continue; // Manual approval rules are handled via UI prompt

      final dueDates = RecurringEngine.calculateDueDates(
        nextRunDate: rule.nextRunDate,
        frequency: rule.frequency,
        intervalUnits: rule.intervalUnits,
        dayOfMonth: rule.dayOfMonth,
        endDate: rule.endDate,
        lastPostedDate: rule.lastPostedDate,
        now: now,
      );

      DateTime? lastPosted;

      for (final dueDate in dueDates) {
        final txId = _uuid.v4();

        await into(transactions).insert(
          TransactionsCompanion.insert(
            id: txId,
            transactionType: rule.transactionType,
            amountOriginalSatang: rule.amountSatang,
            currencyCode: rule.currencyCode,
            amountThbSatang: rule.amountSatang, // rule is in primary currency
            sourceAccountId: Value(rule.sourceAccountId),
            destinationAccountId: Value(rule.destinationAccountId),
            categoryId: Value(rule.categoryId),
            transactionDate: dueDate,
            note: Value(rule.note ?? 'สร้างอัตโนมัติจากกฎ: ${rule.title}'),
            tag: const Value('recurring_auto'),
            createdAt: now,
            updatedAt: now,
          ),
        );

        await into(auditLogs).insert(
          AuditLogsCompanion.insert(
            id: _uuid.v4(),
            entityTable: 'transactions',
            entityId: txId,
            action: 'AUTO_POST_RECURRING',
            afterDataJson: Value('{"ruleId": "${rule.id}", "dueDate": "$dueDate"}'),
            changeTimestamp: now,
            createdAt: now,
            updatedAt: now,
          ),
        );

        lastPosted = dueDate;
        postedCount++;
      }

      if (dueDates.isNotEmpty && lastPosted != null) {
        final nextDate = RecurringEngine.computeNextRunDate(
          frequency: rule.frequency,
          intervalUnits: rule.intervalUnits,
          fromDate: dueDates.last,
          dayOfMonth: rule.dayOfMonth,
        );

        final isExpired = rule.endDate != null && nextDate.isAfter(rule.endDate!);

        await (update(recurringRules)..where((r) => r.id.equals(rule.id))).write(
          RecurringRulesCompanion(
            lastPostedDate: Value(lastPosted),
            nextRunDate: Value(nextDate),
            isActive: Value(!isExpired),
            updatedAt: Value(now),
          ),
        );
      }
    }

    return postedCount;
  }

  /// Manually execute or confirm a single due recurring rule for a specific date
  Future<void> postSingleOccurrence(String ruleId, DateTime dueDate) async {
    final rule = await getRuleById(ruleId);
    if (rule == null) return;

    final now = DateTime.now();
    final txId = _uuid.v4();

    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: txId,
        transactionType: rule.transactionType,
        amountOriginalSatang: rule.amountSatang,
        currencyCode: rule.currencyCode,
        amountThbSatang: rule.amountSatang,
        sourceAccountId: Value(rule.sourceAccountId),
        destinationAccountId: Value(rule.destinationAccountId),
        categoryId: Value(rule.categoryId),
        transactionDate: dueDate,
        note: Value(rule.note ?? 'ยืนยันจากกฎ: ${rule.title}'),
        tag: const Value('recurring_manual_confirmed'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    final nextDate = RecurringEngine.computeNextRunDate(
      frequency: rule.frequency,
      intervalUnits: rule.intervalUnits,
      fromDate: dueDate,
      dayOfMonth: rule.dayOfMonth,
    );
    final isExpired = rule.endDate != null && nextDate.isAfter(rule.endDate!);

    await (update(recurringRules)..where((r) => r.id.equals(rule.id))).write(
      RecurringRulesCompanion(
        lastPostedDate: Value(dueDate),
        nextRunDate: Value(nextDate),
        isActive: Value(!isExpired),
        updatedAt: Value(now),
      ),
    );
  }

  /// Returns projected occurrences for all active rules in the next [windowDays] (default 30 days)
  Future<List<({RecurringRule rule, DateTime projectedDate})>> getUpcoming30Days({int windowDays = 30}) async {
    final active = await getActiveRules();
    final results = <({RecurringRule rule, DateTime projectedDate})>[];

    for (final rule in active) {
      final dates = RecurringEngine.projectUpcomingDates(
        nextRunDate: rule.nextRunDate,
        frequency: rule.frequency,
        intervalUnits: rule.intervalUnits,
        dayOfMonth: rule.dayOfMonth,
        endDate: rule.endDate,
        windowDays: windowDays,
      );

      for (final d in dates) {
        results.add((rule: rule, projectedDate: d));
      }
    }

    results.sort((a, b) => a.projectedDate.compareTo(b.projectedDate));
    return results;
  }
}
