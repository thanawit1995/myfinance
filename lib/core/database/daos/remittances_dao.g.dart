// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remittances_dao.dart';

// ignore_for_file: type=lint
mixin _$RemittancesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ForeignRemittancesTable get foreignRemittances =>
      attachedDatabase.foreignRemittances;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  RemittancesDaoManager get managers => RemittancesDaoManager(this);
}

class RemittancesDaoManager {
  final _$RemittancesDaoMixin _db;
  RemittancesDaoManager(this._db);
  $$ForeignRemittancesTableTableManager get foreignRemittances =>
      $$ForeignRemittancesTableTableManager(
        _db.attachedDatabase,
        _db.foreignRemittances,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
