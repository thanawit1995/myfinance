// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_transactions_dao.dart';

// ignore_for_file: type=lint
mixin _$RecurringTransactionsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecurringRulesTable get recurringRules => attachedDatabase.recurringRules;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  $AccountsTable get accounts => attachedDatabase.accounts;
  $CategoriesTable get categories => attachedDatabase.categories;
  $AuditLogsTable get auditLogs => attachedDatabase.auditLogs;
  RecurringTransactionsDaoManager get managers =>
      RecurringTransactionsDaoManager(this);
}

class RecurringTransactionsDaoManager {
  final _$RecurringTransactionsDaoMixin _db;
  RecurringTransactionsDaoManager(this._db);
  $$RecurringRulesTableTableManager get recurringRules =>
      $$RecurringRulesTableTableManager(
        _db.attachedDatabase,
        _db.recurringRules,
      );
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db.attachedDatabase, _db.categories);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db.attachedDatabase, _db.auditLogs);
}
