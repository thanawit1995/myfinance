import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'insurance_dao.g.dart';

@DriftAccessor(tables: [InsurancePolicies, AuditLogs])
class InsuranceDao extends DatabaseAccessor<AppDatabase> with _$InsuranceDaoMixin {
  InsuranceDao(super.db);

  final _uuid = const Uuid();

  Future<List<InsurancePolicy>> getActivePolicies() {
    return (select(insurancePolicies)
          ..where((p) => p.deletedAt.isNull())
          ..orderBy([(p) => OrderingTerm.asc(p.policyName)]))
        .get();
  }

  Future<InsurancePolicy?> getPolicyById(String id) {
    return (select(insurancePolicies)..where((p) => p.id.equals(id) & p.deletedAt.isNull())).getSingleOrNull();
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
}
