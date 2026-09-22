# SATU RUMAH V2 

> **Sistem Aplikasi Terpadu Urusan Rumah** - Platform digital perizinan Penyerahan Prasarana, Sarana, dan Utilitas Umum (PSU) Perumahan Kota Tasikmalaya.

---

## Tentang Proyek

SATU RUMAH V2 adalah aplikasi mobile berbasis Flutter yang mendigitalisasi proses penyerahan PSU perumahan dari pengembang kepada Pemerintah Kota Tasikmalaya melalui Dinas Perumahan dan Permukiman (Disperwaskim).

Aplikasi ini menghubungkan **3 peran** dalam satu ekosistem digital:

| Peran | Deskripsi |
|---|---|
| **Pengembang** | Mengajukan berkas perizinan PSU secara digital dan memantau status pengajuan |
| **Admin Disperwaskim** | Memverifikasi berkas, menjadwalkan survey, dan mengelola alur persetujuan |
| **Tim Perwaskim Lapangan** | Melaksanakan survey fisik PSU, mendokumentasikan temuan, dan menerbitkan Berita Acara |

---

## Fitur Utama

- **Multi-role Login** — Satu aplikasi untuk 3 peran berbeda
- **Pengajuan Dokumen Digital** — Form multi-step dengan 16 slot dokumen (DOC01–DOC16)
- **Verifikasi Administrasi** — Admin dapat menyetujui, meminta perbaikan, atau menolak berkas
- **Penjadwalan Survey** — Penugasan petugas lapangan dengan tanggal dan instruksi
- **Monitoring & Berita Acara** — Laporan hasil survey dengan foto bukti dan kop surat resmi
- **Cetak / Export PDF** — Berita Acara langsung dicetak atau dibagikan dari perangkat
- **Notifikasi Real-time** — Setiap perubahan status pengajuan memicu notifikasi

---

## Teknologi

| Layer | Teknologi |
|---|---|
| Mobile App | Flutter 3.x (Dart) |
| State Management | Riverpod 2.x |
| Navigasi | GoRouter |
| PDF | `pdf` + `printing` |
| Berbagi File | `share_plus` |
| Backend (Web Admin) | Laravel 11 (PHP 8.3) |

---

## Cara Menjalankan

### Prasyarat
- Flutter SDK ≥ 3.22.0
- Dart SDK ≥ 3.4.0
- Android Studio / VS Code dengan extension Flutter

### Langkah

```bash
# 1. Clone repository
git clone <url-repo>
cd satu-rumahv2

# 2. Install dependencies
flutter pub get

# 3. Jalankan aplikasi (mode debug)
flutter run
```

### Akun Demo (Prototype)

| Role | Email / Aksi |
|---|---|
| Pengembang | Tombol "Masuk sebagai Pengembang" di halaman login |
| Admin Disperwaskim | Tombol "Masuk sebagai Admin" di halaman login |
| Tim Lapangan | Tombol "Masuk sebagai Tim Lapangan" di halaman login |

> **Catatan:** Semua data saat ini menggunakan data dummy lokal (prototype). Integrasi penuh ke backend Laravel akan dilakukan pada tahap produksi.

---

## Struktur Proyek

```
lib/
├── core/
│   ├── auth/          # Session management & role routing
│   ├── router/        # GoRouter configuration
│   ├── theme/         # Design system (warna, tipografi, radius)
│   └── widgets/       # Shared widgets (AppHeader, BottomNav, dll)
└── features/
    ├── auth/          # Login & onboarding
    ├── dashboard/     # Beranda per role
    ├── pengajuan/     # Alur pengajuan dokumen PSU
    ├── monitoring/    # Survey lapangan & Berita Acara
    ├── notifikasi/    # Notifikasi status pengajuan
    └── profil/        # Profil akun per role
```

---

## Pemda Kota Tasikmalaya

Proyek ini dikembangkan dalam rangka mendukung digitalisasi layanan publik Kota Tasikmalaya melalui **Dinas Komunikasi dan Informatika (Diskominfo)** — Bidang Aplikasi dan Informatika (APTIKA), bekerja sama dengan **Dinas Perumahan dan Permukiman (Disperwaskim)**.

---

*SATU RUMAH V2 © 2025–2026 Pemerintah Kota Tasikmalaya*