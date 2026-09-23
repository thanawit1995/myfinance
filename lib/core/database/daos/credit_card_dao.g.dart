// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_card_dao.dart';

// ignore_for_file: type=lint
mixin _$CreditCardDaoMixin on DatabaseAccessor<AppDatabase> {
  $AccountsTable get accounts => attachedDatabase.accounts;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  CreditCardDaoManager get managers => CreditCardDaoManager(this);
}

class CreditCardDaoManager {
  final _$CreditCardDaoMixin _db;
  CreditCardDaoManager(this._db);
  $$AccountsTableTableManager get accounts =>
      $$AccountsTableTableManager(_db.attachedDatabase, _db.accounts);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
