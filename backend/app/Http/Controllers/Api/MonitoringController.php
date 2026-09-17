<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\MonitoringModel;
use Illuminate\Support\Str;

class MonitoringController extends Controller
{
    private array $bulanRomawi = [
        1 => 'I', 2 => 'II', 3 => 'III', 4 => 'IV', 5 => 'V', 6 => 'VI',
        7 => 'VII', 8 => 'VIII', 9 => 'IX', 10 => 'X', 11 => 'XI', 12 => 'XII'
    ];

    private function generateNomorBA(\DateTimeInterface $date): string
    {
        $bulan = $this->bulanRomawi[(int) $date->format('n')];
        $tahun = $date->format('Y');
        return "600.2.5/BA-MON/{$bulan}/{$tahun}";
    }

    public function index(Request $request)
    {
        $user = $request->user();
        $query = MonitoringModel::query();

        // FASE 3e: Jika dipanggil oleh perwaskim, filter hanya tugas yang di-assign ke user tersebut
        if ($user && in_array(strtolower($user->role), ['perwaskim', 'tim_monitoring'])) {
            $query->where(function ($q) use ($user) {
                $q->where('created_by', $user->id)
                  ->orWhereHas('surveySchedule', function ($s) use ($user) {
                      $s->where('assigned_perwaskim_id', $user->id);
                  });
            });
        }

        if ($request->filled('query')) {
            $q = strtolower($request->input('query'));
            $query->where(function ($b) use ($q) {
                $b->whereRaw('LOWER(nama_perumahan) LIKE ?', ["%{$q}%"])
                  ->orWhereRaw('LOWER(nama_developer) LIKE ?', ["%{$q}%"])
                  ->orWhereRaw('LOWER(lokasi_perumahan) LIKE ?', ["%{$q}%"]);
            });
        }

        if ($request->filled('fromDate')) {
            $query->whereDate('tanggal_monitoring', '>=', $request->fromDate);
        }

        if ($request->filled('toDate')) {
            $query->whereDate('tanggal_monitoring', '<=', $request->toDate);
        }

        $items = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $items->map(fn($e) => $e->toFlutterArray())
        ], 200);
    }

    public function store(Request $request)
    {
        $request->validate([
            'namaPerumahan' => 'required|string',
            'statusHasilEvaluasi' => 'required|in:sesuaiSiteplan,tidakSesuaiSiteplan,perluEvaluasiLanjutan',
            'rencanaTindakLanjut' => 'array',
        ]);

        // Enforce RTL constraint for non-compliant statuses
        $status = $request->statusHasilEvaluasi;
        $rtl = array_filter($request->input('rencanaTindakLanjut', []), fn($val) => trim($val) !== '');

        if (in_array($status, ['tidakSesuaiSiteplan', 'perluEvaluasiLanjutan']) && count($rtl) === 0) {
            return response()->json([
                'success' => false,
                'message' => 'Untuk status evaluasi ini, wajib mengisikan minimal 1 poin Rencana Tindak Lanjut.'
            ], 422);
        }

        $tanggal = $request->filled('tanggalMonitoring')
            ? new \DateTime($request->tanggalMonitoring)
            : new \DateTime();

        $newId = (string) (now()->timestamp * 1000); // Ms timestamp ID
        $nomorBA = $this->generateNomorBA($tanggal);
        $isDraft = (bool) $request->input('isDraft', false);

        // FASE 3d: Cari atau kaitkan survey_schedule_id
        $scheduleId = $request->input('surveyScheduleId') ?? $request->input('survey_schedule_id');
        if (!$scheduleId && $request->filled('pengajuanId')) {
            $schedule = \App\Models\SurveySchedule::where('pengajuan_id', $request->input('pengajuanId'))
                ->where('status', 'dijadwalkan')
                ->first();
            $scheduleId = $schedule?->id;
        }

        $monitoring = MonitoringModel::create([
            'id' => $newId,
            'pengajuan_id' => $request->input('pengajuanId'),
            'survey_schedule_id' => $scheduleId,
            'nomor_surat_ba' => $nomorBA,
            'tanggal_monitoring' => $tanggal,
            'nama_perumahan' => $request->namaPerumahan,
            'nama_developer' => $request->input('namaDeveloper', ''),
            'lokasi_perumahan' => $request->input('lokasiPerumahan', ''),
            'maksud_tujuan' => $request->input('maksudTujuan', 'Kegiatan ini dilaksanakan guna memastikan kesesuaian...'),
            'temuan_lapangan' => array_values(array_filter($request->input('temuanLapangan', []), fn($e) => trim($e) !== '')),
            'kesimpulan' => array_values(array_filter($request->input('kesimpulan', []), fn($e) => trim($e) !== '')),
            'kesepakatan' => array_values(array_filter($request->input('kesepakatan', []), fn($e) => trim($e) !== '')),
            'rencana_tindak_lanjut' => array_values($rtl),
            'status_hasil_evaluasi' => $status,
            'pelaksana_nama' => $request->input('pelaksanaNama', ''),
            'pelaksana_jabatan' => $request->input('pelaksanaJabatan', ''),
            'ditemui_nama' => $request->input('ditemuiNama', ''),
            'ditemui_jabatan' => $request->input('ditemuiJabatan', ''),
            'photo_paths' => $request->input('photoPaths', []),
            'is_draft' => $isDraft,
            'created_by' => $request->user()?->id,
        ]);

        // FASE 3d: Update status schedule terkait menjadi 'terlaksana' jika laporan final (is_draft = false)
        if (!$isDraft && $scheduleId) {
            \App\Models\SurveySchedule::where('id', $scheduleId)->update(['status' => 'terlaksana']);
        }

        return response()->json([
            'success' => true,
            'message' => 'Laporan monitoring berhasil disimpan.',
            'data' => $monitoring->toFlutterArray()
        ], 201);
    }

    public function show($id)
    {
        $monitoring = MonitoringModel::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $monitoring->toFlutterArray()
        ], 200);
    }
}
