import 'package:drift/drift.dart';

class InsurancePolicies extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get policyName => text()(); // e.g. AIA Health Happy
  TextColumn get insuranceType => text()(); // life, health, accident, critical_illness
  IntColumn get sumInsuredSatang => integer()(); // ทุนประกันกรณีเสียชีวิต/ทุพพลภาพ (สตางค์)
  IntColumn get medicalCoverageSatang => integer()(); // วงเงินค่ารักษาพยาบาล (สตางค์)
  IntColumn get annualPremiumSatang => integer()(); // เบี้ยประกันต่อปี (สตางค์)
  DateTimeColumn get dueDate => dateTime().nullable()(); // วันครบกำหนดชำระเบี้ย / สิ้นสุดสัญญา
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
