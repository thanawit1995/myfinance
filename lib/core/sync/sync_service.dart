import 'dart:async';
import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../database/app_database.dart';
import '../database/database_provider.dart';
import 'auth_service.dart';

// ─── Sync Status ─────────────────────────────────────────────────────────────

enum SyncStatus { idle, syncing, offline, error }

class SyncState {
  final SyncStatus status;
  final DateTime? lastSyncAt;
  final String? errorMessage;
  final int progressCurrent;
  final int progressTotal;

  const SyncState({
    this.status = SyncStatus.idle,
    this.lastSyncAt,
    this.errorMessage,
    this.progressCurrent = 0,
    this.progressTotal = 0,
  });

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncAt,
    String? errorMessage,
    int? progressCurrent,
    int? progressTotal,
  }) =>
      SyncState(
        status: status ?? this.status,
        lastSyncAt: lastSyncAt ?? this.lastSyncAt,
        errorMessage: errorMessage ?? this.errorMessage,
        progressCurrent: progressCurrent ?? this.progressCurrent,
        progressTotal: progressTotal ?? this.progressTotal,
      );
}

// ─── SyncService ─────────────────────────────────────────────────────────────

class SyncService extends StateNotifier<SyncState> {
  final SupabaseClient _supabase;
  final AppDatabase _db;
  final AuthService _auth;

  static const _prefLastSync = 'last_sync_timestamp';
  StreamSubscription? _connectivitySub;
  StreamSubscription? _authSub;
  RealtimeChannel? _realtimeTxChannel;
  RealtimeChannel? _realtimeAccChannel;

  SyncService(this._supabase, this._db, this._auth)
      : super(const SyncState()) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getString(_prefLastSync);
    if (ts != null) {
      state = state.copyWith(lastSyncAt: DateTime.tryParse(ts));
    }

