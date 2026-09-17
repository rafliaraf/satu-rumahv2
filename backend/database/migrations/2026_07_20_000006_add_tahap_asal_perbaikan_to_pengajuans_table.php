<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('pengajuans', function (Blueprint $table) {
            if (!Schema::hasColumn('pengajuans', 'tahap_asal_perbaikan')) {
                $table->string('tahap_asal_perbaikan')->nullable()->after('catatan_survey');
            }
        });
    }

    public function down(): void
    {
        Schema::table('pengajuans', function (Blueprint $table) {
            if (Schema::hasColumn('pengajuans', 'tahap_asal_perbaikan')) {
                $table->dropColumn('tahap_asal_perbaikan');
            }
        });
    }
};
