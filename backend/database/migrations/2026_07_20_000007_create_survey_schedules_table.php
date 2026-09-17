<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('survey_schedules', function (Blueprint $table) {
            $table->string('id')->primary(); // Format timestamp-based ID or UUID
            $table->string('pengajuan_id');
            $table->foreign('pengajuan_id')->references('id')->on('pengajuans')->onDelete('cascade');
            $table->dateTime('tanggal_execution');
            $table->text('catatan_instruksi')->nullable();
            $table->unsignedBigInteger('assigned_perwaskim_id'); // FK to users
            $table->enum('status', ['dijadwalkan', 'terlaksana', 'dibatalkan', 'dijadwalkan_ulang'])->default('dijadwalkan');
            $table->unsignedBigInteger('created_by')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('survey_schedules');
    }
};
