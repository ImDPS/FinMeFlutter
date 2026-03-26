import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/data/local/database.dart';
import 'package:finme/features/dashboard/data/dashboard_repository.dart';

part 'dashboard_provider.g.dart';

class DashboardState {
  const DashboardState({
    this.totalBalance = 0,
    this.monthSpend = 0,
    this.monthIncome = 0,
    this.topCategories = const {},
    this.recentTransactions = const [],
    this.isLoading = false,
    this.error,
  });

  final int totalBalance;
  final int monthSpend;
  final int monthIncome;
  final Map<String, int> topCategories;
  final List<Transaction> recentTransactions;
  final bool isLoading;
  final String? error;

  DashboardState copyWith({
    int? totalBalance, int? monthSpend, int? monthIncome,
    Map<String, int>? topCategories, List<Transaction>? recentTransactions,
    bool? isLoading, String? error,
  }) => DashboardState(
    totalBalance: totalBalance ?? this.totalBalance,
    monthSpend: monthSpend ?? this.monthSpend,
    monthIncome: monthIncome ?? this.monthIncome,
    topCategories: topCategories ?? this.topCategories,
    recentTransactions: recentTransactions ?? this.recentTransactions,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );
}

@riverpod
DashboardRepository dashboardRepository(Ref ref) {
  // In production, wire up with real AppDatabase provider
  // For now, creates a testing instance (will be replaced when DB provider is added)
  return DashboardRepository(db: AppDatabase.forTesting());
}

@riverpod
class DashboardNotifier extends _$DashboardNotifier {
  @override
  DashboardState build() {
    Future.microtask(load);
    return const DashboardState(isLoading: true);
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final repo = ref.read(dashboardRepositoryProvider);
      final results = await Future.wait([
        repo.totalBalanceInr(),
        repo.currentMonthSpend(),
        repo.currentMonthIncome(),
        repo.topCategoriesThisMonth(),
        repo.recentTransactions(),
      ]);
      state = state.copyWith(
        totalBalance: results[0] as int,
        monthSpend: results[1] as int,
        monthIncome: results[2] as int,
        topCategories: results[3] as Map<String, int>,
        recentTransactions: results[4] as List<Transaction>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
