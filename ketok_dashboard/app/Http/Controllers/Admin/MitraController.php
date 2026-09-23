<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\KategoriLayanan;
use App\Models\MitraProfil;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class MitraController extends Controller
{
    public function index(Request $request)
    {
        // Query Daftar Mitra & Verifikasi
        $query = User::where(function ($q) {
            $q->where('role', 'mitra')
              ->orWhereHas('mitraProfil');
        })->with(['mitraProfil.kategori', 'mitraLayanan']);

        if ($request->filled('status_mitra')) {
            $status = $request->status_mitra;
            if ($status === 'menunggu') {
                $query->where(function ($q) {
                    $q->whereNull('status_mitra')
                      ->orWhereIn('status_mitra', ['menunggu', 'pengajuan', 'pending'])
                      ->orWhereHas('mitraProfil', function ($mq) {
                          $mq->where('status_verifikasi', 'menunggu');
                      });
                });
            } elseif ($status === 'disetujui') {
                $query->whereIn('status_mitra', ['disetujui', 'aktif']);
            } elseif ($status === 'suspended') {
                $query->where('status_mitra', 'suspended');
            } elseif ($status === 'blokir') {
                $query->whereIn('status_mitra', ['blokir', 'banned']);
            } else {
                $query->where('status_mitra', $status);
            }
        }

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('nama', 'ilike', "%{$search}%")
                  ->orWhere('email', 'ilike', "%{$search}%");
            });
        }

        $mitraList = $query->orderBy('id_user', 'desc')->paginate(15);
        $kategoriList = KategoriLayanan::all();
        $menungguCount = User::where(function ($q) {
            $q->where('role', 'mitra')
              ->orWhereHas('mitraProfil');
        })->where(function ($q) {
            $q->whereNull('status_mitra')
              ->orWhereIn('status_mitra', ['menunggu', 'pengajuan', 'pending'])
              ->orWhereHas('mitraProfil', function ($mq) {
                  $mq->where('status_verifikasi', 'menunggu');
              });
        })->count();

        return view('admin.mitra.index', compact('mitraList', 'kategoriList', 'menungguCount'));
    }

    public function show($id)
    {
        $mitra = User::where('role', 'mitra')
            ->with(['mitraProfil.kategori', 'mitraLayanan.kategori', 'pesananSebagaiMitra.pengguna', 'pesananSebagaiMitra.ulasan'])
            ->findOrFail($id);

        return view('admin.mitra.show', compact('mitra'));
    }

    public function approveVerification($id)
    {
        $user = User::findOrFail($id);
        $user->role = 'mitra';
        $user->status_mitra = 'aktif';
        $user->save();

        if ($user->mitraProfil) {
            $user->mitraProfil->update([
                'status_verifikasi' => 'terverifikasi',
                'catatan_verifikasi' => null,
            ]);
        } else {
            MitraProfil::create([
                'user_id' => $user->id_user,
                'status_verifikasi' => 'terverifikasi',
                'status_online' => false,
                'wilayah_operasional' => 'Malang Raya',
            ]);
        }

        Notifikasi::create([
            'user_id' => $user->id_user,
            'judul' => 'Verifikasi KTP Anda telah disetujui admin. Akun Anda kini aktif!',
            'status_baca' => 'belum',
        ]);

        return back()->with('success', "Verifikasi akun mitra {$user->nama} berhasil disetujui!");
    }

    public function rejectVerification(Request $request, $id)
    {
        $alasan = $request->catatan_verifikasi ?? $request->alasan_penolakan;
        if (empty($alasan)) {
            $request->validate([
                'catatan_verifikasi' => 'required|string|max:255',
            ]);
        }

        $user = User::findOrFail($id);
        $user->status_mitra = 'ditolak';
        $user->save();

        if ($user->mitraProfil) {
            $user->mitraProfil->update([
                'status_verifikasi' => 'ditolak',
                'catatan_verifikasi' => $alasan,
            ]);
        }

        Notifikasi::create([
            'user_id' => $user->id_user,
            'judul' => 'Verifikasi KTP Anda ditolak: ' . $alasan . '. Silakan unggah ulang dokumen yang sesuai.',
            'status_baca' => 'belum',
        ]);

        return back()->with('success', "Verifikasi KTP mitra {$user->nama} ditolak.");
    }

    public function approve(Request $request, $id)
    {
        return $this->approveVerification($id);
    }

    public function reject(Request $request, $id)
    {
        return $this->rejectVerification($request, $id);
    }

    public function toggleSuspend($id)
    {
        $mitra = User::findOrFail($id);
        if ($mitra->status_mitra === 'aktif') {
            $mitra->status_mitra = 'suspended';
            $msg = "Akun mitra {$mitra->nama} berhasil disuspend.";
        } else {
            $mitra->status_mitra = 'aktif';
            $msg = "Akun mitra {$mitra->nama} berhasil diaktifkan kembali.";
        }
        $mitra->save();

        Notifikasi::create([
            'user_id' => $mitra->id_user,
            'judul' => $mitra->status_mitra === 'suspended'
                ? 'Akun mitra Anda telah disuspend sementara oleh admin.'
                : 'Akun mitra Anda telah diaktifkan kembali oleh admin.',
            'status_baca' => 'belum',
        ]);

        return back()->with('success', $msg);
    }

    public function updateStatus(Request $request, $id, $status)
    {
        $validStatuses = ['disetujui', 'suspended', 'blokir'];
        if (!in_array($status, $validStatuses)) {
            return back()->with('error', 'Status mitra tidak valid.');
        }

        $user = User::findOrFail($id);
        $user->status_mitra = $status;
        $user->save();

        if ($status === 'disetujui') {
            if ($user->mitraProfil) {
                $user->mitraProfil->update([
                    'status_verifikasi' => 'terverifikasi',
                    'catatan_verifikasi' => null,
                ]);
            } else {
                MitraProfil::create([
                    'user_id' => $user->id_user,
                    'status_verifikasi' => 'terverifikasi',
                    'status_online' => false,
                    'wilayah_operasional' => 'Malang Raya',
                ]);
            }
            $msg = "Akun mitra {$user->nama} berhasil disetujui!";
        } elseif ($status === 'suspended') {
            if ($user->mitraProfil) {
                $user->mitraProfil->update(['status_online' => false]);
            }
            $msg = "Akun mitra {$user->nama} berhasil disuspend.";
        } elseif ($status === 'blokir') {
            if ($user->mitraProfil) {
                $user->mitraProfil->update(['status_online' => false]);
            }
            $msg = "Akun mitra {$user->nama} berhasil diblokir.";
        }

        $pesanNotif = match ($status) {
            'disetujui' => 'Status akun mitra Anda telah disetujui dan aktif.',
            'suspended' => 'Akun mitra Anda telah disuspend sementara oleh admin.',
            'blokir' => 'Akun mitra Anda telah diblokir oleh admin.',
            default => 'Status akun mitra Anda telah diubah menjadi ' . $status,
        };
        Notifikasi::create([
            'user_id' => $user->id_user,
            'judul' => $pesanNotif,
            'status_baca' => 'belum',
        ]);

        return back()->with('success', $msg);
    }
}
