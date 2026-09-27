import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/daos/insurance_dao.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
  });

  tearDown(() async {
    await db.close();
  });

  group('InsuranceDao - Policies, Progress & Net Worth Tests', () {
    test('getOrCreateDefaultSavingsPolicy creates and retrieves default MTL policy', () async {
      final policy = await db.insuranceDao.getOrCreateDefaultSavingsPolicy();
      expect(policy.id, equals(InsuranceDao.defaultSavingsPolicyId));
      expect(policy.policyName, equals('เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20'));
      expect(policy.insuranceType, equals('savings'));
      expect(policy.annualPremiumSatang, equals(4500000)); // 45,000 THB
      expect(policy.totalPeriods, equals(15));
      expect(policy.paymentDueDay, equals(5));
      expect(policy.paymentDueMonth, equals(10));

      final active = await db.insuranceDao.getActivePolicies();
      expect(active.length, equals(1));
    });

    test('Paying insurance expense updates policy progress and retains Net Worth', () async {
      final policy = await db.insuranceDao.getOrCreateDefaultSavingsPolicy();
      final scb = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'SCB');

      // 1. Initial Deposit to SCB (Income): 100,000 THB = 10,000,000 satang
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-initial-deposit',
          transactionType: 'income',
          sourceAccountId: Value(scb.id),
          amountOriginalSatang: 10000000,
          currencyCode: 'THB',
          amountThbSatang: 10000000,
          transactionDate: DateTime(2026, 1, 1),
          createdAt: DateTime(2026, 1, 1),
          updatedAt: DateTime(2026, 1, 1),
        ),
      );

      // Verify SCB Balance & Initial Net Worth
      var scbBalance = await db.accountsDao.getAccountBalanceSatang(scb.id);
      expect(scbBalance, equals(10000000));
      var initialNetWorth = await db.accountsDao.getTotalNetWorthSatang();
      expect(initialNetWorth, equals(10000000));

      // 2. Pay annual premium (Expense): 45,000 THB = 4,500,000 satang
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-pay-insurance-2026',
          transactionType: 'expense',
          sourceAccountId: Value(scb.id),
          categoryId: const Value('cat-exp-0000-4000-8000-000000000015'),
          amountOriginalSatang: 4500000,
          currencyCode: 'THB',
          amountThbSatang: 4500000,
          tag: Value('policy:${policy.id},deduction:life_insurance'),
          note: const Value('ชำระเบี้ย เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20'),
          transactionDate: DateTime(2026, 10, 5),
          createdAt: DateTime(2026, 10, 5),
          updatedAt: DateTime(2026, 10, 5),
        ),
      );

      // 3. Verify SCB Balance is reduced by 45,000 THB
      scbBalance = await db.accountsDao.getAccountBalanceSatang(scb.id);
      expect(scbBalance, equals(5500000)); // 55,000 THB remaining in cash

      // 4. Verify Policy Progress: 1 paid period, 14 remaining periods
      final progress = await db.insuranceDao.getPolicyProgress(policy);
      expect(progress.paidPeriods, equals(1));
      expect(progress.totalPeriods, equals(15));
      expect(progress.totalPaidSatang, equals(4500000));
      expect(progress.remainingSatang, equals(4500000 * 14));
      expect(progress.isPaidForCurrentYear, isTrue);

      // 5. Verify Insurance Accumulated Savings
      final totalInsSavings = await db.insuranceDao.getTotalInsuranceSavingsSatang();
      expect(totalInsSavings, equals(4500000));

      // 6. Verify Net Worth remains 100,000 THB (55,000 Cash + 45,000 Insurance Savings)
      final netWorthAfter = await db.accountsDao.getTotalNetWorthSatang();
      expect(netWorthAfter, equals(10000000)); // Net Worth unchanged!
    });

    test('removeLegacyInsuranceSavingsAccount safely converts legacy transfers to expenses with policy tag', () async {
      final defaultPolicy = await db.insuranceDao.getOrCreateDefaultSavingsPolicy();

      // Create a legacy account
      const legacyId = '00000000-0000-4000-8000-000000000007';
      final scb = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.name == 'SCB');

      await db.into(db.accounts).insert(
        AccountsCompanion.insert(
          id: legacyId,
          name: 'ประกันออมทรัพย์ (เมืองไทยประกันชีวิต)',
          accountType: 'savings_insurance',
          currencyCode: 'THB',
          isDomestic: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Insert legacy transfer transaction
      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: 'tx-legacy-transfer',
          transactionType: 'transfer',
          sourceAccountId: Value(scb.id),
          destinationAccountId: const Value(legacyId),
          categoryId: const Value('cat-exp-0000-4000-8000-000000000015'),
          amountOriginalSatang: 4500000,
          currencyCode: 'THB',
          amountThbSatang: 4500000,
          tag: const Value('deduction:life_insurance'),
          transactionDate: DateTime(2025, 10, 5),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      // Run legacy cleanup
      await db.accountsDao.removeLegacyInsuranceSavingsAccount();

      // Verify legacy account was deleted
      final legacyAcc = await db.accountsDao.getAccountById(legacyId);
      expect(legacyAcc, isNull);

      // Verify transaction was converted to expense with policy tag
      final tx = await (db.select(db.transactions)..where((t) => t.id.equals('tx-legacy-transfer'))).getSingle();
      expect(tx.transactionType, equals('expense'));
      expect(tx.destinationAccountId, isNull);
      expect(tx.tag, contains('policy:${defaultPolicy.id}'));
      expect(tx.tag, contains('deduction:life_insurance'));
    });
  });
}
