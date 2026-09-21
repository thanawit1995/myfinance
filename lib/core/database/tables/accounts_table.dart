import 'package:drift/drift.dart';
import 'currencies_table.dart';

class Accounts extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()();
  TextColumn get accountType => text()(); // bank, fcd, offshore, credit_card, cash
  TextColumn get currencyCode => text().references(Currencies, #code)();
  BoolColumn get isDomestic => boolean()();
  IntColumn get closingDay => integer().nullable()(); // 23 for credit card
  IntColumn get dueDay => integer().nullable()();
  IntColumn get creditLimitSatang => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
