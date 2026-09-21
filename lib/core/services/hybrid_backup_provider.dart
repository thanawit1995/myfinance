import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_provider.dart';
import 'hybrid_backup_service.dart';

final hybridBackupServiceProvider = Provider<HybridBackupService>((ref) {
  final db = ref.watch(databaseProvider);
  return HybridBackupService(db: db);
});
