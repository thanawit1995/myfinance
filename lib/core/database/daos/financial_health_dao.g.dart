// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'financial_health_dao.dart';

// ignore_for_file: type=lint
mixin _$FinancialHealthDaoMixin on DatabaseAccessor<AppDatabase> {
  $FinancialHealthSettingsTable get financialHealthSettings =>
      attachedDatabase.financialHealthSettings;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetsTable get assets => attachedDatabase.assets;
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $LiabilitiesTable get liabilities => attachedDatabase.liabilities;
  $InsurancePoliciesTable get insurancePolicies =>
      attachedDatabase.insurancePolicies;
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
  $$LiabilitiesTableTableManager get liabilities =>
      $$LiabilitiesTableTableManager(_db.attachedDatabase, _db.liabilities);
  $$InsurancePoliciesTableTableManager get insurancePolicies =>
      $$InsurancePoliciesTableTableManager(
        _db.attachedDatabase,
        _db.insurancePolicies,
      );
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db.attachedDatabase, _db.budgets);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
