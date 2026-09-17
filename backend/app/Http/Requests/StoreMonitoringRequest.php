<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StoreMonitoringRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'namaPerumahan' => 'required|string|max:255',
            'statusHasilEvaluasi' => 'required|in:sesuaiSiteplan,tidakSesuaiSiteplan,perluEvaluasiLanjutan',
            'temuanLapangan' => 'nullable|array',
            'kesimpulan' => 'nullable|array',
            'kesepakatan' => 'nullable|array',
            'rencanaTindakLanjut' => 'nullable|array',
            'photoPaths' => 'nullable|array|max:15',
            'pelaksanaNama' => 'nullable|string|max:255',
            'pelaksanaJabatan' => 'nullable|string|max:255',
            'ditemuiNama' => 'nullable|string|max:255',
            'ditemuiJabatan' => 'nullable|string|max:255',
            'isDraft' => 'nullable|boolean',
        ];
    }

    public function withValidator($validator)
    {
        $validator->after(function ($validator) {
            $status = $this->input('statusHasilEvaluasi');
            $rtl = array_filter($this->input('rencanaTindakLanjut', []), fn($val) => trim($val) !== '');

            if (in_array($status, ['tidakSesuaiSiteplan', 'perluEvaluasiLanjutan']) && count($rtl) === 0) {
                $validator->errors()->add(
                    'rencanaTindakLanjut',
                    'Untuk status evaluasi ini, wajib mengisikan minimal 1 poin Rencana Tindak Lanjut.'
                );
            }
        });
    }
}
