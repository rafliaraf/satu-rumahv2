<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'username',
        'password',
        'nama',
        'role',
        'nip',
        'jabatan',
        'instansi',
        'email',
        'no_whatsapp',
        'nama_pt',
        'nama_direktur',
        'nib',
        'npwp_perusahaan',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
        ];
    }

    public function pengajuans()
    {
        return $this->hasMany(Pengajuan::class, 'user_id');
    }

    public function notifikasis()
    {
        return $this->hasMany(NotifikasiModel::class, 'user_id');
    }
}
