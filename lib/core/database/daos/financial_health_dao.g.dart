// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_health_dao.dart';

// ignore_for_file: type=lint
mixin _$FinancialHealthDaoMixin on DatabaseAccessor<AppDatabase> {
  $FinancialHealthSettingsTable get financialHealthSettings =>
      attachedDatabase.financialHealthSettings;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $LiabilitiesTable get liabilities => attachedDatabase.liabilities;
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
  $AssetsTable get assets => attachedDatabase.assets;
  $BudgetsTable get budgets => attachedDatabase.budgets;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  FinancialHealthDaoManager get managers => FinancialHealthDaoManager(this);
}

class FinancialHealthDaoManager {
  final _$FinancialHealthDaoMixin _db;
  FinancialHealthDaoManager(this._db);
  $$FinancialHealthSettingsTableTableManager get financialHealthSettings =>
      $$FinancialHealthSettingsTableTableManager(
        _db.attachedDatabase,
        _db.financialHealthSettings,
      );
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$LiabilitiesTableTableManager get liabilities =>
      $$LiabilitiesTableTableManager(_db.attachedDatabase, _db.liabilities);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(
        _db.attachedDatabase,
        _db.insurancePolicies,
      );
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db.attachedDatabase, _db.budgets);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
