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
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)) &
              (t.isCleared.equals(true) | t.transactionType.equals('income').not()))
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
    String? workPeriod,
  }) {
    final q = select(transactions)..where((t) => t.deletedAt.isNull());

    if (excludeInvestments) {
      q.where((t) => t.tag.isNull() | t.tag.like('investment_%').not());
    }

    if (transactionType != null) {
      q.where((t) => t.transactionType.equals(transactionType));
    }

    if (workPeriod != null && workPeriod.trim().isNotEmpty) {
      q.where((t) => t.workPeriod.equals(workPeriod.trim()));
    }

    if (startDate != null) {
      q.where((t) => t.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      q.where((t) => t.transactionDate.isSmallerOrEqualValue(endDate));
    }
    if (accountId != null) {
      q.where((t) =>
          (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)) &
          (t.isCleared.equals(true) | t.transactionType.equals('income').not()));
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

  /// ดึงข้อมูลรายการธุรกรรมสำหรับหน้ารายงานสรุปภาพรวม (Financial Summary)
  /// โดยจัดกลุ่มรายได้ที่มีรอบการทำงาน (workPeriod) ให้อยู่ในรอบเดือนที่ทำงานจริง
  /// ไม่ว่าวันที่บันทึกรายการ (transactionDate) จะเป็นวันใด
  /// หรือหาก [isCashBasis] เป็น true จะคำนวณตามวันที่รับ/จ่ายเงินจริง (transactionDate) 100%
  Future<List<Transaction>> getTransactionsForSummary({
    required DateTime startDate,
    required DateTime endDate,
    String? targetWorkPeriod,
    bool isCashBasis = false,
  }) async {
    // 1. Transactions within date range
    final dateTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBiggerOrEqualValue(startDate) &
              t.transactionDate.isSmallerOrEqualValue(endDate)))
        .get();

    // หากอยู่ในโหมด Cash Basis: ยึดตามวันที่เงินเข้า/ออกจริง (transactionDate) 100%
    if (isCashBasis) {
      dateTxs.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
      return dateTxs;
    }

    // 2. Income transactions with workPeriod
    final workPeriodTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('income') &
              t.workPeriod.isNotNull()))
        .get();

    final allMap = <String, Transaction>{};
    for (final t in dateTxs) {
      allMap[t.id] = t;
    }
    for (final t in workPeriodTxs) {
      allMap[t.id] = t;
    }

    final result = <Transaction>[];
    for (final t in allMap.values) {
      if (t.transactionType == 'income' && t.workPeriod != null && t.workPeriod!.trim().isNotEmpty) {
        final wp = t.workPeriod!.trim();
        if (targetWorkPeriod != null) {
          // Explicit target workPeriod (e.g. '2026-09')
          if (wp == targetWorkPeriod) {
            result.add(t);
          }
        } else {
          // Range-based workPeriod check
          final parts = wp.split('-');
          if (parts.length == 2) {
            final y = int.tryParse(parts[0]);
            final m = int.tryParse(parts[1]);
            if (y != null && m != null && m >= 1 && m <= 12) {
              final wpStart = DateTime(y, m, 1);
              final wpEnd = DateTime(y, m + 1, 0, 23, 59, 59, 999);
              if (wpStart.isBefore(endDate) && wpEnd.isAfter(startDate)) {
                result.add(t);
              }
            }
          }
        }
      } else {
        // Transactions without workPeriod: must fall strictly inside transactionDate range
        if ((t.transactionDate.isAfter(startDate) || t.transactionDate.isAtSameMomentAs(startDate)) &&
            (t.transactionDate.isBefore(endDate) || t.transactionDate.isAtSameMomentAs(endDate))) {
          result.add(t);
        }
      }
    }

    result.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
    return result;
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

    // รักษารอบเดือนของรายได้ไว้เสมอ:
    // หากเดิมมี workPeriod ให้ใช้ค่าเดิม หากเดิมยังไม่มี ให้คำนวณจาก transactionDate เดิมของรายการนั้น
    String? effectiveWorkPeriod = existing.workPeriod;
    if (effectiveWorkPeriod == null || effectiveWorkPeriod.trim().isEmpty) {
      effectiveWorkPeriod = '${existing.transactionDate.year}-${existing.transactionDate.month.toString().padLeft(2, '0')}';
    }

    // ติด tag รอบรายได้เพื่อให้ค้นหา/ดูย้อนหลังได้ชัดเจน
    String? updatedTag = existing.tag;
    final periodTag = formatPeriodToTag(effectiveWorkPeriod);
    if (updatedTag == null || updatedTag.trim().isEmpty) {
      updatedTag = periodTag;
    } else if (!updatedTag.contains(periodTag) && !updatedTag.contains(effectiveWorkPeriod)) {
      updatedTag = '$updatedTag, $periodTag';
    }

    final updated = await (update(transactions)..where((t) => t.id.equals(transactionId))).write(
      TransactionsCompanion(
        isCleared: const Value(true),
        sourceAccountId: Value(accountId),
        transactionDate: Value(receivedDate),
        amountThbSatang: Value(updatedAmount),
        amountOriginalSatang: Value(updatedAmount),
        workPeriod: Value(effectiveWorkPeriod),
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
            'work_period': existing.workPeriod,
            'tag': existing.tag,
          })),
          afterDataJson: Value(jsonEncode({
            'is_cleared': true,
            'source_account_id': accountId,
            'transaction_date': receivedDate.toIso8601String(),
            'amount_thb_satang': updatedAmount,
            'work_period': effectiveWorkPeriod,
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

  /// ทำซ้ำรายการธุรกรรม (Duplicate Transaction)
  Future<Transaction?> duplicateTransaction(
    String transactionId, {
    DateTime? newDate,
  }) async {
    final existing = await getTransactionById(transactionId);
    if (existing == null) return null;

    final now = DateTime.now();
    final targetDate = newDate ?? now;
    final newId = _uuid.v4();

    // หากเป็น income ให้ปรับ workPeriod ให้ตรงกับรอบเดือนของ targetDate ถ้ามี
    String? newWorkPeriod = existing.workPeriod;
    if (existing.transactionType == 'income') {
      newWorkPeriod = '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}';
    }

    final newTx = TransactionsCompanion.insert(
      id: newId,
      transactionType: existing.transactionType,
      amountOriginalSatang: existing.amountOriginalSatang,
      currencyCode: existing.currencyCode,
      amountThbSatang: existing.amountThbSatang,
      feeThbSatang: Value(existing.feeThbSatang),
      fxRate: Value(existing.fxRate),
      note: Value(existing.note),
      categoryId: Value(existing.categoryId),
      sourceAccountId: Value(existing.sourceAccountId),
      destinationAccountId: Value(existing.destinationAccountId),
      transactionDate: targetDate,
      tag: Value(existing.tag),
      taxCategory: Value(existing.taxCategory),
      withholdingTaxSatang: Value(existing.withholdingTaxSatang),
      workPeriod: Value(newWorkPeriod),
      isCleared: Value(existing.isCleared),
      expectedAmountSatang: Value(existing.expectedAmountSatang),
      createdAt: now,
      updatedAt: now,
    );

    await insertTransaction(newTx);
    return getTransactionById(newId);
  }

  /// ดึงประวัติรายการธุรกรรมตามประเภท ย้อนหลังตามช่วงเวลา (สำหรับหน้า Quick Add History)
  Future<List<Transaction>> getRecentTransactionsByType({
    required String transactionType,
    required DateTime sinceDate,
    int limit = 100,
  }) {
    final q = select(transactions)
      ..where((t) =>
          t.deletedAt.isNull() &
          t.transactionType.equals(transactionType) &
          t.transactionDate.isBiggerOrEqualValue(sinceDate))
      ..orderBy([
        (t) => OrderingTerm.desc(t.transactionDate),
        (t) => OrderingTerm.desc(t.createdAt),
      ])
      ..limit(limit);

    return q.get();
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
      // 1. NEVER delete a transaction that is backing an active investment lot
      if (linkedLotTxIds.contains(tx.id)) {
        continue;
      }

      final tagStr = tx.tag ?? '';
      final noteStr = tx.note ?? '';

      // 2. CRITICAL: Only automated recurring transactions (auto-posted from recurring rules)
      // are eligible for deduplication. Normal manual transactions entered by the user
      // (even with identical amount, note, and date) must NEVER be deleted!
      final isRecurringAuto = tagStr.contains('recurring_auto') ||
          noteStr.contains('สร้างอัตโนมัติจากกฎ:') ||
          noteStr.contains('auto-posted from rule:');

      if (!isRecurringAuto) {
        continue;
      }

      final d = tx.transactionDate.toLocal();
      final dateKey = '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

      String cleanNote = noteStr.trim().toLowerCase();
      cleanNote = cleanNote.replaceFirst('สร้างอัตโนมัติจากกฎ:', '').trim();
      cleanNote = cleanNote.replaceFirst('auto-posted from rule:', '').trim();
      cleanNote = cleanNote
          .replaceAll(RegExp(r'\[work_period:[^\]]+\]'), '')
          .replaceAll(RegExp(r'\[tax_cat:[^\]]+\]'), '')
          .replaceAll('[accrued]', '')
          .replaceAll(RegExp(r'\[dom:\d+\]'), '')
          .replaceAll(RegExp(r'\[day_of_month:\d+\]'), '')
          .trim();

      // Signature for recurring auto duplicates: same date, same amount, same type, same account, same clean note
      final sig = '$dateKey|${tx.amountThbSatang}|${tx.transactionType}|${tx.sourceAccountId ?? ""}|$cleanNote';

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

  /// Optimized summary calculation for month cash flow & daily expense breakdown
  Future<({
    int totalIncomeSatang,
    int totalExpenseSatang,
    Map<int, int> dailyExpenses,
  })> getMonthlyCashFlowSummary(int year, int month, int upToDay) async {
    final startOfMonth = DateTime(year, month, 1);
    final endOfMonth = DateTime(month == 12 ? year + 1 : year, month == 12 ? 1 : month + 1, 1);

    final monthTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionDate.isBiggerOrEqualValue(startOfMonth) &
              t.transactionDate.isSmallerThanValue(endOfMonth)))
        .get();

    int totalIncome = 0;
    int totalExpense = 0;
    final Map<int, int> daily = {};
    for (int d = 1; d <= upToDay; d++) {
      daily[d] = 0;
    }

    for (final t in monthTxs) {
      if (t.transactionType == 'income') {
        if (!t.isCleared) continue;
        totalIncome += t.amountThbSatang;
      } else if (t.transactionType == 'expense') {
        final expAmount = t.amountThbSatang + t.feeThbSatang;
        totalExpense += expAmount;
        final d = t.transactionDate.day;
        if (d <= upToDay) {
          daily[d] = (daily[d] ?? 0) + expAmount;
        }
      }
    }

    return (
      totalIncomeSatang: totalIncome,
      totalExpenseSatang: totalExpense,
      dailyExpenses: daily,
    );
  }
}

