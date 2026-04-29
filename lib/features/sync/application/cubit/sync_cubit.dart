import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_app/core/network/connectivity_service.dart';
import 'package:sync_app/features/sync/domain/entities/sync_operation.dart';
import 'package:sync_app/features/sync/domain/entities/sync_summary.dart';
import 'package:sync_app/features/sync/domain/repositories/sync_repository.dart';
import 'package:sync_app/features/sync/application/services/sync_engine.dart';
import 'package:sync_app/features/sync/application/cubit/sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncEngine _engine;
  final SyncRepository _repository;
  final ConnectivityService _connectivity;
  StreamSubscription<List<SyncOperation>>? _queueSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;
  bool _isOffline = false;

  SyncCubit(this._engine, this._repository, this._connectivity)
      : super(const SyncLoading()) {
    _initConnectivity();
    _listenQueue();
  }

  Future<void> _initConnectivity() async {
    _isOffline = !(await _connectivity.isConnected());
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((connected) {
      _isOffline = !connected;
      _reEmitWithOffline();
    });
  }

  void _reEmitWithOffline() {
    final current = state;
    if (current is SyncLoaded) {
      emit(SyncLoaded(
        operations: current.operations,
        summary: current.summary,
        isOffline: _isOffline,
      ));
    } else if (current is SyncSyncing) {
      emit(SyncSyncing(
        operations: current.operations,
        summary: current.summary,
        isOffline: _isOffline,
      ));
    }
  }

  void _listenQueue() {
    _queueSubscription?.cancel();
    _queueSubscription = _repository.watchQueue().listen(
      (operations) {
        if (_isSyncing) {
          emit(SyncSyncing(
            operations: operations,
            summary: _buildSummary(operations),
            isOffline: _isOffline,
          ));
        } else {
          emit(SyncLoaded(
            operations: operations,
            summary: _buildSummary(operations),
            isOffline: _isOffline,
          ));
        }
      },
      onError: (_) => emit(const SyncError('No se pudo sincronizar la cola.')),
    );
  }

  Future<void> sync() async {
    if (_isSyncing) return;
    if (_isOffline) return;

    await _repository.clearCompleted();

    _isSyncing = true;
    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    emit(SyncSyncing(
      operations: ops,
      summary: _buildSummary(ops),
      isOffline: _isOffline,
    ));

    try {
      await _engine.syncPending();
    } finally {
      _isSyncing = false;
      _listenQueue();
    }
  }

  Future<void> retrySingle(String operationId) async {
    if (_isSyncing) return;
    if (_isOffline) return;
    _isSyncing = true;

    final ops = state is SyncLoaded
        ? (state as SyncLoaded).operations
        : <SyncOperation>[];
    emit(SyncSyncing(
      operations: ops,
      summary: _buildSummary(ops),
      isOffline: _isOffline,
    ));

    try {
      await _engine.retryOne(operationId);
    } finally {
      _isSyncing = false;
      _listenQueue();
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
    _queueSubscription?.cancel();
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
