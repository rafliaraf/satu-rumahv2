import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/monitoring/data/models/monitoring_model.dart';
import 'package:satu_rumah/features/monitoring/data/repositories/monitoring_repository.dart';

void main() {
  test('MonitoringRepository should add and retrieve records', () {
    final repo = MonitoringRepository();
    expect(repo.getAllMonitoring().length, greaterThanOrEqualTo(1));

    final newItem = MonitoringModel(
      id: 'test_123',
      tanggalMonitoring: DateTime.now(),
      namaPerumahan: 'Perumahan Testing',
      namaDeveloper: 'PT Test',
    );

    repo.addMonitoring(newItem);
    final found = repo.getMonitoringById('test_123');
    expect(found, isNotNull);
    expect(found?.namaPerumahan, 'Perumahan Testing');
  });

  test('MonitoringRepository search should filter by query', () {
    final repo = MonitoringRepository();
    final results = repo.searchMonitoring(query: 'Permata');
    expect(results.length, greaterThanOrEqualTo(1));
    expect(results.first.namaPerumahan, contains('Permata'));
  });

  test('MonitoringModel generates correct nomorSuratBA', () {
    final item = MonitoringModel(
      id: 'test_ba',
      tanggalMonitoring: DateTime(2026, 7, 23),
      namaPerumahan: 'Test',
    );
    expect(item.nomorSuratBA, equals('600.2.5/BA-MON/VII/2026'));
  });

  test('MonitoringModel isDraft defaults to false', () {
    final item = MonitoringModel(
      id: 'test_draft',
      tanggalMonitoring: DateTime.now(),
      namaPerumahan: 'Test',
    );
    expect(item.isDraft, isFalse);
  });

  test('MonitoringModel can be created with isDraft true', () {
    final item = MonitoringModel(
      id: 'test_draft_true',
      tanggalMonitoring: DateTime.now(),
      namaPerumahan: 'Test',
      isDraft: true,
    );
    expect(item.isDraft, isTrue);
  });
}
