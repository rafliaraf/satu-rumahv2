import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/monitoring_model.dart';

class BaPdfGenerator {
  static const List<String> _bulanIndonesia = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  static const List<String> _hariIndonesia = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  static String _angkaKataTanggal(DateTime dt) {
    final hari = _hariIndonesia[dt.weekday - 1];
    final bulan = _bulanIndonesia[dt.month];
    return 'hari $hari tanggal ${dt.day} bulan $bulan tahun ${dt.year}';
  }

  /// Generate PDF dokumen BA dan tampilkan native print preview.
  static Future<void> printAndShare(MonitoringModel monitoring) async {
    final doc = pw.Document();

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) => [
          // Kop Surat
          pw.Center(
            child: pw.Column(
              children: [
                pw.Text('PEMERINTAH KOTA TASIKMALAYA',
                    style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.Text('DINAS PERUMAHAN DAN KAWASAN PERMUKIMAN',
                    style: const pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 2),
                pw.SizedBox(height: 8),
                pw.Text(
                  'BERITA ACARA MONITORING DAN EVALUASI LAPANGAN',
                  style: const pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  'Nomor: ${monitoring.nomorSuratBA}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Paragraf pembuka
          pw.Text(
            'Pada ${_angkaKataTanggal(monitoring.tanggalMonitoring)} telah dilakukan monitoring '
            'dan evaluasi lapangan oleh Tim dari Dinas Perumahan dan Kawasan Permukiman '
            'Kota Tasikmalaya bertempat di ${monitoring.namaPerumahan} '
            'yang berlokasi di ${monitoring.lokasiPerumahan.isNotEmpty ? monitoring.lokasiPerumahan : "-"}.',
            style: const pw.TextStyle(fontSize: 11),
          ),
          pw.SizedBox(height: 12),

          // Poin I-V
          _buildPdfSection('I. Maksud dan Tujuan', [monitoring.maksudTujuan]),
          _buildPdfSection('II. Temuan Di Lapangan', monitoring.temuanLapangan),
          _buildPdfSection('III. Kesimpulan', monitoring.kesimpulan),
          _buildPdfSection('IV. Kesepakatan', monitoring.kesepakatan),
          _buildPdfSection('V. Rencana Tindak Lanjut', monitoring.rencanaTindakLanjut),

          pw.SizedBox(height: 12),
          pw.Text(
            'Demikian Berita Acara ini dibuat dengan sebenarnya dan ditandatangani '
            'untuk digunakan sebagaimana mestinya.',
            style: const pw.TextStyle(fontSize: 11, fontStyle: pw.FontStyle.italic),
          ),
          pw.SizedBox(height: 32),

          // Kolom tanda tangan
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Yang Melaksanakan\nObservasi/Inspeksi',
                        style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 48),
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text(monitoring.pelaksanaNama.isNotEmpty ? monitoring.pelaksanaNama : '( _________________ )',
                        style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                    if (monitoring.pelaksanaJabatan.isNotEmpty)
                      pw.Text(monitoring.pelaksanaJabatan,
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text('Yang Ditemui\ndi Lapangan',
                        style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                    pw.SizedBox(height: 48),
                    pw.Container(width: 120, height: 1, color: PdfColors.black),
                    pw.SizedBox(height: 4),
                    pw.Text(monitoring.ditemuiNama.isNotEmpty ? monitoring.ditemuiNama : '( _________________ )',
                        style: const pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                        textAlign: pw.TextAlign.center),
                    if (monitoring.ditemuiJabatan.isNotEmpty)
                      pw.Text(monitoring.ditemuiJabatan,
                          style: const pw.TextStyle(fontSize: 9),
                          textAlign: pw.TextAlign.center),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => doc.save());
  }

  static pw.Widget _buildPdfSection(String title, List<String> items) {
    final valid = items.where((e) => e.trim().isNotEmpty).toList();
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        if (valid.isEmpty)
          pw.Text('• -', style: const pw.TextStyle(fontSize: 11))
        else
          ...valid.map((e) => pw.Text('• $e', style: const pw.TextStyle(fontSize: 11))),
        pw.SizedBox(height: 10),
      ],
    );
  }
}
