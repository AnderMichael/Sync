import 'package:drift/drift.dart';

@DataClassName('SyncLogRow')
class SyncLogTable extends Table {
  @override
  String get tableName => 'sync_log';

  TextColumn get id => text()();
  TextColumn get localId => text()();
  TextColumn get operationType => text()();
  TextColumn get status => text()();
  TextColumn get gestionVersion => text()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
