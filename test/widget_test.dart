import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satu_rumah/app.dart';

void main() {
  testWidgets('App renders dashboard screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SatuRumahApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.textContaining('SATU RUMAH'), findsWidgets);
  });
}
