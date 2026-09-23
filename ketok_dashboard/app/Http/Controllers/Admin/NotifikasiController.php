<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Notifikasi;
use App\Models\User;
use Illuminate\Http\Request;

class NotifikasiController extends Controller
{
    public function index()
    {
        $notifications = Notifikasi::with('user')
            ->orderBy('id_notif', 'desc')
            ->paginate(15);

        return view('admin.notifikasi.index', compact('notifications'));
    }

    public function broadcast(Request $request)
    {
        $request->validate([
            'target_role' => 'required|in:semua,mitra,pengguna',
            'judul' => 'required|string|max:150',
        ]);

        $query = User::query();
        if ($request->target_role === 'mitra') {
            $query->where('role', 'mitra');
        } elseif ($request->target_role === 'pengguna') {
            $query->where('role', 'pengguna');
        }

        $users = $query->get();
        $count = 0;

        foreach ($users as $user) {
            Notifikasi::create([
                'user_id' => $user->id_user,
                'judul' => $request->judul,
                'status_baca' => 'belum',
            ]);
            $count++;
        }

        return back()->with('success', "Pengumuman berhasil di-broadcast ke {$count} akun.");
    }
}
