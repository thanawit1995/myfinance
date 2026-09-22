import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/cloud_sync_provider.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/services/google_drive_sync_service.dart';
import '../../../core/theme/vault_theme.dart';

class CloudSyncScreen extends ConsumerStatefulWidget {
  const CloudSyncScreen({super.key});

  @override
  ConsumerState<CloudSyncScreen> createState() => _CloudSyncScreenState();
}

class _CloudSyncScreenState extends ConsumerState<CloudSyncScreen> {
  bool _isLoading = false;
  GoogleDriveSyncStatus? _status;
  List<PreSyncBackupInfo> _backups = [];
  GoogleAuthUser? _googleUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final authService = ref.read(googleAuthServiceProvider);
    final status = await syncService.getStatus();
    final backups = await syncService.getPreSyncBackups();
    final user = await authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _status = status;
        _backups = backups;
        _googleUser = user;
      });
    }
  }

  Future<String?> _promptGmailInput(BuildContext context) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final emailController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'เข้าสู่ระบบ Gmail สำหรับ Google Drive' : 'Gmail Login for Google Drive'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isThai
                ? 'กรุณากรอกอีเมล Gmail ของคุณเพื่อใช้สำรองข้อมูลไปยัง Google Drive:'
                : 'Enter your Gmail address to back up data to Google Drive:'),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Gmail / Google Account',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, emailController.text.trim()),
            child: Text(isThai ? 'บันทึก' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignIn() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final authService = ref.read(googleAuthServiceProvider);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    try {
      GoogleAuthUser? user;
      if (authService.isSupportedPlatform) {
        try {
          user = await authService.signIn();
        } catch (e) {
          debugPrint('Native Google sign-in fallback: $e');
        }
      }

      if (user != null) {
        await syncService.detectOrGetDriveFolder();
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isThai ? 'เข้าสู่ระบบด้วย ${user.email} สำเร็จ' : 'Signed in as ${user.email}'),
              backgroundColor: VaultTheme.positive(context),
            ),
          );
        }
      } else {
        if (!mounted) return;
        final entered = await _promptGmailInput(context);
        if (entered != null && entered.isNotEmpty) {
          await authService.saveManualEmail(entered);
          await syncService.detectOrGetDriveFolder();
          await _loadData();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isThai ? 'เชื่อมต่อบัญชี $entered เรียบร้อยแล้ว' : 'Connected account $entered'),
                backgroundColor: VaultTheme.positive(context),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาด: $e' : 'Error: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<void> _handleSignOut() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'ออกจากระบบ Google' : 'Sign Out of Google'),
        content: Text(isThai
            ? 'คุณต้องการออกจากระบบบัญชี ${_googleUser?.email ?? ""} ใช่หรือไม่?'
            : 'Sign out of account ${_googleUser?.email ?? ""}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ออกจากระบบ' : 'Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await ref.read(googleAuthServiceProvider).signOut();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isThai ? 'ออกจากระบบเรียบร้อยแล้ว' : 'Signed out successfully')),
        );
      }
    }
  }

  Future<void> _pickDriveFolder() async {
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'เลือกโฟลเดอร์ Google Drive (เช่น G:\\My Drive หรือโฟลเดอร์ที่คุณต้องการซิงค์)',
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        final syncService = ref.read(googleDriveSyncServiceProvider);
        await syncService.setDriveFolder(selectedDirectory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('เชื่อมต่อโฟลเดอร์: $selectedDirectory สำเร็จ'),
              backgroundColor: VaultTheme.positive(context),
            ),
          );
        }
        await _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ไม่สามารถเลือกโฟลเดอร์ได้: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<void> _uploadToGoogleDrive() async {
    setState(() => _isLoading = true);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final result = await syncService.uploadToGoogleDrive();

    if (!mounted) return;
    setState(() => _isLoading = false);
    await _loadData();

    if (!mounted) return;
    final posColor = VaultTheme.positive(context);
    final negColor = VaultTheme.negative(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? posColor : negColor,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _confirmAndDownloadFromDrive() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cloud_download, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(isThai ? 'ดึงข้อมูลจาก Google Drive?' : 'Restore from Google Drive?'),
          ],
        ),
        content: Text(
          isThai
              ? 'ข้อมูลจาก Google Drive จะถูกนำมาแทนที่ฐานข้อมูลปัจจุบันในเครื่อง\n\n'
                '🛡️ เพื่อความปลอดภัยสูงสุด ระบบจะสร้างไฟล์สำรองฉุกเฉิน (Safety Backup) ของข้อมูลปัจจุบันไว้ให้คุณโดยอัตโนมัติก่อนเขียนทับเสมอ'
              : 'Data from Google Drive will replace the current local database.\n\n'
                '🛡️ For maximum safety, an automatic Safety Backup will be created before restoring.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ยืนยันดึงข้อมูล' : 'Confirm Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final result = await syncService.downloadAndRestoreFromGoogleDrive();

    if (!mounted) return;
    setState(() => _isLoading = false);
    await _loadData();

    if (!mounted) return;
    final posColor = VaultTheme.positive(context);
    final negColor = VaultTheme.negative(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? posColor : negColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  Future<void> _confirmRollbackBackup(PreSyncBackupInfo backup) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm:ss', isThai ? 'th' : 'en_US');
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history, color: Colors.orangeAccent),
            const SizedBox(width: 8),
            Text(isThai ? 'กู้คืนไฟล์สำรองฉุกเฉิน?' : 'Restore Safety Backup?'),
          ],
        ),
        content: Text(
          isThai
              ? 'คุณต้องการย้อนกลับไปใช้ข้อมูล ณ วันที่:\n${dateFormat.format(backup.createdAt)} หรือไม่?\n\n'
                'ข้อมูลปัจจุบันจะถูกแทนที่ด้วยข้อมูลจากไฟล์สำรองนี้'
              : 'Roll back database to point in time:\n${dateFormat.format(backup.createdAt)}?\n\n'
                'Current data will be replaced with this backup.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isThai ? 'ยืนยันกู้คืน' : 'Confirm Restore'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final ok = await syncService.restoreFromPreSyncBackup(backup.path);

    if (!mounted) return;
    setState(() => _isLoading = false);
    await _loadData();

    if (!mounted) return;
    final posColor = VaultTheme.positive(context);
    final negColor = VaultTheme.negative(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? (isThai ? 'ย้อนกลับข้อมูลจากไฟล์สำรองสำเร็จเรียบร้อย' : 'Rolled back data successfully')
            : (isThai ? 'เกิดข้อผิดพลาดในการกู้คืน' : 'Failed to restore backup')),
        backgroundColor: ok ? posColor : negColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          'GOOGLE DRIVE SYNC',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: _status == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 0. Google Account Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: VaultTheme.surface(context),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: _googleUser != null
                                ? Colors.teal.withValues(alpha: 0.15)
                                : Colors.blue.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: _googleUser != null
                                ? Text(
                                    _googleUser!.email.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                                  )
                                : const Icon(Icons.account_circle_outlined, color: Colors.blue, size: 26),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _googleUser != null
                                    ? (_googleUser!.displayName ?? _googleUser!.email)
                                    : (isThai ? 'เข้าสู่ระบบด้วย Gmail' : 'Sign in with Gmail'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: VaultTheme.primaryText(context),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _googleUser != null
                                    ? _googleUser!.email
                                    : (isThai ? 'เชื่อมต่อบัญชี Google เพื่อสำรองข้อมูลไปยังไดรฟ์' : 'Connect Google account to back up data to Drive'),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (_googleUser != null)
                          TextButton(
                            onPressed: _handleSignOut,
                            child: Text(isThai ? 'ออกจากระบบ' : 'Sign Out', style: const TextStyle(color: Colors.red, fontSize: 12)),
                          )
                        else
                          FilledButton.tonalIcon(
                            style: FilledButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(Icons.login, size: 16),
                            label: Text(isThai ? 'เข้าสู่ระบบ' : 'Sign In'),
                            onPressed: _handleSignIn,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 1. Main Status Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: VaultTheme.surface(context),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _status!.isConnected
                                    ? Colors.teal.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _status!.isConnected ? Icons.cloud_done : Icons.cloud_off,
                                size: 30,
                                color: _status!.isConnected ? Colors.teal : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _status!.isConnected
                                        ? (isThai ? 'เชื่อมต่อ Google Drive เรียบร้อย' : 'Google Drive Connected')
                                        : (isThai ? 'ยังไม่ได้เชื่อมต่อ Google Drive' : 'Google Drive Disconnected'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                      color: VaultTheme.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _status!.isConnected
                                        ? (_status!.driveFolderPath ?? '')
                                        : (isThai
                                            ? 'ตรวจไม่พบโฟลเดอร์ Google Drive for Desktop ในตำแหน่งมาตรฐาน'
                                            : 'No standard Google Drive folder detected'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _status!.isConnected ? Colors.grey : Colors.orange,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Remote update alert badge
                        if (_status!.hasRemoteUpdate) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.amber, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isThai
                                        ? 'มีข้อมูลเวอร์ชันใหม่กว่าบน Google Drive (บันทึกล่าสุดเมื่อ ${_status!.remoteLastModified != null ? dateFormat.format(_status!.remoteLastModified!) : ""}) แนะนำให้กดดึงข้อมูลล่าสุด'
                                        : 'A newer version is available on Google Drive (last modified ${_status!.remoteLastModified != null ? dateFormat.format(_status!.remoteLastModified!) : ""}). Restoring is recommended.',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Divider(height: 28),

                        // Sync stats
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(isThai ? 'ซิงค์ล่าสุดเมื่อ' : 'Last Synced', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  _status!.lastSyncTime != null
                                      ? dateFormat.format(_status!.lastSyncTime!)
                                      : (isThai ? 'ยังไม่เคยซิงค์ข้อมูล' : 'Never synced'),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isThai ? 'รายการใหม่ในเครื่อง' : 'Pending Changes', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _status!.pendingCount > 0
                                        ? Colors.orange.withValues(alpha: 0.2)
                                        : VaultTheme.positive(context).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${_status!.pendingCount} ${isThai ? "รายการ" : "items"}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: _status!.pendingCount > 0 ? Colors.orange : VaultTheme.positive(context),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Action Buttons: Upload & Download
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: VaultTheme.accent(context),
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                      )
                                    : const Icon(Icons.cloud_upload_outlined, size: 20),
                                label: Text(
                                  isThai ? 'ส่งข้อมูลขึ้น Drive' : 'Backup to Drive',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                onPressed: (_isLoading || !_status!.isConnected) ? null : _uploadToGoogleDrive,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.cloud_download_outlined, size: 20),
                                label: Text(
                                  isThai ? 'ดึงข้อมูลจาก Drive' : 'Restore from Drive',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                                onPressed: (_isLoading || !_status!.isConnected) ? null : _confirmAndDownloadFromDrive,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Settings Section
                Text(isThai ? 'การตั้งค่า Google Drive' : 'Google Drive Settings', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder_outlined, color: Colors.blueAccent),
                        title: Text(isThai ? 'โฟลเดอร์ Google Drive' : 'Google Drive Folder'),
                        subtitle: Text(
                          _status!.isConnected
                              ? (_status!.driveFolderPath ?? (isThai ? 'ระบุแล้ว' : 'Specified'))
                              : (isThai ? 'ยังไม่ได้เลือกโฟลเดอร์ (แตะเพื่อเลือกโฟลเดอร์ไดรฟ์ G: หรือ Google Drive)' : 'No folder selected'),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: _pickDriveFolder,
                          child: Text(_status!.isConnected ? (isThai ? 'เปลี่ยน' : 'Change') : (isThai ? 'เลือกโฟลเดอร์' : 'Select')),
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.sync),
                        title: Text(isThai ? 'ซิงค์อัตโนมัติ (Auto-Sync)' : 'Auto-Sync'),
                        subtitle: Text(isThai ? 'ตรวจสอบและซิงค์ข้อมูลกับ Google Drive ทุกครั้งที่เปิดแอป' : 'Check and sync with Google Drive on startup'),
                        value: _status!.isAutoSync,
                        onChanged: (val) async {
                          await ref.read(googleDriveSyncServiceProvider).setAutoSyncEnabled(val);
                          _loadData();
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.wifi),
                        title: Text(isThai ? 'ซิงค์ผ่าน Wi-Fi เท่านั้น' : 'Sync over Wi-Fi only'),
                        subtitle: Text(isThai ? 'ประหยัดเน็ตมือถือ ไม่ซิงค์เมื่อใช้เครือข่าย Cellular' : 'Save mobile data, do not sync over cellular'),
                        value: _status!.isWifiOnly,
                        onChanged: (val) async {
                          await ref.read(googleDriveSyncServiceProvider).setWifiOnly(val);
                          _loadData();
                        },
                      ),
                      if (_status!.isConnected) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.link_off, color: Colors.redAccent),
                          title: Text(isThai ? 'ยกเลิกการเชื่อมต่อโฟลเดอร์' : 'Disconnect Folder', style: const TextStyle(color: Colors.redAccent)),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(isThai ? 'ยกเลิกการเชื่อมต่อ?' : 'Disconnect Folder?'),
                                content: Text(isThai
                                    ? 'การยกเลิกจะไม่ลบข้อมูลในเครื่องหรือใน Google Drive แต่จะหยุดการซิงค์ไว้ชั่วคราว'
                                    : 'Disconnecting will not delete any files, but sync will be paused.'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: Text(isThai ? 'ยืนยันยกเลิก' : 'Confirm'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref.read(googleDriveSyncServiceProvider).clearDriveFolder();
                              _loadData();
                            }
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 3. Safety Pre-Sync Backups Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(isThai ? 'ไฟล์สำรองฉุกเฉินก่อนซิงค์ (Safety Backups)' : 'Safety Pre-Sync Backups', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${_backups.length} ${isThai ? "ไฟล์" : "files"}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isThai
                      ? 'ทุกครั้งก่อนการดึงข้อมูลทับ ระบบจะสำรองข้อมูลในเครื่องไว้ที่นี่เสมอเพื่อให้คุณย้อนกลับได้ 100%'
                      : 'An automatic backup is created before every restore so you can always roll back.',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                if (_backups.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: VaultTheme.surface(context),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Center(
                        child: Text(
                          isThai
                              ? 'ยังไม่มีไฟล์สำรองฉุกเฉิน (จะสร้างอัตโนมัติเมื่อมีการดึงข้อมูลจาก Drive)'
                              : 'No safety backups yet (created automatically when restoring from Drive)',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _backups.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final b = _backups[idx];
                      final sizeKb = (b.sizeBytes / 1024).toStringAsFixed(1);
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        color: VaultTheme.surface(context),
                        child: ListTile(
                          dense: true,
                          leading: const Icon(Icons.shield_outlined, color: Colors.teal),
                          title: Text(
                            dateFormat.format(b.createdAt),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          subtitle: Text('${b.fileName} ($sizeKb KB)', style: const TextStyle(fontSize: 11)),
                          trailing: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            ),
                            onPressed: () => _confirmRollbackBackup(b),
                            child: Text(isThai ? 'กู้คืนจุดนี้' : 'Rollback', style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
    );
  }
}
