<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Invoice;
use App\Models\KategoriLayanan;
use App\Models\Pesanan;
use App\Models\User;
use Illuminate\Http\Request;

class PesananController extends Controller
{
    public function index(Request $request)
    {
        $query = Pesanan::with(['pengguna', 'mitra', 'kategori', 'invoice']);

        if ($request->filled('status') && $request->status !== 'semua') {
            $query->where('status', $request->status);
        }

        if ($request->filled('kategori_id')) {
            $query->where('katagori_id', $request->kategori_id);
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->whereHas('pengguna', function ($uq) use ($search) {
                    $uq->where('nama', 'ilike', "%{$search}%");
                })->orWhereHas('mitra', function ($mq) use ($search) {
                    $mq->where('nama', 'ilike', "%{$search}%");
                })->orWhere('lokasi', 'ilike', "%{$search}%");
            });
        }

        $orders = $query->orderBy('id_pesanan', 'desc')->paginate(15);
        $kategoriList = KategoriLayanan::all();

        return view('admin.pesanan.index', compact('orders', 'kategoriList'));
    }

    public function show($id)
    {
        $order = Pesanan::with(['pengguna', 'mitra.mitraProfil', 'kategori', 'invoice', 'ulasan'])
            ->findOrFail($id);

        $availableMitras = User::where('role', 'mitra')
            ->where('status_mitra', 'aktif')
            ->where('id_user', '!=', $order->mitra_id ?? 0)
            ->get();

        return view('admin.pesanan.show', compact('order', 'availableMitras'));
    }

    public function reassign(Request $request, $id)
    {
        $request->validate([
            'mitra_id' => 'required|exists:users,id_user',
        ]);

        $order = Pesanan::findOrFail($id);
        $newMitra = User::findOrFail($request->mitra_id);
        
        $order->mitra_id = $newMitra->id_user;
        $order->status = 'menunggu_konfirmasi';
        $order->save();

        return back()->with('success', "Pesanan #KTK-{$order->id_pesanan} berhasil dipindahkan ke mitra {$newMitra->nama}.");
    }

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|string',
        ]);

        $order = Pesanan::findOrFail($id);
        $order->status = $request->status;
        $order->save();

        return back()->with('success', "Status pesanan #KTK-{$order->id_pesanan} berhasil diperbarui menjadi {$request->status}.");
    }

    public function cancel(Request $request, $id)
    {
        $order = Pesanan::findOrFail($id);
        $order->status = 'dibatalkan';
        $order->save();

        return back()->with('success', "Pesanan #KTK-{$order->id_pesanan} telah dibatalkan.");
    }
}
