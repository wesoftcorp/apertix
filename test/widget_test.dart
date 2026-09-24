import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apertix/app.dart';

void main() {
  testWidgets('Apertix app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ApertixApp(),
      ),
    );
  });
}

