import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/management.dart';
import '../../domain/repositories/management_repository.dart';
import '../../../sync/domain/entities/sync_operation.dart';
import '../../../sync/domain/repositories/sync_repository.dart';
import 'management_form_state.dart';

class ManagementFormCubit extends Cubit<ManagementFormState> {
  final ManagementRepository _managementRepo;
  final SyncRepository _syncRepo;
  String? _editingLocalId;

  ManagementFormCubit(this._managementRepo, this._syncRepo)
      : super(const ManagementFormInitial());

  Future<void> loadForEdit(String localId) async {
    _editingLocalId = localId;
    emit(const ManagementFormLoading());
    try {
      final management = await _managementRepo.getById(localId);
      if (management != null) {
        emit(ManagementFormLoaded(management));
      } else {
        emit(const ManagementFormError('Gestión no encontrada.'));
      }
    } catch (_) {
      emit(const ManagementFormError('No se pudo cargar la gestión.'));
    }
  }

  Future<void> save({
    required String title,
    required String description,
    required DateTime date,
    required double amount,
  }) async {
    emit(const ManagementFormLoading());
    try {
      final now = DateTime.now();
      const uuid = Uuid();

      if (_editingLocalId == null) {
        final management = Management(
          localId: uuid.v4(),
          title: title,
          description: description,
          date: date,
          amount: amount,
          syncStatus: 'pending',
          createdAt: now,
          updatedAt: now,
        );
        await _managementRepo.create(management);
        await _syncRepo.insert(SyncOperation(
          id: uuid.v4(),
          localId: management.localId,
          operationType: 'create',
          status: 'pending',
          attempts: 0,
          createdAt: now,
          updatedAt: now,
        ));
      } else {
        final existing = await _managementRepo.getById(_editingLocalId!);
        if (existing == null) {
          emit(const ManagementFormError('No se encontró la gestión.'));
          return;
        }
        final updated = existing.copyWith(
          title: title,
          description: description,
          date: date,
          amount: amount,
          syncStatus: 'pending',
          updatedAt: now,
        );
        await _managementRepo.update(updated);
        await _syncRepo.insert(SyncOperation(
          id: uuid.v4(),
          localId: _editingLocalId!,
          operationType: 'update',
          status: 'pending',
          attempts: 0,
          createdAt: now,
          updatedAt: now,
        ));
      }
      emit(const ManagementFormSuccess());
    } catch (_) {
      emit(const ManagementFormError('No se pudo guardar la gestión.'));
    }
  }
}
