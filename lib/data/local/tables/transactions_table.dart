import 'package:drift/drift.dart';

class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get accountId => text()();
  IntColumn get amount => integer()();
  TextColumn get category => text().withDefault(const Constant('uncategorized'))();
  TextColumn get merchant => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get source => text()();
  TextColumn get smsHash => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
