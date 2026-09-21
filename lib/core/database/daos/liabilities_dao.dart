import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'liabilities_dao.g.dart';

@DriftAccessor(tables: [Liabilities, Accounts, Transactions, AuditLogs])
class LiabilitiesDao extends DatabaseAccessor<AppDatabase> with _$LiabilitiesDaoMixin {
  LiabilitiesDao(super.db);

  final _uuid = const Uuid();

  Future<List<Liability>> getActiveLiabilities() {
    return (select(liabilities)
          ..where((l) => l.deletedAt.isNull())
          ..orderBy([(l) => OrderingTerm.asc(l.name)]))
        .get();
  }

  Future<Liability?> getLiabilityById(String id) {
    return (select(liabilities)..where((l) => l.id.equals(id) & l.deletedAt.isNull())).getSingleOrNull();
  }

  Future<void> createLiability(LiabilitiesCompanion entry) async {
    final now = DateTime.now();
    final companion = entry.copyWith(
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(liabilities).insert(companion);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'liabilities',
        entityId: companion.id.value,
        action: 'CREATE_LIABILITY',
        afterDataJson: Value('{"name": "${companion.name.value}", "type": "${companion.liabilityType.value}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updateLiability(LiabilitiesCompanion entry) async {
    final now = DateTime.now();
    await (update(liabilities)..where((l) => l.id.equals(entry.id.value))).write(
      entry.copyWith(updatedAt: Value(now)),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'liabilities',
        entityId: entry.id.value,
        action: 'UPDATE_LIABILITY',
        afterDataJson: Value('{"name": "${entry.name.present ? entry.name.value : 'N/A'}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deleteLiability(String id) async {
    final now = DateTime.now();
    await (update(liabilities)..where((l) => l.id.equals(id))).write(
      LiabilitiesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'liabilities',
        entityId: id,
        action: 'SOFT_DELETE_LIABILITY',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Calculates total debt in satang, automatically pulling real-time balance
  /// for liabilities linked to a credit card account to prevent double counting.
  Future<int> getTotalLiabilitiesSatang() async {
    final active = await getActiveLiabilities();
    int total = 0;

    for (final item in active) {
      if (item.linkedAccountId != null) {
        final bal = await db.accountsDao.getAccountBalanceSatang(item.linkedAccountId!);
        // For credit cards, balance is stored as negative (spending) or positive
        if (bal < 0) {
          total += bal.abs();
        }
      } else {
        total += item.remainingPrincipalSatang;
      }
    }

    return total;
  }

  /// Calculates short-term debt (<= 1 year) in satang.
  Future<int> getShortTermLiabilitiesSatang() async {
    final active = await getActiveLiabilities();
    int total = 0;

    for (final item in active) {
      // Linked credit cards or explicit isShortTerm are counted as short term
      if (item.linkedAccountId != null) {
        final bal = await db.accountsDao.getAccountBalanceSatang(item.linkedAccountId!);
        if (bal < 0) {
          total += bal.abs();
        }
      } else if (item.isShortTerm) {
        total += item.remainingPrincipalSatang;
      }
    }

    return total;
  }

  /// Calculates total monthly payment for all debts.
  Future<int> getTotalMonthlyPaymentSatang() async {
    final active = await getActiveLiabilities();
    int total = 0;
    for (final item in active) {
      total += item.monthlyPaymentSatang;
    }
    return total;
  }
}
