import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/management.dart';
import '../../domain/repositories/management_repository.dart';

class ManagementRepositoryImpl implements ManagementRepository {
  final AppDatabase _db;

  ManagementRepositoryImpl(this._db);

  @override
  Stream<List<Management>> watchAll({String? syncStatusFilter}) {
    final query = _db.select(_db.managementsTable);
    if (syncStatusFilter != null) {
      query.where((t) => t.syncStatus.equals(syncStatusFilter));
    }
    query.orderBy([
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return query.watch().map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> create(Management m) async {
    await _db.into(_db.managementsTable).insert(ManagementsTableCompanion(
          localId: Value(m.localId),
          title: Value(m.title),
          description: Value(m.description),
          date: Value(m.date),
          amount: Value(m.amount),
          syncStatus: Value(m.syncStatus),
          createdAt: Value(m.createdAt),
          updatedAt: Value(m.updatedAt),
        ));
  }

  @override
  Future<void> update(Management m) async {
    await (_db.update(_db.managementsTable)
          ..where((t) => t.localId.equals(m.localId)))
        .write(ManagementsTableCompanion(
      title: Value(m.title),
      description: Value(m.description),
      date: Value(m.date),
      amount: Value(m.amount),
      syncStatus: Value(m.syncStatus),
      updatedAt: Value(m.updatedAt),
    ));
  }

  @override
  Future<Management?> getById(String localId) async {
    final row = await (_db.select(_db.managementsTable)
          ..where((t) => t.localId.equals(localId)))
        .getSingleOrNull();
    return row == null ? null : _toEntity(row);
  }

  @override
  Future<void> updateSyncStatus(String localId, String syncStatus) async {
    await (_db.update(_db.managementsTable)
          ..where((t) => t.localId.equals(localId)))
        .write(ManagementsTableCompanion(
      syncStatus: Value(syncStatus),
      updatedAt: Value(DateTime.now()),
    ));
  }

  Management _toEntity(ManagementRow row) => Management(
        localId: row.localId,
        title: row.title,
        description: row.description,
        date: row.date,
        amount: row.amount,
        syncStatus: row.syncStatus,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}
