import 'package:drift/drift.dart';

class TaxRules extends Table {
  TextColumn get id => text()(); // UUID v4
  IntColumn get taxYear => integer()(); // e.g. 2025, 2026
  TextColumn get bracketsJson => text()(); // Progressive tax brackets
  IntColumn get personalAllowanceSatang => integer().withDefault(const Constant(6000000))(); // 60,000 THB
  IntColumn get spouseAllowanceSatang => integer().withDefault(const Constant(6000000))(); // 60,000 THB
  IntColumn get childAllowanceSatang => integer().withDefault(const Constant(3000000))(); // 30,000 THB
  TextColumn get expenseRatePercent => text().withDefault(const Constant('50.0'))(); // 50%
  IntColumn get expenseMaxSatang => integer().withDefault(const Constant(10000000))(); // 100,000 THB for 40(1)+(2)
  TextColumn get flatExpense406MedicalPercent => text().withDefault(const Constant('60.0'))(); // 60% for 40(6) Medical
  TextColumn get flatExpense408Percent => text().withDefault(const Constant('60.0'))(); // 60% for 40(8)
  TextColumn get deductionLimitsJson => text()(); // Insurance, SSF, RMF, ThaiESG, Social Security, Donations
  TextColumn get foreignRemittanceRuleJson => text()(); // 180 days threshold, pre-2024 exemption
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
