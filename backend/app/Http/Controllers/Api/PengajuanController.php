<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Pengajuan;
use App\Models\NotifikasiModel;
use Illuminate\Support\Str;

class PengajuanController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();
        $query = Pengajuan::query();

        // If user is pengembang, scope to their own pengajuans
        if ($user->role === 'pengembang') {
            $query->where('user_id', $user->id);
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        if ($request->has('statusTahap')) {
            $query->where('status_tahap', $request->statusTahap);
        }

        $pengajuans = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $pengajuans->map(fn($item) => $item->toFlutterArray())
        ], 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'namaPerumahan' => 'required|string',
            'npwpPerusahaan' => 'required|string',
            'luasLahan' => 'required|numeric|min:0.1',
            'jumlahUnit' => 'required|integer|min:1',
            'tipePerumahan' => 'required|in:Subsidi,Komersil,Keduanya',
            'uploadedDocs' => 'required|array',
            'isAgreed' => 'required|boolean|accepted',
        ]);

        $user = $request->user();

        // Generate ID: SR-YYYYMMDD-XXX
        $todayStr = now()->format('Ymd');
        $randomNum = rand(100, 999);
        $newId = "SR-{$todayStr}-{$randomNum}";

        $pengajuan = Pengajuan::create([
            'id' => $newId,
            'user_id' => $user->id,
            'nama_perumahan' => $request->namaPerumahan,
            'nama_pt' => $user->nama_pt ?? 'PT. Pengembang',
            'nama_direktur' => $user->nama_direktur ?? 'Direktur',
            'npwp_perusahaan' => $request->npwpPerusahaan,
            'luas_lahan' => $request->luasLahan,
            'jumlah_unit' => $request->jumlahUnit,
            'tipe_perumahan' => $request->tipePerumahan,
            'status' => 'Dalam Proses',
            'status_tahap' => 'verifikasiAdministrasi',
            'tanggal' => now()->translatedFormat('d F Y'),
            'uploaded_docs' => $request->uploadedDocs,
            'verified_docs' => [],
            'dokumen_perlu_revisi' => [],
            'created_by' => $user->id,
        ]);

        // Auto trigger Notifikasi pengajuanBaru untuk Admin
        NotifikasiModel::create([
            'id' => 'notif-' . Str::uuid(),
            'user_id' => null, // Ditujukan untuk admin
            'jenis' => 'pengajuanBaru',
            'judul' => 'Pengajuan Baru: ' . $pengajuan->nama_perumahan,
            'deskripsi' => "Pengajuan ({$newId}) telah diterima dan dalam verifikasi administrasi.",
            'waktu' => now(),
            'is_read' => false,
            'target_route' => "/admin/pengajuan/detail/{$newId}",
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Pengajuan berhasil dikirim.',
            'data' => $pengajuan->toFlutterArray()
        ], 201);
    }

    public function show($id)
    {
        $pengajuan = Pengajuan::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $pengajuan->toFlutterArray()
        ], 200);
    }

    public function verifikasiDokumen(Request $request, $id)
    {
        $request->validate([
            'dokumenKey' => 'required|string',
            'sesuai' => 'required|boolean',
        ]);

        $pengajuan = Pengajuan::findOrFail($id);
        $verifiedDocs = $pengajuan->verified_docs ?? [];
        $verifiedDocs[$request->dokumenKey] = (bool) $request->sesuai;

        $pengajuan->verified_docs = $verifiedDocs;
        $pengajuan->save();

        return response()->json([
            'success' => true,
            'message' => 'Status verifikasi dokumen diperbarui.',
            'verifiedDocs' => $pengajuan->verified_docs
        ], 200);
    }

    public function approveTahap(Request $request, $id)
    {
        $currentTahap = $pengajuan->status_tahap;

        // Tentukan tahap efektif (jika dalam status perluPerbaikan, gunakan tahap asal revisi)
        $effectiveTahap = ($currentTahap === 'perluPerbaikan')
            ? ($pengajuan->tahap_asal_perbaikan ?? 'verifikasiAdministrasi')
            : $currentTahap;

        // FASE 1b: Guard sebelum approve dari surveyLapangan
        if ($effectiveTahap === 'surveyLapangan') {
            $latestMonitoring = \App\Models\MonitoringModel::where('pengajuan_id', $pengajuan->id)
                ->orWhere('nama_perumahan', $pengajuan->nama_perumahan)
                ->orderBy('created_at', 'desc')
                ->first();

            if (!$latestMonitoring || $latestMonitoring->is_draft) {
                return response()->json([
                    'success' => false,
                    'message' => 'Approve tahap survey lapangan ditolak: Belum ada Laporan Monitoring & Evaluasi Lapangan yang diunggah/final.'
                ], 422);
            }

            if (in_array($latestMonitoring->status_hasil_evaluasi, ['tidakSesuaiSiteplan', 'tidakSesuai'])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Hasil survey lapangan Tidak Sesuai. Silakan gunakan menu Minta Perbaikan untuk mengirimkan catatan perbaikan ke pengembang.'
                ], 422);
            }
        }

        // Lanjut dari tahap efektif ke tahap berikutnya
        $nextTahap = match ($effectiveTahap) {
            'pengajuanBaru' => 'verifikasiAdministrasi',
            'verifikasiAdministrasi' => 'verifikasiTeknis',
            'verifikasiTeknis' => 'surveyLapangan',
            'surveyLapangan' => 'persetujuan',
            'persetujuan' => 'selesai',
            default => 'selesai',
        };

        $statusStr = ($nextTahap === 'selesai') ? 'Selesai' : 'Dalam Proses';

        $pengajuan->update([
            'status_tahap' => $nextTahap,
            'status' => $statusStr,
            'dokumen_perlu_revisi' => [],
            'tahap_asal_perbaikan' => null,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Tahap pengajuan berhasil diapprove.',
            'data' => $pengajuan->toFlutterArray()
        ], 200);
    }

    public function mintaPerbaikan(Request $request, $id)
    {
        $request->validate([
            'catatan' => 'required|string',
            'dokumenPerluRevisi' => 'required|array',
        ]);

        $pengajuan = Pengajuan::findOrFail($id);

        // FASE 1a: Simpan status_tahap saat ini ke tahap_asal_perbaikan sebelum diubah ke perluPerbaikan
        $pengajuan->update([
            'status' => 'Perlu Perbaikan',
            'tahap_asal_perbaikan' => $pengajuan->status_tahap,
            'status_tahap' => 'perluPerbaikan',
            'catatan_perbaikan' => $request->catatan,
            'dokumen_perlu_revisi' => $request->dokumenPerluRevisi,
        ]);

        // Auto notification untuk pengembang
        NotifikasiModel::create([
            'id' => 'notif-' . Str::uuid(),
            'user_id' => $pengajuan->user_id,
            'jenis' => 'dokumenDiunggahUlang',
            'judul' => 'Perbaikan Dokumen Diumumkan',
            'deskripsi' => "Catatan perbaikan untuk {$pengajuan->nama_perumahan}: {$request->catatan}",
            'waktu' => now(),
            'is_read' => false,
            'target_route' => "/pengajuan/detail/{$pengajuan->id}",
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Catatan perbaikan telah dikirim ke pengembang.',
            'data' => $pengajuan->toFlutterArray()
        ], 200);
    }

    public function jadwalkanSurvey(Request $request, $id)
    {
        $request->validate([
            'tanggalSurvey' => 'required|date',
            'catatanSurvey' => 'nullable|string',
            'assigned_perwaskim_id' => 'required',
        ]);

        $pengajuan = Pengajuan::findOrFail($id);

        // FASE 3b: Reschedule — tandai jadwal dijadwalkan lama sebagai dijadwalkan_ulang
        \App\Models\SurveySchedule::where('pengajuan_id', $pengajuan->id)
            ->where('status', 'dijadwalkan')
            ->update(['status' => 'dijadwalkan_ulang']);

        // FASE 3b: Buat row survey_schedules baru
        $scheduleId = 'sched-' . (now()->timestamp * 1000) . '-' . rand(100, 999);
        $schedule = \App\Models\SurveySchedule::create([
            'id' => $scheduleId,
            'pengajuan_id' => $pengajuan->id,
            'tanggal_execution' => $request->tanggalSurvey,
            'catatan_instruksi' => $request->catatanSurvey,
            'assigned_perwaskim_id' => $request->assigned_perwaskim_id,
            'status' => 'dijadwalkan',
            'created_by' => $request->user()?->id,
        ]);

        // Update pengajuan (tanggal_survey & catatan_survey dipertahankan untuk backward compatibility)
        $pengajuan->update([
            'tanggal_survey' => $request->tanggalSurvey,
            'catatan_survey' => $request->catatanSurvey,
            'status_tahap' => 'surveyLapangan',
            'status' => 'Dalam Proses',
        ]);

        // FASE 3c: Notifikasi terarah ke assigned_perwaskim_id
        NotifikasiModel::create([
            'id' => 'notif-' . Str::uuid(),
            'user_id' => $request->assigned_perwaskim_id,
            'jenis' => 'reminderSurvey',
            'judul' => 'Penugasan Survey Lapangan: ' . $pengajuan->nama_perumahan,
            'deskripsi' => "Anda ditugaskan melakukan survey lokasi {$pengajuan->nama_perumahan} pada " . date('d F Y', strtotime($request->tanggalSurvey)),
            'waktu' => now(),
            'is_read' => false,
            'target_route' => '/monitoring',
        ]);

        $responseData = $pengajuan->toFlutterArray();
        $responseData['schedule'] = $schedule->toFlutterArray();

        return response()->json([
            'success' => true,
            'message' => 'Jadwal survey lapangan berhasil disimpan dan ditugaskan ke petugas.',
            'data' => $responseData
        ], 200);
    }
}
