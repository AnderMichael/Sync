import '../entities/sync_log_entry.dart';

abstract class SyncLogRepository {
  Stream<List<SyncLogEntry>> watchAll();
  Future<void> insert(SyncLogEntry entry);
}
