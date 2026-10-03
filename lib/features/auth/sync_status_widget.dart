import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/sync/sync_service.dart';
import '../../core/sync/auth_service.dart';
import '../../core/theme/vault_theme.dart';

/// Top-Right Floating or AppBar Sync Status Indicator.
/// Easy to tap, shows current sync status and account info.
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    if (user == null) {
      // Not logged in — compact cloud icon to sign in
      return Tooltip(
        message: isThai ? 'เข้าสู่ระบบซิงค์คลาวด์' : 'Sign in to Sync',
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => Navigator.of(context).pushNamed('/login'),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: VaultTheme.surface(context).withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(color: VaultTheme.border(context), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.cloud_off_rounded, size: 18, color: Colors.grey),
              ),
            ),
          ),
        ),
      );
    }

    final syncState = ref.watch(syncServiceProvider);
    final Color statusColor;
    switch (syncState.status) {
      case SyncStatus.syncing:
        statusColor = Colors.blue;
        break;
      case SyncStatus.offline:
        statusColor = Colors.orange;
        break;
      case SyncStatus.error:
        statusColor = Colors.redAccent;
        break;
      case SyncStatus.idle:
        statusColor = Colors.green;
        break;
    }

    return Tooltip(
      message: _getTooltipMessage(context, syncState),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showSyncDetail(context, ref, syncState),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: VaultTheme.surface(context).withValues(alpha: 0.94),
              shape: BoxShape.circle,
              border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withValues(alpha: 0.15),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildIcon(syncState.status),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: VaultTheme.surface(context), width: 1),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getTooltipMessage(BuildContext context, SyncState state) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    switch (state.status) {
      case SyncStatus.syncing:
        return isThai ? 'กำลังซิงค์ข้อมูลกับคลาวด์...' : 'Syncing with cloud...';
      case SyncStatus.offline:
        return isThai ? 'ออฟไลน์ (ไม่มีอินเทอร์เน็ต)' : 'Offline';
      case SyncStatus.error:
        return isThai ? 'ซิงค์ผิดพลาด: แตะเพื่อดูรายละเอียด' : 'Sync error: tap for details';
      case SyncStatus.idle:
        if (state.lastSyncAt != null) {
          final diff = DateTime.now().difference(state.lastSyncAt!);
          if (diff.inMinutes < 1) {
            return isThai ? 'ซิงค์แล้วล่าสุด (ข้อมูลตรงกัน)' : 'In Sync (up to date)';
          } else if (diff.inMinutes < 60) {
            return isThai ? 'ซิงค์เมื่อ ${diff.inMinutes} นาทีที่แล้ว' : 'Synced ${diff.inMinutes}m ago';
          } else {
            return isThai ? 'ซิงค์เมื่อ ${DateFormat('HH:mm').format(state.lastSyncAt!)}' : 'Synced at ${DateFormat('HH:mm').format(state.lastSyncAt!)}';
          }
        }
        return isThai ? 'สถานะคลาวด์: แตะเพื่อดูรายละเอียด' : 'Cloud Status: tap for details';
    }
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue),
        );
      case SyncStatus.offline:
        return const Icon(Icons.wifi_off_rounded, size: 15, color: Colors.orange);
      case SyncStatus.error:
        return const Icon(Icons.warning_amber_rounded, size: 15, color: Colors.redAccent);
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done_rounded, size: 15, color: Colors.green);
    }
  }


  void _showSyncDetail(BuildContext context, WidgetRef ref, SyncState state) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final user = ref.read(currentUserProvider);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isThai ? 'สถานะการเชื่อมต่อคลาวด์' : 'Cloud Sync Status',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (user != null ? Colors.green : Colors.grey).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user != null ? (isThai ? 'เข้าสู่ระบบแล้ว' : 'LOGGED IN') : (isThai ? 'ออฟไลน์' : 'OFFLINE'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: user != null ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              _infoRow(isThai ? 'บัญชี Google' : 'Google Account', user.email ?? '-'),
              const SizedBox(height: 8),
            ],
            _infoRow(
              isThai ? 'ซิงค์ล่าสุด' : 'Last sync',
              state.lastSyncAt != null
                  ? DateFormat('d MMM yyyy HH:mm:ss', isThai ? 'th' : 'en_US').format(state.lastSyncAt!)
                  : (isThai ? 'ยังไม่เคยซิงค์' : 'Never'),
            ),
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              _infoRow(isThai ? 'ข้อผิดพลาด' : 'Error', state.errorMessage!),
            ],
            const SizedBox(height: 20),
            if (user != null) ...[
              // 1. Master push (upload)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.deepOrange.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.status == SyncStatus.syncing
                      ? null
                      : () => _confirmForcePush(context, ref, isThai),
                  icon: const Icon(Icons.upload_rounded, size: 20),
                  label: Text(
                    isThai ? '1. อัปโหลด Master ขึ้นคลาวด์ (Master Push)' : '1. Master Push (Upload)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Download master data
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.status == SyncStatus.syncing
                      ? null
                      : () => _confirmPullMaster(context, ref, isThai),
                  icon: const Icon(Icons.cloud_download_rounded, size: 20),
                  label: Text(
                    isThai ? '2. ดาวน์โหลด Master จากคลาวด์ (Download Master)' : '2. Download Master Data',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Log out
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent, width: 1.2),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(authServiceProvider).signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    isThai ? '3. ออกจากระบบคลาวด์ (Log Out)' : '3. Log Out',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmForcePush(BuildContext context, WidgetRef ref, bool isThai) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.deepOrange),
            const SizedBox(width: 8),
            Text(isThai ? 'ยืนยันเขียนทับคลาวด์ (Force Push)' : 'Confirm Force Push'),
          ],
        ),
        content: Text(
          isThai
              ? 'ระบบจะนำข้อมูลทั้งหมดในเครื่องนี้ขึ้นไปแทนที่บน Google Cloud 100% และลบข้อมูลธุรกรรมเก่าที่มีอยู่บนคลาวด์ทิ้ง\n\n'
                'เหมาะสำหรับ:\n'
                '• คุณเพิ่งกู้คืนไฟล์สำรอง (Backup) มาใหม่\n'
                '• ข้อมูลบนคลาวด์มีรายการเก่าที่ผิดพลาดหรือซ้ำซ้อน\n\n'
                'คุณแน่ใจหรือไม่ว่าต้องการดำเนินการ?'
              : 'This will replace all transactions on the cloud with your current local database.\n\nAre you sure you want to proceed?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.deepOrange),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ยืนยันเขียนทับคลาวด์' : 'Confirm Overwrite'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(); // close bottom sheet
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(isThai ? 'กำลังส่งข้อมูลขึ้นไปเขียนทับบนคลาวด์...' : 'Force pushing data to cloud...'),
          duration: const Duration(seconds: 2),
        ),
      );

      final ok = await ref.read(syncServiceProvider.notifier).forcePushLocalToCloud();
      if (ok) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เขียนทับข้อมูลบนคลาวด์สำเร็จเรียบร้อย! คลาวด์เป็นข้อมูลล่าสุดแล้ว' : 'Cloud successfully overwritten with local data!'),
            backgroundColor: Colors.teal,
          ),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(isThai ? 'เกิดข้อผิดพลาดในการเขียนทับคลาวด์' : 'Failed to overwrite cloud data'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _confirmPullMaster(BuildContext context, WidgetRef ref, bool isThai) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.cloud_download_rounded, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Text(isThai ? 'ยืนยันดึงข้อมูล Master จากคลาวด์' : 'Confirm Pull Master Snapshot'),
          ],
        ),
        content: Text(
          isThai
              ? 'ระบบจะดึงฐานข้อมูล Master 25 ตารางจาก Google Cloud มาเขียนทับฐานข้อมูลในเครื่องนี้ 100%\n\n'
                'ข้อมูลทั้งหมดจะตรงกับเครื่องที่ส่ง Master ขึ้นไปอย่างสมบูรณ์แบบ (เหมือนการนำเข้าไฟล์ .db)\n\n'
                '• มีระบบ Safety Backup สำรองข้อมูลเดิมในเครื่องนี้ให้อัตโนมัติก่อนเริ่มกู้คืน\n\n'
                'คุณแน่ใจหรือไม่ว่าต้องการดำเนินการ?'
              : 'This will replace all tables in this device with the Cloud Master Snapshot 100%.\n\nA safety backup will be created automatically before restoring.\n\nDo you want to proceed?',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isThai ? 'ยกเลิก' : 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.blue.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isThai ? 'ยืนยันดึงข้อมูล Master' : 'Confirm Pull Master'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      Navigator.of(context).pop(); // close bottom sheet
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(isThai ? 'กำลังดึงฐานข้อมูล Master จากคลาวด์...' : 'Pulling Master Snapshot from cloud...'),
          duration: const Duration(seconds: 3),
        ),
      );

      final ok = await ref.read(syncServiceProvider.notifier).pullMasterSnapshotFromCloud(isThai: isThai);
      if (ok) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ดึงข้อมูล Master สำเร็จเรียบร้อย! ข้อมูลทุกตารางตรงกับ Master 100%' : 'Successfully pulled Master Snapshot!'),
            backgroundColor: Colors.teal,
          ),
        );
      } else {
        final err = ref.read(syncServiceProvider).errorMessage;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(err ?? (isThai ? 'เกิดข้อผิดพลาดในการดึงข้อมูล Master' : 'Failed to pull master snapshot')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Widget _infoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}
