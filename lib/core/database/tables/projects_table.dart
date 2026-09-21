import 'package:drift/drift.dart';

class Projects extends Table {
  TextColumn get id => text()(); // UUID v4
  TextColumn get name => text()(); // e.g. ทริปเที่ยวญี่ปุ่น, ปรับปรุงบ้าน
  TextColumn get description => text().nullable()();
  IntColumn get targetBudgetSatang => integer()(); // งบประมาณโครงการหน่วยสตางค์
  DateTimeColumn get startDate => dateTime()(); // วันเริ่มต้น
  DateTimeColumn get endDate => dateTime()(); // วันสิ้นสุด
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  IntColumn get syncVersion => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}
