import 'package:drift/drift.dart';
import 'assets_table.dart';

class AssetPrices extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get assetId => text().references(Assets, #id)();
  DateTimeColumn get priceDate => dateTime()();
  IntColumn get marketPriceOriginalSatang => integer()();
  TextColumn get fxRate => text()();
  IntColumn get marketPriceThbSatang => integer()();
  TextColumn get marketPriceOriginal => text().nullable()(); // Decimal string with 4-8 decimals e.g. "31.9043"
  TextColumn get marketPriceThb => text().nullable()(); // Decimal string with 4-8 decimals
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
