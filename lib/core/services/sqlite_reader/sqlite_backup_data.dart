class SqliteBackupData {
  final int accountsCount;
  final int transactionsCount;
  final DateTime? latestTransactionDate;
  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> categories;
  final List<Map<String, dynamic>> transactions;
  final List<Map<String, dynamic>> assets;
  final List<Map<String, dynamic>> insurancePolicies;
  final List<Map<String, dynamic>> liabilities;
  final List<Map<String, dynamic>> budgets;
  final List<Map<String, dynamic>> recurringRules;
  final List<Map<String, dynamic>> projects;
  final List<Map<String, dynamic>> creditCardInstallments;
  final List<Map<String, dynamic>> investmentLots;
  final List<Map<String, dynamic>> investmentSales;
  final List<Map<String, dynamic>> investmentIncomes;
  final List<Map<String, dynamic>> taxDeductions;
  final Map<String, List<Map<String, dynamic>>> allTables;

  const SqliteBackupData({
    required this.accountsCount,
    required this.transactionsCount,
    this.latestTransactionDate,
    this.accounts = const [],
    this.categories = const [],
    this.transactions = const [],
    this.assets = const [],
    this.insurancePolicies = const [],
    this.liabilities = const [],
    this.budgets = const [],
    this.recurringRules = const [],
    this.projects = const [],
    this.creditCardInstallments = const [],
    this.investmentLots = const [],
    this.investmentSales = const [],
    this.investmentIncomes = const [],
    this.taxDeductions = const [],
    this.allTables = const {},
  });
}
