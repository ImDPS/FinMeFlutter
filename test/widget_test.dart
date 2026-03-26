// Smoke test — verifies FinMeApp builds without crashing.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:finme/app.dart';

void main() {
  testWidgets('FinMeApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FinMeApp()));
    // App should render without throwing.
    expect(tester.takeException(), isNull);
  });
}
