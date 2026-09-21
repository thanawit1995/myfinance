import 'package:drift/drift.dart';
import 'transactions_table.dart';
import 'accounts_table.dart';
import 'currencies_table.dart';

class ForeignRemittances extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get remittanceTransactionId => text().references(Transactions, #id)();
  @ReferenceName('sourceForeignRemittances')
  TextColumn get sourceAccountId => text().references(Accounts, #id)();
  @ReferenceName('destinationForeignRemittances')
  TextColumn get destinationAccountId => text().nullable().references(Accounts, #id)();
  IntColumn get taxYearEarned => integer().nullable()();
  IntColumn get taxYearRemitted => integer().nullable()();
  DateTimeColumn get remittanceDate => dateTime()();
  TextColumn get incomeSourceType => text().withDefault(const Constant('capital_gain'))(); // capital_gain, dividend, salary, savings_principal, other
  BoolColumn get isPrincipal => boolean().withDefault(const Constant(false))(); // True = original capital (Exempt)
  IntColumn get amountOriginalSatang => integer()();
  TextColumn get currencyCode => text().references(Currencies, #code)();
  TextColumn get fxRate => text()();
  IntColumn get amountThbSatang => integer()();
  BoolColumn get isTaxable => boolean().withDefault(const Constant(true))();
  TextColumn get taxableReason => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
