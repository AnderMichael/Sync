import 'package:sync_app/features/managements/domain/entities/management.dart';

abstract class ManagementRepository {
  Stream<List<Management>> watchAll({String? syncStatusFilter});
  Future<void> create(Management management);
  Future<void> update(Management management);
  Future<Management?> getById(String localId);
  Future<void> updateSyncStatus(String localId, String syncStatus);
}
