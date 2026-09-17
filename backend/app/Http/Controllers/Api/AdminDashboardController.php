<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Pengajuan;
use App\Models\MonitoringModel;

class AdminDashboardController extends Controller
{
    public function metrics()
    {
        $pengajuanList = Pengajuan::all();
        $monitoringList = MonitoringModel::where('is_draft', false)->orderBy('created_at', 'desc')->get();

        $pengajuanBaruCount = $pengajuanList->whereIn('status_tahap', ['pengajuanBaru', 'verifikasiAdministrasi'])->count();
        $verifikasiTeknisCount = $pengajuanList->where('status_tahap', 'verifikasiTeknis')->count();
        $surveyTerjadwalCount = $pengajuanList->filter(fn($e) => $e->status_tahap === 'surveyLapangan' || $e->tanggal_survey !== null)->count();

        $perluTindakLanjutPengajuan = $pengajuanList->where('status_tahap', 'perluPerbaikan')->count();
        $perluTindakLanjutMonitoring = $monitoringList->filter(fn($e) => in_array($e->status_hasil_evaluasi, ['tidakSesuaiSiteplan', 'perluEvaluasiLanjutan']))->count();

        $pengajuanPerluAksi = $pengajuanList->where('status_tahap', '!=', 'selesai')->values();

        return response()->json([
            'success' => true,
            'data' => [
                'pengajuanBaruCount' => $pengajuanBaruCount,
                'verifikasiTeknisCount' => $verifikasiTeknisCount,
                'surveyTerjadwalCount' => $surveyTerjadwalCount,
                'perluTindakLanjutCount' => $perluTindakLanjutPengajuan + $perluTindakLanjutMonitoring,
                'pengajuanPerluAksi' => $pengajuanPerluAksi->map(fn($e) => $e->toFlutterArray()),
                'monitoringTerbaru' => $monitoringList->map(fn($e) => $e->toFlutterArray()),
            ]
        ], 200);
    }
}
