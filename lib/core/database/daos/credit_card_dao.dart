import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'credit_card_dao.g.dart';

class CreditCardBillingCycle {
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final DateTime previousCycleStart;
  final DateTime previousCycleEnd;
  final int daysRemaining;
  final int statementDay;
  final int dueDay;

  const CreditCardBillingCycle({
    required this.cycleStart,
    required this.cycleEnd,
    required this.previousCycleStart,
    required this.previousCycleEnd,
    required this.daysRemaining,
    required this.statementDay,
    required this.dueDay,
  });
}

class CreditCardCycleStatement {
  final String label;
  final DateTime cycleStart;
  final DateTime cycleEnd;
  final DateTime dueDate;
  final int chargesSatang;
  final int paymentsSatang;
  final int netDebtSatang;
  final List<Transaction> transactions;

  const CreditCardCycleStatement({
    required this.label,
    required this.cycleStart,
    required this.cycleEnd,
    required this.dueDate,
    required this.chargesSatang,
    required this.paymentsSatang,
    required this.netDebtSatang,
    required this.transactions,
  });
}

class CreditCardSummary {
  final Account account;
  final CreditCardBillingCycle cycle;
  final int previousStatementDebtSatang;
  final int currentCycleDebtSatang;
  final int totalDebtSatang;
  final List<Transaction> currentCycleTransactions;
  final List<Transaction> allTransactions;
  final List<CreditCardCycleStatement> statementCycles;

  const CreditCardSummary({
    required this.account,
    required this.cycle,
    required this.previousStatementDebtSatang,
    required this.currentCycleDebtSatang,
    required this.totalDebtSatang,
    required this.currentCycleTransactions,
    this.allTransactions = const [],
    this.statementCycles = const [],
  });
}

@DriftAccessor(tables: [Accounts, Transactions])
class CreditCardDao extends DatabaseAccessor<AppDatabase> with _$CreditCardDaoMixin {
  CreditCardDao(super.db);

  static const _uuid = Uuid();

  static CreditCardBillingCycle calculateCycle(DateTime ref, {int statementDay = 23, int dueDay = 10}) {
    DateTime cycleStart;
    DateTime cycleEnd;
    DateTime prevCycleStart;
    DateTime prevCycleEnd;

    if (ref.day <= statementDay) {
      // Within current month's statement (ends on 23rd of this month)
      cycleEnd = DateTime(ref.year, ref.month, statementDay, 23, 59, 59, 999);
      
      final prevMonth = ref.month == 1 ? 12 : ref.month - 1;
      final prevYear = ref.month == 1 ? ref.year - 1 : ref.year;
      cycleStart = DateTime(prevYear, prevMonth, statementDay + 1, 0, 0, 0);

      prevCycleEnd = DateTime(prevYear, prevMonth, statementDay, 23, 59, 59, 999);
      final twoMonthsAgo = prevMonth == 1 ? 12 : prevMonth - 1;
      final twoYearsAgo = prevMonth == 1 ? prevYear - 1 : prevYear;
      prevCycleStart = DateTime(twoYearsAgo, twoMonthsAgo, statementDay + 1, 0, 0, 0);
    } else {
      // Past 23rd of this month -> accumulating for next month's statement (ends on 23rd of next month)
      cycleStart = DateTime(ref.year, ref.month, statementDay + 1, 0, 0, 0);
      final nextMonth = ref.month == 12 ? 1 : ref.month + 1;
      final nextYear = ref.month == 12 ? ref.year + 1 : ref.year;
      cycleEnd = DateTime(nextYear, nextMonth, statementDay, 23, 59, 59, 999);

      prevCycleEnd = DateTime(ref.year, ref.month, statementDay, 23, 59, 59, 999);
      final prevMonth = ref.month == 1 ? 12 : ref.month - 1;
      final prevYear = ref.month == 1 ? ref.year - 1 : ref.year;
      prevCycleStart = DateTime(prevYear, prevMonth, statementDay + 1, 0, 0, 0);
    }

    // Days remaining until cycle cutoff
    final endOfToday = DateTime(ref.year, ref.month, ref.day, 23, 59, 59);
    final daysRemaining = cycleEnd.difference(endOfToday).inDays.clamp(0, 31);

    return CreditCardBillingCycle(
      cycleStart: cycleStart,
      cycleEnd: cycleEnd,
      previousCycleStart: prevCycleStart,
      previousCycleEnd: prevCycleEnd,
      daysRemaining: daysRemaining,
      statementDay: statementDay,
      dueDay: dueDay,
    );
  }

