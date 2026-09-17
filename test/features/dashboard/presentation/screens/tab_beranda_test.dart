import 'package:flutter_test/flutter_test.dart';
import 'package:satu_rumah/features/dashboard/presentation/screens/tab_beranda.dart';

void main() {
  test('latest pengajuan safely returns null for an empty list', () {
    expect(latestPengajuan(const []), isNull);
  });

  test(
    'dashboard shortcuts map to real tabs or an explicit unavailable outcome',
    () {
      expect(dashboardShortcutTab('Pengajuan Saya'), 1);
      expect(dashboardShortcutTab('Notifikasi'), 2);
      expect(dashboardShortcutTab('Profil Saya'), 3);
      expect(dashboardShortcutTab('Format Dokumen'), isNull);
    },
  );
}
