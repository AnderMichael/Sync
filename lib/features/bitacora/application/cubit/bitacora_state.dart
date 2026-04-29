import 'package:equatable/equatable.dart';
import 'package:sync_app/features/bitacora/domain/entities/sync_log_entry.dart';

sealed class BitacoraState extends Equatable {
  const BitacoraState();
}

class BitacoraLoading extends BitacoraState {
  const BitacoraLoading();
  @override
  List<Object?> get props => [];
}

class BitacoraLoaded extends BitacoraState {
  final List<SyncLogEntry> entries;
  const BitacoraLoaded(this.entries);
  @override
  List<Object?> get props => [entries];
}

class BitacoraError extends BitacoraState {
  final String message;
  const BitacoraError(this.message);
  @override
  List<Object?> get props => [message];
}
