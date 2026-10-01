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
  });
}
