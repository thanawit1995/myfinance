import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/sync/sync_service.dart';
import '../../core/sync/auth_service.dart';

/// Compact sync status indicator shown in AppBar.
/// Shows: 🟢 synced / 🔄 syncing / 🔴 offline / ⚠️ error
class SyncStatusWidget extends ConsumerWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      // Not logged in — show login prompt icon
      return IconButton(
        icon: const Icon(Icons.cloud_off_outlined, size: 20),
        tooltip: 'ไม่ได้เชื่อมต่อ — กดเพื่อเข้าสู่ระบบ',
        onPressed: () => Navigator.of(context).pushNamed('/login'),
      );
    }

    return GestureDetector(
      onTap: () => _showSyncDetail(context, ref, syncState),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(syncState.status),
            const SizedBox(width: 4),
            _buildLabel(context, syncState),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(SyncStatus status) {
    switch (status) {
      case SyncStatus.syncing:
        return const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        );
      case SyncStatus.offline:
        return const Icon(Icons.cloud_off, size: 18, color: Colors.grey);
      case SyncStatus.error:
        return const Icon(Icons.warning_amber, size: 18, color: Colors.orange);
      case SyncStatus.idle:
        return const Icon(Icons.cloud_done, size: 18, color: Colors.green);
    }
  }

  Widget _buildLabel(BuildContext context, SyncState state) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    String text;
    switch (state.status) {
      case SyncStatus.syncing:
        text = isThai ? 'กำลัง sync...' : 'Syncing...';
        break;
      case SyncStatus.offline:
        text = isThai ? 'Offline' : 'Offline';
        break;
      case SyncStatus.error:
        text = isThai ? 'Sync ผิดพลาด' : 'Sync error';
        break;
      case SyncStatus.idle:
        if (state.lastSyncAt != null) {
          final diff = DateTime.now().difference(state.lastSyncAt!);
          if (diff.inMinutes < 1) {
            text = isThai ? 'เมื่อกี้' : 'Just now';
          } else if (diff.inMinutes < 60) {
            text = isThai
                ? '${diff.inMinutes} นาทีที่แล้ว'
                : '${diff.inMinutes}m ago';
          } else {
            text = DateFormat('HH:mm').format(state.lastSyncAt!);
          }
        } else {
          text = isThai ? 'ยังไม่ sync' : 'Not synced';
        }
    }
    return Text(text, style: const TextStyle(fontSize: 11));
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
            Text(
              isThai ? 'สถานะการ Sync' : 'Sync Status',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (user != null) ...[
              _infoRow(isThai ? 'บัญชี' : 'Account', user.email ?? '-'),
              const SizedBox(height: 8),
            ],
            _infoRow(
              isThai ? 'Sync ล่าสุด' : 'Last sync',
              state.lastSyncAt != null
                  ? DateFormat('d MMM yyyy HH:mm:ss').format(state.lastSyncAt!)
                  : isThai ? 'ยังไม่เคย sync' : 'Never',
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
                    onPressed: state.status == SyncStatus.syncing
                        ? null
                        : () {
                            Navigator.of(ctx).pop();
                            ref.read(syncServiceProvider.notifier).syncAll();
                          },
                    icon: const Icon(Icons.sync, size: 18),
                    label: Text(isThai ? 'Sync ทันที' : 'Sync Now'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
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
          width: 100,
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
