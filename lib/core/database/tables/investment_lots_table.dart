import 'package:drift/drift.dart';
import 'assets_table.dart';
import 'transactions_table.dart';

@TableIndex(name: 'idx_lots_asset', columns: {#assetId})
class InvestmentLots extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get assetId => text().references(Assets, #id)();
  TextColumn get buyTransactionId => text().references(Transactions, #id)();
  DateTimeColumn get buyDate => dateTime()();
  TextColumn get quantity => text()(); // Decimal string with 8 decimals
  TextColumn get remainingQuantity => text()(); // Decimal string with 8 decimals
  IntColumn get costPerUnitOriginalSatang => integer()();
  TextColumn get fxRate => text()(); // Decimal string with 6 decimals
  IntColumn get costPerUnitThbSatang => integer()();
  TextColumn get pricePerUnitOriginal => text().nullable()(); // Decimal string with 4-8 decimals e.g. "31.9043"
  TextColumn get pricePerUnitThb => text().nullable()(); // Decimal string with 4-8 decimals
  IntColumn get feeThbSatang => integer()();
  IntColumn get totalCostThbSatang => integer().withDefault(const Constant(0))();
  IntColumn get remainingCostThbSatang => integer().withDefault(const Constant(0))();
  TextColumn get status => text()(); // open, partially_closed, closed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
