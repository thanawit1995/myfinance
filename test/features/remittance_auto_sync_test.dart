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

  group('Foreign Remittance Auto-Detection & Sync Integration Tests', () {
    test('Dime! FCD is Domestic: transfers between SCB and Dime! FCD do NOT trigger remittance', () async {
      final now = DateTime(2025, 5, 1);
      final accounts = await db.accountsDao.getActiveAccounts();

      final scb = accounts.firstWhere((a) => a.name == 'SCB'); // Domestic THB
      final dimeFcd = accounts.firstWhere((a) => a.name == 'Dime! FCD'); // Domestic USD

      expect(scb.isDomestic, true);
      expect(dimeFcd.isDomestic, true);

      // 1. SCB -> Dime! FCD
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-scb-fcd',
          transactionType: 'transfer',
          sourceAccountId: Value(scb.id),
          destinationAccountId: Value(dimeFcd.id),
          amountOriginalSatang: 3500000,
          currencyCode: 'THB',
          amountThbSatang: 3500000,
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await db.remittancesDao.getRemittanceByTransactionId('tx-scb-fcd'), isNull);

      // 2. Dime! FCD -> SCB
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-fcd-scb',
          transactionType: 'transfer',
          sourceAccountId: Value(dimeFcd.id),
          destinationAccountId: Value(scb.id),
          amountOriginalSatang: 100000, // 1,000 USD
          currencyCode: 'USD',
          fxRate: const Value('35.000000'),
          amountThbSatang: 3500000,
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await db.remittancesDao.getRemittanceByTransactionId('tx-fcd-scb'), isNull);
    });

    test('FIFO Principal Tracking: Outward investment builds principal pool, remittances draw down principal', () async {
      final accounts = await db.accountsDao.getActiveAccounts();
      final dimeFcd = accounts.firstWhere((a) => a.name == 'Dime! FCD'); // Domestic USD
      final dimeUsd = accounts.firstWhere((a) => a.name == 'Dime! USD'); // Offshore USD
      final scb = accounts.firstWhere((a) => a.name == 'SCB'); // Domestic THB

      expect(dimeUsd.isDomestic, false);

      // 1. Initial Remaining Foreign Principal is 0
      expect(await db.remittancesDao.getRemainingForeignPrincipalSatang(), 0);

      // 2. Send capital abroad: Dime! FCD -> Dime! USD: 1,000 USD (35,000 THB)
      final date1 = DateTime(2025, 6, 1);
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-invest-1',
          transactionType: 'transfer',
          sourceAccountId: Value(dimeFcd.id),
          destinationAccountId: Value(dimeUsd.id),
          amountOriginalSatang: 100000,
          currencyCode: 'USD',
          fxRate: const Value('35.000000'),
          amountThbSatang: 3500000, // 35,000 THB
          feeThbSatang: const Value(0),
          transactionDate: date1,
          createdAt: date1,
          updatedAt: date1,
        ),
      );

      // Remaining Foreign Principal is now 35,000 THB
      final principalAfterInvest = await db.remittancesDao.getRemainingForeignPrincipalSatang();
      expect(principalAfterInvest, 3500000);

      // 3. First Remittance: Dime! USD -> SCB: 600 USD (21,000 THB)
      // 21,000 THB <= 35,000 THB remaining -> Automatically isPrincipal = true!
      final date2 = DateTime(2025, 7, 1);
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-remit-fifo-1',
          transactionType: 'transfer',
          sourceAccountId: Value(dimeUsd.id),
          destinationAccountId: Value(scb.id),
          amountOriginalSatang: 60000,
          currencyCode: 'USD',
          fxRate: const Value('35.000000'),
          amountThbSatang: 2100000, // 21,000 THB
          feeThbSatang: const Value(0),
          transactionDate: date2,
          createdAt: date2,
          updatedAt: date2,
        ),
      );

      final remit1 = await db.remittancesDao.getRemittanceByTransactionId('tx-remit-fifo-1');
      expect(remit1, isNotNull);
      expect(remit1!.isPrincipal, true); // Automatic FIFO classified as principal!
      expect(remit1.amountThbSatang, 2100000);

      // Remaining Foreign Principal is now 35,000 - 21,000 = 14,000 THB (1,400,000 satang)
      final principalAfterRemit1 = await db.remittancesDao.getRemainingForeignPrincipalSatang();
      expect(principalAfterRemit1, 1400000);

      // 4. Second Remittance: Dime! USD -> SCB: 500 USD (17,500 THB)
      // 17,500 THB > 14,000 THB remaining -> Exceeds remaining principal, isPrincipal = false!
      final date3 = DateTime(2025, 8, 1);
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-remit-fifo-2',
          transactionType: 'transfer',
          sourceAccountId: Value(dimeUsd.id),
          destinationAccountId: Value(scb.id),
          amountOriginalSatang: 50000,
          currencyCode: 'USD',
          fxRate: const Value('35.000000'),
          amountThbSatang: 1750000, // 17,500 THB
          feeThbSatang: const Value(0),
          transactionDate: date3,
          createdAt: date3,
          updatedAt: date3,
        ),
      );

      final remit2 = await db.remittancesDao.getRemittanceByTransactionId('tx-remit-fifo-2');
      expect(remit2, isNotNull);
      expect(remit2!.isPrincipal, false); // Exceeds principal, so classified as gains!
    });

    test('Updating transfer transaction amount updates foreign_remittances record', () async {
      final now = DateTime(2025, 8, 10);
      final accounts = await db.accountsDao.getActiveAccounts();
      final offshore = accounts.firstWhere((a) => !a.isDomestic);
      final domestic = accounts.firstWhere((a) => a.isDomestic && a.currencyCode == 'THB');

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-remit-update',
          transactionType: 'transfer',
          sourceAccountId: Value(offshore.id),
          destinationAccountId: Value(domestic.id),
          amountOriginalSatang: 100000,
          currencyCode: offshore.currencyCode,
          fxRate: const Value('35.000000'),
          amountThbSatang: 3500000,
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Now update the transaction to 2,000 USD (70,000 THB)
      await db.transactionsDao.updateTransaction(
        TransactionsCompanion(
          id: const Value('tx-remit-update'),
          amountOriginalSatang: const Value(200000),
          amountThbSatang: const Value(7000000),
          updatedAt: Value(DateTime.now()),
        ),
      );

      final updatedRemittance = await db.remittancesDao.getRemittanceByTransactionId('tx-remit-update');
      expect(updatedRemittance, isNotNull);
      expect(updatedRemittance!.amountOriginalSatang, 200000);
      expect(updatedRemittance.amountThbSatang, 7000000);
    });

    test('Soft-deleting transfer transaction soft-deletes foreign_remittances record', () async {
      final now = DateTime(2025, 9, 1);
      final accounts = await db.accountsDao.getActiveAccounts();
      final offshore = accounts.firstWhere((a) => !a.isDomestic);
      final domestic = accounts.firstWhere((a) => a.isDomestic && a.currencyCode == 'THB');

      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-remit-delete',
          transactionType: 'transfer',
          sourceAccountId: Value(offshore.id),
          destinationAccountId: Value(domestic.id),
          amountOriginalSatang: 50000,
          currencyCode: offshore.currencyCode,
          fxRate: const Value('35.000000'),
          amountThbSatang: 1750000,
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      expect(await db.remittancesDao.getRemittanceByTransactionId('tx-remit-delete'), isNotNull);

      // Soft delete
      await db.transactionsDao.softDeleteTransaction('tx-remit-delete');

      // Remittance should now be soft deleted (null when queried without deleted)
      final deletedRemittance = await db.remittancesDao.getRemittanceByTransactionId('tx-remit-delete');
      expect(deletedRemittance, isNull);
    });

    test('syncAllTransferTransactions backfills existing offshore -> domestic transfers', () async {
      final now = DateTime(2025, 10, 1);
      final accounts = await db.accountsDao.getActiveAccounts();
      final offshore = accounts.firstWhere((a) => !a.isDomestic);
      final domestic = accounts.firstWhere((a) => a.isDomestic && a.currencyCode == 'THB');

      // Insert directly bypassing dao sync
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: 'tx-backfill',
          transactionType: 'transfer',
          sourceAccountId: Value(offshore.id),
          destinationAccountId: Value(domestic.id),
          amountOriginalSatang: 80000,
          currencyCode: offshore.currencyCode,
          fxRate: const Value('36.000000'),
          amountThbSatang: 2880000,
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Initially no remittance
      expect(await db.remittancesDao.getRemittanceByTransactionId('tx-backfill'), isNull);

      // Run backfill sync
      final count = await db.remittancesDao.syncAllTransferTransactions();
      expect(count, greaterThanOrEqualTo(1));

      final synced = await db.remittancesDao.getRemittanceByTransactionId('tx-backfill');
      expect(synced, isNotNull);
      expect(synced!.amountThbSatang, 2880000);
    });

    test('USD to THB transfer sets currencyCode to USD and repairMisclassifiedRemittanceCurrencies fixes legacy mislabeled records', () async {
      final now = DateTime(2026, 9, 17);
      final accounts = await db.accountsDao.getActiveAccounts();
      final offshoreUsd = accounts.firstWhere((a) => !a.isDomestic && a.currencyCode == 'USD');
      final domesticThb = accounts.firstWhere((a) => a.isDomestic && a.currencyCode == 'THB');

      // Insert transfer from USD account to THB account with currencyCode 'USD'
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-usd-to-thb-1',
          transactionType: 'transfer',
          sourceAccountId: Value(offshoreUsd.id),
          destinationAccountId: Value(domesticThb.id),
          amountOriginalSatang: 33300, // 333.00 USD
          currencyCode: 'USD',
          fxRate: const Value('3.002402'),
          amountThbSatang: 100000, // 1,000.00 THB
          feeThbSatang: const Value(0),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      final insertedTx = await db.transactionsDao.getTransactionById('tx-usd-to-thb-1');
      expect(insertedTx, isNotNull);
      await db.remittancesDao.syncFromTransferTransaction(insertedTx!);

      final remit = await db.remittancesDao.getRemittanceByTransactionId('tx-usd-to-thb-1');
      expect(remit, isNotNull);
      expect(remit!.currencyCode, 'USD'); // Must be USD, NOT THB!
      expect(remit.amountOriginalSatang, 33300);
      expect(remit.amountThbSatang, 100000);

      // Now simulate legacy bug: remittance and tx mistakenly had currencyCode 'THB'
      await (db.update(db.foreignRemittances)..where((r) => r.id.equals(remit.id))).write(
        ForeignRemittancesCompanion(
          currencyCode: const Value('THB'),
          updatedAt: Value(now),
        ),
      );
      await (db.update(db.transactions)..where((t) => t.id.equals(insertedTx.id))).write(
        TransactionsCompanion(
          currencyCode: const Value('THB'),
          updatedAt: Value(now),
        ),
      );

      // Verify it became 'THB'
      final corruptedRemit = await db.remittancesDao.getRemittanceByTransactionId('tx-usd-to-thb-1');
      expect(corruptedRemit!.currencyCode, 'THB');

      // Run auto-repair
      await db.remittancesDao.repairMisclassifiedRemittanceCurrencies();

      // Verify it is restored to 'USD'
      final repairedRemit = await db.remittancesDao.getRemittanceByTransactionId('tx-usd-to-thb-1');
      expect(repairedRemit!.currencyCode, 'USD');
      final repairedTx = await db.transactionsDao.getTransactionById('tx-usd-to-thb-1');
      expect(repairedTx!.currencyCode, 'USD');
    });

    test('TaxDao auto-inherits tax rule for future year 2027 (พ.ศ. 2570) from latest rule', () async {
      // 2027 does not exist yet in seed data
      final rule2027 = await db.taxDao.getTaxRuleForYear(2027);
      expect(rule2027, isNotNull);
      expect(rule2027!.taxYear, 2027);
      expect(rule2027.personalAllowanceSatang, 6000000); // 60,000 THB inherited
      expect(rule2027.flatExpense406MedicalPercent, '60.0'); // Inherited 60% medical
      expect(rule2027.bracketsJson, contains('150000')); // Progressive brackets inherited
    });
  });
}
