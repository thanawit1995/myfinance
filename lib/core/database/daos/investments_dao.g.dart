// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'investments_dao.dart';

// ignore_for_file: type=lint
mixin _$InvestmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $CurrenciesTable get currencies => attachedDatabase.currencies;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $AssetsTable get assets => attachedDatabase.assets;
  $CategoriesTable get categories => attachedDatabase.categories;
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $InvestmentLotsTable get investmentLots => attachedDatabase.investmentLots;
  $InvestmentSalesTable get investmentSales => attachedDatabase.investmentSales;
  $AssetPricesTable get assetPrices => attachedDatabase.assetPrices;
  $InvestmentIncomesTable get investmentIncomes =>
      attachedDatabase.investmentIncomes;
  $FxRatesTable get fxRates => attachedDatabase.fxRates;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  InvestmentsDaoManager get managers => InvestmentsDaoManager(this);
}

class InvestmentsDaoManager {
  final _$InvestmentsDaoMixin _db;
  InvestmentsDaoManager(this._db);
  $$CurrenciesTableTableManager get currencies =>
      $$CurrenciesTableTableManager(_db.attachedDatabase, _db.currencies);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$AssetsTableTableManager get assets =>
      $$AssetsTableTableManager(_db.attachedDatabase, _db.assets);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db.attachedDatabase, _db.importBatches);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$InvestmentLotsTableTableManager get investmentLots =>
      $$InvestmentLotsTableTableManager(
        _db.attachedDatabase,
        _db.investmentLots,
      );
  $$InvestmentSalesTableTableManager get investmentSales =>
      $$InvestmentSalesTableTableManager(
        _db.attachedDatabase,
        _db.investmentSales,
      );
  $$AssetPricesTableTableManager get assetPrices =>
      $$AssetPricesTableTableManager(_db.attachedDatabase, _db.assetPrices);
  $$InvestmentIncomesTableTableManager get investmentIncomes =>
      $$InvestmentIncomesTableTableManager(
        _db.attachedDatabase,
        _db.investmentIncomes,
      );
  $$FxRatesTableTableManager get fxRates =>
      $$FxRatesTableTableManager(_db.attachedDatabase, _db.fxRates);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
