import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:sync_app/core/database/app_database.dart';
import 'package:sync_app/features/bitacora/domain/entities/sync_log_entry.dart';
import 'package:sync_app/features/bitacora/domain/repositories/sync_log_repository.dart';

class SyncLogRepositoryImpl implements SyncLogRepository {
  final AppDatabase _db;

  SyncLogRepositoryImpl(this._db);

  @override
  Stream<List<SyncLogEntry>> watchAll() {
    return (_db.select(_db.syncLogTable)
          ..orderBy([(t) => OrderingTerm(expression: t.occurredAt, mode: OrderingMode.desc)]))
        .watch()
        .map((rows) => rows.map(_toEntity).toList());
  }

  @override
  Future<void> insert(SyncLogEntry entry) async {
    await _db.into(_db.syncLogTable).insert(SyncLogTableCompanion(
          id: Value(entry.id),
          localId: Value(entry.localId),
          operationType: Value(entry.operationType),
          status: Value(entry.status),
          gestionVersion: Value(jsonEncode(entry.gestionVersion)),
          attempts: Value(entry.attempts),
          errorMessage: Value(entry.errorMessage),
          occurredAt: Value(entry.occurredAt),
        ));
  }

  SyncLogEntry _toEntity(SyncLogRow row) => SyncLogEntry(
        id: row.id,
        localId: row.localId,
        operationType: row.operationType,
        status: row.status,
        gestionVersion: jsonDecode(row.gestionVersion) as Map<String, dynamic>,
        attempts: row.attempts,
        errorMessage: row.errorMessage,
        occurredAt: row.occurredAt,
      );
}
