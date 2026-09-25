import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/database_provider.dart';
import '../../../core/services/backup_restore_service.dart';
import '../../../core/theme/vault_theme.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;
  int _currentAccountsCount = 0;
  int _currentTxCount = 0;
  int _currentDbSize = 0;
  List<SafetyBackupItem> _safetyBackups = [];
  String? _designatedFolder;
  List<RollingBackupItem> _rollingBackups = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final db = ref.read(databaseProvider);
      final service = ref.read(backupRestoreServiceProvider);

      final accounts = await db.accountsDao.getActiveAccounts();
      final txRow = await db.customSelect('SELECT count(*) as cnt FROM transactions WHERE deleted_at IS NULL').getSingleOrNull();
      final txCount = txRow?.data['cnt'] as int? ?? 0;

      final localDb = await service.getLocalDatabaseFile();
      int dbSize = 0;
      if (localDb != null && await localDb.exists()) {
        dbSize = await localDb.length();
      }

      final safetyBackups = await service.getSafetyBackups();
      final designatedFolder = await service.getDesignatedBackupDirectory();
      final rollingBackups = await service.getRollingBackupsInDesignatedDirectory();

      if (mounted) {
        setState(() {
          _currentAccountsCount = accounts.length;
          _currentTxCount = txCount;
          _currentDbSize = dbSize;
          _safetyBackups = safetyBackups;
          _designatedFolder = designatedFolder;
          _rollingBackups = rollingBackups;
        });
      }
    } catch (_) {}
  }

  Future<void> _handleSelectDesignatedFolder() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isThai
                ? 'บน Webapp เบราว์เซอร์ไม่อนุญาตให้เข้าถึงโฟลเดอร์ในเครื่อง กรุณาใช้ปุ่ม "ดาวน์โหลดไฟล์สำรอง" ด้านล่าง'
                : 'Folder selection is not supported in web browsers. Please use "Download Backup" below.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final selectedDir = await FilePicker.platform.getDirectoryPath(
        dialogTitle: isThai ? 'เลือกโฟลเดอร์สำหรับสำรองข้อมูล' : 'Select Backup Folder',
      );

      if (selectedDir == null || selectedDir.trim().isEmpty) return;

      setState(() => _isLoading = true);
      final service = ref.read(backupRestoreServiceProvider);
      final targetPath = await service.setDesignatedBackupDirectory(selectedDir);
      await _loadStats();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isThai
                ? 'ตั้งค่าโฟลเดอร์สำรองข้อมูลเรียบร้อยแล้ว: $targetPath'
                : 'Backup folder configured: $targetPath',
          ),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    } on UnimplementedError {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isThai
                  ? 'อุปกรณ์นี้ไม่รองรับการเข้าถึงโฟลเดอร์โดยตรง กรุณาใช้ปุ่มเลือกไฟล์สำรองด้านล่างแทน'
                  : 'Folder selection is not supported on this platform. Please pick files directly.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "เกิดข้อผิดพลาด: " : "Error: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleManualSyncNow() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    setState(() => _isLoading = true);
    try {
      final service = ref.read(backupRestoreServiceProvider);
      final path = await service.saveRollingBackup();
      await _loadStats();

      if (!mounted) return;
      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'บันทึกเวอร์ชั่นสำรองใหม่เรียบร้อยแล้ว' : 'Backup version saved successfully'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "สำรองไม่สำเร็จ: " : "Backup failed: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRestoreRollingVersion(RollingBackupItem item) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final service = ref.read(backupRestoreServiceProvider);

    setState(() => _isLoading = true);
    try {
      final inspection = await service.inspectBackupFile(
        item.path,
        name: item.fileName,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!inspection.isValid) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(isThai ? 'ไฟล์ไม่ถูกต้อง' : 'Invalid File'),
              ],
            ),
            content: Text(
              inspection.errorMessage ??
                  (isThai
                      ? 'ไฟล์สำรองนี้ไม่สมบูรณ์หรือไม่ใช่ฐานข้อมูล MyFinance ที่ถูกต้อง'
                      : 'This backup file is invalid or not a valid MyFinance database.'),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isThai ? 'ตกลง' : 'OK'),
              ),
            ],
          ),
        );
        return;
      }

      final confirmed = await _showPreviewAndConfirmDialog(inspection, isThai);
      if (confirmed != true) return;

      setState(() => _isLoading = true);
      final ok = await service.restoreDatabase(
        filePath: item.path,
        isThai: isThai,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        await _loadStats();
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.teal),
                const SizedBox(width: 8),
                Text(isThai ? 'กู้คืนข้อมูลสำเร็จ' : 'Restore Complete'),
              ],
            ),
            content: Text(
              isThai
                  ? 'กู้คืนข้อมูลจากเวอร์ชั่นที่เลือกเรียบร้อยแล้ว แนะนำให้ปิดและเปิดแอปใหม่อีกครั้งเพื่อให้ทุกหน้าแสดงผลสมบูรณ์'
                  : 'Data restored successfully from selected version. Please restart the app for all changes to take full effect.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isThai ? 'ตกลง' : 'OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการกู้คืน' : 'Failed to restore database'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "เกิดข้อผิดพลาด: " : "Error: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<void> _handleExport() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    setState(() => _isLoading = true);
    try {
      final service = ref.read(backupRestoreServiceProvider);
      final exportedPath = await service.exportAndShareBackup(isThai: isThai);

      if (!mounted) return;
      if (exportedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ส่งออกไฟล์สำรองสำเร็จเรียบร้อย' : 'Backup exported successfully'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "ส่งออกไม่สำเร็จ: " : "Export failed: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDirectDownload() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    setState(() => _isLoading = true);
    try {
      final service = ref.read(backupRestoreServiceProvider);
      final exportedPath = await service.downloadBackupDirectly(isThai: isThai);

      if (!mounted) return;
      if (exportedPath != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ดาวน์โหลดไฟล์สำรองเรียบร้อย' : 'Backup downloaded successfully'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
        _loadStats();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "ดาวน์โหลดไม่สำเร็จ: " : "Download failed: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePickAndRestore() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final service = ref.read(backupRestoreServiceProvider);

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db', 'sqlite'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      setState(() => _isLoading = true);

      // Safe access: on web, pickedFile.path throws UnimplementedError
      final safePath = kIsWeb ? '' : (pickedFile.path ?? '');

      // 1. Inspect file first to preview summary to user
      final inspection = await service.inspectBackupFile(
        safePath,
        bytes: pickedFile.bytes,
        name: pickedFile.name,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (!inspection.isValid) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Text(isThai ? 'ไฟล์ไม่ถูกต้อง' : 'Invalid File'),
              ],
            ),
            content: Text(
              inspection.errorMessage ?? (isThai
                  ? 'ไฟล์ที่เลือกไม่ใช่ฐานข้อมูล MyFinance ที่ถูกต้อง'
                  : 'Selected file is not a valid MyFinance database.'),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isThai ? 'ตกลง' : 'OK'),
              ),
            ],
          ),
        );
        return;
      }

      // 2. Show Preview and Confirmation Dialog
      final confirmed = await _showPreviewAndConfirmDialog(inspection, isThai);
      if (confirmed != true) return;

      // 3. Perform Restore
      setState(() => _isLoading = true);
      final ok = await service.restoreDatabase(
        filePath: kIsWeb ? null : pickedFile.path,
        bytes: pickedFile.bytes,
        isThai: isThai,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        await _loadStats();
        if (!mounted) return;
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.teal),
                const SizedBox(width: 8),
                Text(isThai ? 'กู้คืนข้อมูลสำเร็จ' : 'Restore Complete'),
              ],
            ),
            content: Text(
              isThai
                  ? 'นำเข้าข้อมูลจากไฟล์สำรองเรียบร้อยแล้ว แนะนำให้ปิดและเปิดแอปใหม่อีกครั้งเพื่อให้ทุกหน้าแสดงผลสมบูรณ์'
                  : 'Data restored successfully. Please restart the app for all changes to take full effect.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(isThai ? 'ตกลง' : 'OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการกู้คืน' : 'Failed to restore database'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${isThai ? "เกิดข้อผิดพลาด: " : "Error: "}$e'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    }
  }

  Future<bool?> _showPreviewAndConfirmDialog(BackupInspectionResult info, bool isThai) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');
    final sizeKb = (info.sizeBytes / 1024).toStringAsFixed(1);

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.preview_rounded, color: Colors.teal),
            const SizedBox(width: 8),
            Text(isThai ? 'พรีวิวข้อมูลในไฟล์สำรอง' : 'Backup File Preview'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isThai
                    ? 'ตรวจพบข้อมูลในไฟล์สำรองที่คุณเลือก ดังนี้:'
                    : 'Found following data inside the selected backup:',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 12),

              // Preview Box
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: VaultTheme.surface(context),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  children: [
                    _buildPreviewRow(
                      Icons.insert_drive_file_outlined,
                      isThai ? 'ชื่อไฟล์' : 'File Name',
                      info.fileName,
                      subtitle: '$sizeKb KB',
                    ),
                    const Divider(height: 16),
                    _buildPreviewRow(
                      Icons.account_balance_outlined,
                      isThai ? 'บัญชี' : 'Accounts',
                      '${info.totalAccounts} ${isThai ? "บัญชี" : "accounts"}',
                      subtitle: info.sampleAccountNames.isNotEmpty
                          ? info.sampleAccountNames.join(', ')
                          : null,
                    ),
                    const Divider(height: 16),
                    _buildPreviewRow(
                      Icons.receipt_long_outlined,
                      isThai ? 'รายการธุรกรรม' : 'Transactions',
                      '${info.totalTransactions} ${isThai ? "รายการ" : "items"}',
                    ),
                    const Divider(height: 16),
                    _buildPreviewRow(
                      Icons.event_available_outlined,
                      isThai ? 'บันทึกล่าสุด' : 'Latest Entry',
                      info.latestTransactionDate != null
                          ? dateFormat.format(info.latestTransactionDate!)
                          : (isThai ? 'ไม่พบวันที่' : 'None'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined, color: Colors.amber, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isThai
                            ? '🛡️ ระบบจะสร้างไฟล์สำรองฉุกเฉินให้อัตโนมัติก่อนเขียนทับเสมอ'
                            : '🛡️ A safety backup will be created automatically before overwriting.',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ยืนยันกู้คืนข้อมูล' : 'Confirm Restore'),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(IconData icon, String label, String value, {String? subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.teal),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _handleRollback(SafetyBackupItem item) async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isThai ? 'กู้คืนไฟล์สำรองฉุกเฉิน?' : 'Restore Safety Backup?'),
        content: Text(
          isThai
              ? 'คุณต้องการย้อนกลับไปใช้ข้อมูล ณ วันที่:\n${dateFormat.format(item.createdAt)} หรือไม่?'
              : 'Roll back database to:\n${dateFormat.format(item.createdAt)}?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(isThai ? 'ยกเลิก' : 'Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ยืนยันกู้คืน' : 'Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    final service = ref.read(backupRestoreServiceProvider);
    final ok = await service.rollbackSafetyBackup(item.path);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      await _loadStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isThai ? 'ย้อนกลับข้อมูลสำเร็จ' : 'Restored successfully'),
          backgroundColor: VaultTheme.positive(context),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final sizeKb = (_currentDbSize / 1024).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: VaultTheme.background(context),
      appBar: AppBar(
        backgroundColor: VaultTheme.surface(context),
        title: Text(
          isThai ? 'สำรองและกู้คืนข้อมูล' : 'BACKUP & RESTORE',
          style: TextStyle(
            fontFamily: VaultTheme.fontFamily,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: VaultTheme.primaryText(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // 1. Current Database Status Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  color: VaultTheme.surface(context),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.storage_rounded, size: 24, color: Colors.teal),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isThai ? 'ฐานข้อมูลปัจจุบันในเครื่อง' : 'Current Local Database',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: VaultTheme.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    isThai
                                        ? 'ข้อมูลถูกจัดเก็บไว้ในเครื่องของคุณอย่างปลอดภัย'
                                        : 'Data is stored securely on your local device',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text(isThai ? 'บัญชี' : 'Accounts', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  '$_currentAccountsCount ${isThai ? "บัญชี" : "accs"}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                            Column(
                              children: [
                                Text(isThai ? 'รายการธุรกรรม' : 'Transactions', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  '$_currentTxCount ${isThai ? "รายการ" : "items"}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(height: 24, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                            Column(
                              children: [
                                Text(isThai ? 'ขนาดไฟล์' : 'File Size', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  '$sizeKb KB',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // 2. Web Backup Card (if Webapp) OR Designated Backup Folder Card (if Native Desktop/Mobile)
                if (kIsWeb) ...[
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: VaultTheme.surface(context),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.cloud_done_rounded, size: 24, color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isThai ? 'การสำรองข้อมูลสำหรับ Webapp' : 'Webapp Backup & Restore',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: VaultTheme.primaryText(context),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      isThai
                                          ? 'ข้อมูลถูกเก็บในเบราว์เซอร์อย่างปลอดภัย สามารถดาวน์โหลดเก็บไว้หรือนำเข้าได้'
                                          : 'Data stored in browser storage. Download or restore anytime.',
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.share_rounded, size: 20),
                              label: Text(
                                isThai ? 'แชร์ / เลือกที่บันทึกไฟล์สำรอง (.db)' : 'Share / Save Backup File (.db)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              onPressed: _isLoading ? null : _handleExport,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.blue.shade700,
                                side: BorderSide(color: Colors.blue.shade400, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.file_download_outlined, size: 20),
                              label: Text(
                                isThai ? 'ดาวน์โหลดไฟล์สำรอง (.db) ลงเครื่องทันที' : 'Download Backup File (.db) Directly',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              onPressed: _isLoading ? null : _handleDirectDownload,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.purple.shade700,
                                side: BorderSide(color: Colors.purple.shade400, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.restore_page_outlined, size: 20),
                              label: Text(
                                isThai ? 'เลือกไฟล์สำรอง (.db) เพื่อกู้คืนข้อมูล' : 'Upload Backup File to Restore',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                              ),
                              onPressed: _isLoading ? null : _handlePickAndRestore,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.lightbulb_outline, size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isThai
                                        ? 'คำแนะนำ: บนมือถือ กดปุ่ม "แชร์ / เลือกที่บันทึก" เพื่อส่งเข้า Google Drive, LINE หรือเลือกโฟลเดอร์ในเครื่องได้ทันที\nส่วนบนคอมพิวเตอร์ หากต้องการให้เด้งถามโฟลเดอร์ปลายทางทุกครั้ง สามารถเปิด "ถามตำแหน่งที่จะบันทึกไฟล์ทุกครั้ง" ในการตั้งค่า Chrome/Edge ได้ครับ'
                                        : 'Tip: On mobile, tap "Share / Save Backup" to save directly to Drive, LINE, or select a device folder.\nOn desktop browser, enable "Ask where to save each file before downloading" in Chrome/Edge settings to always choose a folder.',
                                    style: const TextStyle(fontSize: 11.5, color: Colors.grey, height: 1.35),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // 2. Designated Backup Folder Card (Native Windows / Android)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: VaultTheme.surface(context),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (_designatedFolder != null ? Colors.teal : Colors.blue).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _designatedFolder != null ? Icons.folder_special_rounded : Icons.create_new_folder_outlined,
                                  size: 24,
                                  color: _designatedFolder != null ? Colors.teal : Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          isThai ? 'โฟลเดอร์สำรองข้อมูลอัตโนมัติ' : 'Auto-Backup Folder',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: VaultTheme.primaryText(context),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _designatedFolder != null
                                          ? (isThai
                                              ? 'ซิงค์สำรองอัตโนมัติเมื่อบันทึก/แก้ไข/ลบ (3 เวอร์ชั่น)'
                                              : 'Auto-syncs on transaction changes (keeps 3 versions)')
                                          : (isThai
                                              ? 'เลือกโฟลเดอร์ปลายทาง (เช่น ใน Google Drive, OneDrive) เพื่อเปิดใช้งาน'
                                              : 'Select target folder (e.g. in Google Drive or OneDrive) to enable'),
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (_designatedFolder != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: VaultTheme.background(context),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: VaultTheme.border(context)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.folder_open_rounded, size: 18, color: Colors.blueAccent),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _designatedFolder!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'monospace',
                                        color: VaultTheme.primaryText(context),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
                                  label: Text(isThai ? 'เปลี่ยนโฟลเดอร์' : 'Change Folder'),
                                  onPressed: _isLoading ? null : _handleSelectDesignatedFolder,
                                ),
                                const Spacer(),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  icon: const Icon(Icons.sync_rounded, size: 18),
                                  label: Text(
                                    isThai ? 'สำรองเวอร์ชั่นใหม่ตอนนี้' : 'Backup Now',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: _isLoading ? null : _handleManualSyncNow,
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.folder_open_rounded, size: 20),
                                label: Text(
                                  isThai ? 'เลือกโฟลเดอร์สำหรับสำรองข้อมูล' : 'Select Backup Folder',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                onPressed: _isLoading ? null : _handleSelectDesignatedFolder,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // 3. Rolling Backups Card (3 Latest Versions in Designated Folder)
                  if (_designatedFolder != null) ...[
                    const SizedBox(height: 18),
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      color: VaultTheme.surface(context),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withValues(alpha: 0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.history_toggle_off_rounded, size: 24, color: Colors.teal),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isThai ? 'เวอร์ชั่นสำรองในโฟลเดอร์ (เลือกกู้คืนได้ทันที)' : 'Backup Versions in Folder',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: VaultTheme.primaryText(context),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isThai
                                            ? 'แตะที่เวอร์ชั่นเพื่อพรีวิวและกู้คืนข้อมูลได้ทันที'
                                            : 'Tap any version to preview and restore',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_rollingBackups.isEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Text(
                                  isThai
                                      ? 'ยังไม่พบไฟล์สำรองในโฟลเดอร์นี้ ระบบจะเริ่มสำรองอัตโนมัติเมื่อมีการบันทึกธุรกรรม หรือกด "สำรองเวอร์ชั่นใหม่ตอนนี้" ด้านบน'
                                      : 'No backups in this folder yet. Automatic backups will occur when transactions change, or tap "Backup Now".',
                                  style: const TextStyle(fontSize: 12.5, color: Colors.grey),
                                ),
                              )
                            else
                              Column(
                                children: _rollingBackups.map((item) {
                                  final isLatest = item.versionOrder == 1;
                                  final sizeKb = (item.sizeBytes / 1024).toStringAsFixed(1);
                                  final dateFormat = DateFormat('dd MMM yyyy, HH:mm:ss', isThai ? 'th' : 'en_US');

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: VaultTheme.background(context),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isLatest
                                            ? Colors.teal.withValues(alpha: 0.6)
                                            : VaultTheme.border(context),
                                        width: isLatest ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: (isLatest ? Colors.teal : Colors.blueGrey).withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            isLatest ? Icons.star_rounded : Icons.history_rounded,
                                            color: isLatest ? Colors.teal : Colors.blueGrey,
                                            size: 20,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${isThai ? "เวอร์ชั่น" : "Version"} ${item.versionOrder}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: (isLatest ? Colors.teal : Colors.grey).withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(
                                                      isLatest
                                                          ? (isThai ? 'ล่าสุด' : 'Latest')
                                                          : (item.versionOrder == 2
                                                              ? (isThai ? 'ก่อนหน้า' : 'Previous')
                                                              : (isThai ? 'เก่ากว่า' : 'Older')),
                                                      style: TextStyle(
                                                        fontSize: 10.5,
                                                        fontWeight: FontWeight.bold,
                                                        color: isLatest ? Colors.teal : Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '${dateFormat.format(item.createdAt)}  •  $sizeKb KB',
                                                style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FilledButton.tonal(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: isLatest ? Colors.teal.withValues(alpha: 0.18) : null,
                                            foregroundColor: isLatest ? Colors.teal : null,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: _isLoading ? null : () => _handleRestoreRollingVersion(item),
                                          child: Text(
                                            isThai ? 'กู้คืน' : 'Restore',
                                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),

                  // 4. Other Restore & Export Options
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: VaultTheme.surface(context),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isThai ? 'ตัวเลือกเพิ่มเติม' : 'Additional Options',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: VaultTheme.secondaryText(context),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.teal,
                                side: const BorderSide(color: Colors.teal, width: 1.2),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.file_download_outlined, size: 20),
                              label: Text(
                                isThai ? 'เลือกไฟล์สำรองอื่นจากเครื่อง...' : 'Pick Other Backup File...',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              onPressed: _isLoading ? null : _handlePickAndRestore,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.blueAccent,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.share_rounded, size: 18),
                              label: Text(
                                isThai ? 'ส่งออกและแชร์ไฟล์สำรอง (.db) นอกโฟลเดอร์' : 'Export & Share Backup (.db)',
                                style: const TextStyle(fontSize: 13),
                              ),
                              onPressed: _isLoading ? null : _handleExport,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // 5. Safety Backups History Card
                if (_safetyBackups.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: VaultTheme.surface(context),
                    elevation: 2,
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                      child: ExpansionTile(
                        leading: const Icon(Icons.shield_outlined, color: Colors.orange),
                        title: Text(
                          isThai ? 'ไฟล์สำรองฉุกเฉินในเครื่อง (Safety Backups)' : 'Safety Backups',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${_safetyBackups.length} ${isThai ? "ไฟล์ที่ระบบบันทึกไว้อัตโนมัติ" : "backups auto-saved"}',
                          style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Column(
                              children: _safetyBackups.map((b) {
                                final sizeKb = (b.sizeBytes / 1024).toStringAsFixed(1);
                                final dateFormat = DateFormat('dd MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');
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
                                        onPressed: () => _handleRollback(b),
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
