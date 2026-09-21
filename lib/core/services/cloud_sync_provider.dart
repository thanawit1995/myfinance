import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'google_drive_sync_service.dart';

final googleDriveSyncServiceProvider = Provider<GoogleDriveSyncService>((ref) {
  return GoogleDriveSyncService(
    db: ref.watch(databaseProvider),
    transactionsDao: ref.watch(transactionsDaoProvider),
    accountsDao: ref.watch(accountsDaoProvider),
    syncDao: ref.watch(syncDaoProvider),
  );
});

// Backward-compatibility alias
final cloudSyncServiceProvider = googleDriveSyncServiceProvider;

