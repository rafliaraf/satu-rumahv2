# SATU RUMAH

Aplikasi Flutter untuk alur pengajuan perumahan, pemeriksaan Admin Disperwaskim, dan monitoring lapangan Perwaskim Kota Tasikmalaya.

> **Status:** Prototype lokal. UI consistency pass sudah masuk commit lokal, tetapi belum dipush ke `main`. Backend API dan persistence produksi belum terhubung ke aplikasi Flutter.

## Jalankan proyek

```powershell
flutter pub get
flutter run -d chrome
```

Prototype mencakup tiga role: **Pengembang**, **Admin DPKP**, dan **Tim Perwaskim**. Data utama masih tersimpan di memori dan akan hilang saat proses aplikasi dimulai ulang.

## Dokumentasi

- [Handoff tim berikutnya](PROJECT-HANDOFF.md): status Git, batas prototype, verifikasi, dan urutan kerja berikutnya.
- [Hasil audit anti-slop](anti-slop/audit-001-follow-up-2026-09-07.md): perubahan UI yang sudah diterapkan dan gate yang masih terbuka.
- [Roadmap produksi](PRODUCTION-ROADMAP.md): kebutuhan backend, integrasi, pengujian, dan deployment.
- [Referensi codebase](CODEBASE-SCAN-REFERENCE.md): ukuran source, struktur aplikasi, dan area berisiko.
