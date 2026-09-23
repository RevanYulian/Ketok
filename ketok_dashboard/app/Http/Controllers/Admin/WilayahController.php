<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\WilayahMalang;
use Illuminate\Http\Request;

class WilayahController extends Controller
{
    public function index(Request $request)
    {
        $query = WilayahMalang::query();

        if ($request->filled('tipe')) {
            $query->where('tipe', $request->tipe);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama', 'ilike', "%{$search}%")
                  ->orWhere('parent_nama', 'ilike', "%{$search}%");
            });
        }

        $totalWilayah = WilayahMalang::count();
        $provinsiCount = WilayahMalang::where('tipe', 'provinsi')->count();
        $kotaCount = WilayahMalang::where('tipe', 'kota')->count();
        $kecamatanCount = WilayahMalang::where('tipe', 'kecamatan')->count();
        $kelurahanCount = WilayahMalang::where('tipe', 'kelurahan')->count();

        $wilayahList = $query->orderByRaw("
            CASE tipe
                WHEN 'provinsi' THEN 1
                WHEN 'kota' THEN 2
                WHEN 'kecamatan' THEN 3
                WHEN 'kelurahan' THEN 4
                ELSE 5
            END
        ")->orderBy('nama')->paginate(25)->withQueryString();

        $allWilayah = WilayahMalang::select('id_wilayah', 'nama', 'tipe', 'parent_nama')->orderBy('nama')->get();

        return view('admin.wilayah.index', compact(
            'wilayahList',
            'totalWilayah',
            'provinsiCount',
            'kotaCount',
            'kecamatanCount',
            'kelurahanCount',
            'allWilayah'
        ));
    }

    public function store(Request $request)
    {
        $request->validate([
            'tipe' => 'required|in:provinsi,kota,kecamatan,kelurahan',
            'nama' => 'required|string|max:120',
            'provinsi' => 'nullable|string|max:120',
            'kota' => 'nullable|string|max:120',
            'kecamatan' => 'nullable|string|max:120',
        ]);

        $tipe = $request->tipe;
        $nama = trim($request->nama);
        $provinsi = $request->filled('provinsi') ? trim($request->provinsi) : null;
        $kota = $request->filled('kota') ? trim($request->kota) : null;
        $kecamatan = $request->filled('kecamatan') ? trim($request->kecamatan) : null;

        if ($tipe === 'provinsi') {
            WilayahMalang::firstOrCreate(
                ['nama' => $nama, 'tipe' => 'provinsi'],
                ['parent_nama' => null]
            );
        } elseif ($tipe === 'kota') {
            if ($provinsi) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $provinsi, 'tipe' => 'provinsi'],
                    ['parent_nama' => null]
                );
            }
            WilayahMalang::firstOrCreate(
                ['nama' => $nama, 'tipe' => 'kota', 'parent_nama' => $provinsi],
                ['parent_nama' => $provinsi]
            );
        } elseif ($tipe === 'kecamatan') {
            if ($provinsi) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $provinsi, 'tipe' => 'provinsi'],
                    ['parent_nama' => null]
                );
            }
            if ($kota) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $kota, 'tipe' => 'kota', 'parent_nama' => $provinsi],
                    ['parent_nama' => $provinsi]
                );
            }
            WilayahMalang::firstOrCreate(
                ['nama' => $nama, 'tipe' => 'kecamatan', 'parent_nama' => $kota],
                ['parent_nama' => $kota]
            );
        } elseif ($tipe === 'kelurahan') {
            if ($provinsi) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $provinsi, 'tipe' => 'provinsi'],
                    ['parent_nama' => null]
                );
            }
            if ($kota) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $kota, 'tipe' => 'kota', 'parent_nama' => $provinsi],
                    ['parent_nama' => $provinsi]
                );
            }
            if ($kecamatan) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $kecamatan, 'tipe' => 'kecamatan', 'parent_nama' => $kota],
                    ['parent_nama' => $kota]
                );
            }
            WilayahMalang::firstOrCreate(
                ['nama' => $nama, 'tipe' => 'kelurahan', 'parent_nama' => $kecamatan],
                ['parent_nama' => $kecamatan]
            );
        }

        return back()->with('success', "Wilayah {$nama} ({$tipe}) berhasil ditambahkan.");
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'tipe' => 'required|in:provinsi,kota,kecamatan,kelurahan',
            'nama' => 'required|string|max:120',
            'provinsi' => 'nullable|string|max:120',
            'kota' => 'nullable|string|max:120',
            'kecamatan' => 'nullable|string|max:120',
        ]);

        $wilayah = WilayahMalang::findOrFail($id);
        $tipe = $request->tipe;
        $nama = trim($request->nama);
        $provinsi = $request->filled('provinsi') ? trim($request->provinsi) : null;
        $kota = $request->filled('kota') ? trim($request->kota) : null;
        $kecamatan = $request->filled('kecamatan') ? trim($request->kecamatan) : null;

        $parent = null;
        if ($tipe === 'kota') {
            $parent = $provinsi;
            if ($provinsi) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $provinsi, 'tipe' => 'provinsi'],
                    ['parent_nama' => null]
                );
            }
        } elseif ($tipe === 'kecamatan') {
            $parent = $kota;
            if ($provinsi && $kota) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $kota, 'tipe' => 'kota', 'parent_nama' => $provinsi],
                    ['parent_nama' => $provinsi]
                );
            }
        } elseif ($tipe === 'kelurahan') {
            $parent = $kecamatan;
            if ($kota && $kecamatan) {
                WilayahMalang::firstOrCreate(
                    ['nama' => $kecamatan, 'tipe' => 'kecamatan', 'parent_nama' => $kota],
                    ['parent_nama' => $kota]
                );
            }
        }

        $wilayah->update([
            'nama' => $nama,
            'tipe' => $tipe,
            'parent_nama' => $parent,
        ]);

        return back()->with('success', "Wilayah {$nama} berhasil diperbarui.");
    }

    public function destroy($id)
    {
        $wilayah = WilayahMalang::findOrFail($id);
        $nama = $wilayah->nama;
        $wilayah->delete();

        return back()->with('success', "Wilayah {$nama} berhasil dihapus.");
    }
}
