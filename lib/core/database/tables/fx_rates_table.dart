import 'package:drift/drift.dart';
import 'currencies_table.dart';

class FxRates extends Table {
  TextColumn get id => text()(); // UUID v4
  @ReferenceName('baseFxRates')
  TextColumn get baseCurrency => text().references(Currencies, #code)();
  @ReferenceName('targetFxRates')
  TextColumn get targetCurrency => text().references(Currencies, #code)();
  TextColumn get rate => text()(); // Decimal string with 6 decimals
  DateTimeColumn get effectiveDate => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
