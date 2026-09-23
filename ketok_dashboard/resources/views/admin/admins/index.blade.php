@extends('layouts.admin')

@section('title', 'Manajemen Akun Admin')
@section('page_title', 'Pengaturan Admin')

@section('content')
<div class="space-y-6" x-data="{ addModalOpen: false, editModalOpen: false, currentAdmin: {} }">

    <!-- Header & Action -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-white p-5 rounded-2xl border border-brand-border shadow-xs">
        <div>
            <h2 class="text-xl font-bold text-brand-text">Pengaturan Akun Staf & Administrator</h2>
            <p class="text-xs text-brand-muted mt-0.5">Kelola akun staf platform Ketok dan penentuan hak akses operasional.</p>
        </div>

        <button @click="addModalOpen = true" class="px-4 py-2 rounded-xl bg-brand-dark text-white font-semibold text-xs hover:bg-black transition-colors flex items-center gap-2 shadow-xs shrink-0">
            <i data-lucide="plus" class="w-4 h-4 text-white"></i>
            <span>Tambah Admin Baru</span>
        </button>
    </div>

    <!-- Table Admin -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Nama Admin</th>
                        <th class="px-5 py-3.5">Email</th>
                        <th class="px-5 py-3.5">Level Akses</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($admins as $adm)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4 font-bold text-brand-text flex items-center gap-3">
                                <div class="w-8 h-8 rounded-full bg-brand-surfaceLow text-brand-primary border border-brand-border font-bold flex items-center justify-center text-xs">
                                    {{ strtoupper(substr($adm->nama, 0, 1)) }}
                                </div>
                                <span>{{ $adm->nama }}</span>
                            </td>
                            <td class="px-5 py-4 text-brand-muted">{{ $adm->email }}</td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-gray-100 text-gray-800 border border-gray-200">
                                    {{ $adm->level_akses ?? 'Admin' }}
                                </span>
                            </td>
                            <td class="px-5 py-4 text-right">
                                <div class="flex items-center justify-end gap-1.5">
                                    <button @click="currentAdmin = {{ json_encode($adm) }}; editModalOpen = true" 
                                            class="p-1.5 rounded-lg text-brand-muted hover:text-brand-text hover:bg-gray-100">
                                        <i data-lucide="edit-2" class="w-4 h-4"></i>
                                    </button>
                                    <form action="{{ route('admin.admins.destroy', $adm->id_admin) }}" method="POST"
                                          data-confirm-title="Hapus Akun Admin"
                                          data-confirm-message="Apakah Anda yakin ingin menghapus admin {{ $adm->nama }}? Tindakan ini tidak dapat dibatalkan."
                                          data-confirm-button="Ya, Hapus"
                                          data-confirm-type="danger">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-8 text-center text-brand-muted">Belum ada akun admin terdaftar.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- Modal Tambah Admin -->
    <div x-show="addModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-brand-border" @click.away="addModalOpen = false">
            <h3 class="font-bold text-brand-text text-base pb-3 border-b border-brand-border">Tambah Admin Baru</h3>
            <form action="{{ route('admin.admins.store') }}" method="POST" class="mt-4 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Nama Lengkap</label>
                    <input type="text" name="nama" required placeholder="Cth: Budi Santoso" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Email</label>
                    <input type="email" name="email" required placeholder="admin@ketok.id" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Level Akses</label>
                    <select name="level_akses" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        <option value="Super Admin">Super Admin</option>
                        <option value="Operasional">Operasional</option>
                        <option value="Customer Service">Customer Service</option>
                        <option value="Keuangan">Keuangan</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Kata Sandi (Opsional, Default: admin123)</label>
                    <input type="password" name="password" placeholder="Minimal 6 karakter" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="addModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Simpan Admin</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Admin -->
    <div x-show="editModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-brand-border" @click.away="editModalOpen = false">
            <h3 class="font-bold text-brand-text text-base pb-3 border-b border-brand-border">Edit Data Admin</h3>
            <form :action="'/admin/admins/' + currentAdmin.id_admin" method="POST" class="mt-4 space-y-4">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Nama Lengkap</label>
                    <input type="text" name="nama" :value="currentAdmin.nama" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Email</label>
                    <input type="email" name="email" :value="currentAdmin.email" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Level Akses</label>
                    <select name="level_akses" :value="currentAdmin.level_akses" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        <option value="Super Admin">Super Admin</option>
                        <option value="Operasional">Operasional</option>
                        <option value="Customer Service">Customer Service</option>
                        <option value="Keuangan">Keuangan</option>
                    </select>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Ganti Kata Sandi (Kosongkan jika tidak diubah)</label>
                    <input type="password" name="password" placeholder="Masukkan kata sandi baru (min. 6 karakter)" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="editModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Perbarui Admin</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
