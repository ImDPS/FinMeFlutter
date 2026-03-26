import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:finme/core/router/app_router.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  AppLifecycleObserver({required this.ref});
  final WidgetRef ref;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      final router = ref.read(appRouterProvider);
      router.go('/lock');
    }
  }
}
