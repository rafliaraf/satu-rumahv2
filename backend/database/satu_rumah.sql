-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 16, 2026 at 07:45 PM
-- Server version: 8.4.3
-- PHP Version: 8.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `satu_rumah`
--

-- --------------------------------------------------------

--
-- Table structure for table `cache`
--

CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `cache_locks`
--

CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `dokumen_pengajuan`
--

CREATE TABLE `dokumen_pengajuan` (
  `id` bigint UNSIGNED NOT NULL,
  `pengajuan_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `kategori` enum('perusahaan','perumahan','paket_teknis') COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama_persyaratan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama_file` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ukuran_file` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tanggal_unggah` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('Sesuai','Perlu perbaikan','Belum diperiksa') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Belum diperiksa',
  `catatan` text COLLATE utf8mb4_unicode_ci,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `dokumen_pengajuan`
--

INSERT INTO `dokumen_pengajuan` (`id`, `pengajuan_id`, `kategori`, `nama_persyaratan`, `nama_file`, `ukuran_file`, `tanggal_unggah`, `status`, `catatan`, `created_at`, `updated_at`) VALUES
(1, 'SR-2025-0148', 'perusahaan', 'NIB dan Izin Usaha', 'nib_dan_izin_usaha.pdf', '08 Mei 2025 · 0.8 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(2, 'SR-2025-0148', 'perusahaan', 'NPWP Perusahaan', 'npwp_perusahaan.pdf', '08 Mei 2025 · 1.0 MB', '08 Mei 2025', 'Belum diperiksa', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(3, 'SR-2025-0148', 'perusahaan', 'Akta Pendirian Perusahaan', 'akta_pendirian_perusahaan.pdf', '08 Mei 2025 · 1.1 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(4, 'SR-2025-0148', 'perusahaan', 'KTP Direktur Utama', 'ktp_direktur_utama.pdf', '08 Mei 2025 · 1.3 MB', '08 Mei 2025', 'Perlu perbaikan', 'Scan KTP buram dan tanggal berlaku perlu dikonfirmasi.', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(5, 'SR-2025-0148', 'perusahaan', 'Surat Kuasa Penanggung Jawab', 'surat_kuasa_penanggung_jawab.pdf', '08 Mei 2025 · 1.4 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(6, 'SR-2025-0148', 'perumahan', 'Site Plan yang Disahkan', 'site_plan_yang_disahkan.pdf', '08 Mei 2025 · 0.8 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(7, 'SR-2025-0148', 'perumahan', 'Bukti Kepemilikan Tanah', 'bukti_kepemilikan_tanah.pdf', '08 Mei 2025 · 1.0 MB', '08 Mei 2025', 'Belum diperiksa', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(8, 'SR-2025-0148', 'perumahan', 'Izin Lokasi', 'izin_lokasi.pdf', '08 Mei 2025 · 1.1 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(9, 'SR-2025-0148', 'perumahan', 'Persetujuan Lingkungan', 'persetujuan_lingkungan.pdf', '08 Mei 2025 · 1.3 MB', '08 Mei 2025', 'Perlu perbaikan', 'Pernyataan pengelolaan limbah cair belum melampirkan izin TPS terpadu.', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(10, 'SR-2025-0148', 'perumahan', 'Izin PBG', 'izin_pbg.pdf', '08 Mei 2025 · 1.4 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(11, 'SR-2025-0148', 'perumahan', 'Gambar Rencana Tapak', 'gambar_rencana_tapak.pdf', '08 Mei 2025 · 1.6 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(12, 'SR-2025-0148', 'perumahan', 'Rencana Utilitas', 'rencana_utilitas.pdf', '08 Mei 2025 · 1.7 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(13, 'SR-2025-0148', 'perumahan', 'Rencana Drainase', 'rencana_drainase.pdf', '08 Mei 2025 · 1.9 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(14, 'SR-2025-0148', 'perumahan', 'Surat Pernyataan Pengembang', 'surat_pernyataan_pengembang.pdf', '08 Mei 2025 · 2.0 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(15, 'SR-2025-0148', 'perumahan', 'Daftar Unit Perumahan', 'daftar_unit_perumahan.pdf', '08 Mei 2025 · 2.1 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(16, 'SR-2025-0148', 'perumahan', 'Dokumen Analisis Dampak Lalu Lintas', 'dokumen_analisis_dampak_lalu_lintas.pdf', '08 Mei 2025 · 2.3 MB', '08 Mei 2025', 'Sesuai', '', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(17, 'SR-2025-0148', 'paket_teknis', 'Paket Dokumen Teknis', 'Paket_tekdok_GriyaMahardika.zip', '24.8 MB · berisi 7 berkas', '08 Mei 2025', 'Sesuai', 'Mencakup 21 kategori teknis opsional.', '2026-09-15 05:35:14', '2026-09-15 05:35:14');

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `jobs`
--

CREATE TABLE `jobs` (
  `id` bigint UNSIGNED NOT NULL,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint UNSIGNED NOT NULL,
  `reserved_at` int UNSIGNED DEFAULT NULL,
  `available_at` int UNSIGNED NOT NULL,
  `created_at` int UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `job_batches`
--

CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int UNSIGNED NOT NULL,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '0001_01_01_000000_create_users_table', 1),
(2, '0001_01_01_000001_create_cache_table', 1),
(3, '0001_01_01_000002_create_jobs_table', 1),
(4, '2026_08_19_000001_create_pengajuan_table', 1),
(5, '2026_08_19_000002_create_dokumen_pengajuan_table', 1),
(6, '2026_08_19_000003_create_survey_pengajuan_table', 1),
(7, '2026_08_19_000004_create_monitoring_pengajuan_table', 1),
(8, '2026_08_19_000005_create_riwayat_pengajuan_table', 1),
(9, '2026_08_19_000006_create_notifikasi_table', 1);

-- --------------------------------------------------------

--
-- Table structure for table `monitoring_pengajuan`
--

CREATE TABLE `monitoring_pengajuan` (
  `id` bigint UNSIGNED NOT NULL,
  `pengajuan_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status_monitoring` enum('Draft','Final') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Draft',
  `tanggal_survey` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `petugas_nama` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hasil` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temuan` text COLLATE utf8mb4_unicode_ci,
  `kesimpulan` text COLLATE utf8mb4_unicode_ci,
  `kesepakatan` text COLLATE utf8mb4_unicode_ci,
  `rencana_tindak_lanjut` text COLLATE utf8mb4_unicode_ci,
  `foto_bukti` json DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `monitoring_pengajuan`
--

INSERT INTO `monitoring_pengajuan` (`id`, `pengajuan_id`, `status_monitoring`, `tanggal_survey`, `petugas_nama`, `hasil`, `temuan`, `kesimpulan`, `kesepakatan`, `rencana_tindak_lanjut`, `foto_bukti`, `created_at`, `updated_at`) VALUES
(1, 'SR-2025-0148', 'Draft', '22 Mei 2025', 'Rahmat Hidayat, S.T.', 'Perlu Evaluasi', 'Saluran drainase sisi timur belum sesuai detail rencana. Akses kendaraan pemadam perlu penegasan pada area tikungan blok C.', 'Kawasan dapat dilanjutkan setelah perbaikan desain drainase dan penyampaian revisi gambar teknis.', 'Pengembang akan mengunggah revisi dalam 7 hari kerja.', 'RENCANA TINDAK LANJUT WAJIB: Perbarui gambar drainase dan lengkapi simulasi manuver kendaraan pemadam sebelum persetujuan dilanjutkan.', '[{\"bg\": \"#e2e8f0\", \"label\": \"Drainase sisi timur\"}, {\"bg\": \"#e7dfd5\", \"label\": \"Akses blok C\"}, {\"bg\": \"#dbe5e7\", \"label\": \"Ruang terbuka hijau\"}]', '2026-09-15 05:35:14', '2026-09-15 05:35:14');

-- --------------------------------------------------------

--
-- Table structure for table `notifikasi`
--

CREATE TABLE `notifikasi` (
  `id` bigint UNSIGNED NOT NULL,
  `pengajuan_id` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `judul` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `pesan` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipe` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'info',
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `notifikasi`
--

INSERT INTO `notifikasi` (`id`, `pengajuan_id`, `judul`, `pesan`, `tipe`, `is_read`, `created_at`, `updated_at`) VALUES
(1, 'SR-2025-0148', 'Pengajuan baru', 'Griya Mangkubumi Asri', 'unread', 0, '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(2, 'SR-2025-0144', 'Permintaan perbaikan telah terkirim', 'Tamansari Asri Residence', 'unread', 0, '2026-09-15 03:35:14', '2026-09-15 05:35:14'),
(3, 'SR-2025-0146', 'Survey ditugaskan', 'Pesona Cibeureum Pratama', 'unread', 0, '2026-09-15 01:35:14', '2026-09-15 05:35:14'),
(4, 'SR-2025-0145', 'Monitoring final tersedia', 'Puri Cendana', 'read', 1, '2026-09-14 05:35:14', '2026-09-15 05:35:14'),
(5, 'SR-2025-0147', 'Dokumen persetujuan akhir tersedia', 'Taman Kencana Asri', 'read', 1, '2026-09-13 05:35:14', '2026-09-15 05:35:14');

-- --------------------------------------------------------

--
-- Table structure for table `password_reset_tokens`
--

CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `pengajuan`
--

CREATE TABLE `pengajuan` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama_pengembang` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nama_perumahan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lokasi` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jumlah_unit` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `luas_kawasan` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `penanggung_jawab` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tahap` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `catatan_status` text COLLATE utf8mb4_unicode_ci,
  `diajukan_pada` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `pengajuan`
--

INSERT INTO `pengajuan` (`id`, `nama_pengembang`, `nama_perumahan`, `lokasi`, `jumlah_unit`, `luas_kawasan`, `penanggung_jawab`, `tahap`, `status`, `catatan_status`, `diajukan_pada`, `created_at`, `updated_at`) VALUES
('SR-2025-0107', 'PT Pengembang Mitra Tasik 107', 'Cluster Tasik Indah 107', 'Kec. Tamansari, Kota Tasikmalaya', '99 unit', '45.000 m²', 'Penanggung Jawab 107, S.T.', 'Monitoring', 'Terjadwal', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
('SR-2025-0108', 'PT Pengembang Mitra Tasik 108', 'Puri Tasik Indah 108', 'Kec. Cipedes, Kota Tasikmalaya', '200 unit', '37.000 m²', 'Penanggung Jawab 108, S.T.', 'Verifikasi teknis', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
('SR-2025-0109', 'PT Pengembang Mitra Tasik 109', 'Taman Tasik Indah 109', 'Kec. Cipedes, Kota Tasikmalaya', '74 unit', '43.000 m²', 'Penanggung Jawab 109, S.T.', 'Persetujuan', 'Menunggu verifikasi', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
('SR-2025-0110', 'PT Pengembang Mitra Tasik 110', 'Griya Tasik Indah 110', 'Kec. Kawalu, Kota Tasikmalaya', '169 unit', '33.000 m²', 'Penanggung Jawab 110, S.T.', 'Monitoring', 'Final', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
('SR-2025-0111', 'PT Pengembang Mitra Tasik 111', 'Taman Tasik Indah 111', 'Kec. Purbaratu, Kota Tasikmalaya', '63 unit', '30.000 m²', 'Penanggung Jawab 111, S.T.', 'Monitoring', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
('SR-2025-0112', 'PT Pengembang Mitra Tasik 112', 'Taman Tasik Indah 112', 'Kec. Kawalu, Kota Tasikmalaya', '182 unit', '21.000 m²', 'Penanggung Jawab 112, S.T.', 'Survey', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0113', 'PT Pengembang Mitra Tasik 113', 'Taman Tasik Indah 113', 'Kec. Cibeureum, Kota Tasikmalaya', '118 unit', '42.000 m²', 'Penanggung Jawab 113, S.T.', 'Verifikasi teknis', 'Siap disetujui', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0114', 'PT Pengembang Mitra Tasik 114', 'Puri Tasik Indah 114', 'Kec. Mangkubumi, Kota Tasikmalaya', '87 unit', '26.000 m²', 'Penanggung Jawab 114, S.T.', 'Survey', 'Terjadwal', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0115', 'PT Pengembang Mitra Tasik 115', 'Cluster Tasik Indah 115', 'Kec. Cipedes, Kota Tasikmalaya', '187 unit', '43.000 m²', 'Penanggung Jawab 115, S.T.', 'Dokumen', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0116', 'PT Pengembang Mitra Tasik 116', 'Pesona Tasik Indah 116', 'Kec. Indihiang, Kota Tasikmalaya', '99 unit', '41.000 m²', 'Penanggung Jawab 116, S.T.', 'Verifikasi teknis', 'Terjadwal', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0117', 'PT Pengembang Mitra Tasik 117', 'Griya Tasik Indah 117', 'Kec. Tamansari, Kota Tasikmalaya', '175 unit', '50.000 m²', 'Penanggung Jawab 117, S.T.', 'Persetujuan', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0118', 'PT Pengembang Mitra Tasik 118', 'Cluster Tasik Indah 118', 'Kec. Tawang, Kota Tasikmalaya', '184 unit', '12.000 m²', 'Penanggung Jawab 118, S.T.', 'Monitoring', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0119', 'PT Pengembang Mitra Tasik 119', 'Pesona Tasik Indah 119', 'Kec. Purbaratu, Kota Tasikmalaya', '55 unit', '16.000 m²', 'Penanggung Jawab 119, S.T.', 'Survey', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0120', 'PT Pengembang Mitra Tasik 120', 'Pesona Tasik Indah 120', 'Kec. Cipedes, Kota Tasikmalaya', '181 unit', '30.000 m²', 'Penanggung Jawab 120, S.T.', 'Survey', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0121', 'PT Pengembang Mitra Tasik 121', 'Taman Tasik Indah 121', 'Kec. Bungursari, Kota Tasikmalaya', '108 unit', '47.000 m²', 'Penanggung Jawab 121, S.T.', 'Monitoring', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0122', 'PT Pengembang Mitra Tasik 122', 'Puri Tasik Indah 122', 'Kec. Cipedes, Kota Tasikmalaya', '56 unit', '23.000 m²', 'Penanggung Jawab 122, S.T.', 'Monitoring', 'Final', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0123', 'PT Pengembang Mitra Tasik 123', 'Griya Tasik Indah 123', 'Kec. Kawalu, Kota Tasikmalaya', '118 unit', '11.000 m²', 'Penanggung Jawab 123, S.T.', 'Dokumen', 'Terjadwal', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0124', 'PT Pengembang Mitra Tasik 124', 'Puri Tasik Indah 124', 'Kec. Bungursari, Kota Tasikmalaya', '153 unit', '38.000 m²', 'Penanggung Jawab 124, S.T.', 'Persetujuan', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0125', 'PT Pengembang Mitra Tasik 125', 'Taman Tasik Indah 125', 'Kec. Tawang, Kota Tasikmalaya', '138 unit', '18.000 m²', 'Penanggung Jawab 125, S.T.', 'Monitoring', 'Siap disetujui', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0126', 'PT Pengembang Mitra Tasik 126', 'Puri Tasik Indah 126', 'Kec. Purbaratu, Kota Tasikmalaya', '173 unit', '10.000 m²', 'Penanggung Jawab 126, S.T.', 'Dokumen', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0127', 'PT Pengembang Mitra Tasik 127', 'Puri Tasik Indah 127', 'Kec. Kawalu, Kota Tasikmalaya', '107 unit', '16.000 m²', 'Penanggung Jawab 127, S.T.', 'Dokumen', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0128', 'PT Pengembang Mitra Tasik 128', 'Cluster Tasik Indah 128', 'Kec. Mangkubumi, Kota Tasikmalaya', '88 unit', '25.000 m²', 'Penanggung Jawab 128, S.T.', 'Persetujuan', 'Siap disetujui', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0129', 'PT Pengembang Mitra Tasik 129', 'Puri Tasik Indah 129', 'Kec. Purbaratu, Kota Tasikmalaya', '163 unit', '26.000 m²', 'Penanggung Jawab 129, S.T.', 'Dokumen', 'Final', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0130', 'PT Pengembang Mitra Tasik 130', 'Griya Tasik Indah 130', 'Kec. Cibeureum, Kota Tasikmalaya', '186 unit', '50.000 m²', 'Penanggung Jawab 130, S.T.', 'Persetujuan', 'Menunggu verifikasi', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0131', 'PT Pengembang Mitra Tasik 131', 'Griya Tasik Indah 131', 'Kec. Cipedes, Kota Tasikmalaya', '178 unit', '23.000 m²', 'Penanggung Jawab 131, S.T.', 'Verifikasi teknis', 'Siap disetujui', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0132', 'PT Pengembang Mitra Tasik 132', 'Griya Tasik Indah 132', 'Kec. Tamansari, Kota Tasikmalaya', '193 unit', '49.000 m²', 'Penanggung Jawab 132, S.T.', 'Monitoring', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0133', 'PT Pengembang Mitra Tasik 133', 'Cluster Tasik Indah 133', 'Kec. Cipedes, Kota Tasikmalaya', '160 unit', '11.000 m²', 'Penanggung Jawab 133, S.T.', 'Survey', 'Siap disetujui', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0134', 'PT Pengembang Mitra Tasik 134', 'Pesona Tasik Indah 134', 'Kec. Tawang, Kota Tasikmalaya', '169 unit', '33.000 m²', 'Penanggung Jawab 134, S.T.', 'Persetujuan', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0135', 'PT Pengembang Mitra Tasik 135', 'Griya Tasik Indah 135', 'Kec. Tamansari, Kota Tasikmalaya', '174 unit', '25.000 m²', 'Penanggung Jawab 135, S.T.', 'Persetujuan', 'Final', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0136', 'PT Pengembang Mitra Tasik 136', 'Pesona Tasik Indah 136', 'Kec. Cipedes, Kota Tasikmalaya', '125 unit', '11.000 m²', 'Penanggung Jawab 136, S.T.', 'Survey', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0137', 'PT Pengembang Mitra Tasik 137', 'Cluster Tasik Indah 137', 'Kec. Cipedes, Kota Tasikmalaya', '84 unit', '33.000 m²', 'Penanggung Jawab 137, S.T.', 'Dokumen', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0138', 'PT Pengembang Mitra Tasik 138', 'Puri Tasik Indah 138', 'Kec. Cipedes, Kota Tasikmalaya', '169 unit', '10.000 m²', 'Penanggung Jawab 138, S.T.', 'Monitoring', 'Menunggu verifikasi', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0139', 'PT Pengembang Mitra Tasik 139', 'Cluster Tasik Indah 139', 'Kec. Cipedes, Kota Tasikmalaya', '128 unit', '42.000 m²', 'Penanggung Jawab 139, S.T.', 'Survey', 'Draft', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0140', 'PT Pengembang Mitra Tasik 140', 'Pesona Tasik Indah 140', 'Kec. Bungursari, Kota Tasikmalaya', '116 unit', '40.000 m²', 'Penanggung Jawab 140, S.T.', 'Monitoring', 'Terjadwal', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0141', 'PT Pengembang Mitra Tasik 141', 'Cluster Tasik Indah 141', 'Kec. Purbaratu, Kota Tasikmalaya', '191 unit', '44.000 m²', 'Penanggung Jawab 141, S.T.', 'Survey', 'Menunggu verifikasi', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0142', 'PT Pengembang Mitra Tasik 142', 'Taman Tasik Indah 142', 'Kec. Kawalu, Kota Tasikmalaya', '85 unit', '31.000 m²', 'Penanggung Jawab 142, S.T.', 'Persetujuan', 'Perlu perbaikan', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0143', 'PT Pengembang Mitra Tasik 143', 'Taman Tasik Indah 143', 'Kec. Indihiang, Kota Tasikmalaya', '79 unit', '23.000 m²', 'Penanggung Jawab 143, S.T.', 'Dokumen', 'Final', 'Pengajuan dalam proses verifikasi reguler.', '05 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0144', 'PT Mitra Sejahtera Tasik', 'Tamansari Asri Residence', 'Kec. Tamansari, Kota Tasikmalaya', '160 unit rumah tapak', '38.000 m²', 'Ahmad Fauzi, S.T.', 'Persetujuan', 'Siap disetujui', 'Seluruh tahapan verifikasi teknis dan monitoring telah terpenuhi.', '10 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0145', 'PT Galunggung Asri Propertindo', 'Bungursari Harmoni Indah', 'Kec. Bungursari, Kota Tasikmalaya', '96 unit rumah tapak', '21.200 m²', 'Yudi Permana, S.T.', 'Monitoring', 'Final', 'Hasil monitoring lapangan telah berstatus Final.', '11 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0146', 'PT Priangan Griya Graha', 'Pesona Cibeureum Pratama', 'Kec. Cibeureum, Kota Tasikmalaya', '120 unit rumah tapak', '26.000 m²', 'Ir. Tatan Rustandi', 'Dokumen', 'Menunggu verifikasi', 'Dokumen persyaratan lengkap dan siap diperiksa tim administratif.', '12 Mei 2025', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0147', 'PT Sukapura Mandiri Properti', 'Kencana Kawalu Regency', 'Kec. Kawalu, Kota Tasikmalaya', '85 unit rumah tapak', '18.500 m²', 'Dedi Setiadi, S.T.', 'Survey', 'Terjadwal', 'Jadwal survey lokasi telah dikonfirmasi untuk tanggal 20 Mei 2025.', 'Kemarin, 15.20', '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
('SR-2025-0148', 'PT Citra Tasik Mandiri', 'Griya Mangkubumi Asri', 'Kec. Mangkubumi, Kota Tasikmalaya', '148 unit rumah tapak', '34.800 m²', 'H. Asep Hendrayana, S.T.', 'Verifikasi teknis', 'Perlu perbaikan', 'Terdapat 3 dokumen yang memerlukan perbaikan sebelum proses dapat dilanjutkan ke penjadwalan survey.', '08 Mei 2025 · 09.21 WIB', '2026-09-15 05:35:13', '2026-09-15 05:35:13');

-- --------------------------------------------------------

--
-- Table structure for table `riwayat_pengajuan`
--

CREATE TABLE `riwayat_pengajuan` (
  `id` bigint UNSIGNED NOT NULL,
  `pengajuan_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `judul` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `deskripsi` text COLLATE utf8mb4_unicode_ci,
  `oleh` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `riwayat_pengajuan`
--

INSERT INTO `riwayat_pengajuan` (`id`, `pengajuan_id`, `judul`, `deskripsi`, `oleh`, `tanggal`, `created_at`, `updated_at`) VALUES
(1, 'SR-2025-0148', '14 Mei 2025 · 10.42', 'Verifikator Disperwaskim mengirim permintaan perbaikan untuk 3 dokumen.', 'Verifikator Disperwaskim', '14 Mei 2025 · 10.42', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(2, 'SR-2025-0148', '13 Mei 2025 · 15.10', 'Pengembang mengunggah versi 2 KTP Direktur Utama. Versi 1 tetap tersimpan.', 'PT Citra Tasik Mandiri', '13 Mei 2025 · 15.10', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(3, 'SR-2025-0148', '08 Mei 2025 · 09.21', 'Pengajuan baru dibuat oleh PT Citra Tasik Mandiri.', 'PT Citra Tasik Mandiri', '08 Mei 2025 · 09.21', '2026-09-15 05:35:14', '2026-09-15 05:35:14');

-- --------------------------------------------------------

--
-- Table structure for table `sessions`
--

CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint UNSIGNED DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sessions`
--

INSERT INTO `sessions` (`id`, `user_id`, `ip_address`, `user_agent`, `payload`, `last_activity`) VALUES
('mb77941mO9wrvcCKEnHHNi406n9Qo2lFSTUw7kyS', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoiaGVpaGhrdnNUbzg1T2w2emRnNjc4S2RPajZXNUMxVzdETUI4Vk5MUyI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjMyOiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvbm90aWZpa2FzaSI7czo1OiJyb3V0ZSI7czoxNjoibm90aWZpa2FzaS5pbmRleCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fXM6NTA6ImxvZ2luX3dlYl81OWJhMzZhZGRjMmIyZjk0MDE1ODBmMDE0YzdmNThlYTRlMzA5ODlkIjtpOjE7fQ==', 1789514034),
('zKOiIjoJeztaeiQlL2mPWnFXSSbLwVGBg4wFXEhx', 1, '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/152.0.0.0 Safari/537.36', 'YTo1OntzOjY6Il90b2tlbiI7czo0MDoiUTlYbTd1Zm85eU9ka25LUTFWa0wxQzBHOWxBTFVVMmlUTUFPQ3YyMSI7czozOiJ1cmwiO2E6MDp7fXM6OToiX3ByZXZpb3VzIjthOjI6e3M6MzoidXJsIjtzOjM4OiJodHRwOi8vMTI3LjAuMC4xOjgwMDAvcGVuZ2FqdWFuP3BhZ2U9MyI7czo1OiJyb3V0ZSI7czoxNToicGVuZ2FqdWFuLmluZGV4Ijt9czo2OiJfZmxhc2giO2E6Mjp7czozOiJvbGQiO2E6MDp7fXM6MzoibmV3IjthOjA6e319czo1MDoibG9naW5fd2ViXzU5YmEzNmFkZGMyYjJmOTQwMTU4MGYwMTRjN2Y1OGVhNGUzMDk4OWQiO2k6MTt9', 1789488592);

-- --------------------------------------------------------

--
-- Table structure for table `survey_pengajuan`
--

CREATE TABLE `survey_pengajuan` (
  `id` bigint UNSIGNED NOT NULL,
  `pengajuan_id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tanggal_survey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `jam_survey` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '09.00 WIB',
  `petugas_nama` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `petugas_role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Perwaskim',
  `instruksi` text COLLATE utf8mb4_unicode_ci,
  `status` enum('Terjadwal','Selesai','Dijadwalkan Ulang') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Terjadwal',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `survey_pengajuan`
--

INSERT INTO `survey_pengajuan` (`id`, `pengajuan_id`, `tanggal_survey`, `jam_survey`, `petugas_nama`, `petugas_role`, `instruksi`, `status`, `created_at`, `updated_at`) VALUES
(1, 'SR-2025-0148', '2025-05-22', '09.00 WIB', 'Rahmat Hidayat, S.T.', 'Perwaskim', 'Tinjau kesesuaian site plan, drainase, akses jalan, dan fasilitas umum di lokasi perumahan.', 'Terjadwal', '2026-09-15 05:35:14', '2026-09-15 05:35:14'),
(2, 'SR-2025-0148', '2025-05-20', '09.00 WIB', 'Rahmat Hidayat, S.T.', 'Perwaskim', 'Survey awal lokasi perumahan.', 'Dijadwalkan Ulang', '2026-09-15 05:35:14', '2026-09-15 05:35:14');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint UNSIGNED NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'admin_dpkp',
  `avatar_initials` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'AD',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `email_verified_at`, `password`, `role`, `avatar_initials`, `remember_token`, `created_at`, `updated_at`) VALUES
(1, 'Verifikator Disperwaskim', 'admin@saturumah.go.id', NULL, '$2y$12$mpbojB9/Fb7h9SEhfbZxAeqDLNp2gNVC5e4bCaTLQP7WSbh3QZlLK', 'verifikator', 'VD', NULL, '2026-09-15 05:35:12', '2026-09-15 05:35:12'),
(2, 'Verifikator Disperwaskim', 'verifikator@saturumah.go.id', NULL, '$2y$12$VfdAmfFCWd3tdDltbinfde6R1gI3vWnnbvHeIVDZpxX7Gssp.ZeWi', 'verifikator', 'VD', NULL, '2026-09-15 05:35:13', '2026-09-15 05:35:13'),
(3, 'Rahmat Hidayat, S.T.', 'rahmat@saturumah.go.id', NULL, '$2y$12$KFbYANsl2VPovp96JCDyDebhIc.D5OlXd6PGT7AcMbs/F7JJiJljW', 'perwaskim', 'RH', NULL, '2026-09-15 05:35:13', '2026-09-15 05:35:13');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `cache`
--
ALTER TABLE `cache`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_expiration_index` (`expiration`);

--
-- Indexes for table `cache_locks`
--
ALTER TABLE `cache_locks`
  ADD PRIMARY KEY (`key`),
  ADD KEY `cache_locks_expiration_index` (`expiration`);

--
-- Indexes for table `dokumen_pengajuan`
--
ALTER TABLE `dokumen_pengajuan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `dokumen_pengajuan_pengajuan_id_foreign` (`pengajuan_id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `jobs`
--
ALTER TABLE `jobs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `jobs_queue_index` (`queue`);

--
-- Indexes for table `job_batches`
--
ALTER TABLE `job_batches`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `monitoring_pengajuan`
--
ALTER TABLE `monitoring_pengajuan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `monitoring_pengajuan_pengajuan_id_foreign` (`pengajuan_id`);

--
-- Indexes for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD PRIMARY KEY (`id`),
  ADD KEY `notifikasi_pengajuan_id_foreign` (`pengajuan_id`);

--
-- Indexes for table `password_reset_tokens`
--
ALTER TABLE `password_reset_tokens`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `pengajuan`
--
ALTER TABLE `pengajuan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `riwayat_pengajuan`
--
ALTER TABLE `riwayat_pengajuan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `riwayat_pengajuan_pengajuan_id_foreign` (`pengajuan_id`);

--
-- Indexes for table `sessions`
--
ALTER TABLE `sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `sessions_user_id_index` (`user_id`),
  ADD KEY `sessions_last_activity_index` (`last_activity`);

--
-- Indexes for table `survey_pengajuan`
--
ALTER TABLE `survey_pengajuan`
  ADD PRIMARY KEY (`id`),
  ADD KEY `survey_pengajuan_pengajuan_id_foreign` (`pengajuan_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `dokumen_pengajuan`
--
ALTER TABLE `dokumen_pengajuan`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `jobs`
--
ALTER TABLE `jobs`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `monitoring_pengajuan`
--
ALTER TABLE `monitoring_pengajuan`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `notifikasi`
--
ALTER TABLE `notifikasi`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `riwayat_pengajuan`
--
ALTER TABLE `riwayat_pengajuan`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `survey_pengajuan`
--
ALTER TABLE `survey_pengajuan`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `dokumen_pengajuan`
--
ALTER TABLE `dokumen_pengajuan`
  ADD CONSTRAINT `dokumen_pengajuan_pengajuan_id_foreign` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `monitoring_pengajuan`
--
ALTER TABLE `monitoring_pengajuan`
  ADD CONSTRAINT `monitoring_pengajuan_pengajuan_id_foreign` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `notifikasi`
--
ALTER TABLE `notifikasi`
  ADD CONSTRAINT `notifikasi_pengajuan_id_foreign` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `riwayat_pengajuan`
--
ALTER TABLE `riwayat_pengajuan`
  ADD CONSTRAINT `riwayat_pengajuan_pengajuan_id_foreign` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `survey_pengajuan`
--
ALTER TABLE `survey_pengajuan`
  ADD CONSTRAINT `survey_pengajuan_pengajuan_id_foreign` FOREIGN KEY (`pengajuan_id`) REFERENCES `pengajuan` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
