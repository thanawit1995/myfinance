// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$TransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  $FxRatesTable get fxRates => attachedDatabase.fxRates;
  $CategoriesTable get categories => attachedDatabase.categories;
  TransactionsDaoManager get managers => TransactionsDaoManager(this);
}

class TransactionsDaoManager {
  final _$TransactionsDaoMixin _db;
  TransactionsDaoManager(this._db);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db.attachedDatabase, _db.fxRates);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
}
