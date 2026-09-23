// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_batches_dao.dart';

// ignore_for_file: type=lint
mixin _$ImportBatchesDaoMixin on DatabaseAccessor<AppDatabase> {
  $ImportBatchesTable get importBatches => attachedDatabase.importBatches;
  $TransactionsTable get transactions => attachedDatabase.transactions;
  ImportBatchesDaoManager get managers => ImportBatchesDaoManager(this);
}

class ImportBatchesDaoManager {
  final _$ImportBatchesDaoMixin _db;
  ImportBatchesDaoManager(this._db);
  $$ImportBatchesTableTableManager get importBatches =>
      $$ImportBatchesTableTableManager(_db.attachedDatabase, _db.importBatches);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db.attachedDatabase, _db.transactions);
}
