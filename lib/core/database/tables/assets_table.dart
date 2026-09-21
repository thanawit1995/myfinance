import 'package:drift/drift.dart';
import 'currencies_table.dart';
import 'accounts_table.dart';

class Assets extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get symbol => text()(); // PTT, VOO, BTC
  TextColumn get name => text()();
  TextColumn get assetType => text()(); // thai_stock, foreign_stock, etf, mutual_fund, crypto, gold, bond
  TextColumn get currencyCode => text().references(Currencies, #code)();
  TextColumn get defaultAccountId => text().references(Accounts, #id)();
  TextColumn get market => text().nullable()(); // SET, TFEX, NYSE, NASDAQ, etc.
  TextColumn get note => text().nullable()();
  TextColumn get extraDetailsJson => text().nullable()(); // For bonds: couponRate, maturityDate, frequency
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
