import 'package:drift/drift.dart';
import 'assets_table.dart';

class AssetPrices extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get assetId => text().references(Assets, #id)();
  DateTimeColumn get priceDate => dateTime()();
  IntColumn get marketPriceOriginalSatang => integer()();
  TextColumn get fxRate => text()();
  IntColumn get marketPriceThbSatang => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
