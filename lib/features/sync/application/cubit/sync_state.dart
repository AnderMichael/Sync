import 'package:equatable/equatable.dart';
import 'package:sync_app/features/sync/domain/entities/sync_operation.dart';
import 'package:sync_app/features/sync/domain/entities/sync_summary.dart';

sealed class SyncState extends Equatable {
  const SyncState();
}

class SyncInitial extends SyncState {
  const SyncInitial();
  @override
  List<Object?> get props => [];
}

class SyncLoading extends SyncState {
  const SyncLoading();
  @override
  List<Object?> get props => [];
}

class SyncLoaded extends SyncState {
  final List<SyncOperation> operations;
  final SyncSummary summary;
  final bool isOffline;
  const SyncLoaded({
    required this.operations,
    required this.summary,
    this.isOffline = false,
  });
  @override
  List<Object?> get props => [operations, summary, isOffline];
}

class SyncSyncing extends SyncState {
  final List<SyncOperation> operations;
  final SyncSummary summary;
  final bool isOffline;
  const SyncSyncing({
    required this.operations,
    required this.summary,
    this.isOffline = false,
  });
  @override
  List<Object?> get props => [operations, summary, isOffline];
}

class SyncError extends SyncState {
  final String message;
  const SyncError(this.message);
  @override
  List<Object?> get props => [message];
}
