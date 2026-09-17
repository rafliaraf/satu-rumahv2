<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class StorePengajuanRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'namaPerumahan' => 'required|string|max:255',
            'npwpPerusahaan' => 'required|string|max:32',
            'luasLahan' => 'required|numeric|min:0.1',
            'jumlahUnit' => 'required|integer|min:1',
            'tipePerumahan' => 'required|in:Subsidi,Komersil,Keduanya',
            'uploadedDocs' => 'required|array',
            'uploadedDocs.ktp' => 'required|string',
            'uploadedDocs.nib' => 'required|string',
            'uploadedDocs.npwp_doc' => 'required|string',
            'uploadedDocs.asosiasi' => 'required|string',
            'uploadedDocs.legalitas' => 'required|string',
            'uploadedDocs.surat_permohonan' => 'required|string',
            'uploadedDocs.info_intensitas_ruang' => 'required|string',
            'uploadedDocs.bukti_kepemilikan_lahan' => 'required|string',
            'uploadedDocs.bukti_tpu' => 'required|string',
            'uploadedDocs.kkpr_doc' => 'required|string',
            'uploadedDocs.pbg_induk' => 'required|string',
            'uploadedDocs.rekomendasi_lingkungan' => 'required|string',
            'uploadedDocs.pernyataan_pelepasan' => 'required|string',
            'uploadedDocs.pernyataan_keabsahan' => 'required|string',
            'uploadedDocs.pernyataan_psu' => 'required|string',
            'uploadedDocs.site_plan_dwg' => 'required|string',
            'isAgreed' => 'required|boolean|accepted',
        ];
    }

    public function messages(): array
    {
        return [
            'namaPerumahan.required' => 'Nama perumahan wajib diisi.',
            'npwpPerusahaan.required' => 'NPWP perusahaan wajib diisi.',
            'luasLahan.required' => 'Luas lahan wajib diisi.',
            'jumlahUnit.required' => 'Jumlah unit wajib diisi.',
            'uploadedDocs.site_plan_dwg.required' => 'Berkas DWG Site Plan wajib diunggah.',
            'isAgreed.accepted' => 'Pernyataan keabsahan hukum wajib disetujui.',
        ];
    }
}
