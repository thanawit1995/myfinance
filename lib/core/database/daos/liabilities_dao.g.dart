// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'liabilities_dao.dart';

// ignore_for_file: type=lint
mixin _$LiabilitiesDaoMixin on DatabaseAccessor<AppDatabase> {
  $LiabilitiesTable get liabilities => attachedDatabase.liabilities;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  LiabilitiesDaoManager get managers => LiabilitiesDaoManager(this);
}

class LiabilitiesDaoManager {
  final _$LiabilitiesDaoMixin _db;
  LiabilitiesDaoManager(this._db);
  $$LiabilitiesTableTableManager get liabilities =>
      $$LiabilitiesTableTableManager(_db.attachedDatabase, _db.liabilities);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
