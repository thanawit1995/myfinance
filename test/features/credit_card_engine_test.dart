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
  });
}
