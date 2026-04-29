import '../../../managements/domain/repositories/management_repository.dart';
import '../../../sync/domain/entities/sync_operation.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import '../../../../core/network/fake_backend_service.dart';

class SyncEngine {
  final SyncRepository _syncRepo;
  final ManagementRepository _managementRepo;
  final FakeBackendService _backend;

  SyncEngine(this._syncRepo, this._managementRepo, this._backend);

  Future<void> syncPending() async {
    final operations = await _syncRepo.getPending();
    for (final op in operations) {
      await _processOperation(op);
    }
  }

  Future<void> _processOperation(SyncOperation operation) async {
    await _managementRepo.updateSyncStatus(operation.localId, 'syncing');

    for (int attempt = 1; attempt <= 3; attempt++) {
      await _syncRepo.updateStatus(operation.id, 'syncing', attempts: attempt);
      try {
        await _backend.syncOperation(operation.id);
        await _syncRepo.updateStatus(
          operation.id,
          'synced',
          attempts: attempt,
          syncedAt: DateTime.now(),
        );
        await _managementRepo.updateSyncStatus(operation.localId, 'synced');
        return;
      } catch (e) {
        if (attempt < 3) {
          await Future.delayed(Duration(seconds: attempt));
        } else {
          await _syncRepo.updateStatus(
            operation.id,
            'failed',
            attempts: attempt,
            lastError: e.toString(),
          );
          await _managementRepo.updateSyncStatus(operation.localId, 'failed');
        }
      }
    }
  }

  Future<void> retryFailed() async {
    await _syncRepo.resetFailed();
    await syncPending();
  }

  Future<void> retryOne(String operationId) async {
    await _syncRepo.resetOne(operationId);
    final pending = await _syncRepo.getPending();
    final op = pending.where((o) => o.id == operationId).firstOrNull;
    if (op != null) await _processOperation(op);
  }
}
