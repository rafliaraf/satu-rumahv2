<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\NotifikasiModel;

class NotifikasiController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        $notifikasis = NotifikasiModel::where(function ($q) use ($user) {
            $q->whereNull('user_id')->orWhere('user_id', $user->id);
        })->orderBy('waktu', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $notifikasis->map(fn($item) => $item->toFlutterArray())
        ], 200);
    }

    public function markAsRead($id)
    {
        $notif = NotifikasiModel::findOrFail($id);
        $notif->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Notifikasi ditandai dibaca.'
        ], 200);
    }

    public function markAllAsRead(Request $request)
    {
        $user = $request->user();

        NotifikasiModel::where(function ($q) use ($user) {
            $q->whereNull('user_id')->orWhere('user_id', $user->id);
        })->update(['is_read' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Semua notifikasi ditandai dibaca.'
        ], 200);
    }
}
