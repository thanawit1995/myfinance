// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tax_dao.dart';

// ignore_for_file: type=lint
mixin _$TaxDaoMixin on DatabaseAccessor<AppDatabase> {
  $TaxRulesTable get taxRules => attachedDatabase.taxRules;
  $TaxDeductionsTable get taxDeductions => attachedDatabase.taxDeductions;
  $TaxResidencyRecordsTable get taxResidencyRecords =>
      attachedDatabase.taxResidencyRecords;
  $TransactionsTable get transactions => attachedDatabase.transactions;
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
  $$TaxDeductionsTableTableManager get taxDeductions =>
      $$TaxDeductionsTableTableManager(_db.attachedDatabase, _db.taxDeductions);
  $$TaxResidencyRecordsTableTableManager get taxResidencyRecords =>
      $$TaxResidencyRecordsTableTableManager(
        _db.attachedDatabase,
        _db.taxResidencyRecords,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
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
