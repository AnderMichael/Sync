import 'package:drift/drift.dart';

@DataClassName('ManagementRow')
class ManagementsTable extends Table {
  @override
  String get tableName => 'managements';

  TextColumn get localId => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get date => dateTime()();
  RealColumn get amount => real()();
  TextColumn get syncStatus =>
      text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {localId};
}
