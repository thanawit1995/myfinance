import 'package:drift/drift.dart';

class InvestmentPortfolios extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()(); // e.g. 'พอร์ต DCA เกษียณ', 'พอร์ตเก็งกำไร'
  TextColumn get description => text().nullable()();
  TextColumn get color => text().nullable()(); // hex color string
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
