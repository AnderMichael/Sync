import '../entities/sync_operation.dart';

abstract class SyncRepository {
  Stream<List<SyncOperation>> watchAll();
  Future<List<SyncOperation>> getPending();
  Future<void> insert(SyncOperation operation);
  Future<void> updateStatus(
    String id,
    String status, {
    int? attempts,
    String? lastError,
    DateTime? syncedAt,
  });
  Future<void> resetFailed();
}
