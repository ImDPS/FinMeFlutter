import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:finme/core/theme/app_colors.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const ShellScaffold({super.key, required this.child, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        height: 72,
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => _onTabTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(LucideIcons.home),        label: 'Home'),
          NavigationDestination(icon: Icon(LucideIcons.list),        label: 'Transactions'),
          NavigationDestination(icon: Icon(LucideIcons.pieChart),    label: 'Budgets'),
          NavigationDestination(icon: Icon(LucideIcons.barChart2),   label: 'Net Worth'),
          NavigationDestination(icon: Icon(LucideIcons.settings),    label: 'Settings'),
        ],
      ),
    );
  }

  void _onTabTap(BuildContext context, int index) {
    const routes = ['/dashboard', '/transactions', '/budgets', '/net-worth', '/settings'];
    context.go(routes[index]);
  }
}
