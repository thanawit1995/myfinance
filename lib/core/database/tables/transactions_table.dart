import 'package:drift/drift.dart';
import 'currencies_table.dart';
import 'accounts_table.dart';
import 'categories_table.dart';
import 'assets_table.dart';
import 'import_batches_table.dart';

@TableIndex(name: 'idx_trans_date', columns: {#transactionDate})
@TableIndex(name: 'idx_trans_source_acc', columns: {#sourceAccountId})
@TableIndex(name: 'idx_trans_category', columns: {#categoryId})
@TableIndex(name: 'idx_trans_asset', columns: {#assetId})
@TableIndex(name: 'idx_trans_deleted_at', columns: {#deletedAt})
@TableIndex(name: 'idx_trans_import_batch', columns: {#importBatchId})
class Transactions extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get transactionType => text()(); // income, expense, transfer, invest_buy, invest_sell
  @ReferenceName('sourceTransactions')
  TextColumn get sourceAccountId => text().nullable().references(Accounts, #id)();
  @ReferenceName('destinationTransactions')
  TextColumn get destinationAccountId => text().nullable().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get assetId => text().nullable().references(Assets, #id)();
  TextColumn get importBatchId => text().nullable().references(ImportBatches, #id)();
  IntColumn get amountOriginalSatang => integer()();
  TextColumn get currencyCode => text().references(Currencies, #code)();
  TextColumn get fxRate => text().withDefault(const Constant('1.000000'))();
  IntColumn get amountThbSatang => integer()();
  IntColumn get feeThbSatang => integer().withDefault(const Constant(0))();
  TextColumn get tag => text().nullable()();
  TextColumn get taxCategory => text().nullable()(); // 40_1, 40_2, 40_4_interest, 40_4_dividend_th, 40_4_dividend_foreign, 40_4_crypto, 40_4_foreign_stock_gain, 40_6_medical, 40_8, non_taxable
  IntColumn get withholdingTaxSatang => integer().withDefault(const Constant(0))();
  DateTimeColumn get transactionDate => dateTime()();
  TextColumn get workPeriod => text().nullable()(); // รอบเดือนผลงาน เช่น '2025-12', '2026-07'
  IntColumn get expectedAmountSatang => integer().nullable()(); // ยอดประมาณการ/Budget ใน Notion
  TextColumn get note => text().nullable()();
  BoolColumn get isCleared => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
