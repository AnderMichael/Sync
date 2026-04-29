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
    _subscription = _repository.watchAll().listen(
      (operations) {
        final summary = _buildSummary(operations);
        if (_isSyncing) {
          emit(SyncSyncing(operations: operations, summary: summary));
        } else {
          emit(SyncLoaded(operations: operations, summary: summary));
        }
      },
      onError: (_) => emit(const SyncError('No se pudo sincronizar la cola.')),
    );
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    final summary = state is SyncLoaded
        ? (state as SyncLoaded).summary
        : SyncSummary.empty();
    emit(SyncSyncing(operations: ops, summary: summary));

    try {
      await _engine.syncPending();
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> retryFailed() async {
    if (_isSyncing) return;
    _isSyncing = true;

    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    final summary = state is SyncLoaded
        ? (state as SyncLoaded).summary
        : SyncSummary.empty();
    emit(SyncSyncing(operations: ops, summary: summary));

    try {
      await _engine.retryFailed();
    } finally {
      _isSyncing = false;
    }
  }

  SyncSummary _buildSummary(List<SyncOperation> operations) {
    final pending = operations
        .where((o) => o.status == 'pending' || o.status == 'syncing')
        .length;
    final synced = operations.where((o) => o.status == 'synced').length;
    final failed = operations.where((o) => o.status == 'failed').length;

    DateTime? lastSync;
    final synced_ = operations.where((o) => o.syncedAt != null);
    if (synced_.isNotEmpty) {
      lastSync = synced_
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
