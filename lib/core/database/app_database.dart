import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'package:sync_app/core/database/tables/managements_table.dart';
import 'package:sync_app/core/database/tables/sync_log_table.dart';
import 'package:sync_app/core/database/tables/sync_queue_table.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [ManagementsTable, SyncQueueTable, SyncLogTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'sync_app'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) await m.createTable(syncLogTable);
        },
      );
}
