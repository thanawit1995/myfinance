import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
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

  group('TransactionsDao - Accrued Income Account Deposit Timing Tests', () {
    test('Uncleared income does not enter account balance or account transactions until received', () async {
      final now = DateTime.now();

      // 1. Create a Bank Account (Initial balance: 0 THB)
      const accId = 'acc-kbank-test';
      await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: accId,
          name: 'KBank',
          accountType: 'bank',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final initialBalance = await db.accountsDao.getAccountBalanceSatang(accId);
      expect(initialBalance, equals(0));

      // 2. Create Uncleared Income: 10,000 THB (sourceAccountId: null or accId, isCleared: false)
      const txId = 'tx-salary-accrued';
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: txId,
          transactionType: 'income',
          amountOriginalSatang: 1000000, // 10,000 THB
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          feeThbSatang: const Value(0),
          note: const Value('เงินหมื่นไม่ทำเวช ก.ย. 69'),
          transactionDate: DateTime(2026, 10, 10),
          workPeriod: const Value('2026-09'),
          isCleared: const Value(false),
          sourceAccountId: const Value(null),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Account balance must strictly remain 0
      final balanceBeforeReceive = await db.accountsDao.getAccountBalanceSatang(accId);
      expect(balanceBeforeReceive, equals(0));

      // Account transaction query must NOT return uncleared income
      final accTxsBefore = await db.transactionsDao.searchTransactions(accountId: accId);
      expect(accTxsBefore.any((t) => t.id == txId), isFalse);

      // 3. User clicks "รับเงิน" (Mark as Received) into KBank on 2026-10-25
      final receivedDate = DateTime(2026, 10, 25);
      final success = await db.transactionsDao.markIncomeAsReceived(
        txId,
        accountId: accId,
        receivedDate: receivedDate,
        actualAmountSatang: 1000000,
      );
      expect(success, isTrue);

      // 4. NOW the money must enter the account balance!
      final balanceAfterReceive = await db.accountsDao.getAccountBalanceSatang(accId);
      expect(balanceAfterReceive, equals(1000000)); // Exactly 10,000 THB in satang

      // The transaction must now appear in the account's ledger
      final accTxsAfter = await db.transactionsDao.searchTransactions(accountId: accId);
      expect(accTxsAfter.any((t) => t.id == txId), isTrue);

      final updatedTx = await db.transactionsDao.getTransactionById(txId);
      expect(updatedTx!.isCleared, isTrue);
      expect(updatedTx.sourceAccountId, equals(accId));
      expect(updatedTx.transactionDate.year, equals(2026));
      expect(updatedTx.transactionDate.month, equals(10));
      expect(updatedTx.transactionDate.day, equals(25));
    });
  });
}
