import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';
import 'transactions_dao.dart';
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
    try {
      await repairErroneousAutoPostsAndAlignDates(nowOverride: now);
    } catch (_) {}
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
        // Idempotency check:
        // For monthly rules, check if this rule has already posted anywhere in dueDate's month!
        // For non-monthly rules, check if it has already posted on dueDate.
        final DateTime rangeStart;
        final DateTime rangeEnd;
        if (rule.frequency.toLowerCase() == 'monthly') {
          rangeStart = DateTime(dueDate.year, dueDate.month, 1);
          rangeEnd = DateTime(dueDate.year, dueDate.month + 1, 0, 23, 59, 59, 999);
        } else {
          rangeStart = DateTime(dueDate.year, dueDate.month, dueDate.day);
          rangeEnd = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59, 999);
        }

        final existingTxs = await (select(transactions)
              ..where((t) =>
                  t.deletedAt.isNull() &
                  t.transactionDate.isBiggerOrEqualValue(rangeStart) &
                  t.transactionDate.isSmallerOrEqualValue(rangeEnd) &
                  t.transactionType.equals(rule.transactionType) &
                  t.amountOriginalSatang.equals(rule.amountSatang) &
                  (t.sourceAccountId.equals(rule.sourceAccountId) | t.sourceAccountId.isNull())))
            .get();

        final hasAlreadyPosted = existingTxs.any((t) {
          final tTag = t.tag ?? '';
          final tNote = t.note ?? '';
          return tTag.contains('recurring_auto') ||
              tTag.contains('recurring_manual_confirmed') ||
              tTag.contains('recurring_early_posted') ||
              tNote.contains(rule.title) ||
              (rule.note != null && rule.note!.isNotEmpty && tNote.contains(rule.note!));
        });

        if (hasAlreadyPosted) {
          lastPosted = dueDate;
          continue;
        }

        final txId = _uuid.v4();

        String? workPeriod;
        bool isCleared = rule.autoPost;
        int? expectedAmountSatang;
        String? taxCat;

        final ruleNote = rule.note ?? '';
        final hasPrevMonth = ruleNote.contains('[work_period:prev_month]');
        final hasSameMonth = ruleNote.contains('[work_period:same_month]');
        final isAccruedRule = ruleNote.contains('[accrued]');

        if (rule.transactionType == 'income') {
          if (hasPrevMonth || isAccruedRule) {
            final prevMonthDate = DateTime(dueDate.year, dueDate.month - 1, 1);
            workPeriod = '${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}';
            if (isAccruedRule) {
              isCleared = false;
              expectedAmountSatang = rule.amountSatang;
            }
          } else if (hasSameMonth) {
            workPeriod = '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';
          }

          final taxMatch = RegExp(r'\[tax_cat:([a-zA-Z0-9_]+)\]').firstMatch(ruleNote);
          if (taxMatch != null) {
            taxCat = taxMatch.group(1);
          }
        }

        String cleanNote = ruleNote
            .replaceAll(RegExp(r'\[work_period:(prev_month|same_month)\]'), '')
            .replaceAll(RegExp(r'\[tax_cat:[a-zA-Z0-9_]+\]'), '')
            .replaceAll(RegExp(r'\[(?:dom|day_of_month):\d+\]'), '')
            .replaceAll('[accrued]', '')
            .trim();
        if (cleanNote.isEmpty) {
          cleanNote = 'สร้างอัตโนมัติจากกฎ: ${rule.title}';
        }

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
            workPeriod: Value(workPeriod),
            expectedAmountSatang: Value(expectedAmountSatang),
            isCleared: Value(isCleared),
            taxCategory: Value(taxCat),
            note: Value(cleanNote),
            tag: Value(workPeriod != null && workPeriod.trim().isNotEmpty
                ? 'recurring_auto, ${TransactionsDao.formatPeriodToTag(workPeriod)}'
                : 'recurring_auto'),
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

    // Always clean up any existing duplicate entries
    try {
      await attachedDatabase.transactionsDao.deduplicateTransactions();
    } catch (_) {}

    return postedCount;
  }

  /// Repairs any auto-posted transactions that were generated on the wrong day of month
  /// (e.g. from the Oct 15 2026 sync bug where all monthly rules triggered on the sync date)
  /// and realigns each rule's nextRunDate to its proper upcoming scheduled day.
  /// Returns the list of soft-deleted erroneous transaction IDs so they can be pushed to cloud.
  Future<List<String>> repairErroneousAutoPostsAndAlignDates({DateTime? nowOverride}) async {
    final now = nowOverride ?? DateTime.now();
    final allRules = await (select(recurringRules)..where((r) => r.deletedAt.isNull())).get();

    // Find all auto-posted transactions
    final autoTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.tag.contains('recurring_auto') |
               t.tag.contains('recurring_manual_confirmed') |
               t.tag.contains('recurring_early_posted'))))
        .get();

    final erroneousTxIds = <String>[];
    final affectedRuleIds = <String>{};
    final ruleResolvedDom = <String, int>{};

    for (final rule in allRules) {
      int? dom = rule.dayOfMonth;
      if (dom == null && rule.note != null) {
        final m = RegExp(r'\[(?:dom|day_of_month):(\d+)\]').firstMatch(rule.note!);
        if (m != null) dom = int.tryParse(m.group(1)!);
      }

      final rTitle = rule.title.trim().toLowerCase();
      final rNote = (rule.note ?? '').trim().toLowerCase();

      // If dom is still null, look up historical transactions prior to the bug date (before 2026-10-15)
      if (dom == null) {
        final words = rTitle
            .split(RegExp(r'[\s\-•_/]+'))
            .where((w) => w.length > 2 && w != 'ตัดบัตรเครดิต' && w != 'จ่าย' && w != 'ประจำ')
            .toList();

        // 1. Try exact amount first
        var histQuery = select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isSmallerThanValue(DateTime(2026, 10, 15)) &
              t.transactionType.equals(rule.transactionType) &
              t.amountOriginalSatang.equals(rule.amountSatang) &
              (t.sourceAccountId.equals(rule.sourceAccountId) | t.sourceAccountId.isNull()))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(10);
        var histTxs = await histQuery.get();

        // 2. Fallback to matching by type and account if exact amount had no matches
        if (histTxs.isEmpty && words.isNotEmpty) {
          histTxs = await (select(transactions)
                ..where((t) =>
                    t.deletedAt.isNull() &
                    t.transactionDate.isSmallerThanValue(DateTime(2026, 10, 15)) &
                    t.transactionType.equals(rule.transactionType) &
                    (t.sourceAccountId.equals(rule.sourceAccountId) | t.sourceAccountId.isNull()))
                ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
                ..limit(100))
              .get();
        }

        for (final htx in histTxs) {
          final hNote = (htx.note ?? '').toLowerCase().trim();
          if (hNote.isEmpty) continue;

          bool matched = false;
          if (hNote.contains(rTitle) || rTitle.contains(hNote)) {
            matched = true;
          } else if (rNote.isNotEmpty && (hNote.contains(rNote) || rNote.contains(hNote))) {
            matched = true;
          } else if (words.isNotEmpty && words.any((w) => hNote.contains(w))) {
            matched = true;
          }

          if (matched) {
            dom = htx.transactionDate.toLocal().day;
            break;
          }
        }
      }

      if (dom == null) {
        // Domain fallback for standard user recurring bills and salary patterns
        if (rTitle.contains('ais') || rTitle.contains('mobile')) {
          dom = 8;
        } else if (rTitle.contains('กบข') || rTitle.contains('เงินเดือน') || rTitle.contains('ประจำตำแหน่ง')) {
          dom = 26;
        } else if (rTitle.contains('electric') || rTitle.contains('ไฟ')) {
          dom = 30;
        } else if (rTitle.contains('p4p') || rTitle.contains('พตส')) {
          dom = 20;
        } else if (rTitle.contains('condo') || rTitle.contains('peony') || rTitle.contains('เช่า')) {
          dom = 23;
        }
      }

      if (dom != null) {
        ruleResolvedDom[rule.id] = dom;
      }

      // Find transactions belonging to this rule
      final ruleWords = rTitle
          .split(RegExp(r'[\s\-•_/]+'))
          .where((w) => w.length > 2 && w != 'ตัดบัตรเครดิต' && w != 'จ่าย' && w != 'ประจำ')
          .toList();

      final ruleTxs = autoTxs.where((tx) {
        final matchesType = tx.transactionType == rule.transactionType;
        final matchesAmount = tx.amountOriginalSatang == rule.amountSatang;
        final matchesAccount = rule.sourceAccountId == tx.sourceAccountId || tx.sourceAccountId == null;
        final note = (tx.note ?? '').toLowerCase();
        final matchesTitle = note.contains(rTitle) ||
            rTitle.contains(note) ||
            (rNote.isNotEmpty && (note.contains(rNote) || rNote.contains(note))) ||
            (ruleWords.isNotEmpty && ruleWords.any((w) => note.contains(w)));

        return matchesType && matchesAmount && matchesAccount && matchesTitle;
      }).toList();

      if (rule.frequency.toLowerCase() == 'monthly') {
        // Group by month: 'YYYY-MM'
        final byMonth = <String, List<Transaction>>{};
        for (final tx in ruleTxs) {
          final txDate = tx.transactionDate.toLocal();
          final monthKey = '${txDate.year}-${txDate.month}';
          byMonth.putIfAbsent(monthKey, () => []).add(tx);
        }

        for (final entry in byMonth.entries) {
          final txList = entry.value;

          if (dom != null) {
            // There is a specific day of month expected
            for (final tx in txList) {
              final txDate = tx.transactionDate.toLocal();
              final daysInMonth = DateTime(txDate.year, txDate.month + 1, 0).day;
              final expectedDay = dom > daysInMonth ? daysInMonth : dom;

              final isEarly = tx.tag?.contains('recurring_early_posted') ?? false;
              // If not early-posted and the day does not match expected day, it is erroneous
              if (!isEarly && txDate.day != expectedDay) {
                erroneousTxIds.add(tx.id);
                affectedRuleIds.add(rule.id);
              }
            }
          }

          // If there are multiple transactions for this rule in the same month,
          // only keep ONE (preferring early-posted or the one on expectedDay or earliest)
          final remainingInMonth = txList.where((t) => !erroneousTxIds.contains(t.id)).toList();
          if (remainingInMonth.length > 1) {
            remainingInMonth.sort((a, b) {
              final aSpecial = (a.tag?.contains('early') ?? false) ? 0 : 1;
              final bSpecial = (b.tag?.contains('early') ?? false) ? 0 : 1;
              if (aSpecial != bSpecial) return aSpecial.compareTo(bSpecial);
              return a.createdAt.compareTo(b.createdAt);
            });
            for (var i = 1; i < remainingInMonth.length; i++) {
              erroneousTxIds.add(remainingInMonth[i].id);
              affectedRuleIds.add(rule.id);
            }
          }
        }
      }
    }

    if (erroneousTxIds.isNotEmpty) {
      // Soft-delete all erroneous transactions
      await (update(transactions)..where((t) => t.id.isIn(erroneousTxIds))).write(
        TransactionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );

      for (final txId in erroneousTxIds) {
        await into(auditLogs).insert(
          AuditLogsCompanion.insert(
            id: _uuid.v4(),
            entityTable: 'transactions',
            entityId: txId,
            action: 'SOFT_DELETE_ERRONEOUS_RECURRING',
            changeTimestamp: now,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    // Now re-align all rules to their true upcoming schedule
    for (final rule in allRules) {
      int? dom = rule.dayOfMonth ?? ruleResolvedDom[rule.id];
      if (dom == null && rule.note != null) {
        final m = RegExp(r'\[(?:dom|day_of_month):(\d+)\]').firstMatch(rule.note!);
        if (m != null) dom = int.tryParse(m.group(1)!);
      }

      if (rule.frequency.toLowerCase() == 'monthly' && dom != null) {
        final daysInNextRun = DateTime(rule.nextRunDate.year, rule.nextRunDate.month + 1, 0).day;
        final expectedDay = dom > daysInNextRun ? daysInNextRun : dom;

        final isAffected = affectedRuleIds.contains(rule.id);
        final isUnaligned = rule.nextRunDate.day != expectedDay;
        final isMissingDom = rule.dayOfMonth == null;
        final noteMissingDom = !(rule.note?.contains(RegExp(r'\[(?:dom|day_of_month):\d+\]')) ?? false);

        if (isAffected || isUnaligned || isMissingDom || noteMissingDom) {
          final nextRun = (isAffected || isUnaligned)
              ? RecurringEngine.getUpcomingRunDate(
                  fromDate: now,
                  frequency: rule.frequency,
                  intervalUnits: rule.intervalUnits,
                  dayOfMonth: dom,
                )
              : rule.nextRunDate;

          DateTime? lastPosted = rule.lastPostedDate;
          if (lastPosted != null) {
            final daysInPostedMonth = DateTime(lastPosted.year, lastPosted.month + 1, 0).day;
            final expectedPostedDay = dom > daysInPostedMonth ? daysInPostedMonth : dom;
            if (lastPosted.day != expectedPostedDay) {
              lastPosted = null;
            }
          }

          String? updatedNote = rule.note;
          if (noteMissingDom) {
            final tag = '[dom:$dom]';
            if (updatedNote == null || updatedNote.trim().isEmpty) {
              updatedNote = tag;
            } else {
              updatedNote = '${updatedNote.trim()} $tag';
            }
          }

          await (update(recurringRules)..where((r) => r.id.equals(rule.id))).write(
            RecurringRulesCompanion(
              dayOfMonth: Value(dom),
              note: Value(updatedNote),
              nextRunDate: Value(nextRun),
              lastPostedDate: Value(lastPosted),
              updatedAt: Value(now),
            ),
          );
        }
      }
    }

    return erroneousTxIds;
  }

  /// Manually execute or confirm a single due recurring rule for a specific date
  Future<void> postSingleOccurrence(String ruleId, DateTime dueDate) async {
    final rule = await getRuleById(ruleId);
    if (rule == null) return;

    final now = DateTime.now();
    final txId = _uuid.v4();

    String? workPeriod;
    bool isCleared = rule.autoPost;
    int? expectedAmountSatang;
    String? taxCat;

    final ruleNote = rule.note ?? '';
    final hasPrevMonth = ruleNote.contains('[work_period:prev_month]');
    final hasSameMonth = ruleNote.contains('[work_period:same_month]');
    final isAccruedRule = ruleNote.contains('[accrued]');

    if (rule.transactionType == 'income') {
      if (hasPrevMonth || isAccruedRule) {
        final prevMonthDate = DateTime(dueDate.year, dueDate.month - 1, 1);
        workPeriod = '${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}';
        if (isAccruedRule) {
          isCleared = false;
          expectedAmountSatang = rule.amountSatang;
        }
      } else if (hasSameMonth) {
        workPeriod = '${dueDate.year}-${dueDate.month.toString().padLeft(2, '0')}';
      }

      final taxMatch = RegExp(r'\[tax_cat:([a-zA-Z0-9_]+)\]').firstMatch(ruleNote);
      if (taxMatch != null) {
        taxCat = taxMatch.group(1);
      }
    }

    String cleanNote = ruleNote
        .replaceAll(RegExp(r'\[work_period:(prev_month|same_month)\]'), '')
        .replaceAll(RegExp(r'\[tax_cat:[a-zA-Z0-9_]+\]'), '')
        .replaceAll('[accrued]', '')
        .trim();
    if (cleanNote.isEmpty) {
      cleanNote = 'ยืนยันจากกฎ: ${rule.title}';
    }

    // Idempotency check: see if a transaction for this rule has already been posted on dueDate
    final dayStart = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final dayEnd = DateTime(dueDate.year, dueDate.month, dueDate.day, 23, 59, 59, 999);

    final existingTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBiggerOrEqualValue(dayStart) &
              t.transactionDate.isSmallerOrEqualValue(dayEnd) &
              t.transactionType.equals(rule.transactionType) &
              t.amountOriginalSatang.equals(rule.amountSatang) &
              (t.sourceAccountId.equals(rule.sourceAccountId) | t.sourceAccountId.isNull())))
        .get();

    final hasAlreadyPosted = existingTxs.any((t) {
      final tTag = t.tag ?? '';
      final tNote = t.note ?? '';
      return tTag.contains('recurring_auto') ||
          tTag.contains('recurring_manual_confirmed') ||
          tNote.contains(rule.title) ||
          (rule.note != null && rule.note!.isNotEmpty && tNote.contains(rule.note!));
    });

    if (!hasAlreadyPosted) {
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
          workPeriod: Value(workPeriod),
          expectedAmountSatang: Value(expectedAmountSatang),
          isCleared: Value(isCleared),
          taxCategory: Value(taxCat),
          note: Value(cleanNote),
          tag: const Value('recurring_manual_confirmed'),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

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

  /// Early post or customize an occurrence of a recurring rule before its scheduled due date
  Future<void> postCustomOccurrence({
    required String ruleId,
    required DateTime scheduledDueDate,
    required DateTime actualDate,
    required int amountSatang,
    required String? note,
    String? sourceAccountId,
    String? destinationAccountId,
    String? categoryId,
  }) async {
    final rule = await getRuleById(ruleId);
    if (rule == null) return;

    final now = DateTime.now();
    final txId = _uuid.v4();

    String? workPeriod;
    bool isCleared = true;
    int? expectedAmountSatang;
    String? taxCat;

    final ruleNote = rule.note ?? '';
    final hasPrevMonth = ruleNote.contains('[work_period:prev_month]');
    final hasSameMonth = ruleNote.contains('[work_period:same_month]');
    final isAccruedRule = ruleNote.contains('[accrued]');

    if (rule.transactionType == 'income') {
      if (hasPrevMonth || isAccruedRule) {
        final prevMonthDate = DateTime(scheduledDueDate.year, scheduledDueDate.month - 1, 1);
        workPeriod = '${prevMonthDate.year}-${prevMonthDate.month.toString().padLeft(2, '0')}';
        if (isAccruedRule) {
          isCleared = false;
          expectedAmountSatang = amountSatang;
        }
      } else if (hasSameMonth) {
        workPeriod = '${scheduledDueDate.year}-${scheduledDueDate.month.toString().padLeft(2, '0')}';
      }

      final taxMatch = RegExp(r'\[tax_cat:([a-zA-Z0-9_]+)\]').firstMatch(ruleNote);
      if (taxMatch != null) {
        taxCat = taxMatch.group(1);
      }
    }

    String cleanNote = (note ?? rule.title)
        .replaceAll(RegExp(r'\[work_period:(prev_month|same_month)\]'), '')
        .replaceAll(RegExp(r'\[tax_cat:[a-zA-Z0-9_]+\]'), '')
        .replaceAll('[accrued]', '')
        .trim();
    if (cleanNote.isEmpty) {
      cleanNote = rule.title;
    }

    await into(transactions).insert(
      TransactionsCompanion.insert(
        id: txId,
        transactionType: rule.transactionType,
        amountOriginalSatang: amountSatang,
        currencyCode: rule.currencyCode,
        amountThbSatang: amountSatang,
        sourceAccountId: Value(sourceAccountId ?? rule.sourceAccountId),
        destinationAccountId: Value(destinationAccountId ?? rule.destinationAccountId),
        categoryId: Value(categoryId ?? rule.categoryId),
        transactionDate: actualDate,
        workPeriod: Value(workPeriod),
        expectedAmountSatang: Value(expectedAmountSatang),
        isCleared: Value(isCleared),
        taxCategory: Value(taxCat),
        note: Value(cleanNote),
        tag: const Value('recurring_early_posted'),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'transactions',
        entityId: txId,
        action: 'EARLY_POST_RECURRING',
        afterDataJson: Value('{"ruleId": "$ruleId", "scheduledDate": "$scheduledDueDate", "actualDate": "$actualDate", "amount": $amountSatang}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Compute next run date from the scheduled dueDate to advance cycle
    final nextDate = RecurringEngine.computeNextRunDate(
      frequency: rule.frequency,
      intervalUnits: rule.intervalUnits,
      fromDate: scheduledDueDate,
      dayOfMonth: rule.dayOfMonth,
    );
    final isExpired = rule.endDate != null && nextDate.isAfter(rule.endDate!);

    await (update(recurringRules)..where((r) => r.id.equals(rule.id))).write(
      RecurringRulesCompanion(
        lastPostedDate: Value(scheduledDueDate),
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
