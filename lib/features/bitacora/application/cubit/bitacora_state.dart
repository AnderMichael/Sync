import 'package:equatable/equatable.dart';
import '../../../sync/domain/entities/sync_operation.dart';

sealed class BitacoraState extends Equatable {
  const BitacoraState();
}

class BitacoraLoading extends BitacoraState {
  const BitacoraLoading();
  @override
  List<Object?> get props => [];
}

class BitacoraLoaded extends BitacoraState {
  final List<SyncOperation> entries;
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
