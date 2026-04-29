import 'package:sync_app/features/bitacora/domain/entities/sync_log_entry.dart';

abstract class SyncLogRepository {
  Stream<List<SyncLogEntry>> watchAll();
  Future<void> insert(SyncLogEntry entry);
}
