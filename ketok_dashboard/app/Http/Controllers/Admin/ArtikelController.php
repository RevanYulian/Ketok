<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Artikel;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class ArtikelController extends Controller
{
    public function index(Request $request)
    {
        $query = Artikel::query();

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('judul', 'ilike', "%{$search}%")
                  ->orWhere('ringkasan', 'ilike', "%{$search}%");
            });
        }

        if ($request->filled('status')) {
            if ($request->status === 'tayang') {
                $query->where('aktif', true);
            } elseif ($request->status === 'draft') {
                $query->where('aktif', false);
            }
        }

        $totalArtikel = Artikel::count();
        $tayangCount = Artikel::where('aktif', true)->count();
        $draftCount = Artikel::where('aktif', false)->count();

        $artikels = $query->orderBy('dibuat_pada', 'desc')->paginate(10)->withQueryString();

        return view('admin.artikel.index', compact('artikels', 'totalArtikel', 'tayangCount', 'draftCount'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'judul' => 'required|string|max:200',
            'ringkasan' => 'required|string|max:500',
            'isi' => 'required|string',
            'gambar_url' => 'nullable|url',
            'aktif' => 'nullable|boolean',
        ]);

        Artikel::create([
            'id_artikel' => (string) Str::uuid(),
            'judul' => $request->judul,
            'ringkasan' => $request->ringkasan,
            'isi' => $request->isi,
            'gambar_url' => $request->gambar_url,
            'aktif' => $request->has('aktif') ? (bool)$request->aktif : true,
        ]);

        return back()->with('success', 'Artikel / Tips mitra berhasil dipublikasikan.');
    }

    public function update(Request $request, $id)
    {
        $request->validate([
            'judul' => 'required|string|max:200',
            'ringkasan' => 'required|string|max:500',
            'isi' => 'required|string',
            'gambar_url' => 'nullable|url',
            'aktif' => 'nullable|boolean',
        ]);

        $artikel = Artikel::findOrFail($id);
        $artikel->update([
            'judul' => $request->judul,
            'ringkasan' => $request->ringkasan,
            'isi' => $request->isi,
            'gambar_url' => $request->gambar_url,
            'aktif' => $request->has('aktif') ? (bool)$request->aktif : $artikel->aktif,
        ]);

        return back()->with('success', 'Artikel / Tips mitra berhasil diperbarui.');
    }

    public function toggleStatus($id)
    {
        $artikel = Artikel::findOrFail($id);
        $artikel->update([
            'aktif' => !$artikel->aktif,
        ]);

        $statusText = $artikel->aktif ? 'ditayangkan' : 'dijadikan draft';
        return back()->with('success', "Status artikel berhasil {$statusText}.");
    }

    public function destroy($id)
    {
        $artikel = Artikel::findOrFail($id);
        $artikel->delete();

        return back()->with('success', 'Artikel berhasil dihapus.');
    }
}
