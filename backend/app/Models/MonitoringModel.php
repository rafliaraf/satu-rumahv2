<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MonitoringModel extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'monitoring_models';

    protected $fillable = [
        'id',
        'pengajuan_id',
        'survey_schedule_id',
        'nomor_surat_ba',
        'tanggal_monitoring',
        'nama_perumahan',
        'nama_developer',
        'lokasi_perumahan',
        'maksud_tujuan',
        'temuan_lapangan',
        'kesimpulan',
        'kesepakatan',
        'rencana_tindak_lanjut',
        'status_hasil_evaluasi',
        'pelaksana_nama',
        'pelaksana_jabatan',
        'ditemui_nama',
        'ditemui_jabatan',
        'photo_paths',
        'is_draft',
        'created_by',
    ];

    protected $casts = [
        'tanggal_monitoring' => 'datetime',
        'temuan_lapangan' => 'array',
        'kesimpulan' => 'array',
        'kesepakatan' => 'array',
        'rencana_tindak_lanjut' => 'array',
        'photo_paths' => 'array',
        'is_draft' => 'boolean',
    ];

    public function pengajuan()
    {
        return $this->belongsTo(Pengajuan::class, 'pengajuan_id');
    }

    public function surveySchedule()
    {
        return $this->belongsTo(SurveySchedule::class, 'survey_schedule_id');
    }

    /**
     * Format response JSON yang PERSIS sama dengan kebutuhan FE Flutter
     */
    public function toFlutterArray(): array
    {
        return [
            'id' => $this->id,
            'pengajuanId' => $this->pengajuan_id,
            'surveyScheduleId' => $this->survey_schedule_id,
            'nomorSuratBA' => $this->nomor_surat_ba,
            'tanggalMonitoring' => $this->tanggal_monitoring ? $this->tanggal_monitoring->toIso8601String() : null,
            'namaPerumahan' => $this->nama_perumahan,
            'namaDeveloper' => $this->nama_developer,
            'lokasiPerumahan' => $this->lokasi_perumahan,
            'maksudTujuan' => $this->maksud_tujuan,
            'temuanLapangan' => $this->temuan_lapangan ?? [],
            'kesimpulan' => $this->kesimpulan ?? [],
            'kesepakatan' => $this->kesepakatan ?? [],
            'rencanaTindakLanjut' => $this->rencana_tindak_lanjut ?? [],
            'statusHasilEvaluasi' => $this->status_hasil_evaluasi,
            'pelaksanaNama' => $this->pelaksana_nama,
            'pelaksanaJabatan' => $this->pelaksana_jabatan,
            'ditemuiNama' => $this->ditemui_nama,
            'ditemuiJabatan' => $this->ditemui_jabatan,
            'photoPaths' => $this->photo_paths ?? [],
            'isDraft' => (bool) $this->is_draft,
        ];
    }
}
