<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('monitoring_models', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->string('pengajuan_id')->nullable();
            $table->foreign('pengajuan_id')->references('id')->on('pengajuans')->onDelete('set null');
            $table->string('nomor_surat_ba');
            $table->timestamp('tanggal_monitoring');
            $table->string('nama_perumahan');
            $table->string('nama_developer')->default('');
            $table->string('lokasi_perumahan')->default('');
            $table->text('maksud_tujuan');
            $table->json('temuan_lapangan');
            $table->json('kesimpulan');
            $table->json('kesepakatan');
            $table->json('rencana_tindak_lanjut');
            $table->enum('status_hasil_evaluasi', [
                'sesuaiSiteplan',
                'tidakSesuaiSiteplan',
                'perluEvaluasiLanjutan'
            ])->default('sesuaiSiteplan');
            $table->string('pelaksana_nama')->default('');
            $table->string('pelaksana_jabatan')->default('');
            $table->string('ditemui_nama')->default('');
            $table->string('ditemui_jabatan')->default('');
            $table->json('photo_paths');
            $table->boolean('is_draft')->default(false);
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('monitoring_models');
    }
};