  Future<CreditCardSummary?> getSummary(String accountId, [DateTime? asOf]) async {
    final account = await (select(accounts)..where((a) => a.id.equals(accountId))).getSingleOrNull();
    if (account == null || account.accountType != 'credit_card') {
      return null;
    }

    final refDate = asOf ?? DateTime.now();
    final statementDay = account.closingDay ?? 23;
    final dueDay = account.dueDay ?? 10;
    final cycle = calculateCycle(refDate, statementDay: statementDay, dueDay: dueDay);

    // Fetch all transactions for this card
    final allTrans = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .get();

    int totalCharges = 0;
    int totalPayments = 0;
    int currentCycleCharges = 0;
    int prevCycleCharges = 0;
    int paymentsAfterPrevStatement = 0;
    final currentCycleTrans = <Transaction>[];

    for (final t in allTrans) {
      final isCharge = t.sourceAccountId == accountId && (t.transactionType == 'expense' || t.transactionType == 'transfer');
      final isPayment = t.destinationAccountId == accountId && (t.transactionType == 'transfer' || t.transactionType == 'income');

      final cost = t.amountThbSatang + t.feeThbSatang;

      if (isCharge) {
        totalCharges += cost;
        if (!t.transactionDate.isBefore(cycle.cycleStart) && !t.transactionDate.isAfter(cycle.cycleEnd)) {
          currentCycleCharges += cost;
          currentCycleTrans.add(t);
        } else if (!t.transactionDate.isBefore(cycle.previousCycleStart) && !t.transactionDate.isAfter(cycle.previousCycleEnd)) {
          prevCycleCharges += cost;
        }
      } else if (isPayment) {
        totalPayments += t.amountThbSatang;
        if (!t.transactionDate.isBefore(cycle.previousCycleEnd)) {
          paymentsAfterPrevStatement += t.amountThbSatang;
        }
      }
    }

    final totalDebt = totalCharges - totalPayments;
    final prevStatementUnpaid = (prevCycleCharges - paymentsAfterPrevStatement).clamp(0, totalDebt);

    // Build statement cycles (up to 6 cycles)
    final statementCycles = <CreditCardCycleStatement>[];
    final c0End = cycle.cycleEnd;
    for (int k = 0; k < 6; k++) {
      final cEnd = DateTime(c0End.year, c0End.month - k, statementDay, 23, 59, 59, 999);
      final cStart = DateTime(c0End.year, c0End.month - k - 1, statementDay + 1, 0, 0, 0);
      final due = DateTime(cEnd.year, cEnd.month + 1, dueDay);

      final cycleTxs = allTrans.where((t) =>
        !t.transactionDate.isBefore(cStart) && !t.transactionDate.isAfter(cEnd)
      ).toList();

      int cCharges = 0;
      int cPayments = 0;
      for (final t in cycleTxs) {
        final cost = t.amountThbSatang + t.feeThbSatang;
        if (t.sourceAccountId == accountId && (t.transactionType == 'expense' || t.transactionType == 'transfer')) {
          cCharges += cost;
        } else if (t.destinationAccountId == accountId && (t.transactionType == 'transfer' || t.transactionType == 'income')) {
          cPayments += t.amountThbSatang;
        }
      }

      String label;
      if (k == 0) {
        label = 'รอบปัจจุบัน';
      } else if (k == 1) {
        label = 'รอบที่แล้ว';
      } else {
        label = 'รอบย้อนหลัง $k เดือน';
      }

      statementCycles.add(CreditCardCycleStatement(
        label: label,
        cycleStart: cStart,
        cycleEnd: cEnd,
        dueDate: due,
        chargesSatang: cCharges,
        paymentsSatang: cPayments,
        netDebtSatang: cCharges - cPayments,
        transactions: cycleTxs,
      ));
    }

    return CreditCardSummary(
      account: account,
      cycle: cycle,
      previousStatementDebtSatang: prevStatementUnpaid,
      currentCycleDebtSatang: currentCycleCharges,
      totalDebtSatang: totalDebt,
      currentCycleTransactions: currentCycleTrans,
      allTransactions: allTrans,
      statementCycles: statementCycles,
    );
  }

  Future<int> recordCreditCardPayment({
    required String fromAccountId,
    required String creditCardAccountId,
    required int amountSatang,
    DateTime? paymentDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final date = paymentDate ?? now;
    final card = await (select(accounts)..where((a) => a.id.equals(creditCardAccountId))).getSingleOrNull();
    final cardName = card?.name ?? 'บัตรเครดิต';
    final txNote = note ?? 'ชำระหนี้ $cardName';

    final tx = TransactionsCompanion.insert(
      id: _uuid.v4(),
      transactionType: 'transfer',
      sourceAccountId: Value(fromAccountId),
      destinationAccountId: Value(creditCardAccountId),
      amountOriginalSatang: amountSatang,
      currencyCode: 'THB',
      amountThbSatang: amountSatang,
      feeThbSatang: const Value(0),
      transactionDate: date,
      note: Value(txNote),
      createdAt: now,
      updatedAt: now,
    );

    return into(transactions).insert(tx);
  }
}
