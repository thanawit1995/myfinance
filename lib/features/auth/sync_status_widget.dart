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
    final syncState = ref.watch(syncServiceProvider);
    final user = ref.watch(currentUserProvider);
    final isThai = Localizations.localeOf(context).languageCode == 'th';

    if (user == null) {
      // Not logged in — clear pill to sign in
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => Navigator.of(context).pushNamed('/login'),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: VaultTheme.surface(context).withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: VaultTheme.border(context), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 16, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  isThai ? 'เข้าสู่ระบบซิงค์' : 'Sign in to Sync',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showSyncDetail(context, ref, syncState),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: VaultTheme.surface(context).withValues(alpha: 0.94),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.12),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIcon(syncState.status),
              const SizedBox(width: 5),
              _buildLabel(context, syncState),
            ],
          ),
        ),
      ),
    );
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

  Widget _buildLabel(BuildContext context, SyncState state) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    String text;
    switch (state.status) {
      case SyncStatus.syncing:
        text = isThai ? 'กำลังซิงค์...' : 'Syncing...';
        break;
      case SyncStatus.offline:
        text = isThai ? 'ออฟไลน์' : 'Offline';
        break;
      case SyncStatus.error:
        text = isThai ? 'ซิงค์ผิดพลาด' : 'Sync error';
        break;
      case SyncStatus.idle:
        if (state.lastSyncAt != null) {
          final diff = DateTime.now().difference(state.lastSyncAt!);
          if (diff.inMinutes < 1) {
            text = isThai ? 'ซิงค์แล้ว' : 'In Sync';
          } else if (diff.inMinutes < 60) {
            text = isThai
                ? '${diff.inMinutes} นาทีที่แล้ว'
                : '${diff.inMinutes}m ago';
          } else {
            text = DateFormat('HH:mm').format(state.lastSyncAt!);
          }
        } else {
          text = isThai ? 'ยังไม่เคยซิงค์' : 'Not synced';
        }
    }
    return Text(
      text,
      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
    );
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
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.teal.shade700,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: state.status == SyncStatus.syncing
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                            ref.read(syncServiceProvider.notifier).syncAll();
                          },
                    icon: const Icon(Icons.sync_rounded, size: 18),
                    label: Text(isThai ? 'ซิงค์ทันที' : 'Sync Now'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                  ),
                  onPressed: state.status == SyncStatus.syncing
                      ? null
                      : () {
                          Navigator.of(ctx).pop();
                          ref.read(syncServiceProvider.notifier).syncAll(forceFullSync: true);
                        },
                  child: Text(isThai ? 'ซิงค์ทั้งหมดใหม่' : 'Full Re-sync'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  ),
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await ref.read(authServiceProvider).signOut();
                  },
                  child: Text(isThai ? 'ออกจากระบบ' : 'Sign Out'),
                ),
              ],
            ),
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
