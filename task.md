# 📋 Progress Monitoring Task — Modul Tim Perwaskim Monitoring Lapangan

Dokumen ini digunakan untuk memantau progress pengerjaan task oleh agen secara real-time.

---

- [x] **Task 1: Role-Based Login Routing**
  - [x] Update fungsi `_login()` di `login_screen.dart` untuk pengecekan role `admin_dpkp`, `tim_monitoring`, dan `pengembang`.
  - [x] Update tombol Quick Demo `_loginAsTimMonitoring()`.
  - [x] Menambahkan route `/monitoring/lapangan` di `app_router.dart`.
  - [x] Verifikasi & kompilasi route berhasil.

- [x] **Task 2: Update MonitoringModel — Tambah `nomorSuratBA` dan `isDraft`**
  - [x] Tulis unit test untuk `nomorSuratBA` dan `isDraft` di `monitoring_repository_test.dart`.
  - [x] Tambahkan field `nomorSuratBA`, `isDraft`, dan helper `generateNomorSuratBA()` di `MonitoringModel`.
  - [x] Jalankan `flutter test` — **5/5 tests passed!**

- [x] **Task 3: Refactor TambahMonitoringStepperScreen**
  - [x] Hapus `namaDeveloper` dari `monitoring_form_provider.dart` (`fillDummyData`).
  - [x] Tambahkan method `buildPreviewModel()` di `monitoring_form_provider.dart`.
  - [x] Hapus field "Nama Developer/PT" dari UI Step 1 `tambah_monitoring_stepper_screen.dart`.
  - [x] Ganti tombol submit di Step 3 menjadi **"Lihat Pratinjau Berita Acara"**.

- [x] **Task 4: Refactor LaporanPreviewScreen — Mode Draft vs Final**
  - [x] Update `app_router.dart` route `/monitoring/preview` untuk menerima parameter `isDraft`.
  - [x] Refactor `laporan_preview_screen.dart` merender 1 halaman scrollable dokumen BA resmi (Kop Surat, Nomor BA, Narasi, Poin I-V, Kolom Tanda Tangan Fisik, Foto Evidence).
  - [x] Tombol Aksi Mode Draft: `Submit Laporan` + `Kembali & Edit`.
  - [x] Tombol Aksi Mode Final: `Download PDF` + `Bagikan`.

- [x] **Task 5: Buat Shell Navigasi Tim Monitoring Lapangan**
  - [x] Lengkapi `monitoring_main_screen.dart` (Shell dengan 3 Bottom Navigation Tab).
  - [x] Implementasi `tab_beranda_monitoring.dart` (Header Petugas, CTA Tambah Laporan, List Monitoring Hari Ini).
  - [x] Implementasi `tab_profil_monitoring.dart` (Profil Drs. Rian Hidayat, M.Si, Stat Cards, Menu Akun).

- [x] **Task 6: Sederhanakan LaporanSuccessScreen + Install Package PDF**
  - [x] Tambahkan package `pdf: ^3.10.8` dan `printing: ^5.13.1` ke `pubspec.yaml`.
  - [x] Buat `ba_pdf_generator.dart` untuk cetak/export PDF native.
  - [x] Update `laporan_success_screen.dart` dengan 2 tombol aksi: **"Download / Cetak PDF"** dan **"Bagikan via WhatsApp"**.
