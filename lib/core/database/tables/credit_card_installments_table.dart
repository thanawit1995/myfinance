import 'package:drift/drift.dart';
import 'transactions_table.dart';
import 'accounts_table.dart';

class CreditCardInstallments extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get transactionId => text().references(Transactions, #id)();
  TextColumn get accountId => text().references(Accounts, #id)();
  IntColumn get totalAmountSatang => integer()();
  IntColumn get monthlyAmountSatang => integer()();
  IntColumn get totalTenorMonths => integer()();
  IntColumn get remainingTenorMonths => integer()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
