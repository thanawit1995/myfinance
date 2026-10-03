import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/sync/cloud_vault_snapshot_helper.dart';

void main() {
  group('CloudVaultSnapshotHelper Unit Tests', () {
    late AppDatabase db1;
    late AppDatabase db2;

    setUp(() {
      db1 = AppDatabase.forTesting(inMemoryConnection());
      db2 = AppDatabase.forTesting(inMemoryConnection());
    });

    tearDown(() async {
      await db1.close();
      await db2.close();
    });

    test('Packs database to compressed Base64 and restores completely into another database', () async {
      final now = DateTime.now();

      // 1. Insert distinct master data into db1
      await db1.into(db1.accounts).insert(
        AccountsCompanion.insert(
          id: 'acc-master-1',
          name: 'ธนาคารกสิกรไทย',
          accountType: 'bank',
          isDomestic: true,
          currencyCode: 'THB',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db1.into(db1.categories).insert(
        CategoriesCompanion.insert(
          id: 'cat-master-1',
          categoryType: 'expense',
          nameTh: 'อาหารการกิน',
          nameEn: 'Food',
          sortOrder: const Value(1),
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db1.into(db1.assets).insert(
        AssetsCompanion.insert(
          id: 'ast-master-1',
          symbol: 'SCB',
          name: 'ธนาคารไทยพาณิชย์',
          assetType: 'stock',
          defaultAccountId: 'acc-master-1',
          currencyCode: 'THB',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db1.into(db1.budgets).insert(
        BudgetsCompanion.insert(
          id: 'bdg-master-1',
          categoryId: 'cat-master-1',
          limitSatang: 1500000,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db1.into(db1.transactions).insert(
        TransactionsCompanion.insert(
          id: 'tx-master-1',
          transactionType: 'expense',
          amountOriginalSatang: 25000,
          amountThbSatang: 25000,
          currencyCode: 'THB',
          transactionDate: DateTime(2026, 10, 3, 10, 0),
          createdAt: now,
          updatedAt: now,
          note: const Value('มื้อกลางวัน'),
        ),
      );

      // 2. Pack db1
      final packResult = await CloudVaultSnapshotHelper.packDatabaseToCompressedBase64(db1);
      expect(packResult.base64Payload, isNotEmpty);
      expect(packResult.rawSizeBytes, isPositive);
      expect(packResult.compressedSizeBytes, isPositive);

      // 3. Unpack into db2
      final ok = await CloudVaultSnapshotHelper.unpackCompressedBase64ToDatabase(
        packResult.base64Payload,
        db2,
      );
      expect(ok, isTrue);

      // 4. Verify db2 has all 5 master items
      final accInDb2 = await (db2.select(db2.accounts)..where((t) => t.id.equals('acc-master-1'))).getSingleOrNull();
      expect(accInDb2, isNotNull);
      expect(accInDb2!.name, equals('ธนาคารกสิกรไทย'));

      final catInDb2 = await (db2.select(db2.categories)..where((t) => t.id.equals('cat-master-1'))).getSingleOrNull();
      expect(catInDb2, isNotNull);
      expect(catInDb2!.nameTh, equals('อาหารการกิน'));
      expect(catInDb2.sortOrder, equals(1));

      final astInDb2 = await (db2.select(db2.assets)..where((t) => t.id.equals('ast-master-1'))).getSingleOrNull();
      expect(astInDb2, isNotNull);
      expect(astInDb2!.symbol, equals('SCB'));

      final bdgInDb2 = await (db2.select(db2.budgets)..where((t) => t.id.equals('bdg-master-1'))).getSingleOrNull();
      expect(bdgInDb2, isNotNull);
      expect(bdgInDb2!.limitSatang, equals(1500000));

      final txInDb2 = await (db2.select(db2.transactions)..where((t) => t.id.equals('tx-master-1'))).getSingleOrNull();
      expect(txInDb2, isNotNull);
      expect(txInDb2!.amountThbSatang, equals(25000));
      expect(txInDb2.note, equals('มื้อกลางวัน'));
    });

    test('Deleted asset in master is cleanly purged when snapshot is restored in receiver (Clean Slate Master)', () async {
      // Setup db2 with an old asset (like old GPF)
      await db2.into(db2.assets).insert(
        AssetsCompanion.insert(
          id: 'old-gpf-id',
          symbol: 'GPF',
          name: 'กองทุน กบข.',
          assetType: 'fund',
          defaultAccountId: '00000000-0000-4000-8000-000000000001',
          currencyCode: 'THB',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Verify old GPF exists in db2
      final beforeAst = await (db2.select(db2.assets)..where((t) => t.id.equals('old-gpf-id'))).getSingleOrNull();
      expect(beforeAst, isNotNull);

      // In db1 (Master), GPF has been deleted (db1 has no GPF)
      // Pack master
      final packResult = await CloudVaultSnapshotHelper.packDatabaseToCompressedBase64(db1);

      // Restore snapshot into db2
      final ok = await CloudVaultSnapshotHelper.unpackCompressedBase64ToDatabase(
        packResult.base64Payload,
        db2,
      );
      expect(ok, isTrue);

      // Verify old GPF is completely purged from db2!
      final afterAst = await (db2.select(db2.assets)..where((t) => t.id.equals('old-gpf-id'))).getSingleOrNull();
      expect(afterAst, isNull);
    });
  });
}
