import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/app_database.dart';
import 'dividend_excel_parser.dart';

class DividendExcelImportResult {
  final String batchId;
  final int insertedCount;
  final int totalGrossSatangUsd;
  final int totalTaxSatangUsd;
  final int totalNetThbSatang;
  final int skippedDuplicatesCount;

  const DividendExcelImportResult({
    required this.batchId,
    required this.insertedCount,
    required this.totalGrossSatangUsd,
    required this.totalTaxSatangUsd,
    required this.totalNetThbSatang,
    this.skippedDuplicatesCount = 0,
  });

  int get imported => insertedCount;
  int get skippedDuplicates => skippedDuplicatesCount;
  bool get success => true;
  List<String> get errors => const [];
}

class DividendExcelImportExecutor {
  final AppDatabase db;
  static const _uuid = Uuid();

  DividendExcelImportExecutor(this.db);

  Future<DividendExcelImportResult> executeImport({
    required List<ParsedDividendExcelRow> rows,
    required String fileName,
  }) async {
    return db.transaction(() async {
      final now = DateTime.now();
      final batchId = _uuid.v4();

      // 1. Identify Destination Account (Dime! USD or matching USD offshore account)
      final allAccounts = await (db.select(db.accounts)..where((a) => a.deletedAt.isNull())).get();
      Account? dimeUsd = allAccounts.firstWhere(
        (a) => a.id == DividendExcelParser.dimeUsdAccountId,
        orElse: () => allAccounts.firstWhere(
          (a) => a.name.toLowerCase().contains('dime! usd') || a.name.toLowerCase().contains('dime usd'),
          orElse: () => allAccounts.firstWhere(
            (a) => a.currencyCode == 'USD' && (a.accountType == 'offshore' || a.accountType == 'fcd'),
            orElse: () => allAccounts.first,
          ),
        ),
      );

      // 2. Identify Category (ดอกเบี้ยและเงินปันผล)
      final allCats = await (db.select(db.categories)..where((c) => c.deletedAt.isNull())).get();
      Category? dividendCat = allCats.firstWhere(
        (c) => c.id == DividendExcelParser.dividendCategoryId,
        orElse: () => allCats.firstWhere(
          (c) => c.nameTh.contains('ดอกเบี้ยและเงินปันผล') || c.nameEn.toLowerCase().contains('interest & dividends'),
          orElse: () => allCats.first,
        ),
      );

      // 3. Cache and create missing assets
      final allAssets = await (db.select(db.assets)..where((a) => a.deletedAt.isNull())).get();
      final assetMap = <String, Asset>{};
      for (final a in allAssets) {
        assetMap[a.symbol.trim().toUpperCase()] = a;
      }

      // 4. Query existing transactions for duplicate detection
      final existingTransactions = await (db.select(db.transactions)
            ..where((t) => t.destinationAccountId.equals(dimeUsd.id) & t.deletedAt.isNull()))
          .get();

      int totalGrossUsd = 0;
      int totalTaxUsd = 0;
      int totalNetThb = 0;
      int insertedCount = 0;
      int skippedDuplicates = 0;

      // Create Import Batch Record first
      await db.into(db.importBatches).insert(
        ImportBatchesCompanion.insert(
          id: batchId,
          templateType: const Value('dividend_excel'),
          fileName: fileName,
          totalImported: rows.length,
          importedAt: now,
          note: Value('นำเข้าเงินปันผล US จาก $fileName'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 5. Insert each row
      for (final row in rows) {
        final symUpper = row.symbol.trim().toUpperCase();

        // Check duplicates
        final isDuplicate = existingTransactions.any((tx) {
          final isSameDay = tx.transactionDate.year == row.date.year &&
              tx.transactionDate.month == row.date.month &&
              tx.transactionDate.day == row.date.day;
          final isSameAmount = tx.amountOriginalSatang == row.grossSatang;
          final isSameSymbol = tx.note?.contains(row.symbol) ?? false;
          return isSameDay && isSameAmount && isSameSymbol;
        });

        if (isDuplicate) {
          skippedDuplicates++;
          continue;
        }

        totalGrossUsd += row.grossSatang;
        totalTaxUsd += row.taxSatang;
        totalNetThb += row.netThbSatang;
        insertedCount++;

        final txId = _uuid.v4();
        final incomeId = _uuid.v4();

        Asset? asset = assetMap[symUpper];
        if (asset == null && !row.isTaxExemptRefund && symUpper.isNotEmpty) {
          // Auto-create new asset for foreign stock
          final newAssetId = _uuid.v4();
          await db.into(db.assets).insert(
            AssetsCompanion.insert(
              id: newAssetId,
              symbol: symUpper,
              name: symUpper,
              assetType: 'foreign_stock',
              currencyCode: 'USD',
              defaultAccountId: dimeUsd.id,
              createdAt: now,
              updatedAt: now,
            ),
          );
          asset = await (db.select(db.assets)..where((a) => a.id.equals(newAssetId))).getSingle();
          assetMap[symUpper] = asset;
        }

        // Ledger Transaction
        final noteText = row.isTaxExemptRefund
            ? 'เงินปันผล/ส่วนเว้นภาษี (เรต ${row.fxRate})'
            : 'เงินปันผล ${row.symbol} (หักภาษี \$${row.taxUsd.toStringAsFixed(2)} @ เรต ${row.fxRate})';

        await db.into(db.transactions).insert(
          TransactionsCompanion.insert(
            id: txId,
            transactionType: 'income',
            sourceAccountId: Value(dimeUsd.id),
            destinationAccountId: Value(dimeUsd.id),
            categoryId: Value(dividendCat.id),
            taxCategory: const Value('40_4_dividend_foreign'),
            amountOriginalSatang: row.grossSatang,
            currencyCode: 'USD',
            fxRate: Value(row.fxRate.toString()),
            amountThbSatang: row.netThbSatang,
            feeThbSatang: Value(row.withholdingTaxThbSatang),
            withholdingTaxSatang: Value(row.withholdingTaxThbSatang),
            assetId: Value(asset?.id),
            transactionDate: row.date,
            importBatchId: Value(batchId),
            note: Value(noteText),
            tag: Value(asset != null ? 'investment_income:${asset.id}' : 'investment_income'),
            createdAt: now,
            updatedAt: now,
          ),
        );

        // InvestmentIncomes Table
        await db.into(db.investmentIncomes).insert(
          InvestmentIncomesCompanion.insert(
            id: incomeId,
            transactionId: txId,
            assetId: asset?.id ?? '',
            incomeType: 'dividend',
            grossAmountOriginalSatang: row.grossSatang,
            currencyCode: 'USD',
            fxRate: row.fxRate.toString(),
            grossAmountThbSatang: (Decimal.fromInt(row.grossSatang) * row.fxRate).round().toBigInt().toInt(),
            withholdingTaxThbSatang: Value(row.withholdingTaxThbSatang),
            dividendTaxCreditSatang: const Value(0),
            netAmountThbSatang: row.netThbSatang,
            isForeignIncome: const Value(true),
            note: Value(noteText),
            createdAt: now,
            updatedAt: now,
          ),
        );

        // FxRates Table (Auto-record USD/THB rate for this date if missing)
        if (row.fxRate > Decimal.zero) {
          await db.into(db.fxRates).insert(
            FxRatesCompanion.insert(
              id: _uuid.v4(),
              baseCurrency: 'USD',
              targetCurrency: 'THB',
              rate: row.fxRate.toString(),
              effectiveDate: row.date,
              note: Value('Auto-recorded from dividend import $fileName (${row.symbol})'),
              createdAt: now,
              updatedAt: now,
            ),
            mode: InsertMode.insertOrIgnore,
          );
        }
      }

      return DividendExcelImportResult(
        batchId: batchId,
        insertedCount: insertedCount,
        totalGrossSatangUsd: totalGrossUsd,
        totalTaxSatangUsd: totalTaxUsd,
        totalNetThbSatang: totalNetThb,
        skippedDuplicatesCount: skippedDuplicates,
      );
    });
  }
}
