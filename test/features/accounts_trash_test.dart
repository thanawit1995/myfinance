import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('AccountsDao - Trash Bin & 30-Day Cascade Soft Delete Tests', () {
    test('Soft deleting an account removes it from active list and cascades to transactions', () async {
      final now = DateTime.now();
      const accId = 'acc-trash-test-1';

      // 1. Create Account
      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: accId,
          name: 'บัญชีทดสอบลบ',
          accountType: 'bank',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Add 2 Transactions
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-trash-1',
          transactionType: 'income',
          sourceAccountId: const Value(accId),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-trash-2',
          transactionType: 'expense',
          sourceAccountId: const Value(accId),
          amountOriginalSatang: 100000,
          currencyCode: 'THB',
          amountThbSatang: 100000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Verify active before delete
      var allActive = await db.accountsDao.getAllAccounts();
      expect(allActive.any((a) => a.id == accId), isTrue);

      var recentTx = await db.transactionsDao.getRecentTransactions();
      expect(recentTx.any((t) => t.id == 'tx-trash-1'), isTrue);

      // 3. Soft delete the account
      final deleted = await db.accountsDao.softDeleteAccount(accId);
      expect(deleted, isTrue);

      // Account should NO LONGER be in allAccounts (disappears from accounts screen)
      allActive = await db.accountsDao.getAllAccounts();
      expect(allActive.any((a) => a.id == accId), isFalse);

      // Account should be in deleted accounts (Trash Bin)
      final inTrash = await db.accountsDao.getDeletedAccounts();
      expect(inTrash.any((a) => a.id == accId), isTrue);

      // Transactions of this account should also be soft-deleted (disappears from recent list)
      recentTx = await db.transactionsDao.getRecentTransactions();
      expect(recentTx.any((t) => t.id == 'tx-trash-1'), isFalse);
      expect(recentTx.any((t) => t.id == 'tx-trash-2'), isFalse);

      // 4. Restore the account from Trash
      final restored = await db.accountsDao.restoreAccount(accId);
      expect(restored, isTrue);

      // Account is back in allAccounts
      allActive = await db.accountsDao.getAllAccounts();
      expect(allActive.any((a) => a.id == accId), isTrue);

      // Transactions are restored
      recentTx = await db.transactionsDao.getRecentTransactions();
      expect(recentTx.any((t) => t.id == 'tx-trash-1'), isTrue);
      expect(recentTx.any((t) => t.id == 'tx-trash-2'), isTrue);

      // Balance is intact: 5,000 - 1,000 = 4,000 THB (400,000 satang)
      final balance = await db.accountsDao.getAccountBalanceSatang(accId);
      expect(balance, equals(400000));
    });

    test('Permanent delete completely purges account and transactions', () async {
      final now = DateTime.now();
      const accId = 'acc-perm-delete';

      await db.accountsDao.createAccount(
        AccountsCompanion.insert(
          id: accId,
          name: 'บัญชีลบถาวร',
          accountType: 'bank',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-perm-1',
          transactionType: 'income',
          sourceAccountId: const Value(accId),
          amountOriginalSatang: 300000,
          currencyCode: 'THB',
          amountThbSatang: 300000,
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.accountsDao.softDeleteAccount(accId);
      await db.accountsDao.permanentlyDeleteAccount(accId);

      final inTrash = await db.accountsDao.getDeletedAccounts();
      expect(inTrash.any((a) => a.id == accId), isFalse);

      final acc = await db.accountsDao.getAccountById(accId);
      expect(acc, isNull);
    });
  });
}
