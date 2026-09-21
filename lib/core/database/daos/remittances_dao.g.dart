// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remittances_dao.dart';

// ignore_for_file: type=lint
mixin _$RemittancesDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetsTable get assets => attachedDatabase.assets;
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $ForeignRemittancesTable get foreignRemittances =>
      attachedDatabase.foreignRemittances;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  RemittancesDaoManager get managers => RemittancesDaoManager(this);
}

class RemittancesDaoManager {
  final _$RemittancesDaoMixin _db;
  RemittancesDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db.attachedDatabase, _db.importBatches);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$ForeignRemittancesTableTableManager get foreignRemittances =>
      $$ForeignRemittancesTableTableManager(
        _db.attachedDatabase,
        _db.foreignRemittances,
      );
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
