import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_database.dart';
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

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final accountsDaoProvider = Provider<AccountsDao>((ref) {
  return ref.watch(databaseProvider).accountsDao;
});

final creditCardDaoProvider = Provider<CreditCardDao>((ref) {
  return ref.watch(databaseProvider).creditCardDao;
});

final categoriesDaoProvider = Provider<CategoriesDao>((ref) {
  return ref.watch(databaseProvider).categoriesDao;
});

final transactionsDaoProvider = Provider<TransactionsDao>((ref) {
  return ref.watch(databaseProvider).transactionsDao;
});

final budgetsDaoProvider = Provider<BudgetsDao>((ref) {
  return ref.watch(databaseProvider).budgetsDao;
});

final investmentsDaoProvider = Provider<InvestmentsDao>((ref) {
  return ref.watch(databaseProvider).investmentsDao;
});

final liabilitiesDaoProvider = Provider<LiabilitiesDao>((ref) {
  return ref.watch(databaseProvider).liabilitiesDao;
});

final insuranceDaoProvider = Provider<InsuranceDao>((ref) {
  return ref.watch(databaseProvider).insuranceDao;
});

final recurringTransactionsDaoProvider = Provider<RecurringTransactionsDao>((ref) {
  return ref.watch(databaseProvider).recurringTransactionsDao;
});

final financialHealthDaoProvider = Provider<FinancialHealthDao>((ref) {
  return ref.watch(databaseProvider).financialHealthDao;
});

final projectsDaoProvider = Provider<ProjectsDao>((ref) {
  return ref.watch(databaseProvider).projectsDao;
});

final taxDaoProvider = Provider<TaxDao>((ref) {
  return ref.watch(databaseProvider).taxDao;
});

final remittancesDaoProvider = Provider<RemittancesDao>((ref) {
  return ref.watch(databaseProvider).remittancesDao;
});

final importBatchesDaoProvider = Provider<ImportBatchesDao>((ref) {
  return ref.watch(databaseProvider).importBatchesDao;
});

final syncDaoProvider = Provider<SyncDao>((ref) {
  return ref.watch(databaseProvider).syncDao;
});

/// Incremented whenever transactions or payments are recorded, updated, or deleted
/// to trigger immediate reactive rebuilds of home, accounts, and summary dashboards.
final transactionsVersionProvider = StateProvider<int>((ref) => 0);

