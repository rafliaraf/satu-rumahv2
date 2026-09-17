<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifikasi_models', function (Blueprint $table) {
            $table->string('id')->primary();
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('cascade');
            $table->enum('jenis', [
                'pengajuanBaru',
                'dokumenDiunggahUlang',
                'reminderSurvey',
                'deadlineVerifikasi'
            ]);
            $table->string('judul');
            $table->text('deskripsi');
            $table->timestamp('waktu');
            $table->boolean('is_read')->default(false);
            $table->string('target_route')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifikasi_models');
    }
};
