import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/data/local/database_provider.dart';
import 'package:finme/features/net_worth/data/net_worth_repository.dart';

part 'net_worth_provider.g.dart';

class NetWorthState {
  const NetWorthState({
    this.totalNetWorth = 0,
    this.totalAssets = 0,
    this.totalLiabilities = 0,
    this.accountsByType = const {},
    this.isLoading = false,
  });

  final int totalNetWorth;
  final int totalAssets;
  final int totalLiabilities;
  final Map<String, List<Account>> accountsByType;
  final bool isLoading;
}

@riverpod
Future<NetWorthRepository> netWorthRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return NetWorthRepository(db: db);
}

@riverpod
class NetWorthNotifier extends _$NetWorthNotifier {
  @override
  NetWorthState build() {
    Future.microtask(load);
    return const NetWorthState(isLoading: true);
  }

  Future<void> load() async {
    state = NetWorthState(
      isLoading: true,
      totalNetWorth: state.totalNetWorth,
      totalAssets: state.totalAssets,
      totalLiabilities: state.totalLiabilities,
      accountsByType: state.accountsByType,
    );
    final repo = await ref.read(netWorthRepositoryProvider.future);
    final results = await Future.wait<Object>([
      repo.getTotalNetWorth(),
      repo.getTotalAssets(),
      repo.getTotalLiabilities(),
      repo.getAccountsByType(),
    ]);
    state = NetWorthState(
      totalNetWorth:    results[0] as int,
      totalAssets:      results[1] as int,
      totalLiabilities: results[2] as int,
      accountsByType:   results[3] as Map<String, List<Account>>,
    );
  }
}
