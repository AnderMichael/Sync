import 'package:equatable/equatable.dart';
import 'package:sync_app/features/managements/domain/entities/management.dart';

sealed class ManagementsState extends Equatable {
  const ManagementsState();
}

class ManagementsLoading extends ManagementsState {
  const ManagementsLoading();
  @override
  List<Object?> get props => [];
}

class ManagementsEmpty extends ManagementsState {
  const ManagementsEmpty();
  @override
  List<Object?> get props => [];
}

class ManagementsLoaded extends ManagementsState {
  final List<Management> managements;
  const ManagementsLoaded(this.managements);
  @override
  List<Object?> get props => [managements];
}

class ManagementsError extends ManagementsState {
  final String message;
  const ManagementsError(this.message);
  @override
  List<Object?> get props => [message];
}
