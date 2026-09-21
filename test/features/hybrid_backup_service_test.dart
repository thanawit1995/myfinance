import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/services/hybrid_backup_service.dart';

void main() {
  late AppDatabase db;
  late HybridBackupService service;

  setUp(() async {
    db = AppDatabase.forTesting(inMemoryConnection());
    service = HybridBackupService(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  group('HybridBackupService Tests', () {
    test('exportDataAsJson produces valid structured backup format', () async {
      final exported = await service.exportDataAsJson();

      expect(exported['app'], equals('MyFinance'));
      expect(exported['version'], equals(1));
      expect(exported['data'], isA<Map<String, dynamic>>());

      final data = exported['data'] as Map<String, dynamic>;
      expect(data['accounts'], isA<List>());
      expect(data['categories'], isA<List>());
      expect(data['currencies'], isA<List>());
      expect(data['transactions'], isA<List>());
    });

    test('Round-trip export and restore preserves all financial data', () async {
      final now = DateTime.now();

      // Seed initial data
      await db.into(db.currencies).insertOnConflictUpdate(
            Currency(
              code: 'THB',
              name: 'Thai Baht',
              symbol: '฿',
              isBase: true,
              createdAt: now,
              updatedAt: now,
            ),
          );

      await db.into(db.accounts).insert(
            Account(
              id: 'test-acc-roundtrip',
              name: 'KBank Vault Test',
              accountType: 'bank',
              currencyCode: 'THB',
              isDomestic: true,
              isActive: true,
              createdAt: now,
              updatedAt: now,
              syncVersion: 1,
            ),
          );

      await db.into(db.categories).insert(
            Category(
              id: 'test-cat-roundtrip',
              nameTh: 'อาหารและเครื่องดื่ม',
              nameEn: 'Food & Dining',
              categoryType: 'expense',
              isSystem: false,
              isActive: true,
              createdAt: now,
              updatedAt: now,
              syncVersion: 1,
            ),
          );

      await db.into(db.transactions).insert(
            Transaction(
              id: 'test-tx-roundtrip',
              transactionType: 'expense',
              sourceAccountId: 'test-acc-roundtrip',
              categoryId: 'test-cat-roundtrip',
              amountOriginalSatang: 35000,
              currencyCode: 'THB',
              fxRate: '1.000000',
              amountThbSatang: 35000,
              feeThbSatang: 0,
              withholdingTaxSatang: 0,
              transactionDate: now,
              note: 'อาหารมื้อค่ำ',
              isCleared: true,
              createdAt: now,
              updatedAt: now,
              syncVersion: 1,
            ),
          );

      // 1. Export to JSON
      final exported = await service.exportDataAsJson();
      final jsonString = jsonEncode(exported);

      // 2. Clear or create new clean database
      final cleanDb = AppDatabase.forTesting(inMemoryConnection());
      final restoreService = HybridBackupService(db: cleanDb);

      // 3. Restore to clean database
      final result = await restoreService.restoreFromJsonString(jsonString);

      expect(result.success, isTrue);
      expect(result.accountsCount, greaterThanOrEqualTo(1));
      expect(result.categoriesCount, greaterThanOrEqualTo(1));
      expect(result.transactionsCount, greaterThanOrEqualTo(1));

      // 4. Verify restored record integrity
      final restoredAccount = await (cleanDb.select(cleanDb.accounts)
            ..where((a) => a.id.equals('test-acc-roundtrip')))
          .getSingleOrNull();
      expect(restoredAccount, isNotNull);
      expect(restoredAccount!.name, equals('KBank Vault Test'));

      final restoredTx = await (cleanDb.select(cleanDb.transactions)
            ..where((t) => t.id.equals('test-tx-roundtrip')))
          .getSingleOrNull();
      expect(restoredTx, isNotNull);
      expect(restoredTx!.amountThbSatang, equals(35000));
      expect(restoredTx.note, equals('อาหารมื้อค่ำ'));

      await cleanDb.close();
    });

    test('restoreFromJsonString rejects invalid non-MyFinance JSON', () async {
      const invalidJson = '{"app": "OtherApp", "data": {}}';
      final result = await service.restoreFromJsonString(invalidJson);

      expect(result.success, isFalse);
      expect(result.message, contains('ไม่ใช่ไฟล์สำรองข้อมูลของ MyFinance'));
    });
  });
}
