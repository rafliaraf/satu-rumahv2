import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/monitoring/presentation/widgets/evidence_photo_picker.dart';

Future<void> _pumpPicker(
  WidgetTester tester, {
  required PhotoPathPicker picker,
  required ValueChanged<List<String>> onChanged,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: EvidencePhotoPicker(
          photoPaths: const [],
          onPhotosChanged: onChanged,
          pickPhotoPaths: picker,
        ),
      ),
    ),
  );
}

Finder _addPhotoButton() => find.text('Tambah\nFoto');

void main() {
  testWidgets('canceled picker does not add a fake photo', (tester) async {
    var callbackCount = 0;
    await _pumpPicker(
      tester,
      picker: () async => const [],
      onChanged: (_) => callbackCount++,
    );

    await tester.tap(_addPhotoButton());
    await tester.pumpAndSettle();

    expect(callbackCount, 0);
  });

  testWidgets('stale picker completion is ignored when a newer pick wins', (
    tester,
  ) async {
    final first = Completer<List<String>>();
    final second = Completer<List<String>>();
    var requestCount = 0;
    final updates = <List<String>>[];

    await _pumpPicker(
      tester,
      picker: () {
        requestCount++;
        return requestCount == 1 ? first.future : second.future;
      },
      onChanged: updates.add,
    );

    await tester.tap(_addPhotoButton());
    await tester.pump();
    await tester.tap(_addPhotoButton());
    await tester.pump();

    first.complete(['old.jpg']);
    await tester.pump();
    expect(updates, isEmpty);

    second.complete(['new.jpg']);
    await tester.pump();
    expect(updates, [
      <String>['new.jpg'],
    ]);
  });

  testWidgets('picker completion after disposal is ignored', (tester) async {
    final pending = Completer<List<String>>();
    var callbackCount = 0;
    await _pumpPicker(
      tester,
      picker: () => pending.future,
      onChanged: (_) => callbackCount++,
    );

    await tester.tap(_addPhotoButton());
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());

    pending.complete(['disposed.jpg']);
    await tester.pump();

    expect(callbackCount, 0);
  });
}
