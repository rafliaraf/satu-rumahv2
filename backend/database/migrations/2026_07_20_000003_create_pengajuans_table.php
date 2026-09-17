<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('pengajuans', function (Blueprint $table) {
            $table->string('id')->primary(); // Format: SR-YYYYMMDD-XXX
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('nama_perumahan');
            $table->string('nama_pt');
            $table->string('nama_direktur');
            $table->string('npwp_perusahaan');
            $table->decimal('luas_lahan', 12, 2);
            $table->integer('jumlah_unit');
            $table->enum('tipe_perumahan', ['Subsidi', 'Komersil', 'Keduanya'])->default('Subsidi');
            $table->enum('status', ['Dalam Proses', 'Selesai', 'Perlu Perbaikan'])->default('Dalam Proses');
            $table->enum('status_tahap', [
                'pengajuanBaru',
                'verifikasiAdministrasi',
                'verifikasiTeknis',
                'surveyLapangan',
                'persetujuan',
                'selesai',
                'perluPerbaikan'
            ])->default('verifikasiAdministrasi');
            $table->string('tanggal');
            $table->text('catatan_perbaikan')->nullable();
            $table->json('uploaded_docs');
            $table->json('verified_docs')->nullable();
            $table->json('dokumen_perlu_revisi')->nullable();
            $table->timestamp('tanggal_survey')->nullable();
            $table->text('catatan_survey')->nullable();
            $table->string('tahap_asal_perbaikan')->nullable();
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('pengajuans');
    }
};
