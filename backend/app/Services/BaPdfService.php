<?php

namespace App\Services;

use App\Models\MonitoringModel;

class BaPdfService
{
    private static array $bulanIndonesia = [
        1 => 'Januari', 2 => 'Februari', 3 => 'Maret', 4 => 'April', 5 => 'Mei', 6 => 'Juni',
        7 => 'Juli', 8 => 'Agustus', 9 => 'September', 10 => 'Oktober', 11 => 'November', 12 => 'Desember'
    ];

    private static array $hariIndonesia = [
        1 => 'Senin', 2 => 'Selasa', 3 => 'Rabu', 4 => 'Kamis', 5 => 'Jumat', 6 => 'Sabtu', 7 => 'Minggu'
    ];

    public static function formatTanggalTerbilang(\DateTimeInterface $dt): string
    {
        $hari = self::$hariIndonesia[(int) $dt->format('N')];
        $bulan = self::$bulanIndonesia[(int) $dt->format('n')];
        $tgl = $dt->format('j');
        $thn = $dt->format('Y');

        return "hari {$hari} tanggal {$tgl} bulan {$bulan} tahun {$thn}";
    }

    public static function generatePayloadData(MonitoringModel $monitoring): array
    {
        return [
            'kopSurat' => [
                'pemerintah' => 'PEMERINTAH KOTA TASIKMALAYA',
                'dinas' => 'DINAS PERUMAHAN DAN KAWASAN PERMUKIMAN',
                'judul' => 'BERITA ACARA MONITORING DAN EVALUASI LAPANGAN',
                'nomorSuratBA' => $monitoring->nomor_surat_ba,
            ],
            'paragrafPembuka' => [
                'tanggalTerbilang' => self::formatTanggalTerbilang($monitoring->tanggal_monitoring),
                'namaPerumahan' => $monitoring->nama_perumahan,
                'lokasiPerumahan' => $monitoring->lokasi_perumahan ?: '-',
            ],
            'poinUtama' => [
                'maksudTujuan' => $monitoring->maksud_tujuan,
                'temuanLapangan' => $monitoring->temuan_lapangan ?? [],
                'kesimpulan' => $monitoring->kesimpulan ?? [],
                'kesepakatan' => $monitoring->kesepakatan ?? [],
                'rencanaTindakLanjut' => $monitoring->rencana_tindak_lanjut ?? [],
            ],
            'tandaTangan' => [
                'pelaksana' => [
                    'label' => 'Yang Melaksanakan Observasi/Inspeksi',
                    'nama' => $monitoring->pelaksana_nama ?: '( _________________ )',
                    'jabatan' => $monitoring->pelaksana_jabatan ?: 'Petugas DPKP',
                ],
                'ditemui' => [
                    'label' => 'Yang Ditemui di Lapangan',
                    'nama' => $monitoring->ditemui_nama ?: '( _________________ )',
                    'jabatan' => $monitoring->ditemui_jabatan ?: 'Perwakilan Pengembang',
                ]
            ],
            'photoPaths' => $monitoring->photo_paths ?? []
        ];
    }
}
