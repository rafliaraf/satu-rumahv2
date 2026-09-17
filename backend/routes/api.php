<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\PengajuanController;
use App\Http\Controllers\Api\MonitoringController;
use App\Http\Controllers\Api\NotifikasiController;
use App\Http\Controllers\Api\AdminDashboardController;

/*
|--------------------------------------------------------------------------
| SATU RUMAH REST API Routes - Version 1
| Dinas Perumahan dan Kawasan Permukiman Kota Tasikmalaya
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Public Authentication Endpoint
    Route::post('/auth/login', [AuthController::class, 'login']);

    // Protected Routes (Sanctum Middleware)
    Route::middleware('auth:sanctum')->group(function () {
        
        // Logout & User Info
        Route::post('/auth/logout', [AuthController::class, 'logout']);
        Route::get('/auth/me', [AuthController::class, 'me']);

        // Pengajuan Endpoints
        Route::get('/pengajuan', [PengajuanController::class, 'index']);
        Route::post('/pengajuan', [PengajuanController::class, 'store']);
        Route::get('/pengajuan/{id}', [PengajuanController::class, 'show']);
        Route::post('/pengajuan/{id}/verifikasi-dokumen', [PengajuanController::class, 'verifikasiDokumen'])->middleware(\App\Http\Middleware\EnsureUserHasRole::class . ':admin');
        Route::post('/pengajuan/{id}/approve-tahap', [PengajuanController::class, 'approveTahap'])->middleware(\App\Http\Middleware\EnsureUserHasRole::class . ':admin');
        Route::post('/pengajuan/{id}/minta-perbaikan', [PengajuanController::class, 'mintaPerbaikan'])->middleware(\App\Http\Middleware\EnsureUserHasRole::class . ':admin');
        Route::post('/pengajuan/{id}/jadwalkan-survey', [PengajuanController::class, 'jadwalkanSurvey'])->middleware(\App\Http\Middleware\EnsureUserHasRole::class . ':admin');

        // Monitoring Endpoints
        Route::get('/monitoring', [MonitoringController::class, 'index']);
        Route::post('/monitoring', [MonitoringController::class, 'store'])->middleware(\App\Http\Middleware\EnsureUserHasRole::class . ':perwaskim');
        Route::get('/monitoring/{id}', [MonitoringController::class, 'show']);

        // Notifikasi Endpoints
        Route::get('/notifikasi', [NotifikasiController::class, 'index']);
        Route::patch('/notifikasi/{id}/read', [NotifikasiController::class, 'markAsRead']);
        Route::patch('/notifikasi/read-all', [NotifikasiController::class, 'markAllAsRead']);

        // Admin Dashboard Metrics
        Route::get('/admin/dashboard-metrics', [AdminDashboardController::class, 'metrics']);
    });
});
