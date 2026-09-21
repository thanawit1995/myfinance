import 'package:drift/drift.dart';
import 'accounts_table.dart';

class Liabilities extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()(); // e.g. สินเชื่อบ้าน ธนาคารกรุงไทย
  TextColumn get liabilityType => text()(); // mortgage, auto_loan, personal_loan, credit_card, other
  IntColumn get remainingPrincipalSatang => integer()(); // ยอดหนี้คงค้างหน่วยสตางค์
  IntColumn get monthlyPaymentSatang => integer()(); // ค่างวดต่อเดือนหน่วยสตางค์
  TextColumn get interestRatePercent => text()(); // อัตราดอกเบี้ย % ต่อปี (Decimal เช่น '4.750000')
  BoolColumn get isShortTerm => boolean()(); // true = หนี้ระยะสั้น (<= 1 ปี), false = หนี้ระยะยาว (> 1 ปี)
  TextColumn get linkedAccountId => text().nullable().references(Accounts, #id)(); // เชื่อมโยงบัญชีบัตรเครดิตถ้ามี
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
