<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Pengajuan extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';

    protected $fillable = [
        'id',
        'user_id',
        'nama_perumahan',
        'nama_pt',
        'nama_direktur',
        'npwp_perusahaan',
        'luas_lahan',
        'jumlah_unit',
        'tipe_perumahan',
        'status',
        'status_tahap',
        'tanggal',
        'catatan_perbaikan',
        'uploaded_docs',
        'verified_docs',
        'dokumen_perlu_revisi',
        'tanggal_survey',
        'catatan_survey',
        'tahap_asal_perbaikan',
        'created_by',
    ];

    protected $casts = [
        'luas_lahan' => 'float',
        'jumlah_unit' => 'integer',
        'uploaded_docs' => 'array',
        'verified_docs' => 'array',
        'dokumen_perlu_revisi' => 'array',
        'tanggal_survey' => 'datetime',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function monitorings()
    {
        return $this->hasMany(MonitoringModel::class, 'pengajuan_id');
    }

    /**
     * Format response JSON yang PERSIS sama dengan kebutuhan FE Flutter
     */
    public function toFlutterArray(): array
    {
        return [
            'id' => $this->id,
            'namaPerumahan' => $this->nama_perumahan,
            'namaPt' => $this->nama_pt,
            'namaDirektur' => $this->nama_direktur,
            'npwpPerusahaan' => $this->npwp_perusahaan,
            'luasLahan' => (float) $this->luas_lahan,
            'jumlahUnit' => (int) $this->jumlah_unit,
            'tipePerumahan' => $this->tipe_perumahan,
            'status' => $this->status,
            'statusTahap' => $this->status_tahap,
            'tanggal' => $this->tanggal,
            'catatanPerbaikan' => $this->catatan_perbaikan,
            'uploadedDocs' => $this->uploaded_docs ?? (object)[],
            'verifiedDocs' => $this->verified_docs ?? (object)[],
            'dokumenPerluRevisi' => $this->dokumen_perlu_revisi ?? [],
            'tanggalSurvey' => $this->tanggal_survey ? $this->tanggal_survey->toIso8601String() : null,
            'catatanSurvey' => $this->catatan_survey,
            'tahapAsalPerbaikan' => $this->tahap_asal_perbaikan,
        ];
    }
}
