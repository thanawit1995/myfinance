import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'remittances_dao.g.dart';

@DriftAccessor(tables: [ForeignRemittances, Transactions, Accounts, Currencies, AuditLogs])
class RemittancesDao extends DatabaseAccessor<AppDatabase> with _$RemittancesDaoMixin {
  RemittancesDao(super.db);

  final _uuid = const Uuid();

  Future<List<ForeignRemittance>> getAllRemittances() {
    return (select(foreignRemittances)
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.desc(r.remittanceDate)]))
        .get();
  }

  Future<List<ForeignRemittance>> getRemittancesForYear(int year) async {
    await repairMisclassifiedRemittanceCurrencies();
    return (select(foreignRemittances)
          ..where((r) =>
              r.deletedAt.isNull() &
              (r.taxYearRemitted.equals(year) |
                  (r.taxYearRemitted.isNull() & r.remittanceDate.year.equals(year))))
          ..orderBy([(r) => OrderingTerm.desc(r.remittanceDate)]))
        .get();
  }

  Stream<List<ForeignRemittance>> watchRemittancesForYear(int year) {
    return (select(foreignRemittances)
          ..where((r) =>
              r.deletedAt.isNull() &
              (r.taxYearRemitted.equals(year) |
                  (r.taxYearRemitted.isNull() & r.remittanceDate.year.equals(year))))
          ..orderBy([(r) => OrderingTerm.desc(r.remittanceDate)]))
        .watch();
  }

  Future<void> createRemittance(ForeignRemittancesCompanion entry) => recordRemittance(entry);

  Future<ForeignRemittance?> getRemittanceById(String id) {
    return (select(foreignRemittances)..where((r) => r.id.equals(id) & r.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<ForeignRemittance?> getRemittanceByTransactionId(String txId) {
    return (select(foreignRemittances)
          ..where((r) => r.remittanceTransactionId.equals(txId) & r.deletedAt.isNull()))
        .getSingleOrNull();
  }

  /// Calculates remaining foreign investment principal in satang using FIFO.
  /// Principal Inflow = Transfers from Domestic (isDomestic == true) -> Offshore (isDomestic == false)
  /// Principal Outflow = Transfers from Offshore (isDomestic == false) -> Domestic (isDomestic == true)
  Future<int> getRemainingForeignPrincipalSatang({DateTime? beforeDate, String? excludeTxId}) async {
    final allAccounts = await (select(accounts)..where((a) => a.deletedAt.isNull())).get();
    final accMap = {for (var a in allAccounts) a.id: a};

    final transfers = await (select(transactions)
          ..where((t) => t.transactionType.equals('transfer') & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.transactionDate)]))
        .get();

    int totalInvestedPrincipal = 0;
    int totalRemitted = 0;

    for (final tx in transfers) {
      if (tx.sourceAccountId == null || tx.destinationAccountId == null) continue;
      final src = accMap[tx.sourceAccountId];
      final dst = accMap[tx.destinationAccountId];
      if (src == null || dst == null) continue;

      // Domestic -> Offshore (Money sent abroad to invest)
      if (src.isDomestic && !dst.isDomestic) {
        if (beforeDate == null || !tx.transactionDate.isAfter(beforeDate)) {
          totalInvestedPrincipal += tx.amountThbSatang;
        }
      }
      // Offshore -> Domestic (Money remitted back to Thailand)
      else if (!src.isDomestic && dst.isDomestic) {
        if (excludeTxId != null && tx.id == excludeTxId) {
          continue;
        }
        if (beforeDate != null && tx.transactionDate.isAfter(beforeDate)) {
          continue;
        }
        totalRemitted += tx.amountThbSatang;
      }
    }

    final remaining = totalInvestedPrincipal - totalRemitted;
    return remaining > 0 ? remaining : 0;
  }

  Future<void> syncFromTransferTransaction(
    Transaction tx, {
    int? taxYearEarned,
    String? incomeSourceType,
    bool? isPrincipal,
  }) async {
    if (tx.transactionType != 'transfer') return;
    if (tx.sourceAccountId == null || tx.destinationAccountId == null) return;

    final srcAcc = await (select(accounts)..where((a) => a.id.equals(tx.sourceAccountId!))).getSingleOrNull();
    final dstAcc = await (select(accounts)..where((a) => a.id.equals(tx.destinationAccountId!))).getSingleOrNull();

    if (srcAcc == null || dstAcc == null) return;

    // A foreign remittance is strictly from Offshore (!isDomestic) to Domestic (isDomestic)
    final isOffshoreToDomestic = !srcAcc.isDomestic && dstAcc.isDomestic;

    if (isOffshoreToDomestic) {
      final existing = await getRemittanceByTransactionId(tx.id);
      final now = DateTime.now();
      final earned = taxYearEarned ?? (tx.transactionDate.year - 1);
      final type = incomeSourceType ?? 'capital_gain';

      // Automatic FIFO check: if isPrincipal not specified, check remaining principal pool before this tx
      bool principal;
      if (isPrincipal != null) {
        principal = isPrincipal;
      } else {
        final remainingPrincipal = await getRemainingForeignPrincipalSatang(
          beforeDate: tx.transactionDate,
          excludeTxId: tx.id,
        );
        principal = remainingPrincipal >= tx.amountThbSatang;
      }

      final foreignCurrency = (tx.currencyCode == 'THB' && srcAcc.currencyCode != 'THB')
          ? srcAcc.currencyCode
          : tx.currencyCode;

      // If tx had wrong currency THB, fix tx as well
      if (tx.currencyCode == 'THB' && srcAcc.currencyCode != 'THB') {
        await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
          TransactionsCompanion(
            currencyCode: Value(srcAcc.currencyCode),
            updatedAt: Value(now),
          ),
        );
      }

      if (existing == null) {
        await createRemittance(
          ForeignRemittancesCompanion.insert(
            id: _uuid.v4(),
            remittanceTransactionId: tx.id,
            sourceAccountId: tx.sourceAccountId!,
            destinationAccountId: Value(tx.destinationAccountId),
            amountOriginalSatang: tx.amountOriginalSatang,
            currencyCode: foreignCurrency,
            fxRate: tx.fxRate,
            amountThbSatang: tx.amountThbSatang,
            taxYearEarned: Value(earned),
            taxYearRemitted: Value(tx.transactionDate.year),
            incomeSourceType: Value(type),
            isPrincipal: Value(principal),
            remittanceDate: tx.transactionDate,
            createdAt: now,
            updatedAt: now,
          ),
        );
      } else {
        await updateRemittance(
          ForeignRemittancesCompanion(
            id: Value(existing.id),
            sourceAccountId: Value(tx.sourceAccountId!),
            destinationAccountId: Value(tx.destinationAccountId),
            amountOriginalSatang: Value(tx.amountOriginalSatang),
            currencyCode: Value(foreignCurrency),
            fxRate: Value(tx.fxRate),
            amountThbSatang: Value(tx.amountThbSatang),
            taxYearRemitted: Value(tx.transactionDate.year),
            remittanceDate: Value(tx.transactionDate),
            taxYearEarned: taxYearEarned != null ? Value(taxYearEarned) : Value(existing.taxYearEarned),
            incomeSourceType: incomeSourceType != null ? Value(incomeSourceType) : Value(existing.incomeSourceType),
            isPrincipal: isPrincipal != null ? Value(isPrincipal) : Value(existing.isPrincipal),
            updatedAt: Value(now),
          ),
        );
      }
    } else {
      final existing = await getRemittanceByTransactionId(tx.id);
      if (existing != null) {
        await deleteRemittance(existing.id);
      }
    }
  }

  Future<void> deleteRemittanceForTransaction(String txId) async {
    final existing = await getRemittanceByTransactionId(txId);
    if (existing != null) {
      await deleteRemittance(existing.id);
    }
  }

  /// Automatically repairs any existing foreign remittances that were mistakenly recorded with currencyCode 'THB'
  Future<void> repairMisclassifiedRemittanceCurrencies() async {
    final allAccounts = await (select(accounts)..where((a) => a.deletedAt.isNull())).get();
    final accMap = {for (var a in allAccounts) a.id: a};

    final remittances = await (select(foreignRemittances)..where((r) => r.deletedAt.isNull())).get();
    final now = DateTime.now();

    for (final r in remittances) {
      final src = accMap[r.sourceAccountId];
      if (src != null && !src.isDomestic && src.currencyCode != 'THB' && r.currencyCode == 'THB') {
        await (update(foreignRemittances)..where((row) => row.id.equals(r.id))).write(
          ForeignRemittancesCompanion(
            currencyCode: Value(src.currencyCode),
            updatedAt: Value(now),
          ),
        );
        if (r.remittanceTransactionId.isNotEmpty) {
          await (update(transactions)..where((t) => t.id.equals(r.remittanceTransactionId))).write(
            TransactionsCompanion(
              currencyCode: Value(src.currencyCode),
              updatedAt: Value(now),
            ),
          );
        }
      }
    }
  }

  Future<int> syncAllTransferTransactions() async {
    await repairMisclassifiedRemittanceCurrencies();

    final allAccounts = await (select(accounts)..where((a) => a.deletedAt.isNull())).get();
    final accMap = {for (var a in allAccounts) a.id: a};

    final transfers = await (select(transactions)
          ..where((t) => t.transactionType.equals('transfer') & t.deletedAt.isNull()))
        .get();

    int syncedCount = 0;
    for (final tx in transfers) {
      if (tx.sourceAccountId == null || tx.destinationAccountId == null) continue;
      final src = accMap[tx.sourceAccountId];
      final dst = accMap[tx.destinationAccountId];
      if (src == null || dst == null) continue;

      final isOffshoreToDomestic = !src.isDomestic && dst.isDomestic;

      if (isOffshoreToDomestic) {
        final existing = await getRemittanceByTransactionId(tx.id);
        final foreignCurrency = (tx.currencyCode == 'THB' && src.currencyCode != 'THB')
            ? src.currencyCode
            : tx.currencyCode;

        if (existing == null) {
          final now = DateTime.now();
          final remainingPrincipal = await getRemainingForeignPrincipalSatang(
            beforeDate: tx.transactionDate,
            excludeTxId: tx.id,
          );
          final isPrincipal = remainingPrincipal >= tx.amountThbSatang;

          await createRemittance(
            ForeignRemittancesCompanion.insert(
              id: _uuid.v4(),
              remittanceTransactionId: tx.id,
              sourceAccountId: tx.sourceAccountId!,
              destinationAccountId: Value(tx.destinationAccountId),
              amountOriginalSatang: tx.amountOriginalSatang,
              currencyCode: foreignCurrency,
              fxRate: tx.fxRate,
              amountThbSatang: tx.amountThbSatang,
              taxYearEarned: Value(tx.transactionDate.year - 1),
              taxYearRemitted: Value(tx.transactionDate.year),
              incomeSourceType: const Value('capital_gain'),
              isPrincipal: Value(isPrincipal),
              remittanceDate: tx.transactionDate,
              createdAt: now,
              updatedAt: now,
            ),
          );
          syncedCount++;
        } else if (existing.currencyCode == 'THB' && src.currencyCode != 'THB') {
          await (update(foreignRemittances)..where((row) => row.id.equals(existing.id))).write(
            ForeignRemittancesCompanion(
              currencyCode: Value(src.currencyCode),
              updatedAt: Value(DateTime.now()),
            ),
          );
        }
      }
    }
    return syncedCount;
  }

  Future<void> recordRemittance(ForeignRemittancesCompanion entry) async {
    final now = DateTime.now();
    final companion = entry.copyWith(
      id: entry.id.present ? entry.id : Value(_uuid.v4()),
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );

    await into(foreignRemittances).insert(companion);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'foreign_remittances',
        entityId: companion.id.value,
        action: 'RECORD_FOREIGN_REMITTANCE',
        afterDataJson: Value('{"amountThbSatang": ${companion.amountThbSatang.value}, "isPrincipal": ${companion.isPrincipal.value}}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateRemittance(ForeignRemittancesCompanion entry) async {
    final now = DateTime.now();
    await (update(foreignRemittances)..where((r) => r.id.equals(entry.id.value))).write(
      entry.copyWith(updatedAt: Value(now)),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'foreign_remittances',
        entityId: entry.id.value,
        action: 'UPDATE_FOREIGN_REMITTANCE',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteRemittance(String id) async {
    final now = DateTime.now();
    await (update(foreignRemittances)..where((r) => r.id.equals(id))).write(
      ForeignRemittancesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'foreign_remittances',
        entityId: id,
        action: 'DELETE_FOREIGN_REMITTANCE',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }
}