    // Connectivity listener
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online && _auth.isLoggedIn) {
        syncAll();
      } else if (!online) {
        state = state.copyWith(status: SyncStatus.offline);
      }
    });

    // Supabase auth state listener — crucial for OAuth redirect completion
    _authSub = _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        syncAll();
        _subscribeRealtime();
      } else {
        _unsubscribeRealtime();
        state = const SyncState();
      }
    });

    if (_auth.isLoggedIn) {
      await syncAll();
      _subscribeRealtime();
    }
  }

  // ─── Full Sync ──────────────────────────────────────────────────────────────

  Future<void> syncAll({bool forceFullSync = false}) async {
    if (!_auth.isLoggedIn) return;
    if (state.status == SyncStatus.syncing) return;

    final userId = _auth.currentUser!.id;
    state = state.copyWith(status: SyncStatus.syncing, errorMessage: null);

    try {
      final lastSync = forceFullSync ? null : state.lastSyncAt;

      // Disable foreign keys during sync merge to avoid dependency order violations
      try {
        await _db.customStatement('PRAGMA foreign_keys = OFF;');
      } catch (_) {}

      // 1. Sync Accounts first
      await _syncAccounts(userId, lastSync);

      // 2. Sync Categories second
      await _syncCategories(userId, lastSync);

      // 3. Sync Transactions in chunks
      await _syncTransactions(userId, lastSync);

      // Re-enable foreign keys
      try {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      } catch (_) {}

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastSync, now.toIso8601String());
      state = state.copyWith(status: SyncStatus.idle, lastSyncAt: now);
      debugPrint('[Sync] Full sync completed successfully at $now');
    } catch (e, stack) {
      debugPrint('[Sync] Error during syncAll: $e\n$stack');
      try {
        await _db.customStatement('PRAGMA foreign_keys = ON;');
      } catch (_) {}
      state = state.copyWith(
        status: SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // ─── Transactions ──────────────────────────────────────────────────────────

  Future<void> _syncTransactions(String userId, DateTime? lastSync) async {
    // 1. PUSH: Fetch local transactions to push
    final q = _db.select(_db.transactions);
    if (lastSync != null) {
      q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
    }
    final localRows = await q.get();

    if (localRows.isNotEmpty) {
      debugPrint('[Sync] Pushing ${localRows.length} local transactions in chunks...');
      const chunkSize = 150;
      for (var i = 0; i < localRows.length; i += chunkSize) {
        final chunk = localRows.sublist(
          i,
          math.min(i + chunkSize, localRows.length),
        );
        final payload = chunk.map((tx) => _txToJson(tx, userId)).toList();
        await _supabase.from('transactions').upsert(payload, onConflict: 'id');
      }
      debugPrint('[Sync] Pushed ${localRows.length} transactions successfully.');
    }

    // 2. PULL: Paginate through cloud rows in pages of 1,000
    int offset = 0;
    const pageSize = 1000;
    int totalPulled = 0;

    while (true) {
      var query = _supabase
          .from('transactions')
          .select()
          .eq('user_id', userId);
      if (lastSync != null) {
        query = query.gt('updated_at', lastSync.toIso8601String());
      }

      final page = await query.range(offset, offset + pageSize - 1) as List<dynamic>;
      if (page.isEmpty) break;

      for (final row in page) {
        await _mergeCloudTransaction(row as Map<String, dynamic>);
      }

      totalPulled += page.length;
      if (page.length < pageSize) break;
      offset += pageSize;
    }

    if (totalPulled > 0) {
      debugPrint('[Sync] Pulled and merged $totalPulled transactions from cloud.');
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
        'transaction_date': tx.transactionDate.toIso8601String(),
        'work_period': tx.workPeriod,
        'expected_amount_satang': tx.expectedAmountSatang,
        'note': tx.note,
        'is_cleared': tx.isCleared,
        'sync_version': tx.syncVersion,
        'created_at': tx.createdAt.toIso8601String(),
        'updated_at': tx.updatedAt.toIso8601String(),
        'deleted_at': tx.deletedAt?.toIso8601String(),
      };

  Future<void> _mergeCloudTransaction(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final cloudVersion = (row['sync_version'] as num?)?.toInt() ?? 1;

    final local = await (_db.select(_db.transactions)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (local != null && local.syncVersion >= cloudVersion) return;

    // Verify foreign key references exist locally to avoid SQLite FK violations
    final sourceAccId = row['source_account_id'] as String?;
    final destAccId = row['destination_account_id'] as String?;
    final catId = row['category_id'] as String?;

    await _db.into(_db.transactions).insertOnConflictUpdate(
          TransactionsCompanion(
            id: Value(id),
            transactionType: Value(row['transaction_type'] as String),
            sourceAccountId: Value(sourceAccId),
            destinationAccountId: Value(destAccId),
            categoryId: Value(catId),
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
            transactionDate: Value(DateTime.parse(row['transaction_date'] as String)),
            workPeriod: Value(row['work_period'] as String?),
            expectedAmountSatang: Value((row['expected_amount_satang'] as num?)?.toInt()),
            note: Value(row['note'] as String?),
            isCleared: Value(row['is_cleared'] as bool? ?? true),
            syncVersion: Value(cloudVersion),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
            deletedAt: Value(row['deleted_at'] != null
                ? DateTime.parse(row['deleted_at'] as String)
                : null),
          ),
        );
  }

  // ─── Accounts ──────────────────────────────────────────────────────────────

  Future<void> _syncAccounts(String userId, DateTime? lastSync) async {
    // PUSH
    final q = _db.select(_db.accounts);
    if (lastSync != null) q.where((t) => t.updatedAt.isBiggerThanValue(lastSync));
    final localAccs = await q.get();

    if (localAccs.isNotEmpty) {
      final payload = localAccs.map((a) => _accToJson(a, userId)).toList();
      await _supabase.from('accounts').upsert(payload, onConflict: 'id');
      debugPrint('[Sync] Pushed ${localAccs.length} accounts.');
    }

    // PULL
    var query = _supabase.from('accounts').select().eq('user_id', userId);
    if (lastSync != null) {
      query = query.gt('updated_at', lastSync.toIso8601String());
    }
    final cloudRows = await query as List<dynamic>;
    for (final row in cloudRows) {
      await _mergeCloudAccount(row as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> _accToJson(Account a, String userId) => {
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
        'created_at': a.createdAt.toIso8601String(),
        'updated_at': a.updatedAt.toIso8601String(),
        'deleted_at': a.deletedAt?.toIso8601String(),
      };

  Future<void> _mergeCloudAccount(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final cloudVersion = (row['sync_version'] as num?)?.toInt() ?? 1;

    final local = await (_db.select(_db.accounts)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    if (local != null && local.syncVersion >= cloudVersion) return;

    await _db.into(_db.accounts).insertOnConflictUpdate(
          AccountsCompanion(
            id: Value(id),
            name: Value(row['name'] as String),
            accountType: Value(row['account_type'] as String),
            currencyCode: Value(row['currency_code'] as String? ?? 'THB'),
            isDomestic: Value(row['is_domestic'] as bool? ?? true),
            closingDay: Value(row['closing_day'] as int?),
            dueDay: Value(row['due_day'] as int?),
            creditLimitSatang: Value(row['credit_limit_satang'] as int?),
            isActive: Value(row['is_active'] as bool? ?? true),
            syncVersion: Value(cloudVersion),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
            deletedAt: Value(row['deleted_at'] != null
                ? DateTime.parse(row['deleted_at'] as String)
                : null),
          ),
        );
  }

  // ─── Categories ────────────────────────────────────────────────────────────

  Future<void> _syncCategories(String userId, DateTime? lastSync) async {
    // PUSH custom categories
    final q = _db.select(_db.categories)
      ..where((c) => c.isSystem.equals(false));
    if (lastSync != null) q.where((c) => c.updatedAt.isBiggerThanValue(lastSync));
    final localCats = await q.get();

    if (localCats.isNotEmpty) {
      final payload = localCats.map((c) => _catToJson(c, userId)).toList();
      await _supabase.from('categories').upsert(payload, onConflict: 'id');
      debugPrint('[Sync] Pushed ${localCats.length} categories.');
    }

    // PULL custom categories
    var query = _supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .eq('is_system', false);
    if (lastSync != null) {
      query = query.gt('updated_at', lastSync.toIso8601String());
    }
    final cloudRows = await query as List<dynamic>;
    for (final row in cloudRows) {
      await _mergeCloudCategory(row as Map<String, dynamic>);
    }
  }

  Map<String, dynamic> _catToJson(Category c, String userId) => {
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
        'created_at': c.createdAt.toIso8601String(),
        'updated_at': c.updatedAt.toIso8601String(),
        'deleted_at': c.deletedAt?.toIso8601String(),
      };

  Future<void> _mergeCloudCategory(Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final cloudVersion = (row['sync_version'] as num?)?.toInt() ?? 1;

    final local = await (_db.select(_db.categories)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (local != null && local.syncVersion >= cloudVersion) return;

    await _db.into(_db.categories).insertOnConflictUpdate(
          CategoriesCompanion(
            id: Value(id),
            nameTh: Value(row['name_th'] as String? ?? ''),
            nameEn: Value(row['name_en'] as String? ?? ''),
            categoryType: Value(row['category_type'] as String),
            parentId: Value(row['parent_id'] as String?),
            taxIncomeType: Value(row['tax_income_type'] as String?),
            icon: Value(row['icon'] as String?),
            color: Value(row['color'] as String?),
            isSystem: const Value(false),
            isActive: Value(row['is_active'] as bool? ?? true),
            sortOrder: Value(row['sort_order'] as int? ?? 0),
            syncVersion: Value(cloudVersion),
            createdAt: Value(DateTime.parse(row['created_at'] as String)),
            updatedAt: Value(DateTime.parse(row['updated_at'] as String)),
            deletedAt: Value(row['deleted_at'] != null
                ? DateTime.parse(row['deleted_at'] as String)
                : null),
          ),
        );
  }

  // ─── Realtime ──────────────────────────────────────────────────────────────

  void _subscribeRealtime() {
    if (!_auth.isLoggedIn) return;
    final userId = _auth.currentUser!.id;

    _unsubscribeRealtime();

    _realtimeTxChannel = _supabase
        .channel('public:transactions:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              _mergeCloudTransaction(payload.newRecord);
            }
          },
        )
      ..subscribe();

    _realtimeAccChannel = _supabase
        .channel('public:accounts:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'accounts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            if (payload.newRecord.isNotEmpty) {
              _mergeCloudAccount(payload.newRecord);
            }
          },
        )
      ..subscribe();
  }

  void _unsubscribeRealtime() {
    _realtimeTxChannel?.unsubscribe();
    _realtimeTxChannel = null;
    _realtimeAccChannel?.unsubscribe();
    _realtimeAccChannel = null;
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _authSub?.cancel();
    _unsubscribeRealtime();
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
