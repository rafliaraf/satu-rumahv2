<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SurveySchedule extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'survey_schedules';

    protected $fillable = [
        'id',
        'pengajuan_id',
        'tanggal_execution',
        'catatan_instruksi',
        'assigned_perwaskim_id',
        'status',
        'created_by',
    ];

    protected $casts = [
        'tanggal_execution' => 'datetime',
    ];

    public function pengajuan()
    {
        return $this->belongsTo(Pengajuan::class, 'pengajuan_id');
    }

    public function assignedPerwaskim()
    {
        return $this->belongsTo(User::class, 'assigned_perwaskim_id');
    }

    public function toFlutterArray(): array
    {
        return [
            'id' => $this->id,
            'pengajuanId' => $this->pengajuan_id,
            'tanggalExecution' => $this->tanggal_execution ? $this->tanggal_execution->toIso8601String() : null,
            'catatanInstruksi' => $this->catatan_instruksi,
            'assignedPerwaskimId' => $this->assigned_perwaskim_id,
            'assignedPerwaskimNama' => $this->assignedPerwaskim?->nama,
            'status' => $this->status,
            'createdAt' => $this->created_at ? $this->created_at->toIso8601String() : null,
        ];
    }
}
