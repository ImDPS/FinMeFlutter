import 'package:drift/drift.dart';

class NetWorthSnapshots extends Table {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get totalAssets => integer()();
  IntColumn get totalLiabilities => integer()();
  TextColumn get breakdownJson => text()();

  @override
  Set<Column> get primaryKey => {id};
}
