import 'package:drift/drift.dart';
import 'transactions_table.dart';
import 'assets_table.dart';
import 'currencies_table.dart';

@TableIndex(name: 'idx_incomes_asset', columns: {#assetId})
class InvestmentIncomes extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get assetId => text().references(Assets, #id)();
  TextColumn get incomeType => text()(); // dividend, interest, bond_coupon, other
  IntColumn get grossAmountOriginalSatang => integer()();
  TextColumn get currencyCode => text().references(Currencies, #code)();
  TextColumn get fxRate => text()(); // Decimal string with 6 decimals
  IntColumn get grossAmountThbSatang => integer()();
  IntColumn get withholdingTaxThbSatang => integer().withDefault(const Constant(0))();
  IntColumn get dividendTaxCreditSatang => integer().withDefault(const Constant(0))();
  IntColumn get netAmountThbSatang => integer()();
  BoolColumn get isForeignIncome => boolean().withDefault(const Constant(false))();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
