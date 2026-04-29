import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sync_app/features/managements/domain/entities/management.dart';
import 'package:sync_app/features/managements/domain/repositories/management_repository.dart';
import 'package:sync_app/features/managements/application/cubit/managements_state.dart';

class ManagementsCubit extends Cubit<ManagementsState> {
  final ManagementRepository _repository;
  StreamSubscription<List<Management>>? _subscription;
  String _filter = 'all';

  ManagementsCubit(this._repository) : super(const ManagementsLoading()) {
    _listen();
  }

  void filterBy(String filter) {
    _filter = filter;
    _listen();
  }

  void _listen() {
    _subscription?.cancel();
    emit(const ManagementsLoading());

    final filterArg = _filter == 'all' ? null : _filter;
    _subscription = _repository
        .watchAll(syncStatusFilter: filterArg)
        .listen(
          (managements) {
            if (managements.isEmpty) {
              emit(const ManagementsEmpty());
            } else {
              emit(ManagementsLoaded(managements));
            }
          },
          onError: (_) => emit(
              const ManagementsError('No se pudieron cargar las gestiones.')),
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
