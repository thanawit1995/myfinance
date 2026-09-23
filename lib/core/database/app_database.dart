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
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
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
      },
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON;');
      },
    );
  }
}
