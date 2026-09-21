import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/auth_provider.dart';
import '../../../../core/services/backup_service.dart';
import '../../../../core/services/hybrid_backup_provider.dart';
import '../../../../core/theme/vault_theme.dart';
import '../../../../core/widgets/pin_lock_dialog.dart';
import '../../../../core/widgets/pin_setup_dialog.dart';
import '../../../../l10n/app_localizations.dart';
import '../../categories/presentation/categories_screen.dart';
import '../../financial_health/presentation/financial_health_screen.dart';
import '../../financial_health/presentation/liabilities_insurance_screen.dart';
import '../../recurring/presentation/recurring_rules_screen.dart';
import '../../tax/presentation/tax_screen.dart';
import '../../remittance/presentation/foreign_remittance_screen.dart';
import '../../../core/theme/app_theme_style.dart';
import '../../reports/presentation/reports_screen.dart';
import '../../import/presentation/import_wizard_screen.dart';
import '../../sync/presentation/cloud_sync_screen.dart';
import 'trash_bin_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  final Locale currentLocale;
  final ValueChanged<Locale> onLocaleChanged;
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final AppThemeStyle currentThemeStyle;
  final ValueChanged<AppThemeStyle>? onThemeStyleChanged;

  const SettingsScreen({
    super.key,
    required this.currentLocale,
    required this.onLocaleChanged,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
    this.currentThemeStyle = AppThemeStyle.vault,
    this.onThemeStyleChanged,
  });

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPinConfigured = false;
  bool _isPinLockEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricSupported = false;
  int _sessionTimeoutMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final auth = ref.read(authServiceProvider);
    final pinConfigured = await auth.isPinConfigured();
    final pinLockEnabled = await auth.isPinLockEnabled();
    final bioSupported = await auth.isBiometricsSupported();
    final bioEnabled = await auth.isBiometricsEnabled();
    final timeout = await auth.getSessionTimeoutMinutes();

    if (mounted) {
      setState(() {
        _isPinConfigured = pinConfigured;
        _isPinLockEnabled = pinLockEnabled;
        _isBiometricSupported = bioSupported;
        _isBiometricEnabled = bioEnabled;
        _sessionTimeoutMinutes = timeout;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          (l10n?.more ?? 'MORE').toUpperCase(),
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. Language & Appearance
          _buildSectionHeader(l10n?.languageAndAppearance ?? 'ภาษาและรูปลักษณ์'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n?.language ?? 'ภาษา (Language)'),
                  trailing: DropdownButton<Locale>(
                    value: widget.currentLocale,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: const Locale('th'), child: Text(l10n?.thai ?? 'ไทย (Thai)')),
                      DropdownMenuItem(value: const Locale('en'), child: Text(l10n?.english ?? 'English')),
                    ],
                    onChanged: (loc) {
                      if (loc != null) widget.onLocaleChanged(loc);
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.style_outlined),
                  title: Text(l10n?.themeStyle ?? 'สไตล์ดีไซน์ (Design Theme)'),
                  trailing: DropdownButton<AppThemeStyle>(
                    value: widget.currentThemeStyle,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(
                        value: AppThemeStyle.vault,
                        child: Text(widget.currentLocale.languageCode == 'en' ? AppThemeStyle.vault.displayNameEn : AppThemeStyle.vault.displayNameTh),
                      ),
                      DropdownMenuItem(
                        value: AppThemeStyle.lumi,
                        child: Text(widget.currentLocale.languageCode == 'en' ? AppThemeStyle.lumi.displayNameEn : AppThemeStyle.lumi.displayNameTh),
                      ),
                    ],
                    onChanged: (style) {
                      if (style != null && widget.onThemeStyleChanged != null) {
                        widget.onThemeStyleChanged!(style);
                      }
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(l10n?.themeMode ?? 'ธีมสีหน้าจอ'),
                  trailing: DropdownButton<ThemeMode>(
                    value: widget.currentThemeMode,
                    underline: const SizedBox.shrink(),
                    items: [
                      DropdownMenuItem(value: ThemeMode.light, child: Text(l10n?.themeLight ?? 'สว่าง (Light)')),
                      DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n?.themeDark ?? 'มืด (Dark)')),
                      DropdownMenuItem(value: ThemeMode.system, child: Text(l10n?.themeSystem ?? 'ตามระบบ (System)')),
                    ],
                    onChanged: (m) {
                      if (m != null) widget.onThemeModeChanged(m);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 2. Security (PIN & Biometric)
          _buildSectionHeader(l10n?.security ?? 'ความปลอดภัย (Security & PIN)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    Icons.lock_outline,
                    color: _isPinLockEnabled ? VaultTheme.accent(context) : null,
                  ),
                  title: Text(l10n?.pinLockToggle ?? 'ล็อกแอปด้วยรหัส PIN'),
                  subtitle: Text(
                    _isPinLockEnabled
                        ? (l10n?.pinLockSubtitle ?? 'เปิดใช้งานการล็อกแอป')
                        : (l10n?.pinDisabled ?? 'ปิดใช้งาน (เข้าแอปได้ทันทีโดยไม่ต้องใส่รหัส)'),
                  ),
                  value: _isPinLockEnabled,
                  onChanged: (val) async {
                    final auth = ref.read(authServiceProvider);
                    if (val) {
                      if (!_isPinConfigured) {
                        await _showSetupPinDialog();
                      } else {
                        await auth.setPinLockEnabled(true);
                        setState(() => _isPinLockEnabled = true);
                      }
                    } else {
                      // Confirm with PIN or Biometrics before turning OFF
                      final messenger = ScaffoldMessenger.of(context);
                      final unlocked = await PinLockDialog.show(context);
                      if (!mounted) return;
                      if (unlocked) {
                        await auth.setPinLockEnabled(false);
                        if (!mounted) return;
                        setState(() => _isPinLockEnabled = false);
                        messenger.showSnackBar(
                          SnackBar(content: Text(l10n?.pinDisabled ?? 'ปิดใช้งานระบบล็อก PIN แล้ว')),
                        );
                      }
                    }
                  },
                ),
                if (_isPinLockEnabled) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.pin),
                    title: Text(l10n?.pinCode ?? 'รหัสผ่าน PIN 6 หลัก'),
                    subtitle: Text(_isPinConfigured ? (l10n?.pinConfigured ?? 'ตั้งรหัส PIN เรียบร้อยแล้ว') : (l10n?.pinNotConfigured ?? 'ยังไม่ได้ตั้งรหัส PIN')),
                    trailing: TextButton(
                      onPressed: _showSetupPinDialog,
                      child: Text(_isPinConfigured ? (l10n?.changePin ?? 'เปลี่ยน PIN') : (l10n?.setupPin ?? 'ตั้งค่า PIN')),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    secondary: const Icon(Icons.fingerprint),
                    title: Text(l10n?.biometrics ?? 'สแกนลายนิ้วมือ / ใบหน้า'),
                    subtitle: Text(
                      _isBiometricSupported
                          ? (l10n?.biometricsSubtitle ?? 'ใช้ลายนิ้วมือปลดล็อกควบคู่กับ PIN')
                          : (l10n?.biometricsNotSupported ?? 'อุปกรณ์นี้ไม่รองรับเซนเซอร์สแกนลายนิ้วมือ'),
                    ),
                    value: _isBiometricSupported && _isBiometricEnabled,
                    onChanged: _isBiometricSupported
                        ? (val) async {
                            await ref.read(authServiceProvider).setBiometricsEnabled(val);
                            setState(() => _isBiometricEnabled = val);
                          }
                        : null,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(l10n?.sessionTimeout ?? 'ระยะเวลาจำสถานะปลดล็อก'),
                    subtitle: Text('$_sessionTimeoutMinutes ${widget.currentLocale.languageCode == 'en' ? 'min' : 'นาที'}'),
                    trailing: DropdownButton<int>(
                      value: _sessionTimeoutMinutes,
                      underline: const SizedBox.shrink(),
                      items: [
                        DropdownMenuItem(value: 5, child: Text('5 ${widget.currentLocale.languageCode == 'en' ? 'min' : 'นาที'}')),
                        DropdownMenuItem(value: 15, child: Text('15 ${widget.currentLocale.languageCode == 'en' ? 'min' : 'นาที'}')),
                        DropdownMenuItem(value: 30, child: Text('30 ${widget.currentLocale.languageCode == 'en' ? 'min' : 'นาที'}')),
                        DropdownMenuItem(value: 60, child: Text('60 ${widget.currentLocale.languageCode == 'en' ? 'min' : 'นาที'}')),
                      ],
                      onChanged: (val) async {
                        if (val != null) {
                          await ref.read(authServiceProvider).setSessionTimeoutMinutes(val);
                          setState(() => _sessionTimeoutMinutes = val);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Financial Planning & Automation (Phase 3)
          _buildSectionHeader(l10n?.financialPlanning ?? 'การวางแผนการเงินและระบบอัตโนมัติ'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.health_and_safety_outlined, color: Colors.teal),
                  title: Text(l10n?.financialHealth ?? 'สุขภาพการเงินและพยากรณ์เงิน (Financial Health)'),
                  subtitle: Text(l10n?.financialHealthDesc ?? 'ประเมิน 8 ตัวชี้วัด, Run-rate สิ้นเดือน/สิ้นปี และคำแนะนำ'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FinancialHealthScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.credit_card_off_outlined, color: Colors.deepOrange),
                  title: Text(l10n?.liabilitiesInsurance ?? 'ทะเบียนหนี้สินและกรมธรรม์ประกัน (Debts & Insurance)'),
                  subtitle: Text(l10n?.liabilitiesInsuranceDesc ?? 'จัดการภาระหนี้สิน ดอกเบี้ย และความคุ้มครองประกันภัย'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LiabilitiesInsuranceScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.repeat, color: Colors.blue),
                  title: Text(l10n?.recurringTransactions ?? 'รายการธุรกรรมอัตโนมัติ (Recurring Transactions)'),
                  subtitle: Text(l10n?.recurringRulesDesc ?? 'ตั้งกฎสร้างรายการประจำอัตโนมัติ และดูพยากรณ์เงิน 30 วัน'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RecurringRulesScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.category_outlined, color: Colors.purple),
                  title: Text(l10n?.categoriesManage ?? 'จัดการหมวดหมู่รายรับ-รายจ่าย (Categories)'),
                  subtitle: Text(l10n?.categoriesManageDesc ?? 'สร้างหมวดหมู่ใหม่ กำหนดไอคอน และจัดหมวดหมู่'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 4. Tax & Financial Reports (Phase 4)
          _buildSectionHeader(l10n?.taxAndRemittance ?? 'ภาษีและการเงินต่างประเทศ'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.calculate_outlined, color: Colors.indigo),
                  title: Text(l10n?.taxPlanning ?? 'วางแผนและคำนวณภาษี (ภ.ง.ด. 90/91)'),
                  subtitle: Text(l10n?.taxPlanningDesc ?? 'คำนวณภาษีขั้นบันได, หักค่าใช้จ่าย, ลดหย่อน, เปรียบเทียบปันผล'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TaxScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.flight_takeoff, color: Colors.teal),
                  title: Text(l10n?.foreignRemittance ?? 'ติดตามเงินได้ต่างประเทศ (Foreign Remittance)'),
                  subtitle: Text(l10n?.foreignRemittanceDesc ?? 'เกณฑ์ 180 วัน, ป.161/2566, ป.162/2566 เงินต้น/กำไร'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForeignRemittanceScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.assessment_outlined, color: Colors.blueAccent),
                  title: Text(l10n?.financialReports ?? 'ระบบรายงานทางการเงิน 7 แบบ (Financial Reports)'),
                  subtitle: Text(l10n?.financialReportsDesc ?? 'สรุปรายเดือน/ปี, งบกระแสเงินสด, งบดุล, พอร์ต, ส่งออก Excel & PDF'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ReportsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 5. Cloud Sync & Import (Phase 5)
          _buildSectionHeader(l10n?.cloudSyncTitle ?? 'คลาวด์และนำเข้าข้อมูล (Cloud Sync & Import)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.table_view_outlined, color: Colors.teal),
                  title: Text(l10n?.importWizard ?? 'นำเข้าข้อมูลจาก Notion CSV (Import Wizard)'),
                  subtitle: Text(l10n?.importWizardSubtitle ?? 'ตัดลิงก์ relation, ตรวจจับรายการซ้ำ, กฎภาษี สธ. พร้อม Rollback 1 คลิก'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ImportWizardScreen()),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_sync_outlined, color: Colors.teal),
                  title: Text(l10n?.googleDriveSync ?? 'ซิงค์ข้อมูลผ่าน Google Drive (Cloud Sync)'),
                  subtitle: Text(l10n?.googleDriveSyncSubtitle ?? 'สำรองและซิงค์ข้อมูลผ่าน Google Drive ส่วนตัวของคุณ ปลอดภัย 100%'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CloudSyncScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 6. Backup & Restore (Personal Cloud & Hybrid Backup)
          _buildSectionHeader(l10n?.personalCloudBackup ?? 'สำรองและกู้คืนข้อมูล (Personal Cloud & Backup)'),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
                  title: Text(l10n?.backupToJson ?? 'สำรองข้อมูลลง Google Drive / เครื่อง (JSON Backup)'),
                  subtitle: Text(l10n?.backupToJsonSubtitle ?? 'สร้างไฟล์สำรองข้อมูลส่วนบุคคล นำไปเซฟลง Google Drive, iCloud หรือเครื่องได้ทันที'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _handleExportHybridBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.cloud_download_outlined, color: Colors.teal),
                  title: Text(l10n?.restoreFromJson ?? 'กู้คืนข้อมูลจากไฟล์สำรอง (Restore Backup)'),
                  subtitle: Text(l10n?.restoreFromJsonSubtitle ?? 'เลือกไฟล์สำรองข้อมูล (.json) จาก Google Drive หรือเครื่องเพื่อกู้คืน'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _handleRestoreHybridBackup,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_file_outlined),
                  title: Text(l10n?.exportRawDb ?? 'ส่งออกไฟล์ฐานข้อมูลดิบ (.db)'),
                  subtitle: Text(l10n?.exportRawDbSubtitle ?? 'สำรองไฟล์ SQLite เก็บไว้ในเครื่องหรือแชร์ออก (Windows/Android)'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => BackupService.exportDatabase(context),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.orange),
                  title: Text(l10n?.trashBin ?? 'ถังขยะ (กู้คืนข้อมูล 30 วัน)'),
                  subtitle: Text(l10n?.trashBinSubtitle ?? 'ดูบัญชีที่ถูกลบ กู้คืน หรือลบถาวร'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const TrashBinScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // App version info
          Center(
            child: Text(
              l10n?.appVersionFooter ?? 'JP Money v1.0.0\nLocal-First Financial System',
              style: TextStyle(fontSize: 12, color: VaultTheme.secondaryText(context)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: VaultTheme.secondaryText(context),
        ),
      ),
    );
  }

  Future<void> _showSetupPinDialog() async {
    final wasChanging = _isPinConfigured;
    final success = await PinSetupDialog.show(context, isChanging: wasChanging);
    if (success && mounted) {
      setState(() {
        _isPinConfigured = true;
        _isPinLockEnabled = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(wasChanging ? 'เปลี่ยนรหัส PIN สำเร็จเรียบร้อยแล้ว' : 'ตั้งรหัส PIN และเปิดล็อกแอปเรียบร้อยแล้ว'),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    }
  }

  Future<void> _handleExportHybridBackup() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(widget.currentLocale.languageCode == 'en' ? 'Generating personal backup file...' : 'กำลังสร้างไฟล์สำรองข้อมูลส่วนบุคคล...')),
    );
    final success = await ref.read(hybridBackupServiceProvider).exportBackupFile();
    if (!mounted) return;
    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.exportSuccess ?? 'ส่งออกไฟล์สำรองข้อมูลสำเร็จ สามารถบันทึกลง Google Drive ของคุณได้เลย'),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(widget.currentLocale.languageCode == 'en' ? 'Failed to export backup file' : 'ไม่สามารถส่งออกไฟล์สำรองข้อมูลได้')),
      );
    }
  }

  Future<void> _handleRestoreHybridBackup() async {
    final l10n = AppLocalizations.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.confirmRestoreTitle ?? 'ยืนยันการกู้คืนข้อมูล'),
        content: Text(
          l10n?.confirmRestoreContent ?? 'การกู้คืนข้อมูลจะนำเข้ารายการและบัญชีจากไฟล์สำรองข้อมูล (.json) และอัปเดตลงในฐานข้อมูลเครื่องนี้\n\nต้องการดำเนินการต่อหรือไม่?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n?.cancel ?? 'ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultTheme.accent(context),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n?.restoreFromJson ?? 'เลือกไฟล์สำรอง'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text(widget.currentLocale.languageCode == 'en' ? 'Restoring data from file...' : 'กำลังกู้คืนข้อมูลจากไฟล์...')),
    );

    final result = await ref.read(hybridBackupServiceProvider).pickAndRestoreBackupFile();
    if (!mounted) return;

    if (result.success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n?.restoreSuccess(result.accountsCount, result.transactionsCount) ?? 'กู้คืนข้อมูลสำเร็จ: ${result.accountsCount} บัญชี, ${result.transactionsCount} รายการ'),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    } else if (result.message != 'ยกเลิกการเลือกไฟล์' && result.message != 'Cancelled file picker') {
      messenger.showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: VaultTheme.negative(context),
        ),
      );
    }
  }
}

