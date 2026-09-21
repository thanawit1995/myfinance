import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/services/cloud_sync_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final status = await syncService.getStatus();
    final backups = await syncService.getPreSyncBackups();
    if (mounted) {
      setState(() {
        _status = status;
        _backups = backups;
      });
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.cloud_download, color: Colors.blueAccent),
            SizedBox(width: 8),
            Text('ดึงข้อมูลจาก Google Drive?'),
          ],
        ),
        content: const Text(
          'ข้อมูลจาก Google Drive จะถูกนำมาแทนที่ฐานข้อมูลปัจจุบันในเครื่อง\n\n'
          '🛡️ เพื่อความปลอดภัยสูงสุด ระบบจะสร้างไฟล์สำรองฉุกเฉิน (Safety Backup) ของข้อมูลปัจจุบันไว้ให้คุณโดยอัตโนมัติก่อนเขียนทับเสมอ',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: VaultTheme.accent(context)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ยืนยันดึงข้อมูล'),
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
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.history, color: Colors.orangeAccent),
            SizedBox(width: 8),
            Text('กู้คืนไฟล์สำรองฉุกเฉิน?'),
          ],
        ),
        content: Text(
          'คุณต้องการย้อนกลับไปใช้ข้อมูล ณ วันที่:\n${DateFormat('dd MMM yyyy, HH:mm:ss', 'th').format(backup.createdAt)} หรือไม่?\n\n'
          'ข้อมูลปัจจุบันจะถูกแทนที่ด้วยข้อมูลจากไฟล์สำรองนี้',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.orangeAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('ยืนยันกู้คืน'),
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
        content: Text(ok ? 'ย้อนกลับข้อมูลจากไฟล์สำรองสำเร็จเรียบร้อย' : 'เกิดข้อผิดพลาดในการกู้คืน'),
        backgroundColor: ok ? posColor : negColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', 'th');

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
                                        ? 'เชื่อมต่อ Google Drive เรียบร้อย'
                                        : 'ยังไม่ได้เชื่อมต่อ Google Drive',
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
                                        : 'ตรวจไม่พบโฟลเดอร์ Google Drive for Desktop ในตำแหน่งมาตรฐาน',
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
                                    'มีข้อมูลเวอร์ชันใหม่กว่าบน Google Drive (บันทึกล่าสุดเมื่อ ${_status!.remoteLastModified != null ? dateFormat.format(_status!.remoteLastModified!) : ""}) แนะนำให้กดดึงข้อมูลล่าสุด',
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
                                const Text('ซิงค์ล่าสุดเมื่อ', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text(
                                  _status!.lastSyncTime != null
                                      ? dateFormat.format(_status!.lastSyncTime!)
                                      : 'ยังไม่เคยซิงค์ข้อมูล',
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text('รายการใหม่ในเครื่อง', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                                    '${_status!.pendingCount} รายการ',
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
                                label: const Text(
                                  'ส่งข้อมูลขึ้น Drive',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                                label: const Text(
                                  'ดึงข้อมูลจาก Drive',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
                const Text('การตั้งค่า Google Drive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  color: VaultTheme.surface(context),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.folder_outlined, color: Colors.blueAccent),
                        title: const Text('โฟลเดอร์ Google Drive'),
                        subtitle: Text(
                          _status!.isConnected
                              ? (_status!.driveFolderPath ?? 'ระบุแล้ว')
                              : 'ยังไม่ได้เลือกโฟลเดอร์ (แตะเพื่อเลือกโฟลเดอร์ไดรฟ์ G: หรือ Google Drive)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: OutlinedButton(
                          onPressed: _pickDriveFolder,
                          child: Text(_status!.isConnected ? 'เปลี่ยน' : 'เลือกโฟลเดอร์'),
                        ),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.sync),
                        title: const Text('ซิงค์อัตโนมัติ (Auto-Sync)'),
                        subtitle: const Text('ตรวจสอบและซิงค์ข้อมูลกับ Google Drive ทุกครั้งที่เปิดแอป'),
                        value: _status!.isAutoSync,
                        onChanged: (val) async {
                          await ref.read(googleDriveSyncServiceProvider).setAutoSyncEnabled(val);
                          _loadData();
                        },
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.wifi),
                        title: const Text('ซิงค์ผ่าน Wi-Fi เท่านั้น'),
                        subtitle: const Text('ประหยัดเน็ตมือถือ ไม่ซิงค์เมื่อใช้เครือข่าย Cellular'),
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
                          title: const Text('ยกเลิกการเชื่อมต่อโฟลเดอร์', style: TextStyle(color: Colors.redAccent)),
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('ยกเลิกการเชื่อมต่อ?'),
                                content: const Text('การยกเลิกจะไม่ลบข้อมูลในเครื่องหรือใน Google Drive แต่จะหยุดการซิงค์ไว้ชั่วคราว'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('ยกเลิก')),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    child: const Text('ยืนยันยกเลิก'),
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
                    const Text('ไฟล์สำรองฉุกเฉินก่อนซิงค์ (Safety Backups)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(
                      '${_backups.length} ไฟล์',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'ทุกครั้งก่อนการดึงข้อมูลทับ ระบบจะสำรองข้อมูลในเครื่องไว้ที่นี่เสมอเพื่อให้คุณย้อนกลับได้ 100%',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 10),

                if (_backups.isEmpty)
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: VaultTheme.surface(context),
                    child: const Padding(
                      padding: EdgeInsets.all(18),
                      child: Center(
                        child: Text(
                          'ยังไม่มีไฟล์สำรองฉุกเฉิน (จะสร้างอัตโนมัติเมื่อมีการดึงข้อมูลจาก Drive)',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
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
                            child: const Text('กู้คืนจุดนี้', style: TextStyle(fontSize: 11)),
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
