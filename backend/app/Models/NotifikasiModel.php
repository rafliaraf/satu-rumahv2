<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class NotifikasiModel extends Model
{
    public $incrementing = false;
    protected $keyType = 'string';
    protected $table = 'notifikasi_models';

    protected $fillable = [
        'id',
        'user_id',
        'jenis',
        'judul',
        'deskripsi',
        'waktu',
        'is_read',
        'target_route',
    ];

    protected $casts = [
        'waktu' => 'datetime',
        'is_read' => 'boolean',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function toFlutterArray(): array
    {
        return [
            'id' => $this->id,
            'jenis' => $this->jenis,
            'judul' => $this->judul,
            'deskripsi' => $this->deskripsi,
            'waktu' => $this->waktu ? $this->waktu->toIso8601String() : null,
            'isRead' => (bool) $this->is_read,
            'targetRoute' => $this->target_route,
        ];
    }
}
