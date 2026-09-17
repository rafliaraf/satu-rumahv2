<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('username')->unique();
            $table->string('password');
            $table->string('nama');
            $table->enum('role', ['admin', 'pengembang', 'perwaskim', 'admin_dpkp', 'tim_monitoring']);
            $table->string('nip')->nullable();
            $table->string('jabatan')->nullable();
            $table->string('instansi')->default('Dinas Perumahan dan Kawasan Permukiman');
            $table->string('email')->unique();
            $table->string('no_whatsapp')->nullable();
            $table->string('nama_pt')->nullable();
            $table->string('nama_direktur')->nullable();
            $table->string('nib')->nullable();
            $table->string('npwp_perusahaan')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('users');
    }
};
