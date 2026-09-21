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

  group('Liabilities & Insurance DAO Integration Tests', () {
    test('Linked Credit Card liability uses real-time card balance to avoid double counting', () async {
      final now = DateTime.now();
      final ccAccount = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.accountType == 'credit_card');

      // Record an expense on credit card of 12,000 THB (1,200,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'tx-cc-1',
          transactionType: 'expense',
          amountOriginalSatang: 1200000,
          currencyCode: 'THB',
          amountThbSatang: 1200000,
          sourceAccountId: Value(ccAccount.id),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Create liability linked to this credit card (manual remaining principal = 0)
      await db.liabilitiesDao.createLiability(
        LiabilitiesCompanion.insert(
          id: 'liab-cc',
          name: 'บัตรเครดิตใบหลัก',
          liabilityType: 'credit_card',
          remainingPrincipalSatang: 0, // Ignored because linkedAccountId is present
          monthlyPaymentSatang: 120000, // 10% min pay
          interestRatePercent: '16.000000',
          isShortTerm: true,
          linkedAccountId: Value(ccAccount.id),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Create another normal debt (Mortgage: 2,500,000 THB, long-term)
      await db.liabilitiesDao.createLiability(
        LiabilitiesCompanion.insert(
          id: 'liab-house',
          name: 'สินเชื่อบ้าน',
          liabilityType: 'mortgage',
          remainingPrincipalSatang: 250000000,
          monthlyPaymentSatang: 1800000,
          interestRatePercent: '4.500000',
          isShortTerm: false,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Total debt should be: 12,000 THB (from CC balance) + 2,500,000 THB (House) = 2,512,000 THB
      final totalDebt = await db.liabilitiesDao.getTotalLiabilitiesSatang();
      expect(totalDebt, equals(251200000));

      // Short term debt should only be credit card (12,000 THB)
      final shortTerm = await db.liabilitiesDao.getShortTermLiabilitiesSatang();
      expect(shortTerm, equals(1200000));

      // Total monthly payments: 120,000 satang + 1,800,000 satang = 1,920,000 satang
      final payments = await db.liabilitiesDao.getTotalMonthlyPaymentSatang();
      expect(payments, equals(1920000));
    });

    test('Insurance policies sum insured and medical coverage aggregates correctly', () async {
      final now = DateTime.now();

      await db.insuranceDao.createPolicy(
        InsurancePoliciesCompanion.insert(
          id: 'ins-1',
          policyName: 'AIA Life Term',
          insuranceType: 'life',
          sumInsuredSatang: 200000000, // 2,000,000 THB
          medicalCoverageSatang: 0,
          annualPremiumSatang: 1500000, // 15,000 THB
          createdAt: now,
          updatedAt: now,
        ),
      );

      await db.insuranceDao.createPolicy(
        InsurancePoliciesCompanion.insert(
          id: 'ins-2',
          policyName: 'Bupa Health Happy',
          insuranceType: 'health',
          sumInsuredSatang: 0,
          medicalCoverageSatang: 100000000, // 1,000,000 THB
          annualPremiumSatang: 2500000, // 25,000 THB
          createdAt: now,
          updatedAt: now,
        ),
      );

      final sumInsured = await db.insuranceDao.getTotalSumInsuredSatang();
      final medCoverage = await db.insuranceDao.getTotalMedicalCoverageSatang();
      final premium = await db.insuranceDao.getTotalAnnualPremiumSatang();

      expect(sumInsured, equals(200000000));
      expect(medCoverage, equals(100000000));
      expect(premium, equals(4000000));
    });

    test('Financial Health DAO aggregates and filters true expenses without transfers and investment buys', () async {
      final now = DateTime.now();
      final bankAcc = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.accountType == 'bank');
      final secondAcc = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.id != bankAcc.id);

      // Normal expense: 5,000 THB (counted)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 't-normal-exp',
          transactionType: 'expense',
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          sourceAccountId: Value(bankAcc.id),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Investment buy: 100,000 THB (MUST BE EXCLUDED from average living expenses!)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 't-inv-buy',
          transactionType: 'expense',
          amountOriginalSatang: 10000000,
          currencyCode: 'THB',
          amountThbSatang: 10000000,
          sourceAccountId: Value(bankAcc.id),
          transactionDate: now,
          tag: const Value('investment_buy:asset-1'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Transfer: 20,000 THB (MUST BE EXCLUDED!)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 't-transfer',
          transactionType: 'transfer',
          amountOriginalSatang: 2000000,
          currencyCode: 'THB',
          amountThbSatang: 2000000,
          sourceAccountId: Value(bankAcc.id),
          destinationAccountId: Value(secondAcc.id),
          transactionDate: now,
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 6-month average expense should be: 5,000 THB / 6 = ~833 THB (83,333 satang)
      final avgExp = await db.financialHealthDao.getAverageMonthlyExpenseSatang(months: 6);
      expect(avgExp, equals(83333));
    });

    test('Recurring DAO processes due rules with idempotency and catch-up', () async {
      final now = DateTime(2026, 5, 20, 10, 0);
      final bankAcc = (await db.accountsDao.getActiveAccounts()).firstWhere((a) => a.accountType == 'bank');

      await db.recurringTransactionsDao.createRule(
        RecurringRulesCompanion.insert(
          id: 'rec-daily',
          title: 'Daily Coffee',
          transactionType: 'expense',
          sourceAccountId: bankAcc.id,
          amountSatang: 10000, // 100 THB
          currencyCode: 'THB',
          frequency: 'daily',
          intervalUnits: const Value(1),
          autoPost: const Value(true),
          nextRunDate: DateTime(2026, 5, 18, 8, 0), // 2 days ago
          createdAt: DateTime(2026, 5, 17),
          updatedAt: DateTime(2026, 5, 17),
        ),
      );

      // Run processing for today (should catch up 18th, 19th, 20th = 3 transactions)
      final posted = await db.recurringTransactionsDao.processDueRules(nowOverride: now);
      expect(posted, equals(3));

      // Run again immediately on the same day (Idempotency check: should post 0)
      final postedSecondTime = await db.recurringTransactionsDao.processDueRules(nowOverride: now);
      expect(postedSecondTime, equals(0));

      // Rule nextRunDate should now be 21st May
      final rule = await db.recurringTransactionsDao.getRuleById('rec-daily');
      expect(rule?.nextRunDate.day, equals(21));
    });
  });
}
