import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:finme/core/router/shell_scaffold.dart';
import 'package:finme/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:finme/features/auth/presentation/screens/otp_screen.dart';
import 'package:finme/features/auth/presentation/screens/app_lock_screen.dart';
import 'package:finme/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:finme/features/transactions/presentation/screens/transactions_screen.dart';
import 'package:finme/features/budgets/presentation/screens/budgets_screen.dart';
import 'package:finme/features/net_worth/presentation/screens/net_worth_screen.dart';
import 'package:finme/features/settings/presentation/screens/settings_screen.dart';
import 'package:finme/features/sms_import/presentation/screens/sms_import_screen.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: '/onboarding',
    routes: [
      GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
      GoRoute(path: '/otp',        builder: (_, __) => const OtpScreen()),
      GoRoute(path: '/lock',       builder: (_, __) => const AppLockScreen()),
      GoRoute(path: '/sms-import', builder: (_, __) => const SmsImportScreen()),
      ShellRoute(
        builder: (_, state, child) {
          final index = _tabIndex(state.matchedLocation);
          return ShellScaffold(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(path: '/dashboard',    builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/transactions', builder: (_, __) => const TransactionsScreen()),
          GoRoute(path: '/budgets',      builder: (_, __) => const BudgetsScreen()),
          GoRoute(path: '/net-worth',    builder: (_, __) => const NetWorthScreen()),
          GoRoute(path: '/settings',     builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
}

int _tabIndex(String location) {
  if (location.startsWith('/transactions')) return 1;
  if (location.startsWith('/budgets'))      return 2;
  if (location.startsWith('/net-worth'))    return 3;
  if (location.startsWith('/settings'))     return 4;
  return 0;
}
