import 'package:drift/drift.dart';

class UserSettings extends Table {
  TextColumn get id => text()();
  IntColumn get monthlyIncomeInr => integer().withDefault(const Constant(0))();
  IntColumn get appLockTimeoutSeconds => integer().withDefault(const Constant(30))();

  @override
  Set<Column> get primaryKey => {id};
}
