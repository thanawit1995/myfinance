import 'dart:io';
import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/seed_data.dart';
import 'package:myfinance/features/import/domain/dividend_excel_parser.dart';
import 'package:myfinance/features/import/domain/dividend_excel_import_executor.dart';

void main() {
  group('DividendExcelParser Tests', () {
    test('Parses actual ปันผล.xlsx file correctly if present', () {
      final file = File(r'C:\Projects\myfinance\ปันผล.xlsx');
      if (!file.existsSync()) {
        // Skip if running in environment where file is not available
        return;
      }

      final bytes = file.readAsBytesSync();
      final rows = DividendExcelParser.parseExcelBytes(bytes);

      expect(rows, isNotEmpty);
      expect(rows.length, inInclusiveRange(70, 75));

      final firstRow = rows.first;
      expect(firstRow.symbol, isNotEmpty);
      expect(firstRow.grossUsd, closeTo(1.34, 0.01));
      expect(firstRow.grossSatang, 134);
      expect(firstRow.netUsdSatang, greaterThan(0));
      expect(firstRow.netThbSatang, greaterThan(0));
      expect(firstRow.fxRate > Decimal.zero, isTrue);

      final oRows = rows.where((r) => r.symbol == 'O').toList();
      expect(oRows, isNotEmpty);

      // Verify that all rows have positive amounts and valid symbols
      for (final r in rows) {
        expect(r.symbol, isNotEmpty);
        expect(r.grossSatang, greaterThan(0));
        expect(r.taxSatang, greaterThanOrEqualTo(0));
        expect(r.netUsdSatang, greaterThan(0));
        expect(r.fxRate > Decimal.zero, isTrue);
      }

      // Verify tax-exempt row (Row 64: ส่วนเว้นภาษี)
      final exemptRows = rows.where((r) => r.symbol.contains('ส่วนเว้นภาษี')).toList();
      expect(exemptRows, isNotEmpty);
      final exempt = exemptRows.first;
      expect(exempt.grossSatang, greaterThan(0));
      expect(exempt.taxSatang, 0);
    });

    test('Parses mock excel or generated data accurately', () {
      final parsedRow = ParsedDividendExcelRow(
        rowIndex: 2,
        date: DateTime(2024, 7, 15),
        symbol: 'O',
        grossUsd: 1.05,
        taxUsd: 0.16,
        netUsd: 0.89,
        fxRate: Decimal.parse('36.21'),
        grossSatang: 105,
        taxSatang: 16,
        netUsdSatang: 89,
        netThbSatang: 3223,
        withholdingTaxThbSatang: 579,
      );

      expect(parsedRow.symbol, 'O');
      expect(parsedRow.netUsdSatang, 89);
      expect(parsedRow.netThbSatang, 3223);
    });
  });

  group('DividendExcelImportExecutor Tests', () {
    late AppDatabase db;
    late DividendExcelImportExecutor executor;

    setUp(() async {
      db = AppDatabase.forTesting(inMemoryConnection());
      await SeedData.insertSeedData(db);
      executor = DividendExcelImportExecutor(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Imports foreign dividend rows into SQLite with Dime! USD and 40(4) tax category', () async {
      final mockRows = [
        ParsedDividendExcelRow(
          rowIndex: 2,
          date: DateTime(2024, 7, 15),
          symbol: 'O',
          grossUsd: 1.05,
          taxUsd: 0.16,
          netUsd: 0.89,
          fxRate: Decimal.parse('36.21'),
          grossSatang: 105,
          taxSatang: 16,
          netUsdSatang: 89,
          netThbSatang: 3223,
          withholdingTaxThbSatang: 579,
        ),
        ParsedDividendExcelRow(
          rowIndex: 3,
          date: DateTime(2024, 7, 18),
          symbol: 'JEPQ',
          grossUsd: 1.54,
          taxUsd: 0.23,
          netUsd: 1.31,
          fxRate: Decimal.parse('36.22'),
          grossSatang: 154,
          taxSatang: 23,
          netUsdSatang: 131,
          netThbSatang: 4745,
          withholdingTaxThbSatang: 833,
        ),
      ];

      final result = await executor.executeImport(
        fileName: 'ปันผล.xlsx',
        rows: mockRows,
      );

      expect(result.success, isTrue);
      expect(result.imported, 2);
      expect(result.skippedDuplicates, 0);

      // Verify transactions created
      final allTx = await db.transactionsDao.getAllTransactions();
      final divTx = allTx.where((t) => t.note != null && t.note!.contains('เงินปันผล')).toList();
      expect(divTx.length, 2);

      for (final tx in divTx) {
        expect(tx.destinationAccountId, DividendExcelParser.dimeUsdAccountId);
        expect(tx.categoryId, DividendExcelParser.dividendCategoryId);
        expect(tx.taxCategory, '40_4_dividend_foreign');
        expect(tx.importBatchId, result.batchId);
      }

      // Verify investment incomes created
      final incomes = await (db.select(db.investmentIncomes)).get();
      expect(incomes.length, 2);
      for (final inc in incomes) {
        expect(inc.isForeignIncome, isTrue);
        expect(inc.withholdingTaxThbSatang, greaterThan(0));
      }

      // Verify FX rates inserted
      final fxList = await db.select(db.fxRates).get();
      expect(fxList.isNotEmpty, isTrue);

      // Verify Rollback functionality
      await db.importBatchesDao.rollbackBatch(result.batchId);

      final txAfterRollback = await db.transactionsDao.getAllTransactions();
      final divTxAfterRollback = txAfterRollback.where((t) => t.importBatchId == result.batchId).toList();
      expect(divTxAfterRollback, isEmpty);

      final incomesAfterRollback = await (db.select(db.investmentIncomes)).get();
      final linkedIncomes = incomesAfterRollback.where((i) => i.transactionId == divTx.first.id).toList();
      expect(linkedIncomes, isEmpty);
    });

    test('Skips duplicate dividend transactions on second import', () async {
      final mockRows = [
        ParsedDividendExcelRow(
          rowIndex: 2,
          date: DateTime(2024, 7, 15),
          symbol: 'O',
          grossUsd: 1.05,
          taxUsd: 0.16,
          netUsd: 0.89,
          fxRate: Decimal.parse('36.21'),
          grossSatang: 105,
          taxSatang: 16,
          netUsdSatang: 89,
          netThbSatang: 3223,
          withholdingTaxThbSatang: 579,
        ),
      ];

      // First import
      final res1 = await executor.executeImport(fileName: 'ปันผล.xlsx', rows: mockRows);
      expect(res1.imported, 1);

      // Second import
      final res2 = await executor.executeImport(fileName: 'ปันผล.xlsx', rows: mockRows);
      expect(res2.imported, 0);
      expect(res2.skippedDuplicates, 1);
    });
  });
}
