import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'auth_service.dart';
import 'cloud_vault_snapshot_helper.dart';

// ─── Sync Status ─────────────────────────────────────────────────────────────

enum SyncStatus { idle, syncing, offline, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final String? masterDeviceName;
  final int totalSynced;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.errorMessage,
    this.masterDeviceName,
    this.totalSynced = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? errorMessage,
    String? masterDeviceName,
    int? totalSynced,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        errorMessage: errorMessage ?? this.errorMessage,
        masterDeviceName: masterDeviceName ?? this.masterDeviceName,
        totalSynced: totalSynced ?? this.totalSynced,
      );
}

// ─── SyncService ─────────────────────────────────────────────────────────────

class SyncService extends StateNotifier<SyncState> {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  final AuthService _auth;

  static const _prefLastSync = 'last_sync_timestamp';
  static const _prefDeviceId = 'myfinance_device_id';
  static const _prefForcePushNext = 'pref_force_push_next_sync';
  StreamSubscription? _connectivitySub;
  StreamSubscription? _authSub;

  /// ตั้งค่าสถานะให้การเชื่อมต่อครั้งถัดไปทำ Force Push (เขียนทับคลาวด์) แทนการดึงข้อมูลเก่า
  static Future<void> markForcePushNext() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefForcePushNext, true);
    debugPrint('[Sync] Marked force_push_next_sync = true');
  }

  /// ตรวจสอบว่ามีการตั้งค่าให้ Force Push ในครั้งถัดไปหรือไม่
  static Future<bool> isForcePushNextMarked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefForcePushNext) ?? false;
  }

  SyncService(this._supabase, this._db, this._auth)
      : super(const SyncState()) {
    _init();
  }

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    var devId = prefs.getString(_prefDeviceId);
    if (devId == null || devId.isEmpty) {
      devId = const Uuid().v4();
      await prefs.setString(_prefDeviceId, devId);
    }
    return devId;
  }

  String _getDeviceDisplayName() {
    if (kIsWeb) return 'Web Browser / PC';
    return 'Mobile / Tablet';
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_prefLastSync);
    if (ts != null) {
      state = state.copyWith(lastSyncAt: DateTime.tryParse(ts));
    }

    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) async {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _auth.isLoggedIn) {
        final p = await SharedPreferences.getInstance();
        if (p.getBool(_prefForcePushNext) ?? false) {
          await forcePushLocalToCloud();
        } else {
          await quickStartupSync();
        }
      } else if (!online) {
        state = state.copyWith(status: SyncStatus.offline);
      }
    });

    _authSub = _supabase.auth.onAuthStateChange.listen((data) async {
      if (data.session != null) {
        final p = await SharedPreferences.getInstance();
        if (p.getBool(_prefForcePushNext) ?? false) {
          await forcePushLocalToCloud();
        } else {
          await quickStartupSync();
        }
      } else {
        state = const SyncState();
      }
    });

    if (_auth.isLoggedIn) {
      final p = await SharedPreferences.getInstance();
      if (p.getBool(_prefForcePushNext) ?? false) {
        await forcePushLocalToCloud();
      } else {
        await quickStartupSync();
      }
    }
  }

  /// ซิงค์ด่วนเมื่อเปิดแอป (Quick Startup Sync)
  /// ซิงค์เฉพาะรายการที่มีการเปลี่ยนแปลงล่าสุด (Delta) อย่างรวดเร็ว ไม่รัน Loop ตรวจจับความซ้ำซ้อนทั้งฐานข้อมูล
  Future<void> quickStartupSync() async {
    if (!_auth.isLoggedIn) return;
    if (state.status == SyncStatus.syncing) return;

    final userId = _auth.currentUser!.id;
    final lastSync = state.lastSyncAt;

    if (lastSync == null) {
      await syncAll(forceFullSync: true);
      return;
    }

    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      // Purge any legacy historical settle transactions locally
      await _db.creditCardDao.purgeHistoricalSettlements();

      // Delta sync for essential tables
      await _syncAccounts(userId, lastSync);
      await _syncCategories(userId, lastSync);
      await _syncBudgets(userId, lastSync);
      await _syncRecurring(userId, lastSync);
      await _syncTransactions(userId, lastSync);

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());

      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle();

      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncAt: now,
        masterDeviceName: _getDeviceDisplayName(),
        totalSynced: txCount ?? 0,
      );
      debugPrint('[Sync] Quick startup sync completed in background at $now.');
    } catch (e) {
      debugPrint('[Sync] Quick startup sync error: $e');
      state = state.copyWith(status: SyncStatus.idle);
    }
  }

  // ─── Clean Duplicates (Deduplicate) ─────────────────────────────────────────

  /// ค้นหาและล้างรายการที่ซ้ำกันออกจากทั้งเครื่องและ Supabase
  Future<int> cleanDuplicates() async {
    if (state.status == SyncStatus.syncing) return 0;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      final deletedIds = await _db.transactionsDao.deduplicateTransactions();
      debugPrint('[Sync] Deduplicated locally: ${deletedIds.length} duplicate items removed.');

      if (deletedIds.isNotEmpty && _auth.isLoggedIn) {
        const chunkSize = 150;
        for (var i = 0; i < deletedIds.length; i += chunkSize) {
          final chunk = deletedIds.sublist(i, math.min(i + chunkSize, deletedIds.length));
          await _supabase.from('transactions').delete().inFilter('id', chunk);
        }
        debugPrint('[Sync] Cleaned ${deletedIds.length} duplicate rows from Supabase.');
      }

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());

      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle();

      // บันทึกสถานะว่าเครื่องนี้ได้จัดระเบียบข้อมูลเรียบร้อยแล้ว
      final deviceId = await _getOrCreateDeviceId();
      final devName = _getDeviceDisplayName();
      try {
        await _supabase.from('sync_device_state').upsert({
          'user_id': _auth.currentUser?.id,
          'active_device_id': deviceId,
          'active_device_name': devName,
          'total_transactions': txCount ?? 0,
          'updated_at': now.toIso8601String(),
        });
      } catch (_) {}

      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncAt: now,
        masterDeviceName: devName,
        totalSynced: txCount ?? 0,
      );
      return deletedIds.length;
    } catch (e) {
      debugPrint('[Sync] Error cleaning duplicates: $e');
      state = state.copyWith(status: SyncStatus.error, errorMessage: e.toString());
      return 0;
    }
  }

  /// เขียนทับคลาวด์ด้วยข้อมูลเครื่องนี้ 100% (Force Push Local to Cloud)
  /// ลบข้อมูลธุรกรรมเก่าบน Supabase และส่งข้อมูลที่สะอาด 3,881 รายการจากเครื่องขึ้นไปแทนที่
  Future<bool> forcePushLocalToCloud() async {
    if (!_auth.isLoggedIn) return false;
    if (state.status == SyncStatus.syncing) return false;

    final userId = _auth.currentUser!.id;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      // Purge any legacy historical settle transactions before push
      await _db.creditCardDao.purgeHistoricalSettlements();
      try {
        await _supabase.from('transactions').delete().eq('user_id', userId).eq('tag', 'historical_settle');
      } catch (_) {}

      // 0. Push Cloud Master Snapshot (All 25 tables compressed & Base64 encoded)
      await _pushMasterSnapshot(userId);

      // 1. Push ตารางหลักขึ้นไปก่อน (บัญชี หมวดหมู่ สินทรัพย์) แบบ Push-Only ห้ามดึงข้อมูลเก่ากลับมา
      await _syncAccounts(userId, null, pushOnly: true);
      await _syncCategories(userId, null, pushOnly: true);
      await _syncAssets(userId, null, pushOnly: true);

      // 2. ลบรายการธุรกรรมบน Supabase ของผู้ใช้นี้ทั้งหมดเพื่อเคลียร์ความซ้ำซ้อน
      await _supabase.from('transactions').delete().eq('user_id', userId);

      // 3. ดึงรายการธุรกรรมที่สะอาดจาก SQLite ในเครื่องทั้งหมด และอัปโหลดขึ้นไปแทนที่
      final localTx = await (_db.select(_db.transactions)..where((t) => t.deletedAt.isNull())).get();
      const chunkSize = 200;
      for (var i = 0; i < localTx.length; i += chunkSize) {
        final chunk = localTx.sublist(i, math.min(i + chunkSize, localTx.length));
        final payload = chunk.map((tx) => _txToJson(tx, userId)).toList();
        await _supabase.from('transactions').insert(payload);
      }

      // 4. Push โมดูลอื่นๆ ขึ้นคลาวด์แบบ Push-Only
      await _syncInsurance(userId, null, pushOnly: true);
      await _syncLiabilities(userId, null, pushOnly: true);
      await _syncBudgets(userId, null, pushOnly: true);
      await _syncRecurring(userId, null, pushOnly: true);
      await _syncProjects(userId, null, pushOnly: true);
      await _syncCreditCardInstallments(userId, null, pushOnly: true);

      // 5. บันทึกสถานะว่าเครื่องนี้เป็น Master บน Supabase
      final deviceId = await _getOrCreateDeviceId();
      final devName = _getDeviceDisplayName();
      try {
        await _supabase.from('sync_device_state').upsert({
          'user_id': userId,
          'active_device_id': deviceId,
          'active_device_name': devName,
          'total_transactions': localTx.length,
          'updated_at': DateTime.now().toIso8601String(),
        });
      } catch (_) {}

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());
      await prefs.remove(_prefForcePushNext);

      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncAt: now,
        masterDeviceName: devName,
        totalSynced: localTx.length,
      );
      debugPrint('[Sync] Force Push complete: ${localTx.length} transactions uploaded.');
      return true;
    } catch (e) {
      debugPrint('[Sync] Error force pushing to cloud: $e');
      state = state.copyWith(status: SyncStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  /// อัปโหลดฐานข้อมูล SQLite ทั้ง 25 ตาราง (บีบอัด GZip Base64) ขึ้นเป็น Master Snapshot
  Future<void> _pushMasterSnapshot(String userId) async {
    try {
      final packResult = await CloudVaultSnapshotHelper.packDatabaseToCompressedBase64(_db);
      final devName = _getDeviceDisplayName();
      final now = DateTime.now();

      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle() ?? 0;

      bool saved = false;
      // 1. ลองบันทึกลง cloud_vault_backup ก่อน
      try {
        await _supabase.from('cloud_vault_backup').upsert({
          'user_id': userId,
          'device_name': devName,
          'backup_data': packResult.base64Payload,
          'size_bytes': packResult.rawSizeBytes,
          'total_transactions': txCount,
          'updated_at': now.toIso8601String(),
        });
        saved = true;
        debugPrint('[Sync] Master snapshot saved to cloud_vault_backup (${packResult.compressedSizeBytes} bytes).');
      } catch (e) {
        debugPrint('[Sync] cloud_vault_backup upsert note: $e');
      }

      // 2. หากยังไม่มีตาราง cloud_vault_backup บน Supabase ให้บันทึกสำรองลง projects (fallback)
      if (!saved) {
        await _supabase.from('projects').upsert({
          'id': '__cloud_vault_master_backup__',
          'user_id': userId,
          'name': '__cloud_vault_master_backup__',
          'description': packResult.base64Payload,
          'target_budget_satang': packResult.rawSizeBytes,
          'start_date': now.toIso8601String(),
          'end_date': now.toIso8601String(),
          'icon': devName,
          'color': '$txCount',
          'is_active': false,
          'sync_version': 1,
          'created_at': now.toIso8601String(),
          'updated_at': now.toIso8601String(),
        }, onConflict: 'id');
        debugPrint('[Sync] Master snapshot saved to projects fallback (${packResult.compressedSizeBytes} bytes).');
      }
    } catch (e) {
      debugPrint('[Sync] Error in _pushMasterSnapshot: $e');
    }
  }

  /// ดึงฐานข้อมูล Master Snapshot 25 ตารางจากคลาวด์มาเขียนทับเครื่องนี้ 100%
  Future<bool> pullMasterSnapshotFromCloud({bool isThai = true}) async {
    if (!_auth.isLoggedIn) return false;
    if (state.status == SyncStatus.syncing) return false;

    final userId = _auth.currentUser!.id;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      String? base64Payload;

      // 1. ลองดึงจาก cloud_vault_backup ก่อน
      try {
        final res = await _supabase
            .from('cloud_vault_backup')
            .select('backup_data')
            .eq('user_id', userId)
            .maybeSingle();
        if (res != null && res['backup_data'] != null) {
          base64Payload = res['backup_data'] as String;
        }
      } catch (e) {
        debugPrint('[Sync] cloud_vault_backup select note: $e');
      }

      // 2. ถ้าไม่พบ ลองดึงจาก projects fallback (__cloud_vault_master_backup__)
      if (base64Payload == null || base64Payload.isEmpty) {
        try {
          final res = await _supabase
              .from('projects')
              .select('description')
              .eq('user_id', userId)
              .eq('id', '__cloud_vault_master_backup__')
              .maybeSingle();
          if (res != null && res['description'] != null) {
            base64Payload = res['description'] as String;
          }
        } catch (e) {
          debugPrint('[Sync] projects fallback select note: $e');
        }
      }

      if (base64Payload != null && base64Payload.isNotEmpty) {
        // 3. ปลดล็อกและเขียนทับฐานข้อมูลในเครื่องด้วย snapshot 100%
        final ok = await CloudVaultSnapshotHelper.unpackCompressedBase64ToDatabase(base64Payload, _db);
        if (!ok) {
          debugPrint('[Sync] Snapshot restore failed, falling back to full relational sync...');
          await _executeFullSync(userId, forceFullSync: true);
        } else {
          // ดึง delta เพิ่มเติมหากมีรายการใหม่กว่า snapshot
          try {
            await _executeFullSync(userId, forceFullSync: false);
          } catch (_) {}
        }
      } else {
        // Dual-Engine Fallback: หากไม่มี Snapshot blob ให้ดึงจากตารางจริงทั้งหมดบนคลาวด์
        debugPrint('[Sync] Master snapshot blob not found, executing full relational sync...');
        await _executeFullSync(userId, forceFullSync: true);
      }

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());

      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle();

      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncAt: now,
        masterDeviceName: 'Cloud Master Vault',
        totalSynced: txCount ?? 0,
      );
      return true;
    } catch (e) {
      debugPrint('[Sync] Error pulling master snapshot from cloud: $e');
      state = state.copyWith(status: SyncStatus.error, errorMessage: e.toString());
      return false;
    }
  }

  /// ดึงข้อมูลสรุปของ Master Snapshot บนคลาวด์
  Future<Map<String, dynamic>?> getMasterSnapshotInfo() async {
    if (!_auth.isLoggedIn) return null;
    final userId = _auth.currentUser!.id;

    try {
      final res = await _supabase
          .from('cloud_vault_backup')
          .select('device_name, updated_at, size_bytes, total_transactions')
          .eq('user_id', userId)
          .maybeSingle();
      if (res != null) {
        return {
          'device_name': res['device_name'] as String? ?? 'Cloud Vault',
          'updated_at': res['updated_at'] != null ? DateTime.tryParse(res['updated_at'] as String) : null,
          'size_bytes': (res['size_bytes'] as num?)?.toInt() ?? 0,
          'total_transactions': (res['total_transactions'] as num?)?.toInt() ?? 0,
        };
      }
    } catch (_) {}

    try {
      final res = await _supabase
          .from('projects')
          .select('icon, updated_at, target_budget_satang, color')
          .eq('user_id', userId)
          .eq('id', '__cloud_vault_master_backup__')
          .maybeSingle();
      if (res != null) {
        return {
          'device_name': res['icon'] as String? ?? 'Cloud Vault',
          'updated_at': res['updated_at'] != null ? DateTime.tryParse(res['updated_at'] as String) : null,
          'size_bytes': (res['target_budget_satang'] as num?)?.toInt() ?? 0,
          'total_transactions': int.tryParse(res['color'] as String? ?? '0') ?? 0,
        };
      }
    } catch (_) {}

    try {
      final devState = await _supabase
          .from('sync_device_state')
          .select('active_device_name, updated_at, total_transactions')
          .eq('user_id', userId)
          .maybeSingle();
      if (devState != null) {
        return {
          'device_name': devState['active_device_name'] as String? ?? 'Cloud Synced Database',
          'updated_at': devState['updated_at'] != null ? DateTime.tryParse(devState['updated_at'] as String) : null,
          'size_bytes': 0,
          'total_transactions': (devState['total_transactions'] as num?)?.toInt() ?? 0,
        };
      }
    } catch (_) {}

    return null;
  }

  // ─── Full Sync Across All Modules ──────────────────────────────────────────

  Future<void> syncAll({bool forceFullSync = false}) async {
    if (!_auth.isLoggedIn) return;
    if (state.status == SyncStatus.syncing) return;

    final userId = _auth.currentUser!.id;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      await _executeFullSync(userId, forceFullSync: forceFullSync);

      final devName = _getDeviceDisplayName();
      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle();

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());
      state = state.copyWith(
        status: SyncStatus.idle,
        lastSyncAt: now,
        masterDeviceName: devName,
        totalSynced: txCount ?? 0,
      );
      debugPrint('[Sync] Full cross-module sync completed successfully at $now.');
    } catch (e, stack) {
      debugPrint('[Sync] Error during syncAll: $e\n$stack');
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _executeFullSync(String userId, {bool forceFullSync = false}) async {
    // Purge any legacy historical settle transactions before sync
    await _db.creditCardDao.purgeHistoricalSettlements();
    try {
      await _supabase.from('transactions').delete().eq('user_id', userId).eq('tag', 'historical_settle');
    } catch (_) {}

    // 0. Auto-clean duplicates before sync to ensure local is pristine
    final preDups = await _db.transactionsDao.deduplicateTransactions();
    if (preDups.isNotEmpty && _auth.isLoggedIn) {
      const chunkSize = 150;
      for (var i = 0; i < preDups.length; i += chunkSize) {
        final chunk = preDups.sublist(i, math.min(i + chunkSize, preDups.length));
        await _supabase.from('transactions').delete().inFilter('id', chunk);
      }
    }

    final lastSync = forceFullSync ? null : state.lastSyncAt;

    // 1. Sync Accounts & Currencies
    await _syncAccounts(userId, lastSync);

    // 2. Sync Categories (with sort order & parent_id)
    await _syncCategories(userId, lastSync);

    // 3. Sync Assets (Investments)
    await _syncAssets(userId, lastSync);

    // 4. Sync Insurance Policies
    await _syncInsurance(userId, lastSync);

    // 5. Sync Liabilities (Debts)
    await _syncLiabilities(userId, lastSync);

    // 6. Sync Budgets
    await _syncBudgets(userId, lastSync);

    // 7. Sync Recurring Rules
    await _syncRecurring(userId, lastSync);

    // 8. Sync Projects
    await _syncProjects(userId, lastSync);

    // 9. Sync Credit Card Installments
    await _syncCreditCardInstallments(userId, lastSync);

    // 10. Sync Transactions
    await _syncTransactions(userId, lastSync);

    // 11. Auto-clean duplicates after pull to guarantee zero duplicate rows
    final postDups = await _db.transactionsDao.deduplicateTransactions();
    if (postDups.isNotEmpty && _auth.isLoggedIn) {
      const chunkSize = 150;
      for (var i = 0; i < postDups.length; i += chunkSize) {
        final chunk = postDups.sublist(i, math.min(i + chunkSize, postDups.length));
        await _supabase.from('transactions').delete().inFilter('id', chunk);
      }
    }

    // Update Device State on Supabase (Active Device Wins)
    try {
      final deviceId = await _getOrCreateDeviceId();
      final devName = _getDeviceDisplayName();
      final txCount = await (_db.selectOnly(_db.transactions)..addColumns([_db.transactions.id.count()]))
          .map((row) => row.read(_db.transactions.id.count()))
          .getSingle();
      await _supabase.from('sync_device_state').upsert({
        'user_id': userId,
        'active_device_id': deviceId,
        'active_device_name': devName,
        'total_transactions': txCount ?? 0,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (_) {}
  }

  // ─── 1. Accounts ────────────────────────────────────────────────────────────

  Future<void> _syncAccounts(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    final q = _db.select(_db.accounts);
    if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
    final localRows = await q.get();

    if (localRows.isNotEmpty) {
      final payload = localRows.map((a) => {
        'id': a.id,
        'user_id': userId,
        'name': a.name,
        'account_type': a.accountType,
        'currency_code': a.currencyCode,
        'is_domestic': a.isDomestic,
        'closing_day': a.closingDay,
        'due_day': a.dueDay,
        'credit_limit_satang': a.creditLimitSatang,
        'is_active': a.isActive,
        'sync_version': a.syncVersion,
        'created_at': a.createdAt.toUtc().toIso8601String(),
        'updated_at': a.updatedAt.toUtc().toIso8601String(),
        'deleted_at': a.deletedAt?.toUtc().toIso8601String(),
      }).toList();
      await _supabase.from('accounts').upsert(payload, onConflict: 'id');
    }

    if (pushOnly) return;

    var query = _supabase.from('accounts').select().eq('user_id', userId);
    if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
    final cloudRows = await query as List<dynamic>;

    if (cloudRows.isNotEmpty) {
      await _db.batch((batch) {
        for (final r in cloudRows) {
          final row = r as Map<String, dynamic>;
          batch.insert(
            _db.accounts,
            AccountsCompanion(
              id: Value(row['id'] as String),
              name: Value(row['name'] as String),
              accountType: Value(row['account_type'] as String),
              currencyCode: Value(row['currency_code'] as String? ?? 'THB'),
              isDomestic: Value(row['is_domestic'] as bool? ?? true),
              closingDay: Value(row['closing_day'] as int?),
              dueDay: Value(row['due_day'] as int?),
              creditLimitSatang: Value(row['credit_limit_satang'] as int?),
              isActive: Value(row['is_active'] as bool? ?? true),
              syncVersion: Value((row['sync_version'] as num?)?.toInt() ?? 1),
              createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
              updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
              deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }
  }

  // ─── 2. Categories ──────────────────────────────────────────────────────────

  Future<void> _syncCategories(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    final q = _db.select(_db.categories);
    if (lastSync != null) q.where((c) => c.updatedAt.isBiggerThanValue(lastSync));
    final localRows = await q.get();

    if (localRows.isNotEmpty) {
      final payload = localRows.map((c) => {
        'id': c.id,
        'user_id': userId,
        'name_th': c.nameTh,
        'name_en': c.nameEn,
        'category_type': c.categoryType,
        'parent_id': c.parentId,
        'tax_income_type': c.taxIncomeType,
        'icon': c.icon,
        'color': c.color,
        'is_system': c.isSystem,
        'is_active': c.isActive,
        'sort_order': c.sortOrder,
        'sync_version': c.syncVersion,
        'created_at': c.createdAt.toUtc().toIso8601String(),
        'updated_at': c.updatedAt.toUtc().toIso8601String(),
        'deleted_at': c.deletedAt?.toUtc().toIso8601String(),
      }).toList();
      await _supabase.from('categories').upsert(payload, onConflict: 'id');
    }

    if (pushOnly) return;

    var query = _supabase.from('categories').select().eq('user_id', userId);
    if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
    final cloudRows = await query as List<dynamic>;

    if (cloudRows.isNotEmpty) {
      await _db.batch((batch) {
        for (final r in cloudRows) {
          final row = r as Map<String, dynamic>;
          batch.insert(
            _db.categories,
            CategoriesCompanion(
              id: Value(row['id'] as String),
              nameTh: Value(row['name_th'] as String? ?? ''),
              nameEn: Value(row['name_en'] as String? ?? ''),
              categoryType: Value(row['category_type'] as String),
              parentId: Value(row['parent_id'] as String?),
              taxIncomeType: Value(row['tax_income_type'] as String?),
              icon: Value(row['icon'] as String?),
              color: Value(row['color'] as String?),
              isSystem: Value(row['is_system'] as bool? ?? false),
              isActive: Value(row['is_active'] as bool? ?? true),
              sortOrder: Value(row['sort_order'] as int? ?? 0),
              syncVersion: Value((row['sync_version'] as num?)?.toInt() ?? 1),
              createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
              updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
              deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
            ),
            mode: InsertMode.insertOrReplace,
          );
        }
      });
    }
  }

  // ─── 3. Assets (Investments) ────────────────────────────────────────────────

  Future<void> _syncAssets(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.assets);
      if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((a) => {
          'id': a.id,
          'user_id': userId,
          'symbol': a.symbol,
          'name': a.name,
          'asset_type': a.assetType,
          'currency_code': a.currencyCode,
          'default_account_id': a.defaultAccountId,
          'market': a.market,
          'note': a.note,
          'extra_details_json': a.extraDetailsJson,
          'created_at': a.createdAt.toUtc().toIso8601String(),
          'updated_at': a.updatedAt.toUtc().toIso8601String(),
          'deleted_at': a.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('assets').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('assets').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.assets,
              AssetsCompanion(
                id: Value(row['id'] as String),
                symbol: Value(row['symbol'] as String),
                name: Value(row['name'] as String),
                assetType: Value(row['asset_type'] as String),
                currencyCode: Value(row['currency_code'] as String? ?? 'THB'),
                defaultAccountId: Value(row['default_account_id'] as String? ?? '00000000-0000-4000-8000-000000000001'),
                market: Value(row['market'] as String?),
                note: Value(row['note'] as String?),
                extraDetailsJson: Value(row['extra_details_json'] as String?),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] Assets sync info: $e');
    }
  }

  // ─── 4. Insurance Policies ──────────────────────────────────────────────────

  Future<void> _syncInsurance(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.insurancePolicies);
      if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((p) => {
          'id': p.id,
          'user_id': userId,
          'policy_name': p.policyName,
          'insurance_type': p.insuranceType,
          'sum_insured_satang': p.sumInsuredSatang,
          'medical_coverage_satang': p.medicalCoverageSatang,
          'annual_premium_satang': p.annualPremiumSatang,
          'due_date': p.dueDate?.toUtc().toIso8601String(),
          'total_periods': p.totalPeriods,
          'payment_due_day': p.paymentDueDay,
          'payment_due_month': p.paymentDueMonth,
          'note': p.note,
          'sync_version': p.syncVersion,
          'created_at': p.createdAt.toUtc().toIso8601String(),
          'updated_at': p.updatedAt.toUtc().toIso8601String(),
          'deleted_at': p.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('insurance_policies').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('insurance_policies').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.insurancePolicies,
              InsurancePoliciesCompanion(
                id: Value(row['id'] as String),
                policyName: Value(row['policy_name'] as String),
                insuranceType: Value(row['insurance_type'] as String),
                sumInsuredSatang: Value((row['sum_insured_satang'] as num?)?.toInt() ?? 0),
                medicalCoverageSatang: Value((row['medical_coverage_satang'] as num?)?.toInt() ?? 0),
                annualPremiumSatang: Value((row['annual_premium_satang'] as num?)?.toInt() ?? 0),
                dueDate: Value(row['due_date'] != null ? DateTime.parse(row['due_date'] as String).toLocal() : null),
                totalPeriods: Value(row['total_periods'] as int? ?? 1),
                paymentDueDay: Value(row['payment_due_day'] as int?),
                paymentDueMonth: Value(row['payment_due_month'] as int?),
                note: Value(row['note'] as String?),
                syncVersion: Value((row['sync_version'] as num?)?.toInt() ?? 1),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] Insurance sync info: $e');
    }
  }

  // ─── 5. Liabilities (Debts) ─────────────────────────────────────────────────

  Future<void> _syncLiabilities(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.liabilities);
      if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((l) => {
          'id': l.id,
          'user_id': userId,
          'name': l.name,
          'liability_type': l.liabilityType,
          'remaining_principal_satang': l.remainingPrincipalSatang,
          'monthly_payment_satang': l.monthlyPaymentSatang,
          'interest_rate_percent': l.interestRatePercent,
          'is_short_term': l.isShortTerm,
          'linked_account_id': l.linkedAccountId,
          'note': l.note,
          'sync_version': l.syncVersion,
          'created_at': l.createdAt.toUtc().toIso8601String(),
          'updated_at': l.updatedAt.toUtc().toIso8601String(),
          'deleted_at': l.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('liabilities').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('liabilities').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.liabilities,
              LiabilitiesCompanion(
                id: Value(row['id'] as String),
                name: Value(row['name'] as String),
                liabilityType: Value(row['liability_type'] as String),
                remainingPrincipalSatang: Value((row['remaining_principal_satang'] as num?)?.toInt() ?? 0),
                monthlyPaymentSatang: Value((row['monthly_payment_satang'] as num?)?.toInt() ?? 0),
                interestRatePercent: Value(row['interest_rate_percent'] as String? ?? '0.000000'),
                isShortTerm: Value(row['is_short_term'] as bool? ?? false),
                linkedAccountId: Value(row['linked_account_id'] as String?),
                note: Value(row['note'] as String?),
                syncVersion: Value((row['sync_version'] as num?)?.toInt() ?? 1),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] Liabilities sync info: $e');
    }
  }

  // ─── 6. Budgets ─────────────────────────────────────────────────────────────

  Future<void> _syncBudgets(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.budgets);
      if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((b) => {
          'id': b.id,
          'user_id': userId,
          'category_id': b.categoryId,
          'limit_satang': b.limitSatang,
          'is_active': b.isActive,
          'created_at': b.createdAt.toUtc().toIso8601String(),
          'updated_at': b.updatedAt.toUtc().toIso8601String(),
          'deleted_at': b.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('budgets').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('budgets').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.budgets,
              BudgetsCompanion(
                id: Value(row['id'] as String),
                categoryId: Value(row['category_id'] as String),
                limitSatang: Value((row['limit_satang'] as num).toInt()),
                isActive: Value(row['is_active'] as bool? ?? true),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] Budgets sync info: $e');
    }
  }

  // ─── 7. Recurring Rules ─────────────────────────────────────────────────────

  Future<void> _syncRecurring(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.recurringRules);
      if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((r) => {
          'id': r.id,
          'user_id': userId,
          'title': r.title,
          'transaction_type': r.transactionType,
          'source_account_id': r.sourceAccountId,
          'destination_account_id': r.destinationAccountId,
          'category_id': r.categoryId,
          'amount_satang': r.amountSatang,
          'currency_code': r.currencyCode,
          'frequency': r.frequency,
          'day_of_month': r.dayOfMonth,
          'next_run_date': r.nextRunDate.toUtc().toIso8601String(),
          'end_date': r.endDate?.toUtc().toIso8601String(),
          'is_active': r.isActive,
          'interval_units': r.intervalUnits,
          'auto_post': r.autoPost,
          'last_posted_date': r.lastPostedDate?.toUtc().toIso8601String(),
          'note': r.note,
          'created_at': r.createdAt.toUtc().toIso8601String(),
          'updated_at': r.updatedAt.toUtc().toIso8601String(),
          'deleted_at': r.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('recurring_rules').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('recurring_rules').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.recurringRules,
              RecurringRulesCompanion(
                id: Value(row['id'] as String),
                title: Value(row['title'] as String),
                transactionType: Value(row['transaction_type'] as String),
                sourceAccountId: Value(row['source_account_id'] as String),
                destinationAccountId: Value(row['destination_account_id'] as String?),
                categoryId: Value(row['category_id'] as String?),
                amountSatang: Value((row['amount_satang'] as num).toInt()),
                currencyCode: Value(row['currency_code'] as String? ?? 'THB'),
                frequency: Value(row['frequency'] as String),
                dayOfMonth: Value(row['day_of_month'] as int?),
                nextRunDate: Value(DateTime.parse(row['next_run_date'] as String).toLocal()),
                endDate: Value(row['end_date'] != null ? DateTime.parse(row['end_date'] as String).toLocal() : null),
                isActive: Value(row['is_active'] as bool? ?? true),
                intervalUnits: Value(row['interval_units'] as int? ?? 1),
                autoPost: Value(row['auto_post'] as bool? ?? true),
                lastPostedDate: Value(row['last_posted_date'] != null ? DateTime.parse(row['last_posted_date'] as String).toLocal() : null),
                note: Value(row['note'] as String?),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] Recurring rules sync info: $e');
    }
  }

  // ─── 8. Projects ────────────────────────────────────────────────────────────

  Future<void> _syncProjects(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.projects);
      if (lastSync != null) q.where((p) => p.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((p) => {
          'id': p.id,
          'user_id': userId,
          'name': p.name,
          'description': p.description,
          'target_budget_satang': p.targetBudgetSatang,
          'start_date': p.startDate.toUtc().toIso8601String(),
          'end_date': p.endDate.toUtc().toIso8601String(),
          'icon': p.icon,
          'color': p.color,
          'is_active': p.isActive,
          'sync_version': p.syncVersion,
          'created_at': p.createdAt.toUtc().toIso8601String(),
          'updated_at': p.updatedAt.toUtc().toIso8601String(),
          'deleted_at': p.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('projects').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('projects').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            if (row['id'] == '__cloud_vault_master_backup__') continue;
            batch.insert(
              _db.projects,
              ProjectsCompanion(
                id: Value(row['id'] as String),
                name: Value(row['name'] as String),
                description: Value(row['description'] as String?),
                targetBudgetSatang: Value((row['target_budget_satang'] as num).toInt()),
                startDate: Value(DateTime.parse(row['start_date'] as String).toLocal()),
                endDate: Value(DateTime.parse(row['end_date'] as String).toLocal()),
                icon: Value(row['icon'] as String?),
                color: Value(row['color'] as String?),
                isActive: Value(row['is_active'] as bool? ?? true),
                syncVersion: Value((row['sync_version'] as num?)?.toInt() ?? 1),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] _syncProjects info (cloud table may not be provisioned): $e');
    }
  }

  // ─── 9. Credit Card Installments ────────────────────────────────────────────

  Future<void> _syncCreditCardInstallments(String userId, DateTime? lastSync, {bool pushOnly = false}) async {
    try {
      final q = _db.select(_db.creditCardInstallments);
      if (lastSync != null) q.where((i) => i.updatedAt.isBiggerThanValue(lastSync));
      final localRows = await q.get();

      if (localRows.isNotEmpty) {
        final payload = localRows.map((i) => {
          'id': i.id,
          'user_id': userId,
          'transaction_id': i.transactionId,
          'account_id': i.accountId,
          'total_amount_satang': i.totalAmountSatang,
          'monthly_amount_satang': i.monthlyAmountSatang,
          'total_tenor_months': i.totalTenorMonths,
          'remaining_tenor_months': i.remainingTenorMonths,
          'start_date': i.startDate.toUtc().toIso8601String(),
          'created_at': i.createdAt.toUtc().toIso8601String(),
          'updated_at': i.updatedAt.toUtc().toIso8601String(),
          'deleted_at': i.deletedAt?.toUtc().toIso8601String(),
        }).toList();
        await _supabase.from('credit_card_installments').upsert(payload, onConflict: 'id');
      }

      if (pushOnly) return;

      var query = _supabase.from('credit_card_installments').select().eq('user_id', userId);
      if (lastSync != null) query = query.gt('updated_at', lastSync.toUtc().toIso8601String());
      final cloudRows = await query as List<dynamic>;

      if (cloudRows.isNotEmpty) {
        await _db.batch((batch) {
          for (final r in cloudRows) {
            final row = r as Map<String, dynamic>;
            batch.insert(
              _db.creditCardInstallments,
              CreditCardInstallmentsCompanion(
                id: Value(row['id'] as String),
                transactionId: Value(row['transaction_id'] as String),
                accountId: Value(row['account_id'] as String),
                totalAmountSatang: Value((row['total_amount_satang'] as num).toInt()),
                monthlyAmountSatang: Value((row['monthly_amount_satang'] as num).toInt()),
                totalTenorMonths: Value((row['total_tenor_months'] as num).toInt()),
                remainingTenorMonths: Value((row['remaining_tenor_months'] as num).toInt()),
                startDate: Value(DateTime.parse(row['start_date'] as String).toLocal()),
                createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
                updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
                deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
              ),
              mode: InsertMode.insertOrReplace,
            );
          }
        });
      }
    } catch (e) {
      debugPrint('[Sync] _syncCreditCardInstallments info (cloud table may not be provisioned): $e');
    }
  }

  // ─── 10. Transactions ────────────────────────────────────────────────────────

  Future<void> _syncTransactions(String userId, DateTime? lastSync) async {
    // 1. PUSH
    final q = _db.select(_db.transactions);
    if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
    final localRows = await q.get();

    if (localRows.isNotEmpty) {
      const chunkSize = 200;
      for (var i = 0; i < localRows.length; i += chunkSize) {
        final chunk = localRows.sublist(i, math.min(i + chunkSize, localRows.length));
        final payload = chunk.map((tx) => _txToJson(tx, userId)).toList();
        await _supabase.from('transactions').upsert(payload, onConflict: 'id');
      }
    }

    // 2. PULL: with deterministic ordering and batch inserts
    int offset = 0;
    const pageSize = 1000;

    while (true) {
      var filter = _supabase.from('transactions').select().eq('user_id', userId);
      if (lastSync != null) filter = filter.gt('updated_at', lastSync.toUtc().toIso8601String());
      final query = filter.order('id', ascending: true);

      final page = await query.range(offset, offset + pageSize - 1) as List<dynamic>;
      if (page.isEmpty) break;

      await _db.batch((batch) {
        for (final row in page) {
          final map = row as Map<String, dynamic>;
          batch.insert(
            _db.transactions,
            _rowToTxCompanion(map),
            mode: InsertMode.insertOrReplace,
          );
        }
      });

      if (page.length < pageSize) break;
      offset += pageSize;
    }
  }

  Map<String, dynamic> _txToJson(Transaction tx, String userId) => {
        'id': tx.id,
        'user_id': userId,
        'source_account_id': tx.sourceAccountId,
        'destination_account_id': tx.destinationAccountId,
        'category_id': tx.categoryId,
        'asset_id': tx.assetId,
        'import_batch_id': tx.importBatchId,
        'transaction_type': tx.transactionType,
        'amount_original_satang': tx.amountOriginalSatang,
        'currency_code': tx.currencyCode,
        'fx_rate': tx.fxRate,
        'amount_thb_satang': tx.amountThbSatang,
        'fee_thb_satang': tx.feeThbSatang,
        'tag': tx.tag,
        'tax_category': tx.taxCategory,
        'withholding_tax_satang': tx.withholdingTaxSatang,
        'transaction_date': tx.transactionDate.toUtc().toIso8601String(),
        'work_period': tx.workPeriod,
        'expected_amount_satang': tx.expectedAmountSatang,
        'note': tx.note,
        'is_cleared': tx.isCleared,
        'sync_version': tx.syncVersion,
        'created_at': tx.createdAt.toUtc().toIso8601String(),
        'updated_at': tx.updatedAt.toUtc().toIso8601String(),
        'deleted_at': tx.deletedAt?.toUtc().toIso8601String(),
      };

  TransactionsCompanion _rowToTxCompanion(Map<String, dynamic> row) {
    final id = row['id'] as String;
    final cloudVersion = (row['sync_version'] as num?)?.toInt() ?? 1;

    return TransactionsCompanion(
      id: Value(id),
      transactionType: Value(row['transaction_type'] as String),
      sourceAccountId: Value(row['source_account_id'] as String?),
      destinationAccountId: Value(row['destination_account_id'] as String?),
      categoryId: Value(row['category_id'] as String?),
      assetId: Value(row['asset_id'] as String?),
      importBatchId: Value(row['import_batch_id'] as String?),
      amountOriginalSatang: Value((row['amount_original_satang'] as num).toInt()),
      currencyCode: Value(row['currency_code'] as String? ?? 'THB'),
      fxRate: Value(row['fx_rate'] as String? ?? '1.000000'),
      amountThbSatang: Value((row['amount_thb_satang'] as num).toInt()),
      feeThbSatang: Value((row['fee_thb_satang'] as num?)?.toInt() ?? 0),
      tag: Value(row['tag'] as String?),
      taxCategory: Value(row['tax_category'] as String?),
      withholdingTaxSatang: Value((row['withholding_tax_satang'] as num?)?.toInt() ?? 0),
      transactionDate: Value(DateTime.parse(row['transaction_date'] as String).toLocal()),
      workPeriod: Value(row['work_period'] as String?),
      expectedAmountSatang: Value((row['expected_amount_satang'] as num?)?.toInt()),
      note: Value(row['note'] as String?),
      isCleared: Value(row['is_cleared'] as bool? ?? true),
      syncVersion: Value(cloudVersion),
      createdAt: Value(DateTime.parse(row['created_at'] as String).toLocal()),
      updatedAt: Value(DateTime.parse(row['updated_at'] as String).toLocal()),
      deletedAt: Value(row['deleted_at'] != null ? DateTime.parse(row['deleted_at'] as String).toLocal() : null),
    );
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final db = ref.watch(databaseProvider);
  final auth = ref.watch(authServiceProvider);
  return SyncService(supabase, db, auth);
});
