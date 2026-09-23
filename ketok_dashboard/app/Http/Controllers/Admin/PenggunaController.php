<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Pesanan;
use App\Models\User;
use Illuminate\Http\Request;

class PenggunaController extends Controller
{
    public function index(Request $request)
    {
        $query = User::where('role', 'pengguna')
            ->withCount('pesananSebagaiPengguna');

        if ($request->filled('status')) {
            if ($request->status === 'banned') {
                $query->where('status_mitra', 'banned');
            } elseif ($request->status === 'aktif') {
                $query->where(function ($q) {
                    $q->whereNull('status_mitra')->orWhere('status_mitra', '!=', 'banned');
                });
            }
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%")
                  ->orWhere('nomor_telepon', 'ilike', "%{$search}%");
            });
        }

        $users = $query->orderBy('id_user', 'desc')->paginate(15);

        $totalPengguna = User::where('role', 'pengguna')->count();
        $aktifPengguna = User::where('role', 'pengguna')->where(function ($q) {
            $q->whereNull('status_mitra')->orWhere('status_mitra', '!=', 'banned');
        })->count();
        $bannedPengguna = User::where('role', 'pengguna')->where('status_mitra', 'banned')->count();
        $totalPesanan = Pesanan::count();

        return view('admin.pengguna.index', compact(
            'users',
            'totalPengguna',
            'aktifPengguna',
            'bannedPengguna',
            'totalPesanan'
        ));
    }

    public function toggleStatus($id)
    {
        $user = User::findOrFail($id);
        $user->status_mitra = ($user->status_mitra === 'banned') ? null : 'banned';
        $user->save();

        $statusText = ($user->status_mitra === 'banned') ? 'dinonaktifkan/diblokir' : 'diaktifkan kembali';
        return back()->with('success', "Akun pengguna {$user->nama} berhasil {$statusText}.");
    }
}
