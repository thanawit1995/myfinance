import 'package:drift/drift.dart';
import 'investment_lots_table.dart';
import 'transactions_table.dart';

@TableIndex(name: 'idx_sales_lot', columns: {#lotId})
class InvestmentSales extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get sellTransactionId => text().references(Transactions, #id)();
  TextColumn get lotId => text().references(InvestmentLots, #id)();
  DateTimeColumn get sellDate => dateTime()();
  TextColumn get quantitySold => text()(); // Decimal string with 8 decimals
  IntColumn get sellPriceThbSatang => integer()();
  IntColumn get costThbSatang => integer()();
  IntColumn get realizedGainLossThbSatang => integer()();
  IntColumn get priceGainLossThbSatang => integer().withDefault(const Constant(0))();
  IntColumn get fxGainLossThbSatang => integer().withDefault(const Constant(0))();
  TextColumn get sellFxRate => text().withDefault(const Constant('1.000000'))();
  TextColumn get buyFxRate => text().withDefault(const Constant('1.000000'))();
  IntColumn get feeThbSatang => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
