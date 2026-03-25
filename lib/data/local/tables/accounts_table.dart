import 'package:drift/drift.dart';

class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get institution => text()();
  IntColumn get balance => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSynced => dateTime().nullable()();
  DateTimeColumn get consentExpiryDate => dateTime().nullable()();
  TextColumn get consentStatus => text().withDefault(const Constant('manual'))();

  @override
  Set<Column> get primaryKey => {id};
}
