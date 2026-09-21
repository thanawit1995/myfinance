import 'package:drift/drift.dart';
import 'transactions_table.dart';

class TaxDeductions extends Table {
  TextColumn get id => text()(); // UUID v4
  IntColumn get taxYear => integer()();
  TextColumn get deductionGroup => text()(); // personal, insurance, fund, property, donation
  TextColumn get deductionType => text()();
  IntColumn get amountSatang => integer()();
  TextColumn get transactionId => text().nullable().references(Transactions, #id)();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
