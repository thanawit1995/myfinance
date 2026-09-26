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
      if (a.accountType == 'credit_card') {
        accountMap['credit card'] = a.id;
        accountMap['credit_card'] = a.id;
        accountMap['บัตรเครดิต'] = a.id;
      }
    }

    // Resolve SCB account: Map Money, Online banking -> SCB
    final scbAcc = existingAccounts.where((a) => a.name.trim().toLowerCase() == 'scb').firstOrNull;
    String? scbAccountId = scbAcc?.id;
    if (scbAccountId == null) {
      final defaultScb = existingAccounts.where((a) => a.id == '00000000-0000-4000-8000-000000000001').firstOrNull;
      if (defaultScb != null) {
        scbAccountId = defaultScb.id;
      }
    }
    if (scbAccountId != null) {
      accountMap['money'] = scbAccountId;
      accountMap['online banking'] = scbAccountId;
      accountMap['online_banking'] = scbAccountId;
      accountMap['onlinebanking'] = scbAccountId;
      accountMap['online bank'] = scbAccountId;
    }

    final categoryMap = <String, String>{}; // name.toLowerCase() -> id
    for (final c in existingCategories) {
      categoryMap[c.nameTh.trim().toLowerCase()] = c.id;
      categoryMap[c.nameEn.trim().toLowerCase()] = c.id;
    }

    // Map "ทั่วไป" and "general" -> "Other Expense" / "ค่าใช้จ่ายอื่นๆ"
    final otherExpCat = existingCategories.where((c) =>
      c.nameEn.trim().toLowerCase() == 'other expense' ||
      c.nameTh.trim() == 'ค่าใช้จ่ายอื่นๆ'
    ).firstOrNull;
    if (otherExpCat != null) {
      categoryMap['ทั่วไป'] = otherExpCat.id;
      categoryMap['general'] = otherExpCat.id;
      categoryMap['other expense'] = otherExpCat.id;
      categoryMap['ค่าใช้จ่ายอื่นๆ'] = otherExpCat.id;
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
            final isScb = accKey == 'money' || accKey.contains('online bank') || accKey.contains('online_bank');
            final isCc = accKey.contains('credit') || accKey.contains('เครดิต');
            final newAccId = isScb ? '00000000-0000-4000-8000-000000000001' : _uuid.v4();
            final accName = isScb ? 'SCB' : row.accountName!.trim();
            final accType = isCc ? 'credit_card' : (isScb ? 'bank' : 'cash');
            await accountsDao.createAccount(
              AccountsCompanion.insert(
                id: newAccId,
                name: accName,
                accountType: accType,
                currencyCode: 'THB',
                isDomestic: true,
                closingDay: isCc ? const Value(23) : const Value(null),
                dueDay: isCc ? const Value(10) : const Value(null),
                createdAt: now,
                updatedAt: now,
              ),
            );
            accountMap[accKey] = newAccId;
            if (isScb) {
              accountMap['money'] = newAccId;
              accountMap['online banking'] = newAccId;
              accountMap['scb'] = newAccId;
            }
            createdAccounts.add(accName);
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
          final isGpf = row.categoryName.trim() == 'เงินสะสม กบข.';
          await categoriesDao.createCategory(
            CategoriesCompanion.insert(
              id: newCatId,
              nameTh: row.categoryName.trim(),
              nameEn: isGpf ? 'GPF Pension Fund' : row.categoryName.trim(),
              categoryType: row.transactionType,
              taxIncomeType: Value(row.taxCategory),
              icon: Value(isGpf ? 'account_balance' : 'category'),
              color: Value(isGpf ? '0xFF4CAF50' : '0xFF888888'),
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
        String effectiveNote = row.name
            .replaceAll(RegExp(r'\s*\(\s*https?:\/\/[^\)]+\)'), '')
            .replaceAll(RegExp(r'https?:\/\/\S+'), '')
            .trim();
        if (row.note != null && row.note!.isNotEmpty) {
          final cleanNote = row.note!
              .replaceAll(RegExp(r'\s*\(\s*https?:\/\/[^\)]+\)'), '')
              .replaceAll(RegExp(r'https?:\/\/\S+'), '')
              .trim();
          final parenMatch = RegExp(r'^(.*?)\s*\((.*?)\)$').firstMatch(cleanNote);
          final noteCandidate = parenMatch != null ? parenMatch.group(1)!.trim() : cleanNote;
          if (noteCandidate.isNotEmpty &&
              noteCandidate != effectiveNote &&
              !effectiveNote.contains(noteCandidate) &&
              !noteCandidate.contains(effectiveNote) &&
              !noteCandidate.contains('_') &&
              !noteCandidate.startsWith('🏧') &&
              !noteCandidate.startsWith('👝') &&
              !noteCandidate.startsWith('💼')) {
            effectiveNote = '$effectiveNote ($noteCandidate)';
          }
        }

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
            tag: Value(row.tag),
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

    // 5. Auto-settle historical credit card debt before 24 Aug 2026 for Notion expense imports
    if (templateType == 'notion_expense' || templateType == 'notion_bills') {
      final activeAccs = await accountsDao.getActiveAccounts();
      for (final acc in activeAccs) {
        if (acc.accountType == 'credit_card') {
          await db.creditCardDao.settleHistoricalDebt(acc.id);
        }
      }
    }

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
