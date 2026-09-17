import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/monitoring/data/models/monitoring_model.dart';

void main() {
  test('MonitoringModel should instantiate and copyWith correctly', () {
    final now = DateTime.now();
    final model = MonitoringModel(
      id: '1',
      tanggalMonitoring: now,
      namaPerumahan: 'Permata Hijau',
      namaDeveloper: 'PT ABC Property',
      lokasiPerumahan: 'Kec. Cipedes',
      maksudTujuan: MonitoringModel.defaultMaksudTujuan,
      temuanLapangan: ['Temuan 1'],
      kesimpulan: ['Kesimpulan 1'],
      kesepakatan: ['Kesepakatan 1'],
      rencanaTindakLanjut: ['RTL 1'],
      pelaksanaNama: 'Asep',
      pelaksanaJabatan: 'Surveyor',
      ditemuiNama: 'Budi',
      ditemuiJabatan: 'Manager',
      photoPaths: [],
      createdAt: now,
    );

    expect(model.namaPerumahan, 'Permata Hijau');
    expect(model.namaDeveloper, 'PT ABC Property');
    expect(model.maksudTujuan, contains('pengawasan dan pengendalian'));
  });
}
