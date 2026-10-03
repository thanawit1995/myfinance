class BackupInspectionResult {
  final bool isValid;
  final String? errorMessage;
  final int totalAccounts;
  final List<String> sampleAccountNames;
  final int totalTransactions;
  final DateTime? latestTransactionDate;
  final int totalCategories;
  final int totalBudgets;
  final int totalAssets;
  final int totalInsurance;
  final int totalLiabilities;
  final int totalProjects;
  final int totalRecurringRules;
  final int sizeBytes;
  final String fileName;
  final bool isEncrypted;
  final bool requiresPassword;

  const BackupInspectionResult({
    required this.isValid,
    this.errorMessage,
    this.totalAccounts = 0,
    this.sampleAccountNames = const [],
    this.totalTransactions = 0,
    this.latestTransactionDate,
    this.totalCategories = 0,
    this.totalBudgets = 0,
    this.totalAssets = 0,
    this.totalInsurance = 0,
    this.totalLiabilities = 0,
    this.totalProjects = 0,
    this.totalRecurringRules = 0,
    this.sizeBytes = 0,
    required this.fileName,
    this.isEncrypted = false,
    this.requiresPassword = false,
  });
}
