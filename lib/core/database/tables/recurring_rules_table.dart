import 'package:drift/drift.dart';
import 'accounts_table.dart';
import 'categories_table.dart';
import 'currencies_table.dart';

class RecurringRules extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get title => text()();
  TextColumn get transactionType => text()();
  @ReferenceName('sourceRecurringRules')
  TextColumn get sourceAccountId => text().references(Accounts, #id)();
  @ReferenceName('destinationRecurringRules')
  TextColumn get destinationAccountId => text().nullable().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  IntColumn get amountSatang => integer()();
  TextColumn get currencyCode => text().references(Currencies, #code)();
  TextColumn get frequency => text()(); // daily, weekly, monthly, yearly
  IntColumn get dayOfMonth => integer().nullable()();
  DateTimeColumn get nextRunDate => dateTime()();
  DateTimeColumn get endDate => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get intervalUnits => integer().withDefault(const Constant(1))();
  BoolColumn get autoPost => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastPostedDate => dateTime().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
