import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/sync/sync_service.dart';
import '../../core/sync/auth_service.dart';
import '../../core/theme/vault_theme.dart';
import '../backup/presentation/backup_restore_screen.dart';

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
              // 1. Quick Sync (ด่วน)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: state.status == SyncStatus.syncing
                      ? null
                      : () async {
                          Navigator.of(ctx).pop();
                          await ref.read(syncServiceProvider.notifier).quickStartupSync();
                        },
                  icon: const Icon(Icons.sync_rounded, size: 20),
                  label: Text(
                    isThai ? 'ซิงค์ข้อมูลด่วน' : 'Quick Sync',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 2. Open Settings for Force Push / Download Master
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: VaultTheme.primaryText(context),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_backup_restore_rounded, size: 18),
                  label: Text(
                    isThai ? 'การสำรองและจัดการ Master' : 'Manage Master & Backup',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // 3. Log out
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(authServiceProvider).signOut();
                  },
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    isThai ? 'ออกจากระบบ' : 'Sign Out',
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
