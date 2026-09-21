import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../app_database.dart';
import '../tables/all_tables.dart';

part 'tax_dao.g.dart';

@DriftAccessor(tables: [
  TaxRules,
  TaxDeductions,
  TaxResidencyRecords,
  Transactions,
  InvestmentIncomes,
  ForeignRemittances,
  AuditLogs,
])
class TaxDao extends DatabaseAccessor<AppDatabase> with _$TaxDaoMixin {
  TaxDao(super.db);

  final _uuid = const Uuid();

  Future<TaxRule?> getTaxRuleForYear(int year) async {
    final existing = await (select(taxRules)
          ..where((r) => r.taxYear.equals(year) & r.deletedAt.isNull() & r.isActive.equals(true)))
        .getSingleOrNull();
    if (existing != null) return existing;

    // Auto-inherit from the latest active rule when a new year arrives
    final latest = await getActiveTaxRule();
    if (latest != null) {
      final now = DateTime.now();
      final newRule = TaxRulesCompanion.insert(
        id: _uuid.v4(),
        taxYear: year,
        bracketsJson: latest.bracketsJson,
        personalAllowanceSatang: Value(latest.personalAllowanceSatang),
        spouseAllowanceSatang: Value(latest.spouseAllowanceSatang),
        childAllowanceSatang: Value(latest.childAllowanceSatang),
        expenseRatePercent: Value(latest.expenseRatePercent),
        expenseMaxSatang: Value(latest.expenseMaxSatang),
        flatExpense406MedicalPercent: Value(latest.flatExpense406MedicalPercent),
        flatExpense408Percent: Value(latest.flatExpense408Percent),
        deductionLimitsJson: latest.deductionLimitsJson,
        foreignRemittanceRuleJson: latest.foreignRemittanceRuleJson,
        isActive: const Value(true),
        createdAt: now,
        updatedAt: now,
      );
      await into(taxRules).insert(newRule);
      return (select(taxRules)..where((r) => r.taxYear.equals(year) & r.deletedAt.isNull())).getSingleOrNull();
    }
    return null;
  }

  Future<TaxRule?> getTaxRule(int year) => getTaxRuleForYear(year);

  Future<TaxRule?> getActiveTaxRule() {
    return (select(taxRules)
          ..where((r) => r.deletedAt.isNull() & r.isActive.equals(true))
          ..orderBy([(r) => OrderingTerm.desc(r.taxYear)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<TaxRule>> getAllTaxRules() {
    return (select(taxRules)
          ..where((r) => r.deletedAt.isNull())
          ..orderBy([(r) => OrderingTerm.desc(r.taxYear)]))
        .get();
  }

  Future<void> saveTaxRule(TaxRulesCompanion rule) async {
    final now = DateTime.now();
    final existing = await (select(taxRules)
          ..where((r) => r.taxYear.equals(rule.taxYear.value) & r.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      await (update(taxRules)..where((r) => r.id.equals(existing.id))).write(
        rule.copyWith(updatedAt: Value(now)),
      );
    } else {
      await into(taxRules).insert(
        rule.copyWith(
          id: rule.id.present ? rule.id : Value(_uuid.v4()),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }

    await into(auditLogs).insert(
      AuditLogsCompanion.insert(
        id: _uuid.v4(),
        entityTable: 'tax_rules',
        entityId: existing?.id ?? rule.id.value,
        action: existing != null ? 'UPDATE_TAX_RULE' : 'CREATE_TAX_RULE',
        afterDataJson: Value('{"year": ${rule.taxYear.value}}'),
        changeTimestamp: now,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<List<TaxDeduction>> getDeductionsForYear(int year) {
    return (select(taxDeductions)
          ..where((d) => d.taxYear.equals(year) & d.deletedAt.isNull())
          ..orderBy([(d) => OrderingTerm.asc(d.deductionGroup)]))
        .get();
  }

  Future<void> saveTaxDeduction(TaxDeductionsCompanion deduction) async {
    final now = DateTime.now();
    final existing = await (select(taxDeductions)
          ..where((d) =>
              d.taxYear.equals(deduction.taxYear.value) &
              d.deductionType.equals(deduction.deductionType.value) &
              d.deletedAt.isNull()))
        .getSingleOrNull();

    if (existing != null) {
      await (update(taxDeductions)..where((d) => d.id.equals(existing.id))).write(
        deduction.copyWith(updatedAt: Value(now)),
      );
    } else {
      await into(taxDeductions).insert(
        deduction.copyWith(
          id: deduction.id.present ? deduction.id : Value(_uuid.v4()),
          createdAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
  }

  Future<void> deleteTaxDeduction(String id) {
    final now = DateTime.now();
    return (update(taxDeductions)..where((d) => d.id.equals(id))).write(
      TaxDeductionsCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> insertOrUpdateTaxRule(TaxRulesCompanion rule) => saveTaxRule(rule);

  Future<TaxResidencyRecord?> getResidencyRecord(int year) {
    return (select(taxResidencyRecords)
          ..where((r) => r.taxYear.equals(year) & r.deletedAt.isNull()))
        .getSingleOrNull();
  }

  Future<TaxResidencyRecord?> getTaxResidency(int year) => getResidencyRecord(year);

  Stream<TaxResidencyRecord?> watchTaxResidency(int year) {
    return (select(taxResidencyRecords)
          ..where((r) => r.taxYear.equals(year) & r.deletedAt.isNull()))
        .watchSingleOrNull();
  }

  Future<void> saveResidencyRecord(int year, int daysInThailand, {String? note}) async {
    final now = DateTime.now();
    final existing = await getResidencyRecord(year);

    if (existing != null) {
      await (update(taxResidencyRecords)..where((r) => r.id.equals(existing.id))).write(
        TaxResidencyRecordsCompanion(
          daysInThailand: Value(daysInThailand),
          note: Value(note),
          updatedAt: Value(now),
        ),
      );
    } else {
      await into(taxResidencyRecords).insert(
        TaxResidencyRecordsCompanion.insert(
          id: _uuid.v4(),
          taxYear: year,
          daysInThailand: Value(daysInThailand),
          note: Value(note),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> setTaxResidency(int year, int daysInThailand, {String? note}) =>
      saveResidencyRecord(year, daysInThailand, note: note);

  Future<List<Transaction>> getIncomeTransactionsForYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    return (select(transactions)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.transactionType.equals('income') &
              t.transactionDate.isBiggerOrEqualValue(start) &
              t.transactionDate.isSmallerThanValue(end))
          ..orderBy([(t) => OrderingTerm.asc(t.transactionDate)]))
        .get();
  }

  Future<List<InvestmentIncome>> getInvestmentIncomesForYear(int year) {
    final start = DateTime(year, 1, 1);
    final end = DateTime(year + 1, 1, 1);

    return (select(investmentIncomes)
          ..where((i) =>
              i.deletedAt.isNull() &
              i.createdAt.isBiggerOrEqualValue(start) &
              i.createdAt.isSmallerThanValue(end))
          ..orderBy([(i) => OrderingTerm.asc(i.createdAt)]))
        .get();
  }
}
