import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/core/widgets/glass_card.dart';
import 'package:finme/core/theme/app_theme.dart';

void main() {
  testWidgets('GlassCard renders child content', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: GlassCard(child: Text('Hello FinMe')),
        ),
      ),
    );
    expect(find.text('Hello FinMe'), findsOneWidget);
  });

  testWidgets('GlassCard uses BackdropFilter for blur', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: GlassCard(child: SizedBox()),
        ),
      ),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
  });
}
