<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    public function index()
    {
        $admins = Admin::orderBy('id_admin', 'asc')->get();
        return view('admin.admins.index', compact('admins'));
    }

    public function store(Request $request)
    {
        $request->validate([
            'nama' => 'required|string|max:150',
            'email' => 'required|email|unique:admins,email|max:150',
            'level_akses' => 'required|in:Super Admin,Operasional,Customer Service,Keuangan',
            'password' => 'nullable|string|min:6',
        ]);

        $data = $request->only('nama', 'email', 'level_akses');
        $data['password'] = Hash::make($request->filled('password') ? $request->password : 'admin123');

        Admin::create($data);

        return back()->with('success', "Akun admin {$request->nama} berhasil dibuat.");
    }

    public function update(Request $request, $id)
    {
        $admin = Admin::findOrFail($id);

        $request->validate([
            'nama' => 'required|string|max:150',
            'email' => 'required|email|max:150|unique:admins,email,' . $admin->id_admin . ',id_admin',
            'level_akses' => 'required|in:Super Admin,Operasional,Customer Service,Keuangan',
            'password' => 'nullable|string|min:6',
        ]);

        $data = $request->only('nama', 'email', 'level_akses');
        if ($request->filled('password')) {
            $data['password'] = Hash::make($request->password);
        }

        $admin->update($data);

        return back()->with('success', "Data admin {$admin->nama} berhasil diperbarui.");
    }

    public function destroy($id)
    {
        if (Auth::guard('admin')->id() == $id) {
            return back()->with('error', 'Anda tidak dapat menghapus akun admin yang sedang aktif digunakan.');
        }

        $admin = Admin::findOrFail($id);
        $nama = $admin->nama;
        $admin->delete();

        return back()->with('success', "Akun admin {$nama} berhasil dihapus.");
    }
}
