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
      // Use cached user only — never trigger silent sign-in on page load
      final user = await authService.getCachedUser();
      if (mounted) {
        setState(() {
          _status = status;
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

  /// Bidirectional sync: if Drive is newer → pull; if local is newer → push.
  Future<void> _doSync({bool silent = false}) async {
    final syncService = ref.read(googleDriveSyncServiceProvider);
    final status = await syncService.getStatus();
    if (status.hasRemoteUpdate) {
      await syncService.downloadAndRestoreFromGoogleDrive();
    } else {
      await syncService.uploadToGoogleDrive();
    }
  }

  Future<void> _handleSignIn() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final authService = ref.read(googleAuthServiceProvider);
    final syncService = ref.read(googleDriveSyncServiceProvider);
    setState(() => _isLoading = true);
    try {
      // Step 1: Sign in (includes drive scope on web)
      final user = await authService.signIn();
      if (user != null) {
        // Step 2: Connect drive folder
        await syncService.detectOrGetDriveFolder();
        // Step 3: Auto sync after login
        await _doSync(silent: true);
        await _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isThai
                  ? 'เข้าสู่ระบบด้วย ${user.email} และซิงค์ข้อมูลเรียบร้อยแล้ว'
                  : 'Signed in as ${user.email} and synced'),
              backgroundColor: VaultTheme.positive(context),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final errText = e.toString();
        final String msg;
        if (errText.contains('10') || errText.contains('sign_in_failed')) {
          msg = isThai
              ? 'บริการ Google Play ปฏิเสธการเข้าสู่ระบบ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตหรือบัญชี Google'
              : 'Google Sign-In was rejected. Please check your network or Google account.';
        } else if (errText.contains('People API')) {
          msg = isThai
              ? 'Google Cloud ยังไม่ได้เปิดสิทธิ์ People API กรุณาเปิดใช้งานใน Google Console หรือลองใหม่อีกครั้ง'
              : 'People API is disabled in Google Cloud project.';
        } else {
          msg = isThai ? 'เข้าสู่ระบบไม่สำเร็จ กรุณาลองใหม่อีกครั้ง' : 'Sign in failed. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: VaultTheme.negative(context),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSyncNow() async {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    setState(() => _isLoading = true);
    try {
      await _doSync();
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ซิงค์ข้อมูลเรียบร้อยแล้ว' : 'Sync complete'),
            backgroundColor: VaultTheme.positive(context),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isThai ? 'ซิงค์ไม่สำเร็จ กรุณาลองใหม่อีกครั้ง' : 'Sync failed. Please try again.'),
            backgroundColor: VaultTheme.negative(context),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    final isThai = Localizations.localeOf(context).languageCode == 'th';
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm', isThai ? 'th' : 'en_US');
    final isConnected = (_status?.isConnected ?? false) || _googleUser != null;

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
                    child: _googleUser != null
                        ? Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: Colors.teal.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    _googleUser!.email.substring(0, 1).toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _googleUser!.displayName ?? _googleUser!.email,
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
                                      _googleUser!.email,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                onPressed: _isLoading ? null : _handleSignOut,
                                child: Text(
                                  isThai ? 'ออกจากระบบ' : 'Sign Out',
                                  style: const TextStyle(color: Colors.red, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.account_circle_outlined, color: Colors.blue, size: 26),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          isThai ? 'เข้าสู่ระบบด้วย Google' : 'Sign in with Google',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                            color: VaultTheme.primaryText(context),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isThai ? 'เชื่อมต่อ Google Drive เพื่อซิงค์ข้อมูล' : 'Connect Google Drive for cloud backup',
                                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.tonalIcon(
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: _isLoading ? null : _handleSignIn,
                                  icon: const Icon(Icons.login, size: 18),
                                  label: Text(
                                    isThai ? 'เข้าสู่ระบบ Google' : 'Sign In with Google',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Main Status Card with Sync Now Button
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
                                color: isConnected
                                    ? Colors.teal.withValues(alpha: 0.15)
                                    : Colors.orange.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isConnected ? Icons.cloud_done : Icons.cloud_off,
                                size: 28,
                                color: isConnected ? Colors.teal : Colors.orange,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isConnected
                                        ? (isThai ? 'เชื่อมต่อ Google Drive เรียบร้อย' : 'Google Drive Connected')
                                        : (isThai ? 'ยังไม่ได้เชื่อมต่อ Google Drive' : 'Google Drive Disconnected'),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: VaultTheme.primaryText(context),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    isConnected
                                        ? (isThai ? 'พร้อมสำหรับการซิงค์ข้อมูล' : 'Ready to sync')
                                        : (isThai ? 'เข้าสู่ระบบ Google เพื่อเริ่มซิงค์ข้อมูล' : 'Sign in to start syncing'),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isConnected ? Colors.grey : Colors.orange,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

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

                        if (_googleUser != null) ...[
                          const SizedBox(height: 18),

                          // Single Sync Now button
                          SizedBox(
                            width: double.infinity,
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
                                  : const Icon(Icons.sync, size: 20),
                              label: Text(
                                isThai ? 'ซิงค์ข้อมูลตอนนี้' : 'Sync Now',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              onPressed: _isLoading ? null : _handleSyncNow,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
