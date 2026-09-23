import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/daos/accounts_dao.dart';
import '../../../core/database/daos/categories_dao.dart';
import '../../../core/database/daos/import_batches_dao.dart';
import '../../../core/database/daos/transactions_dao.dart';
import 'csv_import_models.dart';

class ImportExecutor {
  final AppDatabase db;
  final TransactionsDao transactionsDao;
  final AccountsDao accountsDao;
  final CategoriesDao categoriesDao;
  final ImportBatchesDao importBatchesDao;
  final Uuid _uuid = const Uuid();

  ImportExecutor({
    required this.db,
    required this.transactionsDao,
    required this.accountsDao,
    required this.categoriesDao,
    required this.importBatchesDao,
  });

  /// Identifies which rows in [parsedRows] already match an existing transaction.
  Future<List<ParsedCsvRow>> checkDuplicates(List<ParsedCsvRow> parsedRows) async {
    final allTx = await transactionsDao.getAllTransactions();
    final updatedList = <ParsedCsvRow>[];

    for (final row in parsedRows) {
      if (!row.isValid) {
        updatedList.add(row);
        continue;
      }

      final isDup = allTx.any((tx) {
        if (tx.deletedAt != null) return false;
        if (tx.transactionType != row.transactionType) return false;
        if (tx.amountOriginalSatang != row.amountSatang) return false;

        // Check date (same year, month, day)
        final txDate = tx.transactionDate;
        final rowDate = row.date!;
        final sameDate = txDate.year == rowDate.year &&
            txDate.month == rowDate.month &&
            txDate.day == rowDate.day;

        if (!sameDate) return false;

        // Check note or name match
        final note = tx.note?.toLowerCase() ?? '';
        final rowName = row.name.toLowerCase();
        return note.contains(rowName) || rowName.contains(note);
      });

      updatedList.add(row.copyWith(isDuplicate: isDup));
    }

    return updatedList;
  }

  /// Finds or creates missing categories and accounts, and inserts transactions as an atomic batch.
  Future<CsvImportBatchResult> executeImport({
    required String fileName,
    required String templateType,
    required List<ParsedCsvRow> rows,
    required String defaultAccountId,
    bool skipDuplicates = true,
    bool autoCreateMissingCategories = true,
    bool autoCreateMissingAccounts = true,
  }) async {
    final batchId = _uuid.v4();
    final now = DateTime.now();

    final createdCategories = <String>[];
    final createdAccounts = <String>[];

    // 1. Fetch current accounts and categories
    final existingAccounts = await accountsDao.getActiveAccounts();
    final existingCategories = await categoriesDao.getActiveCategories();

    final accountMap = <String, String>{}; // name.toLowerCase() -> id
    for (final a in existingAccounts) {
      accountMap[a.name.trim().toLowerCase()] = a.id;
    }

    final categoryMap = <String, String>{}; // name.toLowerCase() -> id
    for (final c in existingCategories) {
      categoryMap[c.nameTh.trim().toLowerCase()] = c.id;
      categoryMap[c.nameEn.trim().toLowerCase()] = c.id;
    }

    // Default account validation
    String fallbackAccountId = defaultAccountId;
    if (fallbackAccountId.isEmpty && existingAccounts.isNotEmpty) {
      fallbackAccountId = existingAccounts.first.id;
    }

    int importedCount = 0;
    int duplicateCount = 0;
    int skippedCount = 0;

    await db.transaction(() async {
      // 2. Pre-create Import Batch so foreign keys in transactions succeed
      await importBatchesDao.createBatch(
        ImportBatchesCompanion.insert(
          id: batchId,
          fileName: fileName,
          templateType: Value(templateType),
          totalImported: 0,
          importedAt: now,
          isRolledBack: const Value(false),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 3. Prepare categories, accounts, and insert transactions
      for (final row in rows) {
        if (!row.isValid || row.isSummaryRow) {
          skippedCount++;
          continue;
        }
        if (row.isDuplicate && skipDuplicates) {
          duplicateCount++;
          continue;
        }

        // Account Resolution
        String targetAccountId = fallbackAccountId;
        if (row.accountName != null && row.accountName!.isNotEmpty) {
          final accKey = row.accountName!.trim().toLowerCase();
          if (accountMap.containsKey(accKey)) {
            targetAccountId = accountMap[accKey]!;
          } else if (autoCreateMissingAccounts) {
            final newAccId = _uuid.v4();
            await accountsDao.createAccount(
              AccountsCompanion.insert(
                id: newAccId,
                name: row.accountName!.trim(),
                accountType: 'cash',
                currencyCode: 'THB',
                isDomestic: true,
                createdAt: now,
                updatedAt: now,
              ),
            );
            accountMap[accKey] = newAccId;
            createdAccounts.add(row.accountName!.trim());
            targetAccountId = newAccId;
          }
        }

        // Category Resolution
        String? targetCategoryId;
        final catKey = row.categoryName.trim().toLowerCase();
        if (categoryMap.containsKey(catKey)) {
          targetCategoryId = categoryMap[catKey];
        } else if (autoCreateMissingCategories) {
          final newCatId = _uuid.v4();
          await categoriesDao.createCategory(
            CategoriesCompanion.insert(
              id: newCatId,
              nameTh: row.categoryName.trim(),
              nameEn: row.categoryName.trim(),
              categoryType: row.transactionType,
              taxIncomeType: Value(row.taxCategory),
              icon: const Value('category'),
              color: const Value('0xFF888888'),
              isSystem: const Value(false),
              createdAt: now,
              updatedAt: now,
            ),
          );
          categoryMap[catKey] = newCatId;
          createdCategories.add(row.categoryName.trim());
          targetCategoryId = newCatId;
        }

        // Insert Transaction
        final txId = _uuid.v4();
        final effectiveNote = (row.note != null && row.note!.isNotEmpty)
            ? '${row.name} (${row.note})'
            : row.name;

        await transactionsDao.insertTransaction(
          TransactionsCompanion.insert(
            id: txId,
            importBatchId: Value(batchId),
            transactionType: row.transactionType,
            sourceAccountId: Value(targetAccountId),
            categoryId: Value(targetCategoryId),
            amountOriginalSatang: row.amountSatang,
            currencyCode: 'THB',
            fxRate: const Value('1.0'),
            amountThbSatang: row.amountSatang,
            feeThbSatang: const Value(0),
            taxCategory: Value(row.taxCategory),
            withholdingTaxSatang: Value(row.withholdingTaxSatang),
            transactionDate: row.date!,
            workPeriod: Value(row.workPeriod),
            expectedAmountSatang: Value(row.expectedAmountSatang),
            isCleared: Value(row.isCleared),
            note: Value(effectiveNote.isEmpty ? null : effectiveNote),
            createdAt: now,
            updatedAt: now,
          ),
        );
        importedCount++;
      }

      // 4. Update totalImported in Import Batch
      await (db.update(db.importBatches)..where((t) => t.id.equals(batchId))).write(
        ImportBatchesCompanion(
          totalImported: Value(importedCount),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });

    return CsvImportBatchResult(
      batchId: batchId,
      fileName: fileName,
      templateType: templateType,
      totalRows: rows.length,
      importedCount: importedCount,
      duplicateCount: duplicateCount,
      skippedCount: skippedCount,
      createdCategories: createdCategories,
      createdAccounts: createdAccounts,
      importedAt: now,
    );
  }
}
