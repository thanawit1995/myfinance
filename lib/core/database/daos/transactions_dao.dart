import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/transactions_table.dart';
import '../tables/audit_logs_table.dart';
import '../tables/fx_rates_table.dart';
import '../tables/categories_table.dart';

part 'transactions_dao.g.dart';

class CategoryExpenseSummary {
  final String categoryId;
  final String categoryNameTh;
  final String categoryNameEn;
  final String? color;
  final String? icon;
  final int totalSatang;

  const CategoryExpenseSummary({
    required this.categoryId,
    required this.categoryNameTh,
    required this.categoryNameEn,
    this.color,
    this.icon,
    required this.totalSatang,
  });
}

class MonthTrendSummary {
  final int year;
  final int month;
  final int incomeSatang;
  final int expenseSatang;

  const MonthTrendSummary({
    required this.year,
    required this.month,
    required this.incomeSatang,
    required this.expenseSatang,
  });
}

@DriftAccessor(tables: [Transactions, AuditLogs, FxRates, Categories])
class TransactionsDao extends DatabaseAccessor<AppDatabase> with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  static const _uuid = Uuid();

  /// Callback ที่ถูกเรียกเมื่อมีการบันทึก แก้ไข หรือลบรายการธุรกรรม
  void Function()? onLedgerModified;

  Stream<List<Transaction>> watchRecentTransactions({int limit = 50}) {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .watch();
  }

  Future<List<Transaction>> getRecentTransactions({int limit = 50}) {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .get();
  }

  Future<List<Transaction>> getAllTransactions() {
    return (select(transactions)..where((t) => t.deletedAt.isNull())).get();
  }

  Future<List<Transaction>> getTransactionsForAccount(String accountId, {int limit = 50}) {
    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .get();
  }

  Stream<List<Transaction>> watchTransactionsForAccount(String accountId, {int limit = 50}) {
    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(limit))
        .watch();
  }

  Future<Transaction?> getLastTransaction() {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Transaction?> getTransactionById(String id) {
    return (select(transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTransaction(TransactionsCompanion entry) async {
    final now = DateTime.now();

    // 1. Insert transaction
    final result = await into(transactions).insert(entry);

    // 2. If FX rate is provided and not 1.0, record in fx_rates
    if (entry.currencyCode.value != 'THB' &&
        entry.fxRate.present &&
        entry.fxRate.value != '1.000000') {
      await into(fxRates).insert(
        FxRatesCompanion.insert(
          id: _uuid.v4(),
          baseCurrency: entry.currencyCode.value,
          targetCurrency: 'THB',
          rate: entry.fxRate.value,
          effectiveDate: entry.transactionDate.value,
          note: Value('Auto-recorded from transaction ${entry.id.value}'),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }

    // 3. Record Audit Log
    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'transactions',
        entityId: entry.id.value,
        action: 'CREATE',
        afterDataJson: Value(jsonEncode({
          'id': entry.id.value,
          'type': entry.transactionType.value,
          'amountOriginal': entry.amountOriginalSatang.value,
          'amountThb': entry.amountThbSatang.value,
          'feeThb': entry.feeThbSatang.present ? entry.feeThbSatang.value : 0,
          'source': entry.sourceAccountId.present ? entry.sourceAccountId.value : null,
          'dest': entry.destinationAccountId.present ? entry.destinationAccountId.value : null,
          'category': entry.categoryId.present ? entry.categoryId.value : null,
          'tag': entry.tag.present ? entry.tag.value : null,
          'date': entry.transactionDate.value.toIso8601String(),
        })),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );

    // 4. Auto-sync foreign remittance if this is a transfer
    if (entry.transactionType.value == 'transfer') {
      final tx = await getTransactionById(entry.id.value);
      if (tx != null) {
        await db.remittancesDao.syncFromTransferTransaction(tx);
      }
    }

    // 5. Notify ledger modification (for rolling auto-backup)
    onLedgerModified?.call();

    return result;
  }

  Future<bool> updateTransaction(TransactionsCompanion updated) async {
    final before = await getTransactionById(updated.id.value);
    if (before == null) return false;

    final now = DateTime.now();
    final success = await (update(transactions)..where((t) => t.id.equals(updated.id.value)))
        .write(updated);

    if (success > 0) {
      // Record Audit Log
      await into(auditLogs).insert(
        AuditLogsCompanion.insert(
          id: _uuid.v4(),
          entityTable: 'transactions',
          entityId: updated.id.value,
          action: 'UPDATE',
          beforeDataJson: Value(jsonEncode({
            'id': before.id,
            'type': before.transactionType,
            'amountOriginal': before.amountOriginalSatang,
            'amountThb': before.amountThbSatang,
            'feeThb': before.feeThbSatang,
            'source': before.sourceAccountId,
            'dest': before.destinationAccountId,
            'category': before.categoryId,
            'tag': before.tag,
            'date': before.transactionDate.toIso8601String(),
          })),
          afterDataJson: Value(jsonEncode({
            'id': updated.id.value,
            'type': updated.transactionType.present ? updated.transactionType.value : before.transactionType,
            'amountOriginal': updated.amountOriginalSatang.present ? updated.amountOriginalSatang.value : before.amountOriginalSatang,
            'amountThb': updated.amountThbSatang.present ? updated.amountThbSatang.value : before.amountThbSatang,
            'feeThb': updated.feeThbSatang.present ? updated.feeThbSatang.value : before.feeThbSatang,
            'source': updated.sourceAccountId.present ? updated.sourceAccountId.value : before.sourceAccountId,
            'dest': updated.destinationAccountId.present ? updated.destinationAccountId.value : before.destinationAccountId,
            'category': updated.categoryId.present ? updated.categoryId.value : before.categoryId,
            'tag': updated.tag.present ? updated.tag.value : before.tag,
            'date': updated.transactionDate.present ? updated.transactionDate.value.toIso8601String() : before.transactionDate.toIso8601String(),
          })),
          changeTimestamp: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Auto-sync foreign remittance
      final tx = await getTransactionById(updated.id.value);
      if (tx != null) {
        await db.remittancesDao.syncFromTransferTransaction(tx);
      }

      // Notify ledger modification (for rolling auto-backup)
      onLedgerModified?.call();
    }

    return success > 0;
  }

  Future<bool> softDeleteTransaction(String id) async {
    final before = await getTransactionById(id);
    if (before == null) return false;

    final now = DateTime.now();
    final count = await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (count > 0) {
      await db.remittancesDao.deleteRemittanceForTransaction(id);
      await db.investmentsDao.handleInvestmentTransactionDeleted(id, before.tag);
      // Record Audit Log
      await into(auditLogs).insert(
        AuditLogsCompanion.insert(
          id: _uuid.v4(),
          entityTable: 'transactions',
          entityId: id,
          action: 'DELETE',
          beforeDataJson: Value(jsonEncode({
            'id': before.id,
            'type': before.transactionType,
            'amountOriginal': before.amountOriginalSatang,
            'amountThb': before.amountThbSatang,
            'feeThb': before.feeThbSatang,
            'date': before.transactionDate.toIso8601String(),
          })),
          changeTimestamp: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Notify ledger modification (for rolling auto-backup)
      onLedgerModified?.call();
    }

    return count > 0;
  }

  Future<List<Transaction>> searchTransactions({
    String? query,
    DateTime? startDate,
    DateTime? endDate,
    String? accountId,
    String? categoryId,
    String? transactionType, // 'income', 'expense', 'transfer', or null = all
    int? minSatang,
    int? maxSatang,
    bool excludeInvestments = false,
  }) {
    final q = select(transactions)..where((t) => t.deletedAt.isNull());

    if (excludeInvestments) {
      q.where((t) => t.tag.isNull() | t.tag.like('investment_%').not());
    }

    if (transactionType != null) {
      q.where((t) => t.transactionType.equals(transactionType));
    }

    if (startDate != null) {
      q.where((t) => t.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where((t) => t.transactionDate.isSmallerOrEqualValue(endDate));
    }
    if (accountId != null) {
      q.where((t) => t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId));
    }
    if (categoryId != null) {
      q.where((t) => t.categoryId.equals(categoryId));
    }
    if (minSatang != null) {
      q.where((t) => t.amountThbSatang.isBiggerOrEqualValue(minSatang));
    }
    if (maxSatang != null) {
      q.where((t) => t.amountThbSatang.isSmallerOrEqualValue(maxSatang));
    }
    if (query != null && query.trim().isNotEmpty) {
      final term = '%${query.trim()}%';
      q.where((t) => t.note.like(term) | t.tag.like(term) | t.workPeriod.like(term));
    }

    q.orderBy([(t) => OrderingTerm.desc(t.transactionDate)]);
    return q.get();
  }

  /// Calculates monthly expense totals broken down by category for Donut chart.
  Future<List<CategoryExpenseSummary>> getMonthlyExpensesByCategory(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);

    final trans = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('expense') &
              t.transactionDate.isBiggerOrEqualValue(start) &
              t.transactionDate.isSmallerThanValue(end)))
        .get();

    final categoryMap = <String, int>{};
    for (final t in trans) {
      final catId = t.categoryId ?? 'uncategorized';
      final total = t.amountThbSatang + t.feeThbSatang;
      categoryMap[catId] = (categoryMap[catId] ?? 0) + total;
    }

    final allCats = await select(categories).get();
    final catLookup = {for (final c in allCats) c.id: c};

    final result = <CategoryExpenseSummary>[];
    for (final entry in categoryMap.entries) {
      final cat = catLookup[entry.key];
      result.add(CategoryExpenseSummary(
        categoryId: entry.key,
        categoryNameTh: cat?.nameTh ?? 'ไม่ระบุหมวดหมู่',
        categoryNameEn: cat?.nameEn ?? 'Uncategorized',
        color: cat?.color,
        icon: cat?.icon,
        totalSatang: entry.value,
      ));
    }

    result.sort((a, b) => b.totalSatang.compareTo(a.totalSatang));
    return result;
  }

  /// Calculates 6-month income and expense trends for Bar chart.
  Future<List<MonthTrendSummary>> getMonthlyTrend(int lastMonths) async {
    final now = DateTime.now();
    final result = <MonthTrendSummary>[];

    for (int i = lastMonths - 1; i >= 0; i--) {
      final target = DateTime(now.year, now.month - i, 1);
      final start = DateTime(target.year, target.month, 1);
      final end = DateTime(target.month == 12 ? target.year + 1 : target.year, target.month == 12 ? 1 : target.month + 1, 1);

      final trans = await (select(transactions)
            ..where((t) =>
                t.deletedAt.isNull() &
                t.transactionDate.isBiggerOrEqualValue(start) &
                t.transactionDate.isSmallerThanValue(end)))
          .get();

      int income = 0;
      int expense = 0;

      for (final t in trans) {
        if (t.transactionType == 'income') {
          income += t.amountThbSatang;
        } else if (t.transactionType == 'expense') {
          expense += (t.amountThbSatang + t.feeThbSatang);
        }
      }

      result.add(MonthTrendSummary(
        year: target.year,
        month: target.month,
        incomeSatang: income,
        expenseSatang: expense,
      ));
    }

    return result;
  }

  /// ดึงรายการรายได้ค้างรับ/เงินตกเบิกที่ยังไม่ได้รับเงินจริง (isCleared == false)
  Stream<List<Transaction>> watchAccruedIncomes() {
    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('income') &
              t.isCleared.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.workPeriod),
            (t) => OrderingTerm.desc(t.transactionDate),
          ]))
        .watch();
  }

  Future<List<Transaction>> getAccruedIncomes() {
    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('income') &
              t.isCleared.equals(false))
          ..orderBy([
            (t) => OrderingTerm.desc(t.workPeriod),
            (t) => OrderingTerm.desc(t.transactionDate),
          ]))
        .get();
  }

  /// แปลงรอบเดือน เช่น "2026-09" เป็น tag ที่อ่านเข้าใจง่าย เช่น "รายได้ ก.ย. 2026"
  static String formatPeriodToTag(String period) {
    final trimmed = period.trim();
    final parts = trimmed.split('-');
    if (parts.length == 2) {
      final year = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      if (year != null && month != null && month >= 1 && month <= 12) {
        const thaiShortMonths = [
          'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
          'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.'
        ];
        return 'รายได้ ${thaiShortMonths[month - 1]} $year';
      }
    }
    return 'รายได้รอบ $trimmed';
  }

  /// บันทึกรับเงินเข้าบัญชีจริง (Mark as Received)
  Future<bool> markIncomeAsReceived(
    String transactionId, {
    required String accountId,
    required DateTime receivedDate,
    int? actualAmountSatang,
  }) async {
    final existing = await getTransactionById(transactionId);
    if (existing == null) return false;

    final now = DateTime.now();
    final updatedAmount = actualAmountSatang ?? existing.amountThbSatang;

    // ติด tag รอบรายได้ถ้ามี workPeriod เพื่อให้ค้นหา/ดูย้อนหลังได้ชัดเจน
    String? updatedTag = existing.tag;
    if (existing.workPeriod != null && existing.workPeriod!.trim().isNotEmpty) {
      final periodTag = formatPeriodToTag(existing.workPeriod!);
      if (updatedTag == null || updatedTag.trim().isEmpty) {
        updatedTag = periodTag;
      } else if (!updatedTag.contains(periodTag) && !updatedTag.contains(existing.workPeriod!)) {
        updatedTag = '$updatedTag, $periodTag';
      }
    }

    final updated = await (update(transactions)..where((t) => t.id.equals(transactionId))).write(
      TransactionsCompanion(
        isCleared: const Value(true),
        sourceAccountId: Value(accountId),
        transactionDate: Value(receivedDate),
        amountThbSatang: Value(updatedAmount),
        amountOriginalSatang: Value(updatedAmount),
        tag: Value(updatedTag),
        updatedAt: Value(now),
      ),
    );

    if (updated > 0) {
      await into(auditLogs).insert(
        AuditLogsCompanion.insert(
          id: _uuid.v4(),
          entityTable: 'transactions',
          entityId: transactionId,
          action: 'UPDATE',
          beforeDataJson: Value(jsonEncode({
            'is_cleared': existing.isCleared,
            'source_account_id': existing.sourceAccountId,
            'transaction_date': existing.transactionDate.toIso8601String(),
            'amount_thb_satang': existing.amountThbSatang,
            'tag': existing.tag,
          })),
          afterDataJson: Value(jsonEncode({
            'is_cleared': true,
            'source_account_id': accountId,
            'transaction_date': receivedDate.toIso8601String(),
            'amount_thb_satang': updatedAmount,
            'tag': updatedTag,
          })),
          changeTimestamp: now,
          createdAt: now,
          updatedAt: now,
        ),
      );
      return true;
    }
    return false;
  }

  /// ติด tag รอบรายได้ให้กับรายการ accrued income ทั้งหมดที่ยังไม่มี tag ย้อนหลัง
  Future<int> autoTagExistingAccruedIncomes() async {
    final txs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('income') &
              t.workPeriod.isNotNull()))
        .get();

    int updatedCount = 0;
    for (final tx in txs) {
      final wp = tx.workPeriod;
      if (wp == null || wp.trim().isEmpty) continue;
      final periodTag = formatPeriodToTag(wp);
      final currentTag = tx.tag;
      if (currentTag == null || currentTag.trim().isEmpty) {
        await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            tag: Value(periodTag),
            updatedAt: Value(DateTime.now()),
          ),
        );
        updatedCount++;
      } else if (!currentTag.contains(periodTag) && !currentTag.contains(wp)) {
        await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            tag: Value('$currentTag, $periodTag'),
            updatedAt: Value(DateTime.now()),
          ),
        );
        updatedCount++;
      }
    }
    return updatedCount;
  }

  Future<int> cleanupUnclearedExpenses() async {
    return customUpdate(
      "UPDATE transactions SET is_cleared = 1, work_period = NULL, expected_amount_satang = NULL WHERE transaction_type != 'income' AND is_cleared = 0;",
      updates: {transactions},
    );
  }

  /// Cleans up legacy imported notes that contain Notion relation URLs or duplicate tags
  Future<int> cleanDistortedNotionNotes() async {
    final txs = await (select(transactions)
          ..where((t) => t.note.isNotNull() & t.note.like('%http%')))
        .get();

    int cleanedCount = 0;
    for (final tx in txs) {
      if (tx.note == null) continue;
      var clean = tx.note!
          .replaceAll(RegExp(r'\s*\(\s*https?:\/\/[^\)]+\)'), '')
          .replaceAll(RegExp(r'https?:\/\/\S+'), '')
          .replaceAll(RegExp(r'\(\s*\)'), '')
          .trim();

      final parenMatch = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(clean);
      if (parenMatch != null) {
        final mainName = parenMatch.group(1)!.trim();
        final subName = parenMatch.group(2)!.trim();
        if (subName.contains(mainName) ||
            mainName.contains(subName) ||
            subName.contains('_') ||
            subName.startsWith('🏧') ||
            subName.startsWith('👝') ||
            subName.startsWith('💼')) {
          clean = mainName;
        }
      }

      if (clean != tx.note && clean.isNotEmpty) {
        await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            note: Value(clean),
            updatedAt: Value(DateTime.now()),
          ),
        );
        cleanedCount++;
      }
    }
    return cleanedCount;
  }

  /// Align transaction_date with work_period for income transactions imported from Notion
  /// e.g. P4P received on 2026-09-25 with work_period '2026-08' should be dated 2026-08-25
  Future<int> alignIncomeDatesWithWorkPeriod() async {
    final txs = await (select(transactions)
          ..where((t) =>
              t.transactionType.equals('income') &
              t.workPeriod.isNotNull() &
              t.deletedAt.isNull()))
        .get();

    int updatedCount = 0;
    for (final tx in txs) {
      final period = tx.workPeriod;
      if (period == null || !period.contains('-')) continue;
      final parts = period.split('-');
      if (parts.length != 2) continue;
      final targetYear = int.tryParse(parts[0]);
      final targetMonth = int.tryParse(parts[1]);
      if (targetYear == null || targetMonth == null || targetMonth < 1 || targetMonth > 12) continue;

      if (tx.transactionDate.year != targetYear || tx.transactionDate.month != targetMonth) {
        final daysInTargetMonth = DateTime(targetYear, targetMonth + 1, 0).day;
        final targetDay = tx.transactionDate.day.clamp(1, daysInTargetMonth);
        final newDate = DateTime(
          targetYear,
          targetMonth,
          targetDay,
          tx.transactionDate.hour,
          tx.transactionDate.minute,
          tx.transactionDate.second,
        );

        final payDayStr = '${tx.transactionDate.day.toString().padLeft(2, '0')}/${tx.transactionDate.month.toString().padLeft(2, '0')}/${tx.transactionDate.year}';
        var note = tx.note ?? '';
        if (!note.contains('รับเงินจริง')) {
          note = note.isEmpty ? 'รับเงินจริง: $payDayStr' : '$note (รับเงินจริง: $payDayStr)';
        }

        await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            transactionDate: Value(newDate),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
        updatedCount++;
      }
    }
    return updatedCount;
  }

  // ─── Trash Bin ──────────────────────────────────────────────────────────────

  /// Returns all soft-deleted transactions currently in the trash bin,
  /// ordered by deleted_at descending (most recently deleted first).
  Future<List<Transaction>> getDeletedTransactions() {
    return (select(transactions)
          ..where((t) => t.deletedAt.isNotNull())
          ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
        .get();
  }

  /// Restores a soft-deleted transaction from the trash bin.
  Future<bool> restoreTransaction(String id) async {
    final now = DateTime.now();
    final count = await (update(transactions)..where((t) => t.id.equals(id))).write(
      TransactionsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );
    return count > 0;
  }

  /// Permanently deletes a transaction (hard delete, cannot be undone).
  Future<void> permanentlyDeleteTransaction(String id) async {
    await (delete(transactions)..where((t) => t.id.equals(id))).go();
  }

  /// Auto-purges transactions that have been in the trash for more than 30 days.
  Future<int> cleanupExpiredDeletedTransactions() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    return (delete(transactions)
          ..where((t) => t.deletedAt.isNotNull() & t.deletedAt.isSmallerThanValue(cutoff)))
        .go();
  }

  /// ค้นหาและล้างรายการธุรกรรมที่ซ้ำกัน (Deduplicate)
  /// ใช้เกณฑ์: วันที่ (YYYY-MM-DD), จำนวนเงินสตางค์, ประเภทรายการ, และบันทึก
  /// ตัดปัญหาเรื่องความต่างของ Timezone (UTC vs Local) หรือ Account ID ที่ต่างกันจากการสร้างคนละอุปกรณ์
  Future<List<String>> deduplicateTransactions() async {
    final allTx = await (select(transactions)
          ..where((t) => t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
        .get();

    // Query active buy transaction IDs linked to investment lots to ensure they are NEVER accidentally deduplicated
    final linkedLotTxIds = <String>{};
    try {
      final lots = await (attachedDatabase.select(attachedDatabase.investmentLots)
            ..where((l) => l.deletedAt.isNull()))
          .get();
      for (final lot in lots) {
        linkedLotTxIds.add(lot.buyTransactionId);
      }
    } catch (_) {}

    final Map<String, Transaction> seen = {};
    final List<String> duplicateIds = [];

    for (final tx in allTx) {
      // NEVER delete a transaction that is backing an active investment lot
      if (linkedLotTxIds.contains(tx.id)) {
        continue;
      }

      final d = tx.transactionDate;
      final dateKey = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      final cleanNote = (tx.note ?? '').trim().toLowerCase();
      final tagStr = tx.tag ?? '';

      final String sig;
      if (tagStr.isNotEmpty && tagStr.startsWith('investment_')) {
        // Investment trades include currency, original satang, and tag in signature
        sig = '$dateKey|${tx.amountOriginalSatang}|${tx.amountThbSatang}|${tx.currencyCode}|${tx.transactionType}|$tagStr|${tx.sourceAccountId ?? ""}|$cleanNote';
      } else if (cleanNote.isNotEmpty) {
        sig = '$dateKey|${tx.amountThbSatang}|${tx.transactionType}|$cleanNote';
      } else {
        sig = '$dateKey|${tx.amountThbSatang}|${tx.transactionType}|${tx.sourceAccountId ?? ""}|$tagStr';
      }

      if (seen.containsKey(sig)) {
        duplicateIds.add(tx.id);
      } else {
        seen[sig] = tx;
      }
    }

    if (duplicateIds.isNotEmpty) {
      const chunkSize = 200;
      for (var i = 0; i < duplicateIds.length; i += chunkSize) {
        final chunk = duplicateIds.sublist(i, min(i + chunkSize, duplicateIds.length));
        await (delete(transactions)..where((t) => t.id.isIn(chunk))).go();
      }
      onLedgerModified?.call();
    }

    return duplicateIds;
  }
}

