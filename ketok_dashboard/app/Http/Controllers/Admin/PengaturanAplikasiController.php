<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\PengaturanAplikasi;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\File;

class PengaturanAplikasiController extends Controller
{
    public function index()
    {
        $ketokAppConfig = PengaturanAplikasi::getByTipe('ketok_app');
        $ketokMitraConfig = PengaturanAplikasi::getByTipe('ketok_mitra');

        return view('admin.pengaturan_aplikasi.index', compact('ketokAppConfig', 'ketokMitraConfig'));
    }

    public function update(Request $request, $tipe)
    {
        if (!in_array($tipe, ['ketok_app', 'ketok_mitra'])) {
            abort(404);
        }

        $request->validate([
            'nama_aplikasi' => 'required|string|max:100',
            'tagline' => 'nullable|string|max:255',
            'logo_file' => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:2048',
            'logo_url' => 'nullable|string|max:500',
            'banner_file' => 'nullable|image|mimes:jpeg,png,jpg,webp,svg|max:4096',
            'banner_promo_url' => 'nullable|string|max:500',
            'kontak_cs' => 'nullable|string|max:50',
            'email_bantuan' => 'nullable|email|max:100',
            'versi_aplikasi' => 'nullable|string|max:20',
            'status_maintenance' => 'nullable|boolean',
            'pesan_maintenance' => 'nullable|string',
        ]);

        $config = PengaturanAplikasi::getByTipe($tipe);

        $uploadDir = public_path('uploads/branding');
        if (!File::exists($uploadDir)) {
            File::makeDirectory($uploadDir, 0755, true);
        }

        $logoUrl = $request->logo_url ?: $config->logo_url;
        if ($request->hasFile('logo_file')) {
            $file = $request->file('logo_file');
            $fileName = "logo_{$tipe}_" . time() . '.' . $file->getClientOriginalExtension();
            $file->move($uploadDir, $fileName);
            $logoUrl = asset('uploads/branding/' . $fileName);
        }

        $bannerUrl = $request->banner_promo_url ?: $config->banner_promo_url;
        if ($request->hasFile('banner_file')) {
            $file = $request->file('banner_file');
            $fileName = "banner_{$tipe}_" . time() . '.' . $file->getClientOriginalExtension();
            $file->move($uploadDir, $fileName);
            $bannerUrl = asset('uploads/branding/' . $fileName);
        }

        $config->update([
            'nama_aplikasi' => trim($request->nama_aplikasi),
            'tagline' => $request->tagline ? trim($request->tagline) : null,
            'logo_url' => $logoUrl,
            'banner_promo_url' => $bannerUrl,
            'kontak_cs' => $request->kontak_cs ? trim($request->kontak_cs) : null,
            'email_bantuan' => $request->email_bantuan ? trim($request->email_bantuan) : null,
            'versi_aplikasi' => $request->versi_aplikasi ? trim($request->versi_aplikasi) : '1.0.0',
            'status_maintenance' => $request->has('status_maintenance') ? (bool)$request->status_maintenance : false,
            'pesan_maintenance' => $request->pesan_maintenance ? trim($request->pesan_maintenance) : null,
            'diperbarui_pada' => now(),
        ]);

        $appLabel = $tipe === 'ketok_app' ? 'Ketok App' : 'Ketok Mitra';
        return back()->with('success', "Pengaturan tampilan {$appLabel} berhasil disimpan.")
                     ->with('active_tab', $tipe);
    }

    /**
     * Endpoint API publik untuk konsumsi aplikasi Flutter
     */
    public function getConfigApi($tipe)
    {
        if (!in_array($tipe, ['ketok_app', 'ketok_mitra'])) {
            return response()->json([
                'status' => 'error',
                'message' => 'Tipe aplikasi tidak valid.'
            ], 404);
        }

        $config = PengaturanAplikasi::getByTipe($tipe);

        return response()->json([
            'status' => 'success',
            'data' => [
                'tipe_app' => $config->tipe_app,
                'nama_aplikasi' => $config->nama_aplikasi,
                'tagline' => $config->tagline,
                'logo_url' => $config->logo_url ? url($config->logo_url) : null,
                'banner_promo_url' => $config->banner_promo_url ? url($config->banner_promo_url) : null,
                'kontak_cs' => $config->kontak_cs,
                'email_bantuan' => $config->email_bantuan,
                'versi_aplikasi' => $config->versi_aplikasi,
                'status_maintenance' => (bool)$config->status_maintenance,
                'pesan_maintenance' => $config->pesan_maintenance,
                'diperbarui_pada' => $config->diperbarui_pada,
            ]
        ]);
    }
}
