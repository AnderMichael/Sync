import 'package:equatable/equatable.dart';
import '../../domain/entities/management.dart';

sealed class ManagementFormState extends Equatable {
  const ManagementFormState();
}

class ManagementFormInitial extends ManagementFormState {
  const ManagementFormInitial();
  @override
  List<Object?> get props => [];
}

class ManagementFormLoading extends ManagementFormState {
  const ManagementFormLoading();
  @override
  List<Object?> get props => [];
}

class ManagementFormLoaded extends ManagementFormState {
  final Management management;
  const ManagementFormLoaded(this.management);
  @override
  List<Object?> get props => [management];
}

class ManagementFormSuccess extends ManagementFormState {
  const ManagementFormSuccess();
  @override
  List<Object?> get props => [];
}

class ManagementFormError extends ManagementFormState {
  final String message;
  const ManagementFormError(this.message);
  @override
  List<Object?> get props => [message];
}
