// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get appTitle => 'JP Money';

  @override
  String get home => 'หน้าแรก';

  @override
  String get money => 'การเงิน';

  @override
  String get invest => 'การลงทุน';

  @override
  String get plan => 'แผนการเงิน';

  @override
  String get more => 'เพิ่มเติม';

  @override
  String get add => 'เพิ่ม';

  @override
  String get trade => 'ซื้อขายหุ้น';

  @override
  String get dashboard => 'ภาพรวม';

  @override
  String get transactions => 'รายการ';

  @override
  String get quickAdd => 'บันทึกด่วน';

  @override
  String get quickAddKeypad => 'บันทึกด่วน (3 แตะ)';

  @override
  String get portfolio => 'พอร์ตลงทุน';

  @override
  String get accounts => 'บัญชี';

  @override
  String get budget => 'งบประมาณ';

  @override
  String get investments => 'การลงทุน';

  @override
  String get tax => 'ภาษี';

  @override
  String get financialHealth => 'สุขภาพการเงิน';

  @override
  String get reports => 'รายงาน';

  @override
  String get settings => 'ตั้งค่า';

  @override
  String get language => 'ภาษา (Language)';

  @override
  String get thai => 'ไทย';

  @override
  String get english => 'English';

  @override
  String get settingsTitle => 'ตั้งค่าระบบ';

  @override
  String get languageAndAppearance => 'ภาษาและรูปลักษณ์';

  @override
  String get themeMode => 'ธีมสีหน้าจอ';

  @override
  String get themeLight => 'สว่าง (Light)';

  @override
  String get themeDark => 'มืด (Dark)';

  @override
  String get themeSystem => 'ตามระบบ (System)';

  @override
  String get themeStyle => 'สไตล์ธีม (Theme Style)';

  @override
  String get themeStyleVault => 'VAULT (Quiet Luxury)';

  @override
  String get themeStyleLumi => 'Lumi (Sunny Bloom พาสเทล)';

  @override
  String get security => 'ความปลอดภัย (Security & PIN)';

  @override
  String get pinProtection => 'ระบบล็อก PIN';

  @override
  String get pinLockToggle => 'ล็อกแอปด้วยรหัส PIN';

  @override
  String get pinLockSubtitle =>
      'ต้องใส่รหัส PIN หรือสแกนลายนิ้วมือเพื่อเข้าใช้งาน';

  @override
  String get pinDisabled => 'ปิดใช้งาน (เข้าแอปได้ทันทีโดยไม่ต้องใส่รหัส)';

  @override
  String get pinCode => 'รหัสผ่าน PIN 6 หลัก';

  @override
  String get pinConfigured => 'ตั้งรหัส PIN เรียบร้อยแล้ว';

  @override
  String get pinNotConfigured => 'ยังไม่ได้ตั้งรหัส PIN';

  @override
  String get changePin => 'เปลี่ยน PIN';

  @override
  String get setupPin => 'ตั้งค่า PIN';

  @override
  String get sessionTimeout => 'ระยะเวลาจำสถานะปลดล็อก';

  @override
  String get biometrics => 'สแกนลายนิ้วมือ / ใบหน้า';

  @override
  String get biometricsSubtitle => 'ใช้ลายนิ้วมือปลดล็อกควบคู่กับ PIN';

  @override
  String get biometricsNotSupported =>
      'อุปกรณ์นี้ไม่รองรับเซนเซอร์สแกนลายนิ้วมือ';

  @override
  String get backup => 'การสำรองข้อมูล (Local Backup)';

  @override
  String get personalCloudBackup =>
      'สำรองและกู้คืนข้อมูล (Personal Cloud & Backup)';

  @override
  String get backupToJson =>
      'สำรองข้อมูลลง Google Drive / เครื่อง (JSON Backup)';

  @override
  String get backupToJsonSubtitle =>
      'สร้างไฟล์สำรองข้อมูลส่วนบุคคล นำไปเซฟลง Google Drive, iCloud หรือเครื่องได้ทันที';

  @override
  String get restoreFromJson => 'กู้คืนข้อมูลจากไฟล์สำรอง (Restore Backup)';

  @override
  String get restoreFromJsonSubtitle =>
      'เลือกไฟล์สำรองข้อมูล (.json) จาก Google Drive หรือเครื่องเพื่อกู้คืน';

  @override
  String get exportRawDb => 'ส่งออกไฟล์ฐานข้อมูลดิบ (.db)';

  @override
  String get exportRawDbSubtitle =>
      'สำรองไฟล์ SQLite เก็บไว้ในเครื่องหรือแชร์ออก (Windows/Android)';

  @override
  String get exportDatabase => 'ส่งออกสำเนาฐานข้อมูล (Export .db)';

  @override
  String get trashBin => 'ถังขยะกู้คืนข้อมูล (Trash Bin)';

  @override
  String get trashBinSubtitle => 'ดูบัญชีที่ถูกลบ กู้คืน หรือลบถาวร (30 วัน)';

  @override
  String get recurringTransactions => 'รายการประจำ (Recurring Rules)';

  @override
  String get recurringRulesDesc =>
      'ตั้งกฎสร้างรายการประจำอัตโนมัติ และดูพยากรณ์เงิน 30 วัน';

  @override
  String get taxAndRemittance => 'ภาษีและการเงินต่างประเทศ';

  @override
  String get taxPlanning => 'วางแผนภาษี (ภ.ง.ด. 90/91)';

  @override
  String get taxPlanningDesc =>
      'คำนวณภาษีขั้นบันได, หักค่าใช้จ่าย, ลดหย่อน, เปรียบเทียบปันผล';

  @override
  String get foreignRemittance => 'ติดตามเงินได้ต่างประเทศนำเข้าไทย';

  @override
  String get foreignRemittanceDesc =>
      'เกณฑ์ 180 วัน, ป.161/2566, ป.162/2566 เงินต้น/กำไร';

  @override
  String get financialPlanning => 'การวางแผนการเงินและระบบอัตโนมัติ';

  @override
  String get financialHealthDesc =>
      'ประเมิน 8 ตัวชี้วัด, Run-rate สิ้นเดือน/สิ้นปี และคำแนะนำ';

  @override
  String get liabilitiesInsurance =>
      'ทะเบียนหนี้สินและกรมธรรม์ประกัน (Debts & Insurance)';

  @override
  String get liabilitiesInsuranceDesc =>
      'จัดการภาระหนี้สิน ดอกเบี้ย และความคุ้มครองประกันภัย';

  @override
  String get categoriesManage => 'จัดการหมวดหมู่รายรับ-รายจ่าย (Categories)';

  @override
  String get categoriesManageDesc =>
      'สร้างหมวดหมู่ใหม่ กำหนดไอคอน และจัดหมวดหมู่';

  @override
  String get financialReports =>
      'ระบบรายงานทางการเงิน 7 แบบ (Financial Reports)';

  @override
  String get financialReportsDesc =>
      'สรุปรายเดือน/ปี, งบกระแสเงินสด, งบดุล, พอร์ต, ส่งออก Excel & PDF';

  @override
  String get cloudSyncTitle => 'คลาวด์และนำเข้าข้อมูล';

  @override
  String get importWizard => 'นำเข้าข้อมูลจาก Notion CSV (Import Wizard)';

  @override
  String get importWizardSubtitle =>
      'ตัดลิงก์ relation, ตรวจจับรายการซ้ำ, กฎภาษี สธ. พร้อม Rollback 1 คลิก';

  @override
  String get googleDriveSync => 'ซิงค์ข้อมูลผ่าน Google Drive (Cloud Sync)';

  @override
  String get googleDriveSyncSubtitle =>
      'สำรองและซิงค์ข้อมูลผ่าน Google Drive ส่วนตัวของคุณ ปลอดภัย 100%';

  @override
  String get expense => 'รายจ่าย';

  @override
  String get income => 'รายรับ';

  @override
  String get transfer => 'โอนเงิน';

  @override
  String get fromAccount => 'จากบัญชี';

  @override
  String get toAccount => 'ไปยังบัญชี';

  @override
  String get selectAccount => 'เลือกบัญชี';

  @override
  String get category => 'หมวดหมู่';

  @override
  String get amount => 'จำนวนเงิน';

  @override
  String get note => 'บันทึกช่วยจำ (Note)';

  @override
  String get save => 'บันทึก';

  @override
  String get duplicateLast => 'ทำซ้ำล่าสุด';

  @override
  String get usdAmountDestination => 'ยอดเงินปลายทาง (USD)';

  @override
  String get remainingBudget => 'เงินที่ใช้ได้เหลือเดือนนี้';

  @override
  String get netWorth => 'สินทรัพย์สุทธิ';

  @override
  String get monthlyIncome => 'รายรับเดือนนี้';

  @override
  String get netSavings => 'เงินออมสุทธิ';

  @override
  String get spendingByCategory => 'สัดส่วนรายจ่ายเดือนนี้';

  @override
  String get incomeExpenseTrends => 'แนวโน้มรายรับ-รายจ่าย (6 เดือน)';

  @override
  String get availableToSpend => 'เงินที่ใช้ได้ในเดือนนี้';

  @override
  String get budgetRemaining => 'ของงบประมาณเดือนนี้';

  @override
  String get viewAll => 'ดูทั้งหมด';

  @override
  String get recentActivity => 'ธุรกรรมล่าสุด';

  @override
  String get holdings => 'สินทรัพย์ที่ถือครอง';

  @override
  String get realizedPnl => 'กำไรที่รับรู้แล้ว';

  @override
  String get history => 'ประวัติ';

  @override
  String get projects => 'โครงการ';

  @override
  String get cashAndBank => 'เงินสดและธนาคาร';

  @override
  String get creditCards => 'บัตรเครดิต';

  @override
  String get foreignCurrency => 'สกุลเงินต่างประเทศ';

  @override
  String get morningGreeting => 'สวัสดีตอนเช้า ☀️';

  @override
  String get afternoonGreeting => 'สวัสดีตอนบ่าย 🌤️';

  @override
  String get eveningGreeting => 'สวัสดีตอนเย็น 🌙';

  @override
  String get addExpense => '+ บันทึกรายจ่าย';

  @override
  String get addIncome => '+ บันทึกรายรับ';

  @override
  String get monthlyOverview => 'ภาพรวมประจำเดือน';

  @override
  String get availableBalance => 'ยอดเงินคงเหลือ';

  @override
  String get creditCardDebt => 'หนี้บัตรเครดิต';

  @override
  String get currentBillingCycle => 'รอบบิลปัจจุบัน';

  @override
  String get billedCycle => 'ยอดเรียกเก็บแล้ว';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get close => 'ปิด';

  @override
  String get delete => 'ลบ';

  @override
  String get edit => 'แก้ไข';

  @override
  String get success => 'สำเร็จ';

  @override
  String get error => 'เกิดข้อผิดพลาด';

  @override
  String get confirmRestoreTitle => 'ยืนยันการกู้คืนข้อมูล';

  @override
  String get confirmRestoreContent =>
      'การกู้คืนข้อมูลจะนำเข้ารายการและบัญชีจากไฟล์สำรองข้อมูล (.json) และอัปเดตลงในฐานข้อมูลเครื่องนี้ ต้องการดำเนินการต่อหรือไม่?';

  @override
  String restoreSuccess(int accounts, int transactions) {
    return 'กู้คืนข้อมูลสำเร็จ: $accounts บัญชี, $transactions รายการ';
  }

  @override
  String get exportSuccess =>
      'ดาวน์โหลด / ส่งออกไฟล์สำรองข้อมูลสำเร็จ สามารถบันทึกลง Google Drive ของคุณได้เลย';

  @override
  String get appVersionFooter =>
      'JP Money v1.0.0\nLocal-First Financial System';
}
