import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/sync_operation.dart';
import '../../domain/repositories/sync_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  final AppDatabase _db;

  SyncRepositoryImpl(this._db);

  @override
  Stream<List<SyncOperation>> watchQueue() {
    final query = _db.select(_db.syncQueueTable).join([
      leftOuterJoin(
        _db.managementsTable,
        _db.managementsTable.localId.equalsExp(_db.syncQueueTable.localId),
      ),
    ]);
    query.where(_db.syncQueueTable.status.isNotValue('synced'));
    query.orderBy([
      OrderingTerm(
          expression: _db.syncQueueTable.createdAt, mode: OrderingMode.desc),
    ]);
    return query.watch().map((rows) => rows.map((row) {
          final op = row.readTable(_db.syncQueueTable);
          final mgmt = row.readTableOrNull(_db.managementsTable);
          return _toEntity(op, mgmt?.title);
        }).toList());
  }

  @override
  Stream<List<SyncOperation>> watchLog() {
    final query = _db.select(_db.syncQueueTable).join([
      leftOuterJoin(
        _db.managementsTable,
        _db.managementsTable.localId.equalsExp(_db.syncQueueTable.localId),
      ),
    ]);
    query.where(_db.syncQueueTable.status.equals('synced'));
    query.orderBy([
      OrderingTerm(
          expression: _db.syncQueueTable.syncedAt, mode: OrderingMode.desc),
    ]);
    return query.watch().map((rows) => rows.map((row) {
          final op = row.readTable(_db.syncQueueTable);
          final mgmt = row.readTableOrNull(_db.managementsTable);
          return _toEntity(op, mgmt?.title);
        }).toList());
  }

  @override
  Future<List<SyncOperation>> getPending() async {
    final rows = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([
            (t) =>
                OrderingTerm(expression: t.createdAt, mode: OrderingMode.asc)
          ]))
        .get();
    return rows.map((r) => _toEntity(r, null)).toList();
  }

  @override
  Future<void> insert(SyncOperation op) async {
    await _db.into(_db.syncQueueTable).insert(SyncQueueTableCompanion(
          id: Value(op.id),
          localId: Value(op.localId),
          operationType: Value(op.operationType),
          status: Value(op.status),
          attempts: Value(op.attempts),
          lastError: Value(op.lastError),
          createdAt: Value(op.createdAt),
          updatedAt: Value(op.updatedAt),
          syncedAt: Value(op.syncedAt),
        ));
  }

  @override
  Future<void> updateStatus(
    String id,
    String status, {
    int? attempts,
    String? lastError,
    DateTime? syncedAt,
  }) async {
    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id)))
        .write(SyncQueueTableCompanion(
      status: Value(status),
      attempts: attempts != null ? Value(attempts) : const Value.absent(),
      lastError: lastError != null ? Value(lastError) : const Value.absent(),
      syncedAt: syncedAt != null ? Value(syncedAt) : const Value.absent(),
      updatedAt: Value(DateTime.now()),
    ));
  }

  @override
  Future<void> resetFailed() async {
    final failed = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.status.equals('failed')))
        .get();

    await (_db.update(_db.syncQueueTable)
          ..where((t) => t.status.equals('failed')))
        .write(SyncQueueTableCompanion(
      status: const Value('pending'),
      attempts: const Value(0),
      lastError: const Value<String?>(null),
      updatedAt: Value(DateTime.now()),
    ));

    for (final op in failed) {
      await (_db.update(_db.managementsTable)
            ..where((t) => t.localId.equals(op.localId)))
          .write(ManagementsTableCompanion(
        syncStatus: const Value('pending'),
        updatedAt: Value(DateTime.now()),
      ));
    }
  }

  @override
  Future<void> resetOne(String id) async {
    final rows = await (_db.select(_db.syncQueueTable)
          ..where((t) => t.id.equals(id)))
        .get();
    if (rows.isEmpty) return;

    await (_db.update(_db.syncQueueTable)..where((t) => t.id.equals(id)))
        .write(SyncQueueTableCompanion(
      status: const Value('pending'),
      attempts: const Value(0),
      lastError: const Value<String?>(null),
      updatedAt: Value(DateTime.now()),
    ));

    await (_db.update(_db.managementsTable)
          ..where((t) => t.localId.equals(rows.first.localId)))
        .write(ManagementsTableCompanion(
      syncStatus: const Value('pending'),
      updatedAt: Value(DateTime.now()),
    ));
  }

  SyncOperation _toEntity(SyncQueueRow row, String? managementTitle) =>
      SyncOperation(
        id: row.id,
        localId: row.localId,
        operationType: row.operationType,
        status: row.status,
        attempts: row.attempts,
        lastError: row.lastError,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
        syncedAt: row.syncedAt,
        managementTitle: managementTitle,
      );
}
