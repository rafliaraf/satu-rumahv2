import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:satu_rumah/features/monitoring/data/models/monitoring_model.dart';
import 'package:satu_rumah/features/pengajuan/data/models/pengajuan_model.dart';
import 'package:satu_rumah/features/pengajuan/data/models/status_tahap_pengajuan.dart';
import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_form_controller.dart';
import 'package:satu_rumah/features/pengajuan/presentation/screens/pengajuan_detail_screen.dart';

void main() {
  MonitoringModel report({
    required String id,
    String? pengajuanId,
    bool isDraft = false,
  }) {
    return MonitoringModel(
      id: id,
      pengajuanId: pengajuanId,
      tanggalMonitoring: DateTime(2026, 7, 1),
      namaPerumahan: 'Perumahan Uji',
      isDraft: isDraft,
    );
  }

  test('finds only a linked final report when a BA path exists', () {
    final found = findLinkedFinalMonitoring(
      [
        report(id: 'draft', pengajuanId: 'SR-1', isDraft: true),
        report(id: 'final', pengajuanId: 'SR-1'),
      ],
      'SR-1',
      beritaAcaraPath: 'BA.pdf',
    );

    expect(found?.id, 'final');
  });

  test('returns unavailable when the BA path is missing', () {
    final found = findLinkedFinalMonitoring([
      report(id: 'final', pengajuanId: 'SR-1'),
    ], 'SR-1');

    expect(found, isNull);
  });

  test('returns unavailable for draft or unlinked reports', () {
    final reports = [
      report(id: 'draft', pengajuanId: 'SR-1', isDraft: true),
      report(id: 'other', pengajuanId: 'SR-2'),
    ];

    expect(
      findLinkedFinalMonitoring(reports, 'SR-1', beritaAcaraPath: 'BA.pdf'),
      isNull,
    );
  });

  testWidgets('developer detail avoids horizontal overflow at 320px', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    final container = ProviderContainer();
    addTearDown(() async {
      container.dispose();
      await tester.binding.setSurfaceSize(null);
    });
    container.read(pengajuanListProvider.notifier).addPengajuan(
      Pengajuan(
        id: 'SR-LONG-001',
        namaPerumahan:
            'Perumahan dengan nama yang sangat panjang untuk pengujian responsive',
        namaPt:
            'PT Pengembang Perumahan Nusantara dengan Nama Legal yang Panjang',
        namaDirektur: 'Direktur',
        npwpPerusahaan: '01.001',
        luasLahan: 1000,
        jumlahUnit: 10,
        tipePerumahan: 'Subsidi Komersil Keduanya dengan Keterangan Tambahan',
        status: 'Dalam Proses',
        statusTahap: StatusTahapPengajuan.verifikasiAdministrasi,
        tanggal: '19 Agustus 2026 dengan catatan waktu yang panjang',
        uploadedDocs: const {},
      ),
    );

    final overflowErrors = <FlutterErrorDetails>[];
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      if (details.exceptionAsString().contains('overflowed')) {
        overflowErrors.add(details);
      }
    };
    try {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PengajuanDetailScreen(id: 'SR-LONG-001'),
          ),
        ),
      );
      await tester.pump();
    } finally {
      FlutterError.onError = previousOnError;
    }

    expect(overflowErrors, isEmpty);
  });
}
