// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'net_worth_dao.dart';

// ignore_for_file: type=lint
mixin _$NetWorthDaoMixin on DatabaseAccessor<AppDatabase> {
  $NetWorthSnapshotsTable get netWorthSnapshots =>
      attachedDatabase.netWorthSnapshots;
  NetWorthDaoManager get managers => NetWorthDaoManager(this);
}

class NetWorthDaoManager {
  final _$NetWorthDaoMixin _db;
  NetWorthDaoManager(this._db);
  $$NetWorthSnapshotsTableTableManager get netWorthSnapshots =>
      $$NetWorthSnapshotsTableTableManager(
          _db.attachedDatabase, _db.netWorthSnapshots);
}
