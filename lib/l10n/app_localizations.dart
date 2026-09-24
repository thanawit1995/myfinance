import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_th.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('th'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In th, this message translates to:
  /// **'OURS'**
  String get appTitle;

  /// No description provided for @home.
  ///
  /// In th, this message translates to:
  /// **'หน้าแรก'**
  String get home;

  /// No description provided for @money.
  ///
  /// In th, this message translates to:
  /// **'การเงิน'**
  String get money;

  /// No description provided for @invest.
  ///
  /// In th, this message translates to:
  /// **'การลงทุน'**
  String get invest;

  /// No description provided for @plan.
  ///
  /// In th, this message translates to:
  /// **'แผนการเงิน'**
  String get plan;

  /// No description provided for @more.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มเติม'**
  String get more;

  /// No description provided for @add.
  ///
  /// In th, this message translates to:
  /// **'เพิ่ม'**
  String get add;

  /// No description provided for @trade.
  ///
  /// In th, this message translates to:
  /// **'ซื้อขายหุ้น'**
  String get trade;

  /// No description provided for @dashboard.
  ///
  /// In th, this message translates to:
  /// **'ภาพรวม'**
  String get dashboard;

  /// No description provided for @transactions.
  ///
  /// In th, this message translates to:
  /// **'รายการ'**
  String get transactions;

  /// No description provided for @quickAdd.
  ///
  /// In th, this message translates to:
  /// **'บันทึกด่วน'**
  String get quickAdd;

  /// No description provided for @quickAddKeypad.
  ///
  /// In th, this message translates to:
  /// **'บันทึกด่วน'**
  String get quickAddKeypad;

  /// No description provided for @portfolio.
  ///
  /// In th, this message translates to:
  /// **'พอร์ตการลงทุน'**
  String get portfolio;

  /// No description provided for @accounts.
  ///
  /// In th, this message translates to:
  /// **'บัญชี'**
  String get accounts;

  /// No description provided for @budget.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณ'**
  String get budget;

  /// No description provided for @investments.
  ///
  /// In th, this message translates to:
  /// **'การลงทุน'**
  String get investments;

  /// No description provided for @tax.
  ///
  /// In th, this message translates to:
  /// **'ภาษี'**
  String get tax;

  /// No description provided for @financialHealth.
  ///
  /// In th, this message translates to:
  /// **'สุขภาพการเงิน'**
  String get financialHealth;

  /// No description provided for @reports.
  ///
  /// In th, this message translates to:
  /// **'รายงาน'**
  String get reports;

  /// No description provided for @settings.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In th, this message translates to:
  /// **'ภาษา'**
  String get language;

  /// No description provided for @thai.
  ///
  /// In th, this message translates to:
  /// **'ไทย'**
  String get thai;

  /// No description provided for @english.
  ///
  /// In th, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @settingsTitle.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่าระบบ'**
  String get settingsTitle;

  /// No description provided for @languageAndAppearance.
  ///
  /// In th, this message translates to:
  /// **'ภาษาและรูปลักษณ์'**
  String get languageAndAppearance;

  /// No description provided for @themeMode.
  ///
  /// In th, this message translates to:
  /// **'ธีมสีหน้าจอ'**
  String get themeMode;

  /// No description provided for @themeLight.
  ///
  /// In th, this message translates to:
  /// **'สว่าง'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In th, this message translates to:
  /// **'มืด'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In th, this message translates to:
  /// **'ตามระบบ'**
  String get themeSystem;

  /// No description provided for @themeStyle.
  ///
  /// In th, this message translates to:
  /// **'สไตล์ดีไซน์'**
  String get themeStyle;

  /// No description provided for @themeStyleVault.
  ///
  /// In th, this message translates to:
  /// **'VAULT (Quiet Luxury)'**
  String get themeStyleVault;

  /// No description provided for @themeStyleLumi.
  ///
  /// In th, this message translates to:
  /// **'Lumi (Sunny Bloom พาสเทล)'**
  String get themeStyleLumi;

  /// No description provided for @security.
  ///
  /// In th, this message translates to:
  /// **'ความปลอดภัยและรหัส PIN'**
  String get security;

  /// No description provided for @pinProtection.
  ///
  /// In th, this message translates to:
  /// **'ระบบล็อก PIN'**
  String get pinProtection;

  /// No description provided for @pinLockToggle.
  ///
  /// In th, this message translates to:
  /// **'ล็อกแอปด้วยรหัส PIN'**
  String get pinLockToggle;

  /// No description provided for @pinLockSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ต้องใส่รหัส PIN หรือสแกนลายนิ้วมือเพื่อเข้าใช้งาน'**
  String get pinLockSubtitle;

  /// No description provided for @pinDisabled.
  ///
  /// In th, this message translates to:
  /// **'ปิดใช้งาน (เข้าแอปได้ทันทีโดยไม่ต้องใส่รหัส)'**
  String get pinDisabled;

  /// No description provided for @pinCode.
  ///
  /// In th, this message translates to:
  /// **'รหัสผ่าน PIN 6 หลัก'**
  String get pinCode;

  /// No description provided for @pinConfigured.
  ///
  /// In th, this message translates to:
  /// **'ตั้งรหัส PIN เรียบร้อยแล้ว'**
  String get pinConfigured;

  /// No description provided for @pinNotConfigured.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งรหัส PIN'**
  String get pinNotConfigured;

  /// No description provided for @changePin.
  ///
  /// In th, this message translates to:
  /// **'เปลี่ยน PIN'**
  String get changePin;

  /// No description provided for @setupPin.
  ///
  /// In th, this message translates to:
  /// **'ตั้งค่า PIN'**
  String get setupPin;

  /// No description provided for @sessionTimeout.
  ///
  /// In th, this message translates to:
  /// **'ระยะเวลาจำสถานะปลดล็อก'**
  String get sessionTimeout;

  /// No description provided for @biometrics.
  ///
  /// In th, this message translates to:
  /// **'สแกนลายนิ้วมือ / ใบหน้า'**
  String get biometrics;

  /// No description provided for @biometricsSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ใช้ลายนิ้วมือปลดล็อกควบคู่กับ PIN'**
  String get biometricsSubtitle;

  /// No description provided for @biometricsNotSupported.
  ///
  /// In th, this message translates to:
  /// **'อุปกรณ์นี้ไม่รองรับเซนเซอร์สแกนลายนิ้วมือ'**
  String get biometricsNotSupported;

  /// No description provided for @backup.
  ///
  /// In th, this message translates to:
  /// **'การสำรองข้อมูล'**
  String get backup;

  /// No description provided for @personalCloudBackup.
  ///
  /// In th, this message translates to:
  /// **'สำรองและกู้คืนข้อมูล'**
  String get personalCloudBackup;

  /// No description provided for @backupToJson.
  ///
  /// In th, this message translates to:
  /// **'สำรองข้อมูล JSON'**
  String get backupToJson;

  /// No description provided for @backupToJsonSubtitle.
  ///
  /// In th, this message translates to:
  /// **'สร้างไฟล์สำรองข้อมูลส่วนบุคคล นำไปเซฟลง Google Drive หรือเครื่องได้ทันที'**
  String get backupToJsonSubtitle;

  /// No description provided for @restoreFromJson.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนข้อมูลสำรอง'**
  String get restoreFromJson;

  /// No description provided for @restoreFromJsonSubtitle.
  ///
  /// In th, this message translates to:
  /// **'เลือกไฟล์สำรองข้อมูล (.json) เพื่อนำเข้าและกู้คืน'**
  String get restoreFromJsonSubtitle;

  /// No description provided for @exportRawDb.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกไฟล์ฐานข้อมูล (.db)'**
  String get exportRawDb;

  /// No description provided for @exportRawDbSubtitle.
  ///
  /// In th, this message translates to:
  /// **'สำรองไฟล์ SQLite เก็บไว้ในเครื่องหรือแชร์ออก'**
  String get exportRawDbSubtitle;

  /// No description provided for @exportDatabase.
  ///
  /// In th, this message translates to:
  /// **'ส่งออกสำเนาฐานข้อมูล (.db)'**
  String get exportDatabase;

  /// No description provided for @trashBin.
  ///
  /// In th, this message translates to:
  /// **'ถังขยะกู้คืนข้อมูล'**
  String get trashBin;

  /// No description provided for @trashBinSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ดูรายการหรือบัญชีที่ถูกลบ กู้คืน หรือลบถาวร (30 วัน)'**
  String get trashBinSubtitle;

  /// No description provided for @recurringTransactions.
  ///
  /// In th, this message translates to:
  /// **'รายการประจำอัตโนมัติ'**
  String get recurringTransactions;

  /// No description provided for @recurringRulesDesc.
  ///
  /// In th, this message translates to:
  /// **'ตั้งกฎสร้างรายการประจำอัตโนมัติ และดูพยากรณ์เงิน 30 วัน'**
  String get recurringRulesDesc;

  /// No description provided for @taxAndRemittance.
  ///
  /// In th, this message translates to:
  /// **'ภาษีและการเงินต่างประเทศ'**
  String get taxAndRemittance;

  /// No description provided for @taxPlanning.
  ///
  /// In th, this message translates to:
  /// **'วางแผนภาษี (ภ.ง.ด. 90/91)'**
  String get taxPlanning;

  /// No description provided for @taxPlanningDesc.
  ///
  /// In th, this message translates to:
  /// **'คำนวณภาษีขั้นบันได, หักค่าใช้จ่าย, ลดหย่อน, เปรียบเทียบปันผล'**
  String get taxPlanningDesc;

  /// No description provided for @foreignRemittance.
  ///
  /// In th, this message translates to:
  /// **'ติดตามเงินได้ต่างประเทศนำเข้าไทย'**
  String get foreignRemittance;

  /// No description provided for @foreignRemittanceDesc.
  ///
  /// In th, this message translates to:
  /// **'เกณฑ์ 180 วัน, ป.161/2566, ป.162/2566 เงินต้น/กำไร'**
  String get foreignRemittanceDesc;

  /// No description provided for @financialPlanning.
  ///
  /// In th, this message translates to:
  /// **'การวางแผนการเงินและระบบอัตโนมัติ'**
  String get financialPlanning;

  /// No description provided for @financialHealthDesc.
  ///
  /// In th, this message translates to:
  /// **'ประเมิน 8 ตัวชี้วัด, Run-rate สิ้นเดือน/สิ้นปี และคำแนะนำ'**
  String get financialHealthDesc;

  /// No description provided for @liabilitiesInsurance.
  ///
  /// In th, this message translates to:
  /// **'ทะเบียนหนี้สินและประกันภัย'**
  String get liabilitiesInsurance;

  /// No description provided for @liabilitiesInsuranceDesc.
  ///
  /// In th, this message translates to:
  /// **'จัดการภาระหนี้สิน ดอกเบี้ย และความคุ้มครองประกันภัย'**
  String get liabilitiesInsuranceDesc;

  /// No description provided for @categoriesManage.
  ///
  /// In th, this message translates to:
  /// **'จัดการหมวดหมู่'**
  String get categoriesManage;

  /// No description provided for @categoriesManageDesc.
  ///
  /// In th, this message translates to:
  /// **'สร้างหมวดหมู่ใหม่ กำหนดไอคอน และจัดหมวดหมู่'**
  String get categoriesManageDesc;

  /// No description provided for @financialReports.
  ///
  /// In th, this message translates to:
  /// **'รายงานทางการเงิน'**
  String get financialReports;

  /// No description provided for @financialReportsDesc.
  ///
  /// In th, this message translates to:
  /// **'สรุปรายเดือน/ปี, งบกระแสเงินสด, งบดุล, พอร์ต, ส่งออก Excel & PDF'**
  String get financialReportsDesc;

  /// No description provided for @cloudSyncTitle.
  ///
  /// In th, this message translates to:
  /// **'คลาวด์และนำเข้าข้อมูล'**
  String get cloudSyncTitle;

  /// No description provided for @importWizard.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าข้อมูล (Notion CSV)'**
  String get importWizard;

  /// No description provided for @importWizardSubtitle.
  ///
  /// In th, this message translates to:
  /// **'ตัดลิงก์ relation, ตรวจจับรายการซ้ำ, กฎภาษี สธ. พร้อม Rollback 1 คลิก'**
  String get importWizardSubtitle;

  /// No description provided for @googleDriveSync.
  ///
  /// In th, this message translates to:
  /// **'ซิงค์ข้อมูล Google Drive'**
  String get googleDriveSync;

  /// No description provided for @googleDriveSyncSubtitle.
  ///
  /// In th, this message translates to:
  /// **'สำรองและซิงค์ข้อมูลผ่าน Google Drive ส่วนตัวของคุณ ปลอดภัย 100%'**
  String get googleDriveSyncSubtitle;

  /// No description provided for @expense.
  ///
  /// In th, this message translates to:
  /// **'รายจ่าย'**
  String get expense;

  /// No description provided for @income.
  ///
  /// In th, this message translates to:
  /// **'รายรับ'**
  String get income;

  /// No description provided for @transfer.
  ///
  /// In th, this message translates to:
  /// **'โอนเงิน'**
  String get transfer;

  /// No description provided for @fromAccount.
  ///
  /// In th, this message translates to:
  /// **'จากบัญชี'**
  String get fromAccount;

  /// No description provided for @toAccount.
  ///
  /// In th, this message translates to:
  /// **'ไปยังบัญชี'**
  String get toAccount;

  /// No description provided for @selectAccount.
  ///
  /// In th, this message translates to:
  /// **'เลือกบัญชี'**
  String get selectAccount;

  /// No description provided for @category.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่'**
  String get category;

  /// No description provided for @amount.
  ///
  /// In th, this message translates to:
  /// **'จำนวนเงิน'**
  String get amount;

  /// No description provided for @note.
  ///
  /// In th, this message translates to:
  /// **'บันทึกช่วยจำ'**
  String get note;

  /// No description provided for @save.
  ///
  /// In th, this message translates to:
  /// **'บันทึก'**
  String get save;

  /// No description provided for @duplicateLast.
  ///
  /// In th, this message translates to:
  /// **'ทำซ้ำล่าสุด'**
  String get duplicateLast;

  /// No description provided for @usdAmountDestination.
  ///
  /// In th, this message translates to:
  /// **'ยอดเงินปลายทาง (USD)'**
  String get usdAmountDestination;

  /// No description provided for @remainingBudget.
  ///
  /// In th, this message translates to:
  /// **'เงินที่ใช้ได้เหลือเดือนนี้'**
  String get remainingBudget;

  /// No description provided for @netWorth.
  ///
  /// In th, this message translates to:
  /// **'สินทรัพย์สุทธิ'**
  String get netWorth;

  /// No description provided for @monthlyIncome.
  ///
  /// In th, this message translates to:
  /// **'รายรับเดือนนี้'**
  String get monthlyIncome;

  /// No description provided for @netSavings.
  ///
  /// In th, this message translates to:
  /// **'เงินออมสุทธิ'**
  String get netSavings;

  /// No description provided for @spendingByCategory.
  ///
  /// In th, this message translates to:
  /// **'สัดส่วนรายจ่ายเดือนนี้'**
  String get spendingByCategory;

  /// No description provided for @incomeExpenseTrends.
  ///
  /// In th, this message translates to:
  /// **'แนวโน้มรายรับ-รายจ่าย (6 เดือน)'**
  String get incomeExpenseTrends;

  /// No description provided for @availableToSpend.
  ///
  /// In th, this message translates to:
  /// **'เงินที่ใช้ได้ในเดือนนี้'**
  String get availableToSpend;

  /// No description provided for @budgetRemaining.
  ///
  /// In th, this message translates to:
  /// **'ของงบประมาณเดือนนี้'**
  String get budgetRemaining;

  /// No description provided for @viewAll.
  ///
  /// In th, this message translates to:
  /// **'ดูทั้งหมด'**
  String get viewAll;

  /// No description provided for @recentActivity.
  ///
  /// In th, this message translates to:
  /// **'บันทึกรายการล่าสุด'**
  String get recentActivity;

  /// No description provided for @holdings.
  ///
  /// In th, this message translates to:
  /// **'สินทรัพย์ที่ถือครอง'**
  String get holdings;

  /// No description provided for @realizedPnl.
  ///
  /// In th, this message translates to:
  /// **'กำไรที่รับรู้แล้ว'**
  String get realizedPnl;

  /// No description provided for @history.
  ///
  /// In th, this message translates to:
  /// **'ประวัติการซื้อ-ขาย'**
  String get history;

  /// No description provided for @projects.
  ///
  /// In th, this message translates to:
  /// **'โครงการ'**
  String get projects;

  /// No description provided for @cashAndBank.
  ///
  /// In th, this message translates to:
  /// **'เงินสดและธนาคาร'**
  String get cashAndBank;

  /// No description provided for @creditCards.
  ///
  /// In th, this message translates to:
  /// **'บัตรเครดิต'**
  String get creditCards;

  /// No description provided for @foreignCurrency.
  ///
  /// In th, this message translates to:
  /// **'สกุลเงินต่างประเทศ'**
  String get foreignCurrency;

  /// No description provided for @morningGreeting.
  ///
  /// In th, this message translates to:
  /// **'สวัสดีตอนเช้า ☀️'**
  String get morningGreeting;

  /// No description provided for @afternoonGreeting.
  ///
  /// In th, this message translates to:
  /// **'สวัสดีตอนบ่าย 🌤️'**
  String get afternoonGreeting;

  /// No description provided for @eveningGreeting.
  ///
  /// In th, this message translates to:
  /// **'สวัสดีตอนเย็น 🌙'**
  String get eveningGreeting;

  /// No description provided for @addExpense.
  ///
  /// In th, this message translates to:
  /// **'+ บันทึกรายจ่าย'**
  String get addExpense;

  /// No description provided for @addIncome.
  ///
  /// In th, this message translates to:
  /// **'+ บันทึกรายรับ'**
  String get addIncome;

  /// No description provided for @monthlyOverview.
  ///
  /// In th, this message translates to:
  /// **'ภาพรวมประจำเดือน'**
  String get monthlyOverview;

  /// No description provided for @availableBalance.
  ///
  /// In th, this message translates to:
  /// **'ยอดเงินคงเหลือ'**
  String get availableBalance;

  /// No description provided for @creditCardDebt.
  ///
  /// In th, this message translates to:
  /// **'หนี้บัตรเครดิต'**
  String get creditCardDebt;

  /// No description provided for @currentBillingCycle.
  ///
  /// In th, this message translates to:
  /// **'รอบบิลปัจจุบัน'**
  String get currentBillingCycle;

  /// No description provided for @billedCycle.
  ///
  /// In th, this message translates to:
  /// **'ยอดเรียกเก็บแล้ว'**
  String get billedCycle;

  /// No description provided for @cancel.
  ///
  /// In th, this message translates to:
  /// **'ยกเลิก'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In th, this message translates to:
  /// **'ยืนยัน'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In th, this message translates to:
  /// **'ปิด'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In th, this message translates to:
  /// **'ลบ'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In th, this message translates to:
  /// **'แก้ไข'**
  String get edit;

  /// No description provided for @success.
  ///
  /// In th, this message translates to:
  /// **'สำเร็จ'**
  String get success;

  /// No description provided for @error.
  ///
  /// In th, this message translates to:
  /// **'เกิดข้อผิดพลาด'**
  String get error;

  /// No description provided for @confirmRestoreTitle.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันการกู้คืนข้อมูล'**
  String get confirmRestoreTitle;

  /// No description provided for @confirmRestoreContent.
  ///
  /// In th, this message translates to:
  /// **'การกู้คืนข้อมูลจะนำเข้ารายการและบัญชีจากไฟล์สำรองข้อมูล (.json) และอัปเดตลงในฐานข้อมูลเครื่องนี้ ต้องการดำเนินการต่อหรือไม่?'**
  String get confirmRestoreContent;

  /// No description provided for @restoreSuccess.
  ///
  /// In th, this message translates to:
  /// **'กู้คืนข้อมูลสำเร็จ: {accounts} บัญชี, {transactions} รายการ'**
  String restoreSuccess(int accounts, int transactions);

  /// No description provided for @exportSuccess.
  ///
  /// In th, this message translates to:
  /// **'ดาวน์โหลด / ส่งออกไฟล์สำรองข้อมูลสำเร็จ สามารถบันทึกลง Google Drive ของคุณได้เลย'**
  String get exportSuccess;

  /// No description provided for @appVersionFooter.
  ///
  /// In th, this message translates to:
  /// **'OURS v1.0.0\nOur money, our journey.'**
  String get appVersionFooter;

  /// No description provided for @masterBudget.
  ///
  /// In th, this message translates to:
  /// **'MASTER BUDGET'**
  String get masterBudget;

  /// No description provided for @availableToSpendLumi.
  ///
  /// In th, this message translates to:
  /// **'เงินที่ใช้ได้ในเดือนนี้ 🌸'**
  String get availableToSpendLumi;

  /// No description provided for @availableToSpendVault.
  ///
  /// In th, this message translates to:
  /// **'เหลือให้ใช้ได้'**
  String get availableToSpendVault;

  /// No description provided for @daysRemainingInCycle.
  ///
  /// In th, this message translates to:
  /// **'{days} วันที่เหลือในรอบเดือน'**
  String daysRemainingInCycle(int days);

  /// No description provided for @fromBudget.
  ///
  /// In th, this message translates to:
  /// **'จากงบ {amount}'**
  String fromBudget(String amount);

  /// No description provided for @ofTotalMonthlyBudget.
  ///
  /// In th, this message translates to:
  /// **'เหลือ {percent}% ของงบประมาณรวมทั้งเดือน'**
  String ofTotalMonthlyBudget(int percent);

  /// No description provided for @usedSoFar.
  ///
  /// In th, this message translates to:
  /// **'ใช้ไปแล้ว'**
  String get usedSoFar;

  /// No description provided for @fromTotalBudget.
  ///
  /// In th, this message translates to:
  /// **'จากงบรวม'**
  String get fromTotalBudget;

  /// No description provided for @spendingProgress.
  ///
  /// In th, this message translates to:
  /// **'ความคืบหน้าการใช้เงิน'**
  String get spendingProgress;

  /// No description provided for @percentUsed.
  ///
  /// In th, this message translates to:
  /// **'ใช้ไป {percent}%'**
  String percentUsed(int percent);

  /// No description provided for @noBudgetSet.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่ได้ตั้งงบประมาณเดือนนี้'**
  String get noBudgetSet;

  /// No description provided for @setBudgetAction.
  ///
  /// In th, this message translates to:
  /// **'ตั้งงบประมาณ'**
  String get setBudgetAction;

  /// No description provided for @financialOverview.
  ///
  /// In th, this message translates to:
  /// **'ภาพรวมสถานะการเงิน'**
  String get financialOverview;

  /// No description provided for @viewMonthlyReport.
  ///
  /// In th, this message translates to:
  /// **'ดูรายงานรายเดือน'**
  String get viewMonthlyReport;

  /// No description provided for @netWorthDesc.
  ///
  /// In th, this message translates to:
  /// **'ความมั่งคั่งสุทธิ (สินทรัพย์ - หนี้สิน)'**
  String get netWorthDesc;

  /// No description provided for @monthIncome.
  ///
  /// In th, this message translates to:
  /// **'รายรับ'**
  String get monthIncome;

  /// No description provided for @monthExpense.
  ///
  /// In th, this message translates to:
  /// **'รายจ่าย'**
  String get monthExpense;

  /// No description provided for @cashFlow.
  ///
  /// In th, this message translates to:
  /// **'กระแสเงินสด'**
  String get cashFlow;

  /// No description provided for @creditCardSummary.
  ///
  /// In th, this message translates to:
  /// **'บัตรเครดิต'**
  String get creditCardSummary;

  /// No description provided for @creditCardNoDebt.
  ///
  /// In th, this message translates to:
  /// **'ไม่มีหนี้ค้างชำระ ยอดเยี่ยมมาก! 🎉'**
  String get creditCardNoDebt;

  /// No description provided for @creditCardPending.
  ///
  /// In th, this message translates to:
  /// **'ยอดรอเรียกเก็บรอบบิลปัจจุบัน'**
  String get creditCardPending;

  /// No description provided for @noTransactionsThisMonth.
  ///
  /// In th, this message translates to:
  /// **'ยังไม่มีรายการในเดือนนี้'**
  String get noTransactionsThisMonth;

  /// No description provided for @noTransactionsDesc.
  ///
  /// In th, this message translates to:
  /// **'เริ่มจดบันทึกรายรับหรือรายจ่ายรายการแรกเพื่อติดตามการเงินของคุณ'**
  String get noTransactionsDesc;

  /// No description provided for @addFirstTransaction.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มรายการแรก'**
  String get addFirstTransaction;

  /// No description provided for @searchTransactions.
  ///
  /// In th, this message translates to:
  /// **'ค้นหาธุรกรรม'**
  String get searchTransactions;

  /// No description provided for @settingsAndSecurity.
  ///
  /// In th, this message translates to:
  /// **'การตั้งค่าและระบบความปลอดภัย'**
  String get settingsAndSecurity;

  /// No description provided for @savingsRateStatus.
  ///
  /// In th, this message translates to:
  /// **'อัตราการออมเดือนนี้อยู่ที่ {percent}%'**
  String savingsRateStatus(int percent);

  /// No description provided for @creditCardDueWarning.
  ///
  /// In th, this message translates to:
  /// **'บัตรเครดิตจะตัดรอบในอีกไม่กี่วัน ยอดรอตัด {amount}'**
  String creditCardDueWarning(String amount);

  /// No description provided for @budgetLowWarning.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณเดือนนี้เหลือต่ำกว่า 20% แล้ว โปรดระมัดระวังการใช้จ่าย'**
  String get budgetLowWarning;

  /// No description provided for @dailySpendRecommendation.
  ///
  /// In th, this message translates to:
  /// **'ใช้เงินได้เฉลี่ยวันละ {amount} จนถึงสิ้นเดือน'**
  String dailySpendRecommendation(String amount);

  /// No description provided for @budgetAndProjects.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณและโครงการ'**
  String get budgetAndProjects;

  /// No description provided for @budgetTab.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณ'**
  String get budgetTab;

  /// No description provided for @manageCategories.
  ///
  /// In th, this message translates to:
  /// **'จัดการหมวดหมู่'**
  String get manageCategories;

  /// No description provided for @expenseCategories.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่รายจ่าย'**
  String get expenseCategories;

  /// No description provided for @incomeCategories.
  ///
  /// In th, this message translates to:
  /// **'หมวดหมู่รายรับ'**
  String get incomeCategories;

  /// No description provided for @addNewCategory.
  ///
  /// In th, this message translates to:
  /// **'เพิ่มหมวดหมู่ใหม่'**
  String get addNewCategory;

  /// No description provided for @editCategory.
  ///
  /// In th, this message translates to:
  /// **'แก้ไขหมวดหมู่'**
  String get editCategory;

  /// No description provided for @hideCategory.
  ///
  /// In th, this message translates to:
  /// **'ซ่อนหมวดหมู่'**
  String get hideCategory;

  /// No description provided for @restoreCategory.
  ///
  /// In th, this message translates to:
  /// **'กู้คืน'**
  String get restoreCategory;

  /// No description provided for @defaultBadge.
  ///
  /// In th, this message translates to:
  /// **'ค่าเริ่มต้น'**
  String get defaultBadge;

  /// No description provided for @monthlyBudgetTab.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณรายเดือน'**
  String get monthlyBudgetTab;

  /// No description provided for @specialProjectsTab.
  ///
  /// In th, this message translates to:
  /// **'โครงการพิเศษ'**
  String get specialProjectsTab;

  /// No description provided for @summaryBudgetNonRollover.
  ///
  /// In th, this message translates to:
  /// **'สรุปงบประมาณรวมเดือนนี้ 🌸 (ไม่ Rollover)'**
  String get summaryBudgetNonRollover;

  /// No description provided for @budgetByCategory.
  ///
  /// In th, this message translates to:
  /// **'งบประมาณแยกตามหมวดหมู่'**
  String get budgetByCategory;

  /// No description provided for @tapItemToEdit.
  ///
  /// In th, this message translates to:
  /// **'แตะรายการเพื่อแก้ไข'**
  String get tapItemToEdit;

  /// No description provided for @budgetStatusNormal.
  ///
  /// In th, this message translates to:
  /// **'ปกติ'**
  String get budgetStatusNormal;

  /// No description provided for @budgetStatusExceeded.
  ///
  /// In th, this message translates to:
  /// **'เกินงบแล้ว!'**
  String get budgetStatusExceeded;

  /// No description provided for @budgetStatusWarning.
  ///
  /// In th, this message translates to:
  /// **'ใกล้เต็มงบ (≥ 80%)'**
  String get budgetStatusWarning;

  /// No description provided for @deleteBudget.
  ///
  /// In th, this message translates to:
  /// **'ลบงบประมาณ'**
  String get deleteBudget;

  /// No description provided for @confirmDeleteBudget.
  ///
  /// In th, this message translates to:
  /// **'ยืนยันลบงบประมาณ'**
  String get confirmDeleteBudget;

  /// No description provided for @leftBudget.
  ///
  /// In th, this message translates to:
  /// **'เหลือ'**
  String get leftBudget;

  /// No description provided for @totalBudgetLabel.
  ///
  /// In th, this message translates to:
  /// **'งบรวม'**
  String get totalBudgetLabel;

  /// No description provided for @spentLabel.
  ///
  /// In th, this message translates to:
  /// **'ใช้ไป'**
  String get spentLabel;

  /// No description provided for @budgetLabel.
  ///
  /// In th, this message translates to:
  /// **'งบ'**
  String get budgetLabel;

  /// No description provided for @tagline.
  ///
  /// In th, this message translates to:
  /// **'Our money, our journey.'**
  String get tagline;

  /// No description provided for @importNotionInvestStocks.
  ///
  /// In th, this message translates to:
  /// **'Notion ซื้อหุ้น US'**
  String get importNotionInvestStocks;

  /// No description provided for @importNotionInvestStocksSubtitle.
  ///
  /// In th, this message translates to:
  /// **'Invest-Stocks (O, JEPQ, NVDA…)'**
  String get importNotionInvestStocksSubtitle;

  /// No description provided for @importInvestSuccessTitle.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าหุ้นสำเร็จ!'**
  String get importInvestSuccessTitle;

  /// No description provided for @importInvestSuccessLot.
  ///
  /// In th, this message translates to:
  /// **'นำเข้าสำเร็จ: {count} lot'**
  String importInvestSuccessLot(int count);

  /// No description provided for @importInvestDuplicateSkipped.
  ///
  /// In th, this message translates to:
  /// **'ข้าม lot ซ้ำ: {count}'**
  String importInvestDuplicateSkipped(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'th'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'th':
      return AppLocalizationsTh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
