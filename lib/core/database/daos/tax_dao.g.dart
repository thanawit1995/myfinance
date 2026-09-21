// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_dao.dart';

// ignore_for_file: type=lint
mixin _$TaxDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaxRulesTable get taxRules => attachedDatabase.taxRules;
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AssetsTable get assets => attachedDatabase.assets;
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $TaxDeductionsTable get taxDeductions => attachedDatabase.taxDeductions;
  $TaxResidencyRecordsTable get taxResidencyRecords =>
      attachedDatabase.taxResidencyRecords;
  $InvestmentIncomesTable get investmentIncomes =>
      attachedDatabase.investmentIncomes;
  $ForeignRemittancesTable get foreignRemittances =>
      attachedDatabase.foreignRemittances;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  TaxDaoManager get managers => TaxDaoManager(this);
}

class TaxDaoManager {
  final _$TaxDaoMixin _db;
  TaxDaoManager(this._db);
  $$TaxRulesTableTableManager get taxRules =>
      $$TaxRulesTableTableManager(_db.attachedDatabase, _db.taxRules);
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
  $$TaxDeductionsTableTableManager get taxDeductions =>
      $$TaxDeductionsTableTableManager(_db.attachedDatabase, _db.taxDeductions);
  $$TaxResidencyRecordsTableTableManager get taxResidencyRecords =>
      $$TaxResidencyRecordsTableTableManager(
        _db.attachedDatabase,
        _db.taxResidencyRecords,
      );
  $$InvestmentIncomesTableTableManager get investmentIncomes =>
      $$InvestmentIncomesTableTableManager(
        _db.attachedDatabase,
        _db.investmentIncomes,
      );
  $$ForeignRemittancesTableTableManager get foreignRemittances =>
      $$ForeignRemittancesTableTableManager(
        _db.attachedDatabase,
        _db.foreignRemittances,
      );
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
