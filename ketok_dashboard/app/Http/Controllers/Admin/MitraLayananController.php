<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KategoriLayanan;
use App\Models\MitraLayanan;
use App\Models\User;
use Illuminate\Http\Request;

class MitraLayananController extends Controller
{
    public function index(Request $request)
    {
        $query = MitraLayanan::with(['mitra', 'kategori']);

        if ($request->filled('kategori_id')) {
            $query->where('katagori_id', $request->kategori_id);
        }

        if ($request->filled('status')) {
            $query->where('aktif', $request->status === 'aktif');
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama_jasa', 'ilike', "%{$search}%")
                  ->orWhere('deskripsi', 'ilike', "%{$search}%")
                  ->orWhereHas('mitra', function ($mq) use ($search) {
                      $mq->where('nama', 'ilike', "%{$search}%");
                  });
            });
        }

        $listings = $query->orderBy('id_layanan_mitra', 'desc')->paginate(15);
        $kategoriList = KategoriLayanan::all();

        return view('admin.mitra_layanan.index', compact('listings', 'kategoriList'));
    }

    public function toggleStatus($id)
    {
        $listing = MitraLayanan::findOrFail($id);
        $listing->aktif = !$listing->aktif;
        $listing->save();

        $statusText = $listing->aktif ? 'diaktifkan' : 'dinonaktifkan';
        return back()->with('success', "Layanan {$listing->nama_jasa} berhasil {$statusText}.");
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'nama_jasa' => 'required|string|max:150',
            'tarif_mulai' => 'required|numeric|min:0',
            'biaya_kunjungan' => 'required|numeric|min:0',
            'satuan_tarif' => 'nullable|string|max:50',
            'deskripsi' => 'nullable|string',
        ]);

        $listing = MitraLayanan::findOrFail($id);
        $listing->update([
            'nama_jasa' => $request->nama_jasa,
            'tarif_mulai' => $request->tarif_mulai,
            'biaya_kunjungan' => $request->biaya_kunjungan,
            'satuan_tarif' => $request->satuan_tarif ?? 'per layanan',
            'deskripsi' => $request->deskripsi,
        ]);

        return back()->with('success', "Layanan {$listing->nama_jasa} berhasil diperbarui.");
    }

    public function destroy($id)
    {
        $listing = MitraLayanan::findOrFail($id);
        $nama = $listing->nama_jasa;
        $listing->delete();

        return back()->with('success', "Layanan {$nama} berhasil dihapus dari marketplace.");
    }
}
