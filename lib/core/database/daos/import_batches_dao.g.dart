// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_batches_dao.dart';

// ignore_for_file: type=lint
mixin _$ImportBatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetsTable get assets => attachedDatabase.assets;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  ImportBatchesDaoManager get managers => ImportBatchesDaoManager(this);
}

class ImportBatchesDaoManager {
  final _$ImportBatchesDaoMixin _db;
  ImportBatchesDaoManager(this._db);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db.attachedDatabase, _db.importBatches);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
