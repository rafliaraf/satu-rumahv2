<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\DokumenType;
use App\Models\Pengajuan;
use App\Models\MonitoringModel;
use App\Models\NotifikasiModel;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Users (Kredensial Quick Demo)
        $devUser = User::create([
            'username' => 'pt_tasik_indah',
            'password' => Hash::make('demo123'),
            'nama' => 'PT. Tasik Indah Sentosa',
            'role' => 'pengembang',
            'email' => 'tasikindah@developer.com',
            'nama_pt' => 'PT. Tasik Indah Sentosa',
            'nama_direktur' => 'H. Tatang Sutisna',
            'nib' => '9120304958102',
            'npwp_perusahaan' => '09.123.456.7-423.000',
        ]);

        $adminUser = User::create([
            'username' => 'admin_disperwaskim',
            'password' => Hash::make('admin123'),
            'nama' => 'Rizki Pratama, S.T.',
            'role' => 'admin_disperwaskim',
            'nip' => '19930512 202010 1 001',
            'jabatan' => 'Verifikator Administrasi',
            'email' => 'rizki.pratama@tasikmalayakota.go.id',
        ]);

        $monitoringUser = User::create([
            'username' => 'tim_monitoring_perwaskim',
            'password' => Hash::make('monitoring123'),
            'nama' => 'Drs. Rian Hidayat, M.Si',
            'role' => 'tim_monitoring',
            'nip' => '19880512 201503 1 002',
            'jabatan' => 'Ketua Tim Monitoring & Evaluasi DPKP',
            'email' => 'rian.perwaskim@tasikmalayakota.go.id',
            'no_whatsapp' => '0812-3456-7890',
        ]);

        // 2. Seed Dokumen Types (Section 9.1)
        $dokumenTypes = [
            ['key' => 'ktp', 'label' => 'KTP-Elektronik Pemohon', 'is_mandatory' => true, 'allowed_formats' => ['pdf', 'jpg'], 'max_size_mb' => 5, 'step' => 2, 'section' => 'Dokumen Perusahaan'],
            ['key' => 'nib', 'label' => 'Nomor Induk Berusaha (NIB)', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 5, 'step' => 2, 'section' => 'Dokumen Perusahaan'],
            ['key' => 'npwp_doc', 'label' => 'NPWP Perusahaan', 'is_mandatory' => true, 'allowed_formats' => ['pdf', 'jpg'], 'max_size_mb' => 5, 'step' => 2, 'section' => 'Dokumen Perusahaan'],
            ['key' => 'asosiasi', 'label' => 'Keanggotaan Asosiasi Pengembang', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 5, 'step' => 2, 'section' => 'Dokumen Perusahaan'],
            ['key' => 'legalitas', 'label' => 'Legalitas Perusahaan (Akta)', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 5, 'step' => 2, 'section' => 'Dokumen Perusahaan'],
            
            ['key' => 'surat_permohonan', 'label' => 'Surat permohonan persetujuan', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Legalitas & Perizinan'],
            ['key' => 'info_intensitas_ruang', 'label' => 'Informasi intensitas ruang', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Legalitas & Perizinan'],
            ['key' => 'bukti_kepemilikan_lahan', 'label' => 'Bukti kepemilikan lahan', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Legalitas & Perizinan'],
            ['key' => 'bukti_tpu', 'label' => 'Bukti penyediaan lahan TPU', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Legalitas & Perizinan'],

            ['key' => 'kkpr_doc', 'label' => 'Persetujuan KKPR', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Teknis & Rekomendasi'],
            ['key' => 'pbg_induk', 'label' => 'PBG Induk Perumahan', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Teknis & Rekomendasi'],
            ['key' => 'rekomendasi_lingkungan', 'label' => 'Rekomendasi Dokumen Lingkungan', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Teknis & Rekomendasi'],
            ['key' => 'pelepasan_lahan', 'label' => 'Rekomendasi Pelepasan Lahan (Kondisional)', 'is_mandatory' => false, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Teknis & Rekomendasi'],

            ['key' => 'pernyataan_pelepasan', 'label' => 'Surat Pernyataan Pelepasan Hak', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Dokumen Pernyataan'],
            ['key' => 'pernyataan_keabsahan', 'label' => 'Surat Pernyataan Keabsahan Dokumen', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Dokumen Pernyataan'],
            ['key' => 'pernyataan_psu', 'label' => 'Surat Pernyataan Kesanggupan PSU', 'is_mandatory' => true, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 3, 'section' => 'Dokumen Pernyataan'],

            ['key' => 'site_plan_dwg', 'label' => 'Desain Layout Site Plan (AutoCAD DWG)', 'is_mandatory' => true, 'allowed_formats' => ['dwg'], 'max_size_mb' => 15, 'step' => 4, 'section' => 'Dokumen Teknis'],
            ['key' => 'drainase_doc', 'label' => 'Dokumen Kajian Teknis Drainase', 'is_mandatory' => false, 'allowed_formats' => ['pdf'], 'max_size_mb' => 10, 'step' => 4, 'section' => 'Dokumen Teknis'],
        ];

        foreach ($dokumenTypes as $type) {
            DokumenType::create($type);
        }

        // 3. Seed Pengajuans (Section 5.3)
        $p1 = Pengajuan::create([
            'id' => 'SR-20260710-045',
            'user_id' => $devUser->id,
            'nama_perumahan' => 'Mutiara Regency Tasik',
            'nama_pt' => 'PT. Tasik Indah Sentosa',
            'nama_direktur' => 'H. Tatang Sutisna',
            'npwp_perusahaan' => '09.123.456.7-423.000',
            'luas_lahan' => 20000.0,
            'jumlah_unit' => 120,
            'tipe_perumahan' => 'Komersil',
            'status' => 'Dalam Proses',
            'status_tahap' => 'verifikasiAdministrasi',
            'tanggal' => '10 Juli 2026',
            'uploaded_docs' => [
                'ktp' => 'ktp_direktur.pdf',
                'nib' => 'nib_perusahaan.pdf',
                'npwp_doc' => 'npwp_perusahaan.pdf',
                'asosiasi' => 'bukti_asosiasi.pdf',
                'legalitas' => 'legalitas_pt.pdf'
            ],
            'verified_docs' => [],
            'dokumen_perlu_revisi' => [],
        ]);

        $p2 = Pengajuan::create([
            'id' => 'SR-20260615-012',
            'user_id' => $devUser->id,
            'nama_perumahan' => 'Griya Asri Kawalu',
            'nama_pt' => 'PT. Tasik Indah Sentosa',
            'nama_direktur' => 'H. Tatang Sutisna',
            'npwp_perusahaan' => '09.123.456.7-423.000',
            'luas_lahan' => 8500.0,
            'jumlah_unit' => 45,
            'tipe_perumahan' => 'Subsidi',
            'status' => 'Perlu Perbaikan',
            'status_tahap' => 'perluPerbaikan',
            'tanggal' => '15 Juni 2026',
            'catatan_perbaikan' => 'Dokumen Kesesuaian Tata Ruang tidak terbaca/buram. Harap unggah ulang file dengan resolusi lebih tinggi.',
            'uploaded_docs' => [
                'ktp' => 'ktp_direktur.pdf',
                'nib' => 'nib_perusahaan.pdf',
                'kkpr_doc' => 'kkpr_buram.pdf'
            ],
            'verified_docs' => ['ktp' => true, 'nib' => true, 'kkpr_doc' => false],
            'dokumen_perlu_revisi' => ['kkpr_doc'],
        ]);

        $p3 = Pengajuan::create([
            'id' => 'SR-20260520-008',
            'user_id' => $devUser->id,
            'nama_perumahan' => 'Bumi Tasik Lestari',
            'nama_pt' => 'PT. Tasik Indah Sentosa',
            'nama_direktur' => 'H. Tatang Sutisna',
            'npwp_perusahaan' => '09.123.456.7-423.000',
            'luas_lahan' => 12000.0,
            'jumlah_unit' => 70,
            'tipe_perumahan' => 'Komersil',
            'status' => 'Selesai',
            'status_tahap' => 'selesai',
            'tanggal' => '20 Mei 2026',
            'uploaded_docs' => ['ktp' => 'ktp.pdf', 'nib' => 'nib.pdf'],
        ]);

        // 4. Seed Monitoring Models (Section 5.4)
        MonitoringModel::create([
            'id' => 'm1',
            'pengajuan_id' => $p1->id,
            'nomor_surat_ba' => '600.2.5/BA-MON/V/2024',
            'tanggal_monitoring' => '2024-05-20 00:00:00',
            'nama_perumahan' => 'Permata Hijau Residence',
            'nama_developer' => 'PT ABC Property',
            'lokasi_perumahan' => 'Jl. Ir. H. Juanda No. 45, Tasikmalaya',
            'maksud_tujuan' => 'Kegiatan ini dilaksanakan guna memastikan kesesuaian pelaksanaan dengan perencanaan...',
            'temuan_lapangan' => [
                'Drainase utama sudah terbangun 80%',
                'Penerangan jalan umum belum terpasang di Blok C'
            ],
            'kesimpulan' => [
                'Progres pembangunan PSU sesuai jadwal namun perlu percepatan PJU.'
            ],
            'kesepakatan' => [
                'Pengembang bersedia menyelesaikan PJU sebelum akhir bulan.'
            ],
            'rencana_tindak_lanjut' => [
                'Pemeriksaan ulang fisik PJU pada tanggal 5 Juni 2024.'
            ],
            'status_hasil_evaluasi' => 'perluEvaluasiLanjutan',
            'pelaksana_nama' => 'Ir. Ahmad Subagja',
            'pelaksana_jabatan' => 'Ketua Tim Evaluasi DPKP',
            'ditemui_nama' => 'H. Endang',
            'ditemui_jabatan' => 'Perwakilan PT ABC Property',
            'photo_paths' => [],
            'is_draft' => false,
            'created_by' => $monitoringUser->id,
        ]);

        // 5. Seed Notifikasis (Section 5.5)
        NotifikasiModel::create([
            'id' => 'n1',
            'user_id' => null,
            'jenis' => 'pengajuanBaru',
            'judul' => 'Pengajuan Baru: Mutiara Regency Tasik',
            'deskripsi' => 'PT. Tasik Indah Sentosa telah mengajukan berkas pengesahan site plan baru.',
            'waktu' => now()->subHours(2),
            'is_read' => false,
            'target_route' => '/admin/pengajuan/detail/SR-20260710-045',
        ]);

        NotifikasiModel::create([
            'id' => 'n2',
            'user_id' => null,
            'jenis' => 'dokumenDiunggahUlang',
            'judul' => 'Dokumen Perbaikan Diunggah',
            'deskripsi' => 'Pengembang Griya Asri Kawalu telah memperbarui file KKPR yang sebelumnya buram.',
            'waktu' => now()->subHours(5),
            'is_read' => false,
            'target_route' => '/admin/pengajuan/detail/SR-20260615-012',
        ]);

        NotifikasiModel::create([
            'id' => 'n3',
            'user_id' => $monitoringUser->id,
            'jenis' => 'reminderSurvey',
            'judul' => 'Jadwal Survey Lapangan Besok',
            'deskripsi' => 'Survey lokasi Perumahan Permata Hijau Residence dijadwalkan pukul 09:00 WIB.',
            'waktu' => now()->subDays(1),
            'is_read' => true,
            'target_route' => '/monitoring',
        ]);
    }
}
