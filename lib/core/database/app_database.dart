import 'package:drift/drift.dart';
import 'tables/all_tables.dart';
import 'daos/accounts_dao.dart';
import 'daos/credit_card_dao.dart';
import 'daos/categories_dao.dart';
import 'daos/transactions_dao.dart';
import 'daos/budgets_dao.dart';
import 'daos/investments_dao.dart';
import 'daos/liabilities_dao.dart';
import 'daos/insurance_dao.dart';
import 'daos/recurring_transactions_dao.dart';
import 'daos/financial_health_dao.dart';
import 'daos/projects_dao.dart';
import 'daos/tax_dao.dart';
import 'daos/remittances_dao.dart';
import 'daos/import_batches_dao.dart';
import 'daos/sync_dao.dart';
import 'connection/connection.dart' as impl;
import 'seed_data.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Currencies,
    FxRates,
    Accounts,
    Categories,
    Assets,
    Transactions,
    AuditLogs,
    CreditCardInstallments,
    InvestmentLots,
    InvestmentSales,
    AssetPrices,
    Budgets,
    RecurringRules,
    TaxDeductions,
    ForeignRemittances,
    FinancialHealthSettings,
    BalanceSnapshots,
    InvestmentIncomes,
    Liabilities,
    InsurancePolicies,
    Projects,
    TaxRules,
    TaxResidencyRecords,
    ImportBatches,
    ConflictLogs,
    InvestmentPortfolios,
  ],
  daos: [
    AccountsDao,
    CreditCardDao,
    CategoriesDao,
    TransactionsDao,
    BudgetsDao,
    InvestmentsDao,
    LiabilitiesDao,
    InsuranceDao,
    RecurringTransactionsDao,
    FinancialHealthDao,
    ProjectsDao,
    TaxDao,
    RemittancesDao,
    ImportBatchesDao,
    SyncDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.openConnection());

  AppDatabase.forTesting(super.connection);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        final existingTables = await customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE '_drift_%';",
        ).get();
        if (existingTables.isNotEmpty) {
          // Tables already exist in this database file (e.g. from restored backup, CSV import, or master snapshot with user_version = 0).
          // Do NOT run m.createAll() as it throws 'SqliteException(1): index idx_trans_date already exists'.
          for (final entity in allSchemaEntities) {
            if (entity is TableInfo) {
              final exists = existingTables.any((t) => t.data['name'] == entity.actualTableName);
              if (!exists) {
                await m.createTable(entity);
              }
            }
          }
          await _ensureAllColumnsExist(m);
          await _ensureAllIndexesExist();
          await customStatement('PRAGMA user_version = $schemaVersion;');
          return;
        }
        await m.createAll();
        await SeedData.insertSeedData(this);
        await SeedData.insertTaxRulesSeedData(this);
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.addColumn(transactions, transactions.feeThbSatang);
          await m.addColumn(transactions, transactions.tag);
        }
        if (from < 3) {
          await m.addColumn(assets, assets.market);
          await m.addColumn(assets, assets.note);
          await m.addColumn(assets, assets.extraDetailsJson);
          await m.addColumn(investmentLots, investmentLots.totalCostThbSatang);
          await m.addColumn(investmentLots, investmentLots.remainingCostThbSatang);
          await m.addColumn(investmentSales, investmentSales.priceGainLossThbSatang);
          await m.addColumn(investmentSales, investmentSales.fxGainLossThbSatang);
          await m.addColumn(investmentSales, investmentSales.sellFxRate);
          await m.addColumn(investmentSales, investmentSales.buyFxRate);
          await m.createTable(investmentIncomes);
        }
        if (from < 4) {
          await m.createTable(liabilities);
          await m.createTable(insurancePolicies);
          await m.addColumn(recurringRules, recurringRules.intervalUnits);
          await m.addColumn(recurringRules, recurringRules.autoPost);
          await m.addColumn(recurringRules, recurringRules.lastPostedDate);
          await m.addColumn(recurringRules, recurringRules.note);
          await m.addColumn(financialHealthSettings, financialHealthSettings.warningValue);
        }
        if (from < 5) {
          await m.createTable(projects);
        }
        if (from < 6) {
          await m.createTable(taxRules);
          await m.createTable(taxResidencyRecords);
          await m.addColumn(transactions, transactions.taxCategory);
          await m.addColumn(transactions, transactions.withholdingTaxSatang);
          await m.addColumn(foreignRemittances, foreignRemittances.destinationAccountId);
          await m.addColumn(foreignRemittances, foreignRemittances.incomeSourceType);
          await m.addColumn(foreignRemittances, foreignRemittances.isPrincipal);
          await m.addColumn(foreignRemittances, foreignRemittances.taxYearRemitted);
          await m.addColumn(foreignRemittances, foreignRemittances.taxableReason);
          await SeedData.insertTaxRulesSeedData(this);
        }
        if (from < 7) {
          await m.createTable(importBatches);
          await m.createTable(conflictLogs);
          await m.addColumn(transactions, transactions.importBatchId);
          await m.addColumn(transactions, transactions.syncVersion);
          await m.addColumn(accounts, accounts.syncVersion);
          await m.addColumn(categories, categories.syncVersion);
        }
        if (from < 8) {
          await m.addColumn(transactions, transactions.workPeriod);
          await m.addColumn(transactions, transactions.expectedAmountSatang);
        }
        if (from < 9) {
          await m.addColumn(investmentLots, investmentLots.pricePerUnitOriginal);
          await m.addColumn(investmentLots, investmentLots.pricePerUnitThb);
          await m.addColumn(assetPrices, assetPrices.marketPriceOriginal);
          await m.addColumn(assetPrices, assetPrices.marketPriceThb);
        }
        if (from < 10) {
          await m.addColumn(categories, categories.sortOrder);
        }
        if (from < 11) {
          await m.addColumn(accounts, accounts.icon);
          await m.addColumn(assets, assets.icon);
        }
        if (from < 12) {
          await m.createTable(investmentPortfolios);
          await m.addColumn(assets, assets.portfolioId);
        }
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
        await categoriesDao.ensureEssentialTaxCategories();
        await customStatement(
          "UPDATE transactions SET is_cleared = 1, work_period = NULL, expected_amount_satang = NULL WHERE transaction_type != 'income' AND is_cleared = 0;",
        );
        await customStatement(
          "UPDATE transactions SET source_account_id = destination_account_id WHERE (source_account_id IS NULL OR source_account_id = '') AND destination_account_id IS NOT NULL;",
        );
        await customStatement(
          "UPDATE transactions SET destination_account_id = source_account_id WHERE (destination_account_id IS NULL OR destination_account_id = '') AND transaction_type = 'income' AND source_account_id IS NOT NULL;",
        );
        await insuranceDao.patchLegacyInsuranceTransactions();
        await transactionsDao.cleanupExpiredDeletedTransactions();
      },
    );
  }

  Future<void> _safeAddColumn(Migrator m, dynamic table, GeneratedColumn col) async {
    try {
      await m.addColumn(table, col);
    } catch (_) {}
  }

  Future<void> _ensureAllColumnsExist(Migrator m) async {
    await _safeAddColumn(m, transactions, transactions.feeThbSatang);
    await _safeAddColumn(m, transactions, transactions.tag);
    await _safeAddColumn(m, assets, assets.market);
    await _safeAddColumn(m, assets, assets.note);
    await _safeAddColumn(m, assets, assets.extraDetailsJson);
    await _safeAddColumn(m, investmentLots, investmentLots.totalCostThbSatang);
    await _safeAddColumn(m, investmentLots, investmentLots.remainingCostThbSatang);
    await _safeAddColumn(m, investmentSales, investmentSales.priceGainLossThbSatang);
    await _safeAddColumn(m, investmentSales, investmentSales.fxGainLossThbSatang);
    await _safeAddColumn(m, investmentSales, investmentSales.sellFxRate);
    await _safeAddColumn(m, investmentSales, investmentSales.buyFxRate);
    await _safeAddColumn(m, recurringRules, recurringRules.intervalUnits);
    await _safeAddColumn(m, recurringRules, recurringRules.autoPost);
    await _safeAddColumn(m, recurringRules, recurringRules.lastPostedDate);
    await _safeAddColumn(m, recurringRules, recurringRules.note);
    await _safeAddColumn(m, financialHealthSettings, financialHealthSettings.warningValue);
    await _safeAddColumn(m, transactions, transactions.taxCategory);
    await _safeAddColumn(m, transactions, transactions.withholdingTaxSatang);
    await _safeAddColumn(m, foreignRemittances, foreignRemittances.destinationAccountId);
    await _safeAddColumn(m, foreignRemittances, foreignRemittances.incomeSourceType);
    await _safeAddColumn(m, foreignRemittances, foreignRemittances.isPrincipal);
    await _safeAddColumn(m, foreignRemittances, foreignRemittances.taxYearRemitted);
    await _safeAddColumn(m, foreignRemittances, foreignRemittances.taxableReason);
    await _safeAddColumn(m, transactions, transactions.importBatchId);
    await _safeAddColumn(m, transactions, transactions.syncVersion);
    await _safeAddColumn(m, accounts, accounts.syncVersion);
    await _safeAddColumn(m, categories, categories.syncVersion);
    await _safeAddColumn(m, transactions, transactions.workPeriod);
    await _safeAddColumn(m, transactions, transactions.expectedAmountSatang);
    await _safeAddColumn(m, investmentLots, investmentLots.pricePerUnitOriginal);
    await _safeAddColumn(m, investmentLots, investmentLots.pricePerUnitThb);
    await _safeAddColumn(m, assetPrices, assetPrices.marketPriceOriginal);
    await _safeAddColumn(m, assetPrices, assetPrices.marketPriceThb);
    await _safeAddColumn(m, categories, categories.sortOrder);
    await _safeAddColumn(m, accounts, accounts.icon);
    await _safeAddColumn(m, assets, assets.icon);
    await _safeAddColumn(m, assets, assets.portfolioId);
  }

  Future<void> _ensureAllIndexesExist() async {
    const indexSqls = [
      'CREATE INDEX IF NOT EXISTS idx_trans_date ON transactions (transaction_date);',
      'CREATE INDEX IF NOT EXISTS idx_trans_source_acc ON transactions (source_account_id);',
      'CREATE INDEX IF NOT EXISTS idx_trans_category ON transactions (category_id);',
      'CREATE INDEX IF NOT EXISTS idx_trans_asset ON transactions (asset_id);',
      'CREATE INDEX IF NOT EXISTS idx_trans_deleted_at ON transactions (deleted_at);',
      'CREATE INDEX IF NOT EXISTS idx_trans_import_batch ON transactions (import_batch_id);',
      'CREATE INDEX IF NOT EXISTS idx_lots_asset ON investment_lots (asset_id);',
      'CREATE INDEX IF NOT EXISTS idx_sales_lot ON investment_sales (lot_id);',
      'CREATE INDEX IF NOT EXISTS idx_snapshots_acc_date ON account_snapshots (account_id, snapshot_date);',
      'CREATE INDEX IF NOT EXISTS idx_incomes_asset ON investment_incomes (asset_id);',
    ];
    for (final sql in indexSqls) {
      try {
        await customStatement(sql);
      } catch (_) {}
    }
  }
}

