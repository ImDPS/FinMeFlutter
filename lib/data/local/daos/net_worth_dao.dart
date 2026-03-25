import 'package:drift/drift.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/tables/net_worth_table.dart';

part 'net_worth_dao.g.dart';

@DriftAccessor(tables: [NetWorthSnapshots])
class NetWorthDao extends DatabaseAccessor<AppDatabase> with _$NetWorthDaoMixin {
  NetWorthDao(super.db);

  Future<List<NetWorthSnapshot>> getAllSnapshots() =>
      (select(netWorthSnapshots)..orderBy([(s) => OrderingTerm.desc(s.date)])).get();

  Future<List<NetWorthSnapshot>> getLastTwoSnapshots() =>
      (select(netWorthSnapshots)
            ..orderBy([(s) => OrderingTerm.desc(s.date)])
            ..limit(2))
          .get();

  Future<void> insertSnapshot(NetWorthSnapshotsCompanion entry) =>
      into(netWorthSnapshots).insertOnConflictUpdate(entry);
}
