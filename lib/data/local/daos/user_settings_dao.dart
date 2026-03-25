import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/tables/user_settings_table.dart';

part 'user_settings_dao.g.dart';

@DriftAccessor(tables: [UserSettings])
class UserSettingsDao extends DatabaseAccessor<AppDatabase> with _$UserSettingsDaoMixin {
  UserSettingsDao(super.db);

  Future<UserSetting?> getSettings() =>
      (select(userSettings)..limit(1)).getSingleOrNull();

  Future<void> upsertSettings(UserSettingsCompanion entry) =>
      into(userSettings).insertOnConflictUpdate(entry);
}
