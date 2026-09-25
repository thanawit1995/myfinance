class BackupInspectionResult {
  final bool isValid;
  final String? errorMessage;
  final int totalAccounts;
  final List<String> sampleAccountNames;
  final int totalTransactions;
  final DateTime? latestTransactionDate;
  final int sizeBytes;
  final String fileName;

  const BackupInspectionResult({
    required this.isValid,
    this.errorMessage,
    this.totalAccounts = 0,
    this.sampleAccountNames = const [],
    this.totalTransactions = 0,
    this.latestTransactionDate,
    this.sizeBytes = 0,
    required this.fileName,
  });
}
