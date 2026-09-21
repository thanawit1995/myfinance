// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insurance_dao.dart';

// ignore_for_file: type=lint
mixin _$InsuranceDaoMixin on DatabaseAccessor<AppDatabase> {
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  InsuranceDaoManager get managers => InsuranceDaoManager(this);
}

class InsuranceDaoManager {
  final _$InsuranceDaoMixin _db;
  InsuranceDaoManager(this._db);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(
        _db.attachedDatabase,
        _db.insurancePolicies,
      );
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
