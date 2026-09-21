import 'package:drift/drift.dart';
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

class CreditCardSummary {
  final Account account;
  final CreditCardBillingCycle cycle;
  final int previousStatementDebtSatang;
  final int currentCycleDebtSatang;
  final int totalDebtSatang;
  final List<Transaction> currentCycleTransactions;

  const CreditCardSummary({
    required this.account,
    required this.cycle,
    required this.previousStatementDebtSatang,
    required this.currentCycleDebtSatang,
    required this.totalDebtSatang,
    required this.currentCycleTransactions,
  });
}

@DriftAccessor(tables: [Accounts, Transactions])
class CreditCardDao extends DatabaseAccessor<AppDatabase> with _$CreditCardDaoMixin {
  CreditCardDao(super.db);

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
      final isCharge = t.sourceAccountId == accountId && t.transactionType == 'expense';
      final isPayment = t.destinationAccountId == accountId && t.transactionType == 'transfer';

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

    return CreditCardSummary(
      account: account,
      cycle: cycle,
      previousStatementDebtSatang: prevStatementUnpaid,
      currentCycleDebtSatang: currentCycleCharges,
      totalDebtSatang: totalDebt,
      currentCycleTransactions: currentCycleTrans,
    );
  }
}
