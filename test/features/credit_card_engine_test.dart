import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNotNull;
import 'package:myfinance/core/database/app_database.dart';
import 'package:myfinance/core/database/connection/connection.dart';
import 'package:myfinance/core/database/daos/credit_card_dao.dart';

void main() {
  late AppDatabase db;
  late CreditCardDao ccDao;

  setUp(() {
    db = AppDatabase.forTesting(inMemoryConnection());
    ccDao = db.creditCardDao;
  });

  tearDown(() async {
    await db.close();
  });

  group('Credit Card Billing Cycle Logic Tests', () {
    test('On the 23rd at 23:59:59, cycle ends today (Current Cycle)', () {
      final ref = DateTime(2026, 9, 23, 23, 59, 59);
      final cycle = CreditCardDao.calculateCycle(ref, statementDay: 23);

      // Cycle start: 24 Aug 2026 00:00:00
      expect(cycle.cycleStart, equals(DateTime(2026, 8, 24, 0, 0, 0)));
      // Cycle end: 23 Sep 2026 23:59:59.999
      expect(cycle.cycleEnd.year, equals(2026));
      expect(cycle.cycleEnd.month, equals(9));
      expect(cycle.cycleEnd.day, equals(23));
      expect(cycle.daysRemaining, equals(0)); // Cuts off today!
    });

    test('On the 24th at 00:00:00, cycle rolls over to next month', () {
      final ref = DateTime(2026, 9, 24, 0, 0, 0);
      final cycle = CreditCardDao.calculateCycle(ref, statementDay: 23);

      // Cycle start: 24 Sep 2026 00:00:00
      expect(cycle.cycleStart, equals(DateTime(2026, 9, 24, 0, 0, 0)));
      // Cycle end: 23 Oct 2026 23:59:59.999
      expect(cycle.cycleEnd.year, equals(2026));
      expect(cycle.cycleEnd.month, equals(10));
      expect(cycle.cycleEnd.day, equals(23));
      expect(cycle.daysRemaining, equals(29));
    });

    test('Year crossover: 24 Dec 2026 rolls into 23 Jan 2027', () {
      final ref = DateTime(2026, 12, 25);
      final cycle = CreditCardDao.calculateCycle(ref, statementDay: 23);

      expect(cycle.cycleStart, equals(DateTime(2026, 12, 24, 0, 0, 0)));
      expect(cycle.cycleEnd.year, equals(2027));
      expect(cycle.cycleEnd.month, equals(1));
      expect(cycle.cycleEnd.day, equals(23));

      // Check January reference before cutoff
      final janRef = DateTime(2027, 1, 10);
      final janCycle = CreditCardDao.calculateCycle(janRef, statementDay: 23);
      expect(janCycle.cycleStart, equals(DateTime(2026, 12, 24, 0, 0, 0)));
      expect(janCycle.cycleEnd, equals(DateTime(2027, 1, 23, 23, 59, 59, 999)));
    });

    test('February leap year vs non-leap year boundary', () {
      // 2024 is leap year (29 days in Feb)
      final leapRef = DateTime(2024, 2, 28);
      final leapCycle = CreditCardDao.calculateCycle(leapRef, statementDay: 23);
      expect(leapCycle.cycleStart, equals(DateTime(2024, 2, 24, 0, 0, 0)));
      expect(leapCycle.cycleEnd, equals(DateTime(2024, 3, 23, 23, 59, 59, 999)));

      // 2025 is non-leap year (28 days in Feb)
      final nonLeapRef = DateTime(2025, 2, 28);
      final nonLeapCycle = CreditCardDao.calculateCycle(nonLeapRef, statementDay: 23);
      expect(nonLeapCycle.cycleStart, equals(DateTime(2025, 2, 24, 0, 0, 0)));
      expect(nonLeapCycle.cycleEnd, equals(DateTime(2025, 3, 23, 23, 59, 59, 999)));
    });

    test('Credit card payment is a transfer from bank, NOT a double expense', () async {
      final cardAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.accountType == 'credit_card');
      final bankAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      // 1. Charge 5,000 THB on 10 Sep 2026
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'card-tx-1',
          transactionType: 'expense',
          sourceAccountId: Value(cardAcc.id),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          transactionDate: DateTime(2026, 9, 10),
          createdAt: DateTime(2026, 9, 10),
          updatedAt: DateTime(2026, 9, 10),
        ),
      );

      // Verify card debt is 5,000 THB (balance = -5,000 THB)
      final cardBal1 = await db.accountsDao.getAccountBalanceSatang(cardAcc.id);
      expect(cardBal1, equals(-500000));

      final summary1 = await ccDao.getSummary(cardAcc.id, DateTime(2026, 9, 15));
      expect(summary1, isNotNull);
      expect(summary1!.currentCycleDebtSatang, equals(500000));
      expect(summary1.totalDebtSatang, equals(500000));

      // 2. Pay 5,000 THB from SCB bank account to credit card on 16 Sep 2026
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'pay-tx-1',
          transactionType: 'transfer',
          sourceAccountId: Value(bankAcc.id),
          destinationAccountId: Value(cardAcc.id),
          amountOriginalSatang: 500000,
          currencyCode: 'THB',
          amountThbSatang: 500000,
          transactionDate: DateTime(2026, 9, 16),
          createdAt: DateTime(2026, 9, 16),
          updatedAt: DateTime(2026, 9, 16),
        ),
      );

      // Verify card balance is now 0 THB (debt paid off!)
      final cardBal2 = await db.accountsDao.getAccountBalanceSatang(cardAcc.id);
      expect(cardBal2, equals(0));

      final summary2 = await ccDao.getSummary(cardAcc.id, DateTime(2026, 9, 17));
      expect(summary2!.totalDebtSatang, equals(0));
    });

    test('getSummary generates statementCycles and recordCreditCardPayment clears balance', () async {
      final cardAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.accountType == 'credit_card');
      final bankAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      // Charge 3,000 THB in current cycle
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'card-tx-cycle',
          transactionType: 'expense',
          sourceAccountId: Value(cardAcc.id),
          amountOriginalSatang: 300000,
          currencyCode: 'THB',
          amountThbSatang: 300000,
          transactionDate: DateTime(2026, 9, 25),
          createdAt: DateTime(2026, 9, 25),
          updatedAt: DateTime(2026, 9, 25),
        ),
      );

      final summary = await ccDao.getSummary(cardAcc.id, DateTime(2026, 9, 26));
      expect(summary, isNotNull);
      expect(summary!.statementCycles.length, equals(6));
      expect(summary.allTransactions.isNotEmpty, isTrue);
      expect(summary.totalDebtSatang, equals(300000));

      // Record payment via DAO helper
      await ccDao.recordCreditCardPayment(
        fromAccountId: bankAcc.id,
        creditCardAccountId: cardAcc.id,
        amountSatang: 300000,
        paymentDate: DateTime(2026, 9, 26),
      );

      final summaryAfterPay = await ccDao.getSummary(cardAcc.id, DateTime(2026, 9, 26));
      expect(summaryAfterPay!.totalDebtSatang, equals(0));
    });

    test('purgeHistoricalSettlements removes any obsolete historical settle transactions', () async {
      final cardAcc = AccountsCompanion.insert(
        id: 'card-purge-test',
        name: 'SCB Card',
        accountType: 'credit_card',
        currencyCode: 'THB',
        isDomestic: true,
        closingDay: const Value(23),
        dueDay: const Value(10),
        createdAt: DateTime(2023, 10, 1),
        updatedAt: DateTime(2023, 10, 1),
      );
      await db.into(db.accounts).insert(cardAcc);

      await db.into(db.transactions).insert(
        TransactionsCompanion.insert(
          id: 'settle-tx-1',
          transactionType: 'transfer',
          destinationAccountId: Value(cardAcc.id.value),
          amountOriginalSatang: 150000,
          currencyCode: 'THB',
          amountThbSatang: 150000,
          transactionDate: DateTime(2026, 8, 23, 23, 59, 59),
          note: const Value('ชำระหนี้ SCB Card รอบประวัติศาสตร์ก่อน 24 ส.ค. 2569 (Auto-settle)'),
          tag: const Value('historical_settle'),
          createdAt: DateTime(2026, 8, 24, 10, 0),
          updatedAt: DateTime(2026, 8, 24, 10, 0),
        ),
      );

      final removed = await ccDao.purgeHistoricalSettlements();
      expect(removed, equals(1));

      final remaining = await (db.select(db.transactions)
            ..where((t) => t.tag.equals('historical_settle')))
          .get();
      expect(remaining.isEmpty, isTrue);
    });

    test('Credit transactions reduce budget, do NOT reduce bank accounts, and do NOT reduce getTotalCashSatang / Net Worth', () async {
      final cardAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.accountType == 'credit_card');
      final bankAcc = (await db.accountsDao.getActiveAccounts())
          .firstWhere((a) => a.name == 'SCB');

      // 1. Initial SCB balance: 10,000 THB (1,000,000 satang)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'initial-scb',
          transactionType: 'income',
          sourceAccountId: Value(bankAcc.id),
          amountOriginalSatang: 1000000,
          currencyCode: 'THB',
          amountThbSatang: 1000000,
          isCleared: const Value(true),
          transactionDate: DateTime(2026, 9, 1),
          createdAt: DateTime(2026, 9, 1),
          updatedAt: DateTime(2026, 9, 1),
        ),
      );

      // Setup a monthly budget of 5,000 THB (500,000 satang) for Dining
      const catDining = 'cat-exp-0000-4000-8000-000000000001';
      await db.budgetsDao.setBudget(categoryId: catDining, limitSatang: 500000);

      // Verify baseline:
      final initialScbBal = await db.accountsDao.getAccountBalanceSatang(bankAcc.id);
      final initialCash = await db.accountsDao.getTotalCashSatang();
      final initialNetWorth = await db.accountsDao.getTotalNetWorthSatang();
      expect(initialScbBal, equals(1000000)); // 10,000 THB
      expect(initialCash, equals(1000000)); // 10,000 THB
      expect(initialNetWorth, equals(1000000)); // 10,000 THB

      // 2. Spend 2,000 THB on Credit Card (Dining category)
      await db.transactionsDao.insertTransaction(
        TransactionsCompanion.insert(
          id: 'cc-swipe-1',
          transactionType: 'expense',
          sourceAccountId: Value(cardAcc.id),
          categoryId: const Value(catDining),
          amountOriginalSatang: 200000,
          currencyCode: 'THB',
          amountThbSatang: 200000,
          transactionDate: DateTime(2026, 9, 10),
          createdAt: DateTime(2026, 9, 10),
          updatedAt: DateTime(2026, 9, 10),
        ),
      );

      // (A) Check Budget: Dining budget MUST be deducted by 2,000 THB (Spent = 2,000, Remaining = 3,000)
      final budgetStatus = await db.budgetsDao.getBudgetStatusForMonth(2026, 9);
      final diningStatus = budgetStatus.firstWhere((b) => b.categoryId == catDining);
      expect(diningStatus.spentSatang, equals(200000));
      expect(diningStatus.remainingSatang, equals(300000));

      // (B) Check SCB Bank Account: MUST NOT be deducted! (Still 10,000 THB)
      final scbBalAfterSwipe = await db.accountsDao.getAccountBalanceSatang(bankAcc.id);
      expect(scbBalAfterSwipe, equals(1000000));

      // (C) Check Total Cash & Net Worth: MUST NOT be reduced by unpaid credit card debt! (Still 10,000 THB)
      final cashAfterSwipe = await db.accountsDao.getTotalCashSatang();
      final netWorthAfterSwipe = await db.accountsDao.getTotalNetWorthSatang();
      expect(cashAfterSwipe, equals(1000000));
      expect(netWorthAfterSwipe, equals(1000000));

      // (D) Check Credit Card: Shows debt of 2,000 THB
      final cardBal = await db.accountsDao.getAccountBalanceSatang(cardAcc.id);
      expect(cardBal, equals(-200000));
      final ccSummary = await ccDao.getSummary(cardAcc.id, DateTime(2026, 9, 15));
      expect(ccSummary!.totalDebtSatang, equals(200000));

      // 3. User manually pays credit card from SCB (Pay 2,000 THB)
      await ccDao.recordCreditCardPayment(
        fromAccountId: bankAcc.id,
        creditCardAccountId: cardAcc.id,
        amountSatang: 200000,
        paymentDate: DateTime(2026, 9, 20),
      );

      // (E) After payment: SCB is deducted to 8,000 THB, Card debt is 0, Total Cash is 8,000 THB
      final scbAfterPay = await db.accountsDao.getAccountBalanceSatang(bankAcc.id);
      expect(scbAfterPay, equals(800000)); // 8,000 THB
      final cardBalAfterPay = await db.accountsDao.getAccountBalanceSatang(cardAcc.id);
      expect(cardBalAfterPay, equals(0)); // 0 THB
      final cashAfterPay = await db.accountsDao.getTotalCashSatang();
      expect(cashAfterPay, equals(800000)); // 8,000 THB
      final netWorthAfterPay = await db.accountsDao.getTotalNetWorthSatang();
      expect(netWorthAfterPay, equals(800000)); // 8,000 THB
    });
  });
}


