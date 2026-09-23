import 'package:decimal/decimal.dart';
import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/transactions_table.dart';

part 'accounts_dao.g.dart';

@DriftAccessor(tables: [Accounts, Transactions])
class AccountsDao extends DatabaseAccessor<AppDatabase> with _$AccountsDaoMixin {
  AccountsDao(super.db);

  Stream<List<Account>> watchActiveAccounts() {
    return (select(accounts)
          ..where((a) => a.isActive.equals(true) & a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm(expression: a.createdAt)]))
        .watch();
  }

  Future<List<Account>> getActiveAccounts() {
    return (select(accounts)
          ..where((a) => a.isActive.equals(true) & a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm(expression: a.createdAt)]))
        .get();
  }

  Future<List<Account>> getAllAccounts() {
    return (select(accounts)
          ..where((a) => a.deletedAt.isNull())
          ..orderBy([(a) => OrderingTerm(expression: a.createdAt)]))
        .get();
  }

  Future<Account?> getAccountById(String id) {
    return (select(accounts)..where((a) => a.id.equals(id))).getSingleOrNull();
  }

  Future<int> createAccount(AccountsCompanion account) {
    return into(accounts).insert(account);
  }

  Future<bool> updateAccount(AccountsCompanion account) {
    return update(accounts).replace(account);
  }

  Future<int> deactivateAccount(String id) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isActive: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> activateAccount(String id) {
    return (update(accounts)..where((a) => a.id.equals(id))).write(
      AccountsCompanion(
        isActive: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Soft deletes an account and cascades soft-delete to all related transactions.
  /// Transactions are marked with tag 'account_deleted:{accountId}' so they can be restored accurately.
  Future<bool> softDeleteAccount(String accountId) async {
    final account = await getAccountById(accountId);
    if (account == null) return false;

    final now = DateTime.now();

    // 1. Soft-delete the account
    final accUpdated = await (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    if (accUpdated == 0) return false;

    // 2. Cascade soft-delete active transactions belonging to this account
    final relatedTxList = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId))))
        .get();

    for (final tx in relatedTxList) {
      await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
        TransactionsCompanion(
          tag: Value('account_deleted:$accountId'),
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    return true;
  }

  /// Restores a soft-deleted account and its cascaded transactions.
  Future<bool> restoreAccount(String accountId) async {
    final now = DateTime.now();

    final accRestored = await (update(accounts)..where((a) => a.id.equals(accountId))).write(
      AccountsCompanion(
        deletedAt: const Value(null),
        updatedAt: Value(now),
      ),
    );

    if (accRestored == 0) return false;

    // Restore transactions that were cascaded deleted with this account
    final cascadedTxList = await (select(transactions)
          ..where((t) =>
              t.tag.equals('account_deleted:$accountId') &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId))))
        .get();

    for (final tx in cascadedTxList) {
      await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
        TransactionsCompanion(
          tag: const Value(null),
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    }

    return true;
  }

  /// Returns all soft-deleted accounts currently in the trash bin.
  Future<List<Account>> getDeletedAccounts() {
    return (select(accounts)
          ..where((a) => a.deletedAt.isNotNull())
          ..orderBy([(a) => OrderingTerm.desc(a.deletedAt)]))
        .get();
  }

  /// Count how many transactions were deleted along with this account.
  Future<int> countTransactionsForAccount(String accountId) async {
    final list = await (select(transactions)
          ..where((t) =>
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId))))
        .get();
    return list.length;
  }

  /// Permanently deletes an account and its transactions (Hard Delete).
  Future<void> permanentlyDeleteAccount(String accountId) async {
    await (delete(transactions)
          ..where((t) =>
              t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId)))
        .go();
    await (delete(accounts)..where((a) => a.id.equals(accountId))).go();
  }

  /// Cleans up any accounts that have been in the trash for more than 30 days.
  Future<int> cleanupExpiredDeletedAccounts() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final expired = await (select(accounts)..where((a) => a.deletedAt.isSmallerOrEqualValue(cutoff))).get();

    for (final acc in expired) {
      await permanentlyDeleteAccount(acc.id);
    }

    return expired.length;
  }

  /// Fetches the latest USD to THB exchange rate from fx_rates table.
  Future<Decimal> getLatestUsdFxRate() async {
    final rateRow = await (attachedDatabase.select(attachedDatabase.fxRates)
          ..where((f) => f.baseCurrency.equals('USD') & f.targetCurrency.equals('THB') & f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm.desc(f.effectiveDate), (f) => OrderingTerm.desc(f.createdAt)])
          ..limit(1))
        .getSingleOrNull();

    if (rateRow != null) {
      final parsed = Decimal.tryParse(rateRow.rate);
      if (parsed != null && parsed > Decimal.zero) {
        return parsed;
      }
    }
    return Decimal.parse('35.000000');
  }

  /// Calculates the real-time balance of an account in its native integer satang/cents directly from the ledger.
  Future<int> getAccountBalanceSatang(String accountId) async {
    final account = await getAccountById(accountId);
    if (account == null) return 0;

    final transList = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              (t.sourceAccountId.equals(accountId) | t.destinationAccountId.equals(accountId))))
        .get();

    final isForeign = account.currencyCode != 'THB';
    int balance = 0;

    if (account.accountType == 'credit_card') {
      // Credit card logic: charges are debt (negative), payments reduce debt (positive)
      for (final t in transList) {
        final amount = isForeign ? t.amountOriginalSatang : t.amountThbSatang;
        final fee = isForeign ? 0 : t.feeThbSatang;
        if (t.sourceAccountId == accountId && t.transactionType == 'expense') {
          balance -= (amount + fee);
        } else if (t.destinationAccountId == accountId && t.transactionType == 'transfer') {
          balance += amount;
        }
      }
    } else {
      // Deposit / Cash / Asset account logic
      for (final t in transList) {
        final amount = isForeign ? t.amountOriginalSatang : t.amountThbSatang;
        final fee = isForeign ? 0 : t.feeThbSatang;

        if (t.sourceAccountId == accountId) {
          if (t.transactionType == 'income') {
            // Only cleared income transactions are included in real-time cash balance
            if (t.isCleared) {
              final netIncome = amount - (isForeign ? 0 : t.withholdingTaxSatang);
              balance += netIncome;
            }
          } else if (t.transactionType == 'expense') {
            balance -= (amount + fee);
          } else if (t.transactionType == 'transfer') {
            balance -= (amount + fee);
          } else if (t.transactionType == 'invest_buy') {
            balance -= (amount + fee);
          }
        }

        if (t.destinationAccountId == accountId) {
          if (t.transactionType == 'transfer') {
            balance += amount;
          } else if (t.transactionType == 'invest_sell') {
            balance += amount;
          }
        }
      }
    }

    return balance;
  }

  /// Returns native balance, equivalent THB satang, and the FX rate used.
  Future<({int nativeBalanceSatang, int thbEquivalentSatang, Decimal fxRate})> getAccountBalanceBreakdown(String accountId) async {
    final account = await getAccountById(accountId);
    if (account == null) {
      return (nativeBalanceSatang: 0, thbEquivalentSatang: 0, fxRate: Decimal.one);
    }

    final nativeBalance = await getAccountBalanceSatang(accountId);

    if (account.currencyCode == 'THB') {
      return (nativeBalanceSatang: nativeBalance, thbEquivalentSatang: nativeBalance, fxRate: Decimal.one);
    }

    final fxRate = await getLatestUsdFxRate();
    final thbEquivalent = (Decimal.fromInt(nativeBalance) * fxRate).round().toBigInt().toInt();

    return (nativeBalanceSatang: nativeBalance, thbEquivalentSatang: thbEquivalent, fxRate: fxRate);
  }

  /// Returns total net worth in THB satang across all active accounts only.
  Future<int> getTotalNetWorthSatang() async {
    final active = await getActiveAccounts();
    int totalThb = 0;
    for (final acc in active) {
      final breakdown = await getAccountBalanceBreakdown(acc.id);
      totalThb += breakdown.thbEquivalentSatang;
    }
    return totalThb;
  }
}
