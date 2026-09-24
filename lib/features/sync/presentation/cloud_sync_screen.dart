import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/cloud_sync_provider.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/services/google_drive_sync_service.dart';
import '../../../core/services/web_db_helper/web_db_helper.dart';
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
    try {
      final syncService = ref.read(googleDriveSyncServiceProvider);
      final authService = ref.read(googleAuthServiceProvider);
      final status = await syncService.getStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () => const GoogleDriveSyncStatus(
          isConnected: false,
          isAutoSync: false,
          isWifiOnly: false,
          lastSyncTime: null,
          pendingCount: 0,
        ),
      );
      final backups = kIsWeb ? <PreSyncBackupInfo>[] : await syncService.getPreSyncBackups();
      final user = await authService.getCurrentUser().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (mounted) {
        setState(() {
          _status = status;
          _backups = backups;
          _googleUser = user;
        });
      }
    } catch (e, stack) {
      debugPrint('CloudSyncScreen _loadData error: $e\n$stack');
      if (mounted) {
        setState(() {
          _status = const GoogleDriveSyncStatus(
            isConnected: false,
            isAutoSync: false,
            isWifiOnly: false,
            lastSyncTime: null,
            pendingCount: 0,
            lastError: 'พร้อมใช้งาน',
          );
        });
      }
    }
  }

  String _formatDriveFolderDisplay(String? rawPath, bool isThai) {
    if (rawPath == null || rawPath.isEmpty) {
      return isThai ? 'ยังไม่ได้เชื่อมต่อโฟลเดอร์ Google Drive' : 'No Google Drive folder connected';
    }
    if (kIsWeb || rawPath.contains('Google Drive Cloud')) {
      return 'Google Drive Cloud (MyFinance_Backup)';
    }
    // Check if on mobile or contains default backup path
    if (rawPath.contains('GoogleDrive_Backup') || rawPath.startsWith('/data/user/') || rawPath.startsWith('/data/data/')) {
      final segments = rawPath.split(RegExp(r'[/\\]'));
      final folderName = segments.isNotEmpty && segments.last.isNotEmpty ? segments.last : 'MyFinance_Backup';
      return 'Google Drive: /$folderName';
    }
    return rawPath;
  }

  Future<void> _handleSignIn() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final authService = ref.read(googleAuthServiceProvider);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    try {
      final user = await authService.signIn();
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
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString();
        final msg = errText.contains('10') || errText.contains('sign_in_failed')
            ? (isThai
                ? 'บริการ Google Play ปฏิเสธการเข้าสู่ระบบ (ต้องใช้ SHA-1 ในระบบ Google) คุณยังสามารถกดเลือกโฟลเดอร์ Google Drive บนเครื่องเพื่อซิงค์ข้อมูลได้ตามปกติ'
                : 'Google Sign-In rejected (OAuth config required). You can still select your Google Drive folder directly below.')
            : (isThai ? 'เข้าสู่ระบบไม่สำเร็จ: $errText' : 'Sign in failed: $errText');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: VaultTheme.negative(context),
            duration: const Duration(seconds: 5),
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
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    try {
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: isThai
            ? 'เลือกโฟลเดอร์ Google Drive สำหรับจัดเก็บไฟล์สำรอง'
            : 'Select Google Drive folder for backup',
      );

      if (selectedDirectory != null && selectedDirectory.isNotEmpty) {
        final syncService = ref.read(googleDriveSyncServiceProvider);
        await syncService.setDriveFolder(selectedDirectory);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isThai ? 'เชื่อมต่อโฟลเดอร์: $selectedDirectory สำเร็จ' : 'Connected to folder: $selectedDirectory'),
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
            content: Text(isThai ? 'ไม่สามารถเปิดตัวเลือกโฟลเดอร์ได้: $e' : 'Could not open folder picker: $e'),
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
                '🛡️ เพื่อความปลอดภัย ระบบจะสร้างไฟล์สำรองฉุกเฉิน (Safety Backup) ให้คุณโดยอัตโนมัติก่อนเขียนทับเสมอ'
              : 'Data from Google Drive will replace the current local database.\n\n'
                '🛡️ For safety, an automatic Safety Backup will be created before restoring.',
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

  Future<void> _handleConnectDriveScope() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    setState(() => _isLoading = true);
    try {
      final authService = ref.read(googleAuthServiceProvider);
      final granted = await authService.requestDriveScopeOnWeb();
      if (!mounted) return;
      if (granted) {
        await _loadData();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เชื่อมต่อ Google Drive สำเร็จเรียบร้อย' : 'Google Drive connected successfully'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ยังไม่ได้รับการอนุญาตสิทธิ์ Google Drive' : 'Google Drive permission was not granted'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการเชื่อมต่อ: $e' : 'Connection error: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndRestoreDbFile() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (!mounted) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.file_upload_outlined, color: Colors.teal),
              const SizedBox(width: 8),
              Text(isThai ? 'กู้คืนจากไฟล์ฐานข้อมูล?' : 'Restore Database File?'),
            ],
          ),
          content: Text(
            isThai
                ? 'คุณต้องการนำเข้าไฟล์ "${file.name}" เพื่อใช้เป็นฐานข้อมูลหลักหรือไม่?\n\n'
                  '🛡️ เพื่อความปลอดภัย ข้อมูลเดิมจะถูกสำรองไว้ก่อนเสมอ'
                : 'Replace current database with "${file.name}"?\n\n'
                  '🛡️ A safety backup will be created before restoring.',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(isThai ? 'ยืนยันกู้คืน' : 'Confirm Restore'),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      setState(() => _isLoading = true);
      final syncService = ref.read(googleDriveSyncServiceProvider);
      final GoogleDriveSyncResult res;

      if (file.bytes != null && file.bytes!.isNotEmpty) {
        res = await syncService.restoreFromDatabaseBytes(file.bytes!);
      } else if (file.path != null && file.path!.isNotEmpty) {
        res = await syncService.restoreFromDatabasePath(file.path!);
      } else {
        res = GoogleDriveSyncResult(
          success: false,
          message: isThai ? 'ไม่สามารถอ่านเนื้อหาไฟล์ได้' : 'Could not read file data',
          timestamp: DateTime.now(),
        );
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      await _loadData();

      if (!mounted) return;
      final posColor = VaultTheme.positive(context);
      final negColor = VaultTheme.negative(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(res.message),
          backgroundColor: res.success ? posColor : negColor,
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการเลือกไฟล์: $e' : 'Error selecting file: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<void> _exportLocalDbFileWeb() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    try {
      final bytes = await exportWebDatabase();
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isThai ? 'ไม่พบข้อมูลฐานข้อมูลในเบราว์เซอร์' : 'No database found in browser storage'),
              backgroundColor: VaultTheme.negative(context),
            ),
          );
        }
        return;
      }
      final nowStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      downloadFileWeb(bytes, 'myfinance_vault_$nowStr.db');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ดาวน์โหลดไฟล์ฐานข้อมูลสำรองสำเร็จเรียบร้อย' : 'Database backup downloaded successfully'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการส่งออกไฟล์: $e' : 'Export failed: $e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
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
                // 1. Google Account Card
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
                                    : (isThai ? 'เชื่อมต่อ Google Drive เพื่อสำรองข้อมูล' : 'Connect Google Drive for cloud backup'),
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_googleUser != null)
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            onPressed: _handleSignOut,
                            child: Text(
                              isThai ? 'ออกจากระบบ' : 'Sign Out',
                              style: const TextStyle(color: Colors.red, fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                          )
                        else
                          FilledButton.tonal(
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                            onPressed: _handleSignIn,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.login, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  isThai ? 'เข้าสู่ระบบ' : 'Sign In',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Main Status Card with Action Buttons
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
                                    : (_googleUser != null
                                        ? Colors.blue.withValues(alpha: 0.15)
                                        : Colors.orange.withValues(alpha: 0.15)),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _status!.isConnected
                                    ? Icons.cloud_done
                                    : (_googleUser != null ? Icons.cloud_queue : Icons.cloud_off),
                                size: 28,
                                color: _status!.isConnected
                                    ? Colors.teal
                                    : (_googleUser != null ? Colors.blueAccent : Colors.orange),
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
                                        : (_googleUser != null
                                            ? (isThai ? 'เข้าสู่ระบบแล้ว (รอสิทธิ์ Drive)' : 'Signed In (Pending Drive Scope)')
                                            : (isThai ? 'ยังไม่ได้เชื่อมต่อ Google Drive' : 'Google Drive Disconnected')),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: VaultTheme.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _status!.isConnected
                                        ? _formatDriveFolderDisplay(_status!.driveFolderPath, isThai)
                                        : (_googleUser != null
                                            ? (isThai ? 'แตะ "เชื่อมต่อสิทธิ์ Drive" หรือกด "ดึงจาก Drive" ด้านล่าง' : 'Tap "Authorize Drive" or "Restore" below')
                                            : (isThai
                                                ? 'แตะเลือกโฟลเดอร์ หรือเข้าสู่ระบบ Google เพื่อเริ่มซิงค์'
                                                : 'Sign in or select a folder to start syncing')),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _status!.isConnected
                                          ? Colors.grey
                                          : (_googleUser != null ? Colors.blueAccent : Colors.orange),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Action banner to request Drive scope when signed into Google but scope not yet granted
                        if (!_status!.isConnected && _googleUser != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.blueAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isThai
                                        ? 'คุณเข้าสู่ระบบ Gmail แล้ว แตะเพื่ออนุญาตสิทธิ์เข้าถึง Google Drive'
                                        : 'Signed in. Tap to authorize Google Drive access.',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                FilledButton.tonal(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  onPressed: _isLoading ? null : _handleConnectDriveScope,
                                  child: Text(
                                    isThai ? 'เชื่อมต่อสิทธิ์' : 'Authorize',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Remote update alert badge
                        if (_status!.hasRemoteUpdate) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.4)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    isThai
                                        ? 'มีข้อมูลใหม่กว่าบน Google Drive แนะนำให้กดดึงข้อมูลล่าสุด'
                                        : 'A newer backup is available on Drive. Restore is recommended.',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const Divider(height: 24),

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
                                      : (isThai ? 'ยังไม่เคยซิงค์' : 'Never'),
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(isThai ? 'รายการรอซิงค์' : 'Pending', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

                        const SizedBox(height: 18),

                        // Action Buttons: Backup & Restore
                        Builder(
                          builder: (context) {
                            final canSync = !_isLoading && (_status!.isConnected || _googleUser != null);
                            return Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: VaultTheme.accent(context),
                                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: _isLoading
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                          )
                                        : const Icon(Icons.cloud_upload_outlined, size: 18),
                                    label: Text(
                                      isThai ? 'ส่งขึ้น Drive' : 'Backup to Drive',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                    onPressed: canSync ? _uploadToGoogleDrive : null,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    icon: const Icon(Icons.cloud_download_outlined, size: 18),
                                    label: Text(
                                      isThai ? 'ดึงจาก Drive' : 'Restore from Drive',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                    onPressed: canSync ? _confirmAndDownloadFromDrive : null,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Settings Section Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder_outlined, color: Colors.blueAccent),
                        title: Text(isThai ? 'โฟลเดอร์ Google Drive' : 'Google Drive Folder'),
                        subtitle: Text(
                          _formatDriveFolderDisplay(_status!.driveFolderPath, isThai),
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: kIsWeb
                            ? null
                            : OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: _pickDriveFolder,
                                child: Text(
                                  _status!.isConnected ? (isThai ? 'เปลี่ยน' : 'Change') : (isThai ? 'เลือก' : 'Select'),
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.sync),
                        title: Text(isThai ? 'ซิงค์อัตโนมัติ (Auto-Sync)' : 'Auto-Sync'),
                        subtitle: Text(
                          isThai ? 'ตรวจสอบและซิงค์กับ Google Drive เมื่อเปิดแอป' : 'Sync with Google Drive on startup',
                          style: const TextStyle(fontSize: 11.5),
                        ),
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
                        subtitle: Text(
                          isThai ? 'ประหยัดเน็ต ไม่ซิงค์ผ่านเน็ตมือถือ' : 'Save mobile data, Wi-Fi only',
                          style: const TextStyle(fontSize: 11.5),
                        ),
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
                          title: Text(
                            isThai ? 'ยกเลิกการเชื่อมต่อโฟลเดอร์' : 'Disconnect Folder',
                            style: const TextStyle(color: Colors.redAccent, fontSize: 13.5),
                          ),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text(isThai ? 'ยกเลิกการเชื่อมต่อ?' : 'Disconnect Folder?'),
                                content: Text(isThai
                                    ? 'การยกเลิกจะไม่ลบข้อมูลในเครื่องหรือใน Google Drive แต่จะหยุดการซิงค์ชั่วคราว'
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

                // 4. Direct Database File Backup & Restore (Local File / Offline)
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                        child: Text(
                          isThai ? 'จัดการไฟล์ฐานข้อมูล (.db / .sqlite)' : 'Direct Database File Options',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: VaultTheme.secondaryText(context),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.file_upload_outlined, color: Colors.teal),
                        title: Text(isThai ? 'กู้คืนจากไฟล์ฐานข้อมูลในเครื่อง' : 'Restore from Local File (.db)'),
                        subtitle: Text(
                          isThai
                              ? 'เลือกไฟล์ myfinance_vault.db หรือ .sqlite เพื่อนำเข้าข้อมูลทันที'
                              : 'Select a database file to restore directly into the app',
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        trailing: const Icon(Icons.chevron_right, size: 20),
                        onTap: _isLoading ? null : _pickAndRestoreDbFile,
                      ),
                      if (kIsWeb) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.file_download_outlined, color: Colors.blueAccent),
                          title: Text(isThai ? 'ดาวน์โหลดไฟล์สำรอง (.db) ลงเครื่อง' : 'Download Database Backup (.db)'),
                          subtitle: Text(
                            isThai
                                ? 'ส่งออกสำเนาไฟล์ฐานข้อมูล SQLite จากเบราว์เซอร์เก็บไว้ในเครื่อง'
                                : 'Download a SQLite database copy from browser storage',
                            style: const TextStyle(fontSize: 11.5),
                          ),
                          trailing: const Icon(Icons.download, size: 20),
                          onTap: _isLoading ? null : _exportLocalDbFileWeb,
                        ),
                      ],
                    ],
                  ),
                ),

                // 5. Collapsible Safety Backups Section (Clean & non-intrusive)
                if (_backups.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    color: VaultTheme.surface(context),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.shield_outlined, color: Colors.teal),
                        title: Text(
                          isThai ? 'ไฟล์สำรองฉุกเฉิน (Safety Backups)' : 'Safety Backups',
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${_backups.length} ${isThai ? "ไฟล์ที่เก็บไว้ก่อนซิงค์" : "pre-sync backups available"}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: _backups.map((b) {
                                final sizeKb = (b.sizeBytes / 1024).toStringAsFixed(1);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              dateFormat.format(b.createdAt),
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                            ),
                                            Text(
                                              '${b.fileName} ($sizeKb KB)',
                                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.orange,
                                          side: const BorderSide(color: Colors.orange),
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        ),
                                        onPressed: () => _confirmRollbackBackup(b),
                                        child: Text(isThai ? 'กู้คืน' : 'Rollback', style: const TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
