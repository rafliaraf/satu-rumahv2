import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/monitoring/presentation/widgets/dynamic_bullet_field.dart';

void main() {
  testWidgets('DynamicBulletField renders items and allows adding points', (tester) async {
    List<String> currentItems = ['Poin 1'];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DynamicBulletField(
            label: 'Temuan di Lapangan',
            items: currentItems,
            onItemsChanged: (newItems) {
              currentItems = newItems;
            },
          ),
        ),
      ),
    );

    expect(find.text('Temuan di Lapangan'), findsOneWidget);
    expect(find.text('Poin 1'), findsOneWidget);

    await tester.tap(find.text('+ Tambah Poin'));
    await tester.pump();

    expect(currentItems.length, 2);
  });
}
