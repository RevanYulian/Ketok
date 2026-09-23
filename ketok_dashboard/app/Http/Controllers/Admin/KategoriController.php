<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\JasaLayanan;
use App\Models\KategoriLayanan;
use App\Models\KategoriUtama;
use Illuminate\Http\Request;

class KategoriController extends Controller
{
    public function index()
    {
        $kategoriList = KategoriLayanan::withCount(['mitraLayanan', 'pesanan'])->orderBy('id_katagori', 'asc')->get();
        $kelompokList = KategoriUtama::orderBy('nama_kelompok', 'asc')->get();

        return view('admin.kategori.index', compact('kategoriList', 'kelompokList'));
    }

    public function storeKelompok(Request $request)
    {
        $request->validate([
            'nama_kelompok' => 'required|string|max:150|unique:kategori_utama,nama_kelompok',
        ], [
            'nama_kelompok.required' => 'Nama kategori utama wajib diisi.',
            'nama_kelompok.unique' => 'Kategori utama dengan nama ini sudah terdaftar.',
        ]);

        KategoriUtama::create([
            'nama_kelompok' => trim($request->nama_kelompok),
        ]);

        return back()->with('success', "Kategori utama '{$request->nama_kelompok}' berhasil ditambahkan.");
    }

    public function storeKategori(Request $request)
    {
        $request->validate([
            'nama_katagori' => 'required|string|max:150',
            'kelompok' => 'nullable|string|max:100',
            'deskripsi' => 'nullable|string',
        ]);

        KategoriLayanan::create($request->only('nama_katagori', 'kelompok', 'deskripsi'));

        return back()->with('success', 'Kategori baru berhasil ditambahkan.');
    }

    public function updateKategori(Request $request, $id)
    {
        $request->validate([
            'nama_katagori' => 'required|string|max:150',
            'kelompok' => 'nullable|string|max:100',
            'deskripsi' => 'nullable|string',
        ]);

        $kategori = KategoriLayanan::findOrFail($id);
        $kategori->update($request->only('nama_katagori', 'kelompok', 'deskripsi'));

        return back()->with('success', 'Kategori berhasil diperbarui.');
    }

    public function destroyKategori($id)
    {
        $kategori = KategoriLayanan::findOrFail($id);

        if ($kategori->pesanan()->exists() || $kategori->mitraLayanan()->exists()) {
            return back()->with('error', 'Kategori tidak dapat dihapus karena memiliki pesanan atau layanan mitra aktif.');
        }

        $kategori->delete();
        return back()->with('success', 'Kategori berhasil dihapus.');
    }

    public function storeJasa(Request $request)
    {
        $request->validate([
            'katagori_id' => 'required|exists:kategori_layanan,id_katagori',
            'nama_jasa' => 'required|string|max:150',
            'harga_mulai' => 'required|numeric|min:0',
            'deskripsi' => 'required|string',
            'kategori_menu' => 'nullable|string|max:100',
        ]);

        $kategori = KategoriLayanan::find($request->katagori_id);

        JasaLayanan::create([
            'katagori_id' => $request->katagori_id,
            'kategori_menu' => $request->kategori_menu ?? ($kategori->kelompok ?? $kategori->nama_katagori),
            'nama_jasa' => $request->nama_jasa,
            'harga_mulai' => $request->harga_mulai,
            'deskripsi' => $request->deskripsi,
            'aktif' => true,
        ]);

        return back()->with('success', 'Master jasa layanan berhasil ditambahkan.');
    }

    public function updateJasa(Request $request, $id)
    {
        $request->validate([
            'katagori_id' => 'required|exists:kategori_layanan,id_katagori',
            'nama_jasa' => 'required|string|max:150',
            'harga_mulai' => 'required|numeric|min:0',
            'deskripsi' => 'required|string',
            'aktif' => 'nullable|boolean',
        ]);

        $jasa = JasaLayanan::findOrFail($id);
        $jasa->update([
            'katagori_id' => $request->katagori_id,
            'nama_jasa' => $request->nama_jasa,
            'harga_mulai' => $request->harga_mulai,
            'deskripsi' => $request->deskripsi,
            'aktif' => $request->has('aktif') ? (bool)$request->aktif : $jasa->aktif,
        ]);

        return back()->with('success', 'Master jasa layanan berhasil diperbarui.');
    }

    public function destroyJasa($id)
    {
        $jasa = JasaLayanan::findOrFail($id);
        $jasa->delete();

        return back()->with('success', 'Master jasa berhasil dihapus.');
    }
}
