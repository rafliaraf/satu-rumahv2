import 'package:flutter_test/flutter_test.dart';

import 'package:satu_rumah/features/pengajuan/presentation/providers/pengajuan_form_controller.dart';

void main() {
  group('PengajuanFormState validation', () {
    test('requires positive finite step 1 values', () {
      final valid = PengajuanFormState(
        namaPerumahan: 'Perumahan A',
        npwpPerusahaan: '01.234',
        luasLahan: 1,
        jumlahUnit: 1,
      );

      expect(valid.isStep1Valid, isTrue);
      expect(valid.copyWith(luasLahan: 0).isStep1Valid, isFalse);
      expect(valid.copyWith(luasLahan: -1).isStep1Valid, isFalse);
      expect(valid.copyWith(luasLahan: double.nan).isStep1Valid, isFalse);
      expect(valid.copyWith(jumlahUnit: 0).isStep1Valid, isFalse);
    });

    test('requires every named document for steps 2 and 3', () {
      final notifier = PengajuanFormNotifier();
      final required = <String, String>{
        'ktp': 'ktp.pdf',
        'nib': 'nib.pdf',
        'npwp_doc': 'npwp.pdf',
        'asosiasi': 'asosiasi.pdf',
        'legalitas': 'legalitas.pdf',
        'surat_permohonan': 'permohonan.pdf',
        'info_intensitas_ruang': 'intensitas.pdf',
        'bukti_kepemilikan_lahan': 'lahan.pdf',
        'bukti_tpu': 'tpu.pdf',
        'kkpr_doc': 'kkpr.pdf',
        'pbg_induk': 'pbg.pdf',
        'rekomendasi_lingkungan': 'lingkungan.pdf',
        'pernyataan_pelepasan': 'pelepasan.pdf',
        'pernyataan_keabsahan': 'keabsahan.pdf',
        'pernyataan_psu': 'psu.pdf',
      };

      for (final entry in required.entries) {
        notifier.uploadDocument(entry.key, entry.value);
      }

      expect(notifier.state.isStep2Valid, isTrue);
      expect(notifier.state.isStep3Valid, isTrue);
      notifier.deleteDocument('legalitas');
      expect(notifier.state.isStep2Valid, isFalse);
    });

    test('technical files satisfy step 4 and empty names do not', () {
      final notifier = PengajuanFormNotifier();

      notifier.uploadDocument('site_plan_dwg', '');
      expect(notifier.state.uploadedDocs, isEmpty);
      notifier.addTechnicalFiles(['', '  ', 'siteplan.dwg']);
      expect(notifier.state.isStep4Valid, isTrue);
      expect(notifier.state.technicalFiles, ['siteplan.dwg']);
      notifier.removeTechnicalFile(0);
      expect(notifier.state.isStep4Valid, isFalse);
      expect(notifier.state.uploadedDocs.containsKey('site_plan_dwg'), isFalse);
    });

    test('list notifier rejects duplicate IDs', () {
      final notifier = PengajuanListNotifier();
      final original = notifier.state.first;

      final added = notifier.addPengajuanIfAbsent(original.copyWith());

      expect(added, isFalse);
      expect(
        notifier.state.where((item) => item.id == original.id),
        hasLength(1),
      );
    });
  });
}
