import 'package:uuid/uuid.dart';
import 'package:sync_app/features/bitacora/domain/entities/sync_log_entry.dart';
import 'package:sync_app/features/bitacora/domain/repositories/sync_log_repository.dart';
import 'package:sync_app/features/managements/domain/repositories/management_repository.dart';
import 'package:sync_app/features/sync/domain/entities/sync_operation.dart';
import 'package:sync_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:sync_app/core/network/fake_backend_service.dart';

class SyncEngine {
  final SyncRepository _syncRepo;
  final ManagementRepository _managementRepo;
  final FakeBackendService _backend;
  final SyncLogRepository _logRepo;
  final _uuid = const Uuid();

  SyncEngine(
    this._syncRepo,
    this._managementRepo,
    this._backend,
    this._logRepo,
  );

  Future<void> syncPending() async {
    final operations = await _syncRepo.getPending();
    for (final op in operations) {
      await _processOperation(op);
    }
  }

  Future<void> _processOperation(SyncOperation operation) async {
    await _managementRepo.updateSyncStatus(operation.localId, 'syncing');

    final management = await _managementRepo.getById(operation.localId);
    final snapshot = management?.toJson() ?? {'localId': operation.localId};

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
        await _logRepo.insert(SyncLogEntry(
          id: _uuid.v4(),
          localId: operation.localId,
          operationType: operation.operationType,
          status: 'synced',
          gestionVersion: snapshot,
          attempts: attempt,
          occurredAt: DateTime.now(),
        ));
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
          await _logRepo.insert(SyncLogEntry(
            id: _uuid.v4(),
            localId: operation.localId,
            operationType: operation.operationType,
            status: 'failed',
            gestionVersion: snapshot,
            attempts: attempt,
            errorMessage: e.toString(),
            occurredAt: DateTime.now(),
          ));
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
