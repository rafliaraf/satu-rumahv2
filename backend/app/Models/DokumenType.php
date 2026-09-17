<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DokumenType extends Model
{
    protected $fillable = [
        'key',
        'label',
        'is_mandatory',
        'allowed_formats',
        'max_size_mb',
        'step',
        'section',
    ];

    protected $casts = [
        'is_mandatory' => 'boolean',
        'allowed_formats' => 'array',
        'max_size_mb' => 'integer',
        'step' => 'integer',
    ];
}
