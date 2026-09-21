class CsvColumnMapping {
  final int dateCol;
  final int nameCol;
  final int categoryCol;
  final int amountCol;
  final int? accountCol;
  final int? noteCol;
  final int? taxTypeCol;
  final int? whtCol;

  const CsvColumnMapping({
    required this.dateCol,
    required this.nameCol,
    required this.categoryCol,
    required this.amountCol,
    this.accountCol,
    this.noteCol,
    this.taxTypeCol,
    this.whtCol,
  });

  CsvColumnMapping copyWith({
    int? dateCol,
    int? nameCol,
    int? categoryCol,
    int? amountCol,
    int? accountCol,
    int? noteCol,
    int? taxTypeCol,
    int? whtCol,
  }) {
    return CsvColumnMapping(
      dateCol: dateCol ?? this.dateCol,
      nameCol: nameCol ?? this.nameCol,
      categoryCol: categoryCol ?? this.categoryCol,
      amountCol: amountCol ?? this.amountCol,
      accountCol: accountCol ?? this.accountCol,
      noteCol: noteCol ?? this.noteCol,
      taxTypeCol: taxTypeCol ?? this.taxTypeCol,
      whtCol: whtCol ?? this.whtCol,
    );
  }
}

class ParsedCsvRow {
  final int rowIndex;
  final DateTime? date;
  final String rawDateString;
  final String name;
  final String categoryName;
  final String? accountName;
  final int amountSatang;
  final String transactionType; // 'income' or 'expense'
  final String? taxCategory; // '40_1', '40_2', 'non_taxable', etc.
  final int withholdingTaxSatang;
  final String? note;
  final bool isSummaryRow;
  final bool isDuplicate;
  final String? validationError;
  final List<dynamic> rawRow;

  const ParsedCsvRow({
    required this.rowIndex,
    this.date,
    required this.rawDateString,
    required this.name,
    required this.categoryName,
    this.accountName,
    required this.amountSatang,
    required this.transactionType,
    this.taxCategory,
    this.withholdingTaxSatang = 0,
    this.note,
    this.isSummaryRow = false,
    this.isDuplicate = false,
    this.validationError,
    required this.rawRow,
  });

  bool get isValid => validationError == null && !isSummaryRow && date != null;

  ParsedCsvRow copyWith({
    int? rowIndex,
    DateTime? date,
    String? rawDateString,
    String? name,
    String? categoryName,
    String? accountName,
    int? amountSatang,
    String? transactionType,
    String? taxCategory,
    int? withholdingTaxSatang,
    String? note,
    bool? isSummaryRow,
    bool? isDuplicate,
    String? validationError,
    List<dynamic>? rawRow,
  }) {
    return ParsedCsvRow(
      rowIndex: rowIndex ?? this.rowIndex,
      date: date ?? this.date,
      rawDateString: rawDateString ?? this.rawDateString,
      name: name ?? this.name,
      categoryName: categoryName ?? this.categoryName,
      accountName: accountName ?? this.accountName,
      amountSatang: amountSatang ?? this.amountSatang,
      transactionType: transactionType ?? this.transactionType,
      taxCategory: taxCategory ?? this.taxCategory,
      withholdingTaxSatang: withholdingTaxSatang ?? this.withholdingTaxSatang,
      note: note ?? this.note,
      isSummaryRow: isSummaryRow ?? this.isSummaryRow,
      isDuplicate: isDuplicate ?? this.isDuplicate,
      validationError: validationError ?? this.validationError,
      rawRow: rawRow ?? this.rawRow,
    );
  }
}

class CsvImportBatchResult {
  final String batchId;
  final String fileName;
  final String templateType;
  final int totalRows;
  final int importedCount;
  final int duplicateCount;
  final int skippedCount;
  final List<String> createdCategories;
  final List<String> createdAccounts;
  final DateTime importedAt;

  const CsvImportBatchResult({
    required this.batchId,
    required this.fileName,
    required this.templateType,
    required this.totalRows,
    required this.importedCount,
    required this.duplicateCount,
    required this.skippedCount,
    required this.createdCategories,
    required this.createdAccounts,
    required this.importedAt,
  });
}
