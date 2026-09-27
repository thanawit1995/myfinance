import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import 'money_big_plan_parser.dart';

class MoneyBigPlanImportResult {
  final int totalImported;
  final int totalIncome;
  final int totalExpense;
  final int totalTransfer;
  final String batchId;
  final List<String> errors;

  const MoneyBigPlanImportResult({
    required this.totalImported,
    required this.totalIncome,
    required this.totalExpense,
    required this.totalTransfer,
    required this.batchId,
    required this.errors,
  });

  int get imported => totalImported;
  int get skippedDuplicates => 0;
}

class MoneyBigPlanImportExecutor {
  final AppDatabase db;
  final _uuid = const Uuid();

  MoneyBigPlanImportExecutor(this.db);

  Future<MoneyBigPlanImportResult> executeImport(
    List<ParsedMoneyBigPlanRow> rows, {
    Set<int>? selectedIndices,
    required String fileName,
  }) async {
    final batchId = _uuid.v4();
    final now = DateTime.now();

    final toImport = selectedIndices != null
        ? rows.where((r) => selectedIndices.contains(r.rowIndex)).toList()
        : rows;

    int totalIncome = 0;
    int totalExpense = 0;
    int totalTransfer = 0;
    final errors = <String>[];

    await db.transaction(() async {
      // 1. Create Import Batch record
      await db.into(db.importBatches).insert(
        ImportBatchesCompanion.insert(
          id: batchId,
          fileName: fileName,
          templateType: const Value('money_big_plan'),
          totalImported: toImport.length,
          importedAt: now,
          isRolledBack: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Ensure Insurance Asset Account exists
      final insuranceAccount = await db.accountsDao.getOrCreateInsuranceSavingsAccount();

      // 3. Insert transactions
      for (final row in toImport) {
        try {
          final txId = _uuid.v4();

          if (row.tag == 'deduction:life_insurance') {
            // Record as Transfer to Insurance Asset Account (Asset growth)
            await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: txId,
                transactionType: 'transfer',
                sourceAccountId: Value(row.sourceAccountId),
                destinationAccountId: Value(insuranceAccount.id),
                categoryId: Value(row.categoryId),
                amountOriginalSatang: row.amountSatang,
                currencyCode: 'THB',
                fxRate: const Value('1.000000'),
                amountThbSatang: row.amountSatang,
                feeThbSatang: const Value(0),
                transactionDate: row.date,
                isCleared: const Value(true),
                tag: Value(row.tag),
                note: Value(row.note),
                workPeriod: Value(row.workPeriod),
                importBatchId: Value(batchId),
                createdAt: now,
                updatedAt: now,
              ),
            );
            totalTransfer++;
          } else if (row.transactionType == 'income') {
            await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: txId,
                transactionType: 'income',
                sourceAccountId: Value(row.sourceAccountId),
                categoryId: Value(row.categoryId),
                taxCategory: Value(row.taxCategory),
                amountOriginalSatang: row.amountSatang,
                currencyCode: 'THB',
                fxRate: const Value('1.000000'),
                amountThbSatang: row.amountSatang,
                feeThbSatang: const Value(0),
                transactionDate: row.date,
                isCleared: const Value(true),
                tag: Value(row.tag),
                note: Value(row.note),
                workPeriod: Value(row.workPeriod),
                importBatchId: Value(batchId),
                createdAt: now,
                updatedAt: now,
              ),
            );
            totalIncome++;
          } else {
            await db.into(db.transactions).insert(
              TransactionsCompanion.insert(
                id: txId,
                transactionType: 'expense',
                sourceAccountId: Value(row.sourceAccountId),
                categoryId: Value(row.categoryId),
                amountOriginalSatang: row.amountSatang,
                currencyCode: 'THB',
                fxRate: const Value('1.000000'),
                amountThbSatang: row.amountSatang,
                feeThbSatang: const Value(0),
                transactionDate: row.date,
                isCleared: const Value(true),
                tag: Value(row.tag),
                note: Value(row.note),
                workPeriod: Value(row.workPeriod),
                importBatchId: Value(batchId),
                createdAt: now,
                updatedAt: now,
              ),
            );
            totalExpense++;
          }
        } catch (e) {
          errors.add('แถว ${row.originalLabel} (${row.workPeriod}): $e');
        }
      }
    });

    return MoneyBigPlanImportResult(
      totalImported: totalIncome + totalExpense + totalTransfer,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      totalTransfer: totalTransfer,
      batchId: batchId,
      errors: errors,
    );
  }
}
