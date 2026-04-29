import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/entities/sync_summary.dart';
import '../../domain/repositories/sync_repository.dart';
import '../services/sync_engine.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncEngine _engine;
  final SyncRepository _repository;
  StreamSubscription<List<SyncOperation>>? _subscription;
  bool _isSyncing = false;

  SyncCubit(this._engine, this._repository) : super(const SyncLoading()) {
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = _repository.watchQueue().listen(
      (operations) {
        if (_isSyncing) {
          emit(SyncSyncing(
              operations: operations, summary: _buildSummary(operations)));
        } else {
          emit(SyncLoaded(
              operations: operations, summary: _buildSummary(operations)));
        }
      },
      onError: (_) => emit(const SyncError('No se pudo sincronizar la cola.')),
    );
  }

  Future<void> sync() async {
    if (_isSyncing) return;

    await _repository.clearCompleted();

    _isSyncing = true;
    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    emit(SyncSyncing(operations: ops, summary: _buildSummary(ops)));

    try {
      await _engine.syncPending();
    } finally {
      _isSyncing = false;
      _listen();
    }
  }

  Future<void> retrySingle(String operationId) async {
    if (_isSyncing) return;
    _isSyncing = true;

    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    emit(SyncSyncing(operations: ops, summary: _buildSummary(ops)));

    try {
      await _engine.retryOne(operationId);
    } finally {
      _isSyncing = false;
      _listen();
    }
  }

  SyncSummary _buildSummary(List<SyncOperation> operations) {
    final pending = operations
        .where((o) => o.status == 'pending' || o.status == 'syncing')
        .length;
    final synced = operations.where((o) => o.status == 'synced').length;
    final failed = operations.where((o) => o.status == 'failed').length;

    DateTime? lastSync;
    final withSyncedAt = operations.where((o) => o.syncedAt != null);
    if (withSyncedAt.isNotEmpty) {
      lastSync = withSyncedAt
          .map((o) => o.syncedAt!)
          .reduce((a, b) => a.isAfter(b) ? a : b);
    }

    return SyncSummary(
        pending: pending, synced: synced, failed: failed, lastSync: lastSync);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
