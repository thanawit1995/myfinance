import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/security/auth_provider.dart';
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
import '../../backup/presentation/backup_restore_screen.dart';
import '../../import/presentation/import_wizard_screen.dart';
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
    final isThai = widget.currentLocale.languageCode == 'th';

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text(
          isThai ? 'การตั้งค่า' : 'Setting',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: isThai ? 0.5 : 1.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // 1. Language & Appearance
          _buildSectionHeader(l10n?.languageAndAppearance ?? 'ภาษาและรูปลักษณ์'),
          _buildSectionCard([
            _buildDropdownRow<Locale>(
              icon: Icons.language_rounded,
              iconColor: Colors.blue,
              title: l10n?.language ?? 'ภาษา',
              value: widget.currentLocale,
              items: [
                DropdownMenuItem(value: const Locale('th'), child: Text(l10n?.thai ?? 'ไทย')),
                DropdownMenuItem(value: const Locale('en'), child: Text(l10n?.english ?? 'English')),
              ],
              onChanged: (loc) {
                if (loc != null) widget.onLocaleChanged(loc);
              },
            ),
            _buildDivider(),
            _buildDropdownRow<AppThemeStyle>(
              icon: Icons.style_rounded,
              iconColor: const Color(0xFFFF5C9D),
              title: l10n?.themeStyle ?? 'สไตล์ดีไซน์',
              value: widget.currentThemeStyle,
              items: const [
                DropdownMenuItem(
                  value: AppThemeStyle.vault,
                  child: Text('VAULT'),
                ),
                DropdownMenuItem(
                  value: AppThemeStyle.lumi,
                  child: Text('Lumi'),
                ),
              ],
              onChanged: (style) {
                if (style != null && widget.onThemeStyleChanged != null) {
                  widget.onThemeStyleChanged!(style);
                }
              },
            ),
            _buildDivider(),
            _buildDropdownRow<ThemeMode>(
              icon: Icons.palette_rounded,
              iconColor: Colors.purple,
              title: l10n?.themeMode ?? 'ธีมสีหน้าจอ',
              value: widget.currentThemeMode,
              items: [
                DropdownMenuItem(value: ThemeMode.light, child: Text(l10n?.themeLight ?? 'สว่าง')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text(l10n?.themeDark ?? 'มืด')),
                DropdownMenuItem(value: ThemeMode.system, child: Text(l10n?.themeSystem ?? 'ตามระบบ')),
              ],
              onChanged: (m) {
                if (m != null) widget.onThemeModeChanged(m);
              },
            ),
          ]),

          const SizedBox(height: 18),

          // 2. Security (PIN & Biometric)
          _buildSectionHeader(l10n?.security ?? 'ความปลอดภัยและรหัส PIN'),
          _buildSectionCard([
            _buildSwitchRow(
              icon: Icons.lock_outline_rounded,
              iconColor: Colors.indigo,
              title: l10n?.pinLockToggle ?? 'ล็อกแอปด้วยรหัส PIN',
              subtitle: _isPinLockEnabled
                  ? (l10n?.pinLockSubtitle ?? 'เปิดใช้งานการล็อกแอป')
                  : (l10n?.pinDisabled ?? 'ปิดใช้งาน'),
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
              _buildDivider(),
              _buildTile(
                icon: Icons.pin_rounded,
                iconColor: Colors.teal,
                title: l10n?.pinCode ?? 'รหัสผ่าน PIN 6 หลัก',
                subtitle: _isPinConfigured
                    ? (l10n?.pinConfigured ?? 'ตั้งรหัส PIN เรียบร้อยแล้ว')
                    : (l10n?.pinNotConfigured ?? 'ยังไม่ได้ตั้งรหัส PIN'),
                trailing: TextButton(
                  onPressed: _showSetupPinDialog,
                  child: Text(_isPinConfigured ? (l10n?.changePin ?? 'เปลี่ยน') : (l10n?.setupPin ?? 'ตั้งค่า')),
                ),
              ),
              _buildDivider(),
              _buildSwitchRow(
                icon: Icons.fingerprint_rounded,
                iconColor: Colors.amber.shade800,
                title: l10n?.biometrics ?? 'สแกนลายนิ้วมือ / ใบหน้า',
                subtitle: _isBiometricSupported
                    ? (l10n?.biometricsSubtitle ?? 'ใช้ลายนิ้วมือปลดล็อกควบคู่กับ PIN')
                    : (l10n?.biometricsNotSupported ?? 'อุปกรณ์นี้ไม่รองรับเซนเซอร์สแกนลายนิ้วมือ'),
                value: _isBiometricSupported && _isBiometricEnabled,
                onChanged: _isBiometricSupported
                    ? (val) async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await ref.read(authServiceProvider).setBiometricsEnabled(val);
                          if (mounted) setState(() => _isBiometricEnabled = val);
                        } catch (e) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
                            );
                          }
                        }
                      }
                    : null,
              ),
              _buildDivider(),
              _buildDropdownRow<int>(
                icon: Icons.timer_outlined,
                iconColor: Colors.deepPurple,
                title: l10n?.sessionTimeout ?? 'ระยะเวลาจำสถานะปลดล็อก',
                value: _sessionTimeoutMinutes,
                items: [
                  DropdownMenuItem(value: 5, child: Text('5 ${isThai ? 'นาที' : 'min'}')),
                  DropdownMenuItem(value: 15, child: Text('15 ${isThai ? 'นาที' : 'min'}')),
                  DropdownMenuItem(value: 30, child: Text('30 ${isThai ? 'นาที' : 'min'}')),
                  DropdownMenuItem(value: 60, child: Text('60 ${isThai ? 'นาที' : 'min'}')),
                ],
                onChanged: (val) async {
                  if (val != null) {
                    await ref.read(authServiceProvider).setSessionTimeoutMinutes(val);
                    setState(() => _sessionTimeoutMinutes = val);
                  }
                },
              ),
            ],
          ]),

          const SizedBox(height: 18),

          // 3. Financial Planning & Tools
          _buildSectionHeader(l10n?.financialPlanning ?? 'การวางแผนการเงินและระบบอัตโนมัติ'),
          _buildSectionCard([
            _buildTile(
              icon: Icons.health_and_safety_rounded,
              iconColor: Colors.teal,
              title: l10n?.financialHealth ?? 'สุขภาพการเงินและพยากรณ์เงิน',
              subtitle: l10n?.financialHealthDesc ?? 'ประเมิน 8 ตัวชี้วัด, Run-rate สิ้นเดือน และคำแนะนำ',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FinancialHealthScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.credit_card_off_rounded,
              iconColor: Colors.deepOrange,
              title: l10n?.liabilitiesInsurance ?? 'ทะเบียนหนี้สินและประกันภัย',
              subtitle: l10n?.liabilitiesInsuranceDesc ?? 'จัดการภาระหนี้สิน ดอกเบี้ย และความคุ้มครองประกันภัย',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LiabilitiesInsuranceScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.repeat_rounded,
              iconColor: Colors.blue,
              title: l10n?.recurringTransactions ?? 'รายการประจำอัตโนมัติ',
              subtitle: l10n?.recurringRulesDesc ?? 'ตั้งกฎสร้างรายการประจำ และดูพยากรณ์เงิน 30 วัน',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RecurringRulesScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.category_rounded,
              iconColor: Colors.purple,
              title: l10n?.categoriesManage ?? 'จัดการหมวดหมู่',
              subtitle: l10n?.categoriesManageDesc ?? 'สร้างหมวดหมู่ใหม่ กำหนดไอคอน และจัดหมวดหมู่',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CategoriesScreen()),
                );
              },
            ),
          ]),

          const SizedBox(height: 18),

          // 4. Tax & Financial Reports
          _buildSectionHeader(l10n?.taxAndRemittance ?? 'ภาษีและการเงินต่างประเทศ'),
          _buildSectionCard([
            _buildTile(
              icon: Icons.calculate_rounded,
              iconColor: Colors.indigo,
              title: l10n?.taxPlanning ?? 'วางแผนภาษี (ภ.ง.ด. 90/91)',
              subtitle: l10n?.taxPlanningDesc ?? 'คำนวณภาษีขั้นบันได, หักค่าใช้จ่าย, ลดหย่อน, เปรียบเทียบปันผล',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TaxScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.flight_takeoff_rounded,
              iconColor: Colors.teal,
              title: l10n?.foreignRemittance ?? 'ติดตามเงินได้ต่างประเทศ',
              subtitle: l10n?.foreignRemittanceDesc ?? 'เกณฑ์ 180 วัน, ป.161/2566, ป.162/2566 เงินต้น/กำไร',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ForeignRemittanceScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.assessment_rounded,
              iconColor: Colors.blueAccent,
              title: l10n?.financialReports ?? 'รายงานทางการเงิน',
              subtitle: l10n?.financialReportsDesc ?? 'สรุปรายเดือน/ปี, งบกระแสเงินสด, งบดุล, ส่งออก Excel & PDF',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ReportsScreen()),
                );
              },
            ),
          ]),

          const SizedBox(height: 18),

          // 5. Backup & Restore (Local File Backup)
          _buildSectionHeader(isThai ? 'ข้อมูลและการสำรองข้อมูล' : 'Data & Backup'),
          _buildSectionCard([
            _buildTile(
              icon: Icons.backup_rounded,
              iconColor: Colors.teal,
              title: isThai ? 'สำรองและกู้คืนข้อมูล (Backup & Restore)' : 'Backup & Restore',
              subtitle: isThai
                  ? 'ส่งออกไฟล์สำรอง, กู้คืนข้อมูลจากไฟล์ (.db) พร้อมพรีวิวสรุปข้อมูลก่อนกู้คืน'
                  : 'Export & share backup, restore from file (.db) with preview summary',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.upload_file_rounded,
              iconColor: const Color(0xFF2E7D32),
              title: isThai ? 'นำเข้าข้อมูลจาก Notion CSV' : 'Import from Notion CSV',
              subtitle: isThai
                  ? 'นำเข้าไฟล์รายจ่าย, รายรับการแพทย์ และหุ้นสหรัฐฯ พร้อมตัด Relation ลิงก์'
                  : 'Import expenses, healthcare incomes, and US stocks from Notion export',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ImportWizardScreen()),
                );
              },
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.delete_outline_rounded,
              iconColor: Colors.orange,
              title: l10n?.trashBin ?? (isThai ? 'ถังขยะกู้คืนข้อมูล' : 'Trash Bin'),
              subtitle: l10n?.trashBinSubtitle ?? (isThai ? 'ดูรายการหรือบัญชีที่ถูกลบ กู้คืน หรือลบถาวร (30 วัน)' : 'View, restore, or permanently delete items (30 days)'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const TrashBinScreen()),
                );
              },
            ),
          ]),

          const SizedBox(height: 28),

          // App version info
          Center(
            child: Text(
              l10n?.appVersionFooter ?? 'OURS v1.0.0\nOur money, our journey.',
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 12,
                height: 1.5,
                color: VaultTheme.secondaryText(context),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: VaultTheme.fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 13,
          letterSpacing: 0.3,
          color: VaultTheme.secondaryText(context),
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: VaultTheme.surface(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultTheme.border(context), width: 0.8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildIconBadge(IconData icon, Color color) {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 20, color: color),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 0.6,
      indent: 66,
      endIndent: 16,
      color: VaultTheme.border(context),
    );
  }

  Widget _buildDropdownRow<T>({
    required IconData icon,
    required Color iconColor,
    required String title,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildIconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontFamily: VaultTheme.fontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: VaultTheme.primaryText(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: VaultTheme.background(context),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: VaultTheme.border(context), width: 0.6),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                isDense: true,
                style: TextStyle(
                  fontFamily: VaultTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: VaultTheme.primaryText(context),
                ),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _buildIconBadge(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: VaultTheme.fontFamily,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: VaultTheme.primaryText(context),
                  ),
                ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 12,
                      color: VaultTheme.secondaryText(context),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            activeThumbColor: VaultTheme.accent(context),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildIconBadge(icon, iconColor),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: VaultTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: VaultTheme.primaryText(context),
                    ),
                  ),
                  if (subtitle != null && subtitle.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: VaultTheme.fontFamily,
                        fontSize: 12,
                        color: VaultTheme.secondaryText(context),
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            trailing ?? Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: VaultTheme.mutedText(context),
            ),
          ],
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
}
