import 'dart:math';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'insurance_dao.g.dart';

class PolicyProgress {
  final InsurancePolicy policy;
  final int paidPeriods;
  final int totalPeriods;
  final int totalPaidSatang;
  final int remainingSatang;
  final bool isPaidForCurrentYear;
  final DateTime? nextDueDate;
  final int? daysUntilDue;

  const PolicyProgress({
    required this.policy,
    required this.paidPeriods,
    required this.totalPeriods,
    required this.totalPaidSatang,
    required this.remainingSatang,
    required this.isPaidForCurrentYear,
    this.nextDueDate,
    this.daysUntilDue,
  });
}

@DriftAccessor(tables: [InsurancePolicies, AuditLogs, Transactions])
class InsuranceDao extends DatabaseAccessor<AppDatabase> with _$InsuranceDaoMixin {
  InsuranceDao(super.db);

  static const String defaultSavingsPolicyId = 'policy-mtl-savings-15-20';

  final _uuid = const Uuid();

  Stream<List<InsurancePolicy>> watchActivePolicies() {
    return (select(insurancePolicies)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.policyName)]))
        .watch();
  }

  Future<List<InsurancePolicy>> getActivePolicies() {
    return (select(insurancePolicies)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.policyName)]))
        .get();
  }

  Future<List<InsurancePolicy>> getAllPolicies() => getActivePolicies();

  Future<InsurancePolicy?> getPolicyById(String id) {
    return (select(insurancePolicies)..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
  }

  /// Ensures default policy "เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20" exists
  Future<InsurancePolicy> getOrCreateDefaultSavingsPolicy() async {
    final existing = await getPolicyById(defaultSavingsPolicyId);
    if (existing != null) return existing;

    final byName = await (select(insurancePolicies)
          ..where((p) =>
              p.policyName.equals('เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20') &
              p.deletedAt.isNull()))
        .getSingleOrNull();
    if (byName != null) return byName;

    final now = DateTime.now();
    await into(insurancePolicies).insert(
      InsurancePoliciesCompanion.insert(
        id: defaultSavingsPolicyId,
        policyName: 'เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20',
        insuranceType: 'savings',
        annualPremiumSatang: 4500000, // 45,000 THB
        sumInsuredSatang: 10000000, // 100,000 THB
        medicalCoverageSatang: 0,
        totalPeriods: const Value(15),
        paymentDueDay: const Value(5),
        paymentDueMonth: const Value(10),
        note: const Value('ประกันชีวิตและออมทรัพย์ เมืองไทยประกันชีวิต 15/20'),
        createdAt: now,
        updatedAt: now,
      ),
      mode: InsertMode.insertOrIgnore,
    );

    final created = await getPolicyById(defaultSavingsPolicyId);
    return created ??
        InsurancePolicy(
          id: defaultSavingsPolicyId,
          policyName: 'เมืองไทยประกันชีวิต ออมมั่งคั่ง 15/20',
          insuranceType: 'savings',
          sumInsuredSatang: 10000000,
          medicalCoverageSatang: 0,
          annualPremiumSatang: 4500000,
          totalPeriods: 15,
          paymentDueDay: 5,
          paymentDueMonth: 10,
          note: 'ประกันชีวิตและออมทรัพย์ เมืองไทยประกันชีวิต 15/20',
          createdAt: now,
          updatedAt: now,
          syncVersion: 1,
        );
  }

  Future<void> createPolicy(InsurancePoliciesCompanion entry) async {
    final now = DateTime.now();
    final companion = entry.copyWith(
      createdAt: entry.createdAt.present ? entry.createdAt : Value(now),
      updatedAt: entry.updatedAt.present ? entry.updatedAt : Value(now),
    );
    await into(insurancePolicies).insert(companion);

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'insurance_policies',
        entityId: companion.id.value,
        action: 'CREATE_INSURANCE_POLICY',
        afterDataJson: Value('{"policyName": "${companion.policyName.value}", "type": "${companion.insuranceType.value}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> updatePolicy(InsurancePoliciesCompanion entry) async {
    final now = DateTime.now();
    await (update(insurancePolicies)..where((p) => p.id.equals(entry.id.value))).write(
      entry.copyWith(updatedAt: Value(now)),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'insurance_policies',
        entityId: entry.id.value,
        action: 'UPDATE_INSURANCE_POLICY',
        afterDataJson: Value('{"policyName": "${entry.policyName.present ? entry.policyName.value : 'N/A'}"}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> deletePolicy(String id) async {
    final now = DateTime.now();
    await (update(insurancePolicies)..where((p) => p.id.equals(id))).write(
      InsurancePoliciesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'insurance_policies',
        entityId: id,
        action: 'SOFT_DELETE_INSURANCE_POLICY',
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Calculates payment progress for a single policy
  Future<PolicyProgress> getPolicyProgress(InsurancePolicy policy) async {
    final now = DateTime.now();

    // Query transactions linked to this policy via tag only.
    // Note matching is intentionally excluded to avoid false positives from
    // Notion Bill transactions whose note text may contain the policy name
    // but are not actual premium payments (e.g. recurring bill descriptions).
    final txs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.tag.like('%policy:${policy.id}%')))
        .get();

    // สำหรับประกันรายปี เช่น 15/20 ให้นับจำนวนงวดตามปีที่มีการชำระจริง (Distinct Years)
    // เพื่อป้องกันการนับซ้ำกรณีมีรายการธุรกรรมหลายแถวในปีเดียวกัน
    final distinctYearsPaid = txs.map((t) => t.transactionDate.year).toSet().length;
    final paidPeriods = policy.totalPeriods > 0
        ? min(policy.totalPeriods, distinctYearsPaid)
        : txs.length;

    int totalPaidSatang = 0;
    bool isPaidThisYear = false;

    for (final t in txs) {
      totalPaidSatang += t.amountThbSatang;
      if (t.transactionDate.year == now.year) {
        isPaidThisYear = true;
      }
    }

    final totalTargetSatang = policy.annualPremiumSatang * policy.totalPeriods;
    final remainingSatang = max(0, totalTargetSatang - totalPaidSatang);

    DateTime? nextDue;
    int? daysUntil;

    if (policy.paymentDueMonth != null && policy.paymentDueDay != null) {
      final dueMonth = policy.paymentDueMonth!;
      final dueDay = min(policy.paymentDueDay!, DateTime(now.year, dueMonth + 1, 0).day);

      var dueThisYear = DateTime(now.year, dueMonth, dueDay);
      if (isPaidThisYear) {
        // Already paid this year -> next due is next year
        nextDue = DateTime(now.year + 1, dueMonth, min(policy.paymentDueDay!, DateTime(now.year + 1, dueMonth + 1, 0).day));
      } else {
        nextDue = dueThisYear;
      }
      daysUntil = nextDue.difference(DateTime(now.year, now.month, now.day)).inDays;
    } else if (policy.dueDate != null) {
      nextDue = policy.dueDate;
      daysUntil = nextDue!.difference(DateTime(now.year, now.month, now.day)).inDays;
    }

    return PolicyProgress(
      policy: policy,
      paidPeriods: paidPeriods,
      totalPeriods: policy.totalPeriods,
      totalPaidSatang: totalPaidSatang,
      remainingSatang: remainingSatang,
      isPaidForCurrentYear: isPaidThisYear,
      nextDueDate: nextDue,
      daysUntilDue: daysUntil,
    );
  }

  /// Returns progress for all active policies
  Future<List<PolicyProgress>> getAllPolicyProgresses() async {
    final policies = await getActivePolicies();
    final results = <PolicyProgress>[];
    for (final p in policies) {
      results.add(await getPolicyProgress(p));
    }
    return results;
  }

  /// Returns policies due within [daysThreshold] days (or overdue) that haven't been paid this year
  Future<List<PolicyProgress>> getUpcomingDuePolicies({int daysThreshold = 30}) async {
    final all = await getAllPolicyProgresses();
    return all.where((p) {
      if (p.isPaidForCurrentYear) return false;
      if (p.daysUntilDue == null) return false;
      // Due within threshold days (or up to 60 days overdue)
      return p.daysUntilDue! <= daysThreshold && p.daysUntilDue! >= -60;
    }).toList();
  }

  /// Total accumulated cash/savings from all payments made to savings insurance policies
  /// This is added to Net Worth so Net Worth remains unchanged when paying savings insurance.
  Future<int> getTotalInsuranceSavingsSatang() async {
    final policies = await getActivePolicies();
    final savingsPolicies = policies.where((p) => p.insuranceType == 'savings' || p.insuranceType == 'endowment').toList();
    if (savingsPolicies.isEmpty) return 0;

    int totalSavings = 0;
    for (final p in savingsPolicies) {
      final progress = await getPolicyProgress(p);
      totalSavings += progress.totalPaidSatang;
    }
    return totalSavings;
  }

  /// Total sum insured (Life / Disability / Total Coverage) in satang
  Future<int> getTotalSumInsuredSatang() async {
    final active = await getActivePolicies();
    int total = 0;
    for (final p in active) {
      total += p.sumInsuredSatang;
    }
    return total;
  }

  /// Total medical coverage (Health / Accident) in satang
  Future<int> getTotalMedicalCoverageSatang() async {
    final active = await getActivePolicies();
    int total = 0;
    for (final p in active) {
      total += p.medicalCoverageSatang;
    }
    return total;
  }

  /// Total annual premiums in satang
  Future<int> getTotalAnnualPremiumSatang() async {
    final active = await getActivePolicies();
    int total = 0;
    for (final p in active) {
      total += p.annualPremiumSatang;
    }
    return total;
  }

  /// One-time migration: fixes legacy insurance transactions that were imported
  /// before the policy-tag fix. Patches all expense transactions with
  /// `deduction:life_insurance` tag (but missing `policy:` prefix) and
  /// category id = healthcare or life&savings insurance to include the correct
  /// policy tag so that [getPolicyProgress] counts them correctly.
  ///
  /// Safe to call multiple times — already-correct rows are skipped.
  Future<int> patchLegacyInsuranceTransactions() async {
    final now = DateTime.now();
    int patchedCount = 0;

    // Find all expense transactions that have deduction:life_insurance tag
    // but do NOT yet have policy:policy-mtl-savings-15-20 in the tag.
    final legacyTxs = await (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('expense') &
              t.tag.like('%deduction:life_insurance%') &
              t.tag.like('%policy:policy-mtl-savings-15-20%').not()))
        .get();

    for (final tx in legacyTxs) {
      final newTag = tx.tag != null && tx.tag!.isNotEmpty
          ? 'policy:$defaultSavingsPolicyId,${tx.tag}'
          : 'policy:$defaultSavingsPolicyId,deduction:life_insurance';

      await (update(transactions)..where((t) => t.id.equals(tx.id))).write(
        TransactionsCompanion(
          tag: Value(newTag),
          categoryId: const Value('cat-exp-0000-4000-8000-000000000015'),
          updatedAt: Value(now),
        ),
      );
      patchedCount++;
    }
    return patchedCount;
  }
}

