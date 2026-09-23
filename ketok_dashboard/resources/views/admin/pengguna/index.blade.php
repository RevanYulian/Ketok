@extends('layouts.admin')

@section('title', 'Manajemen Pengguna')
@section('page_title', 'Manajemen Pengguna')

@section('content')
<div class="space-y-6" x-data="{ 
    detailModalOpen: false, 
    selectedUser: null 
}">

    <!-- Header & Ringkasan Metrik -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
        <!-- 1. Total Pengguna -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold shrink-0">
                <i data-lucide="users" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Total Pengguna</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($totalPengguna ?? 0) }}</p>
                <p class="text-[10px] text-brand-muted mt-0.5">Akun pelanggan terdaftar</p>
            </div>
        </div>

        <!-- 2. Pengguna Aktif -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="user-check" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Pengguna Aktif</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($aktifPengguna ?? 0) }}</p>
                <p class="text-[10px] text-emerald-600 font-semibold mt-0.5">Dapat melakukan booking</p>
            </div>
        </div>

        <!-- 3. Pengguna Diblokir -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-rose-50 text-rose-600 border border-rose-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="user-x" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Akun Diblokir</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($bannedPengguna ?? 0) }}</p>
                <p class="text-[10px] text-rose-600 font-semibold mt-0.5">Akses akun dibatasi</p>
            </div>
        </div>

        <!-- 4. Total Booking -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-brand-primary text-white flex items-center justify-center font-bold shrink-0 shadow-xs">
                <i data-lucide="shopping-bag" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Total Pemesanan</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($totalPesanan ?? 0) }}</p>
                <p class="text-[10px] text-brand-muted mt-0.5">Pekerjaan jasa di Ketok</p>
            </div>
        </div>
    </div>

    <!-- Filter & Search Toolbar -->
    <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <div>
            <h3 class="font-bold text-brand-text text-base">Daftar Pengguna / Pelanggan</h3>
            <p class="text-xs text-brand-muted">Kelola akun pelanggan aplikasi Ketok yang melakukan pemesanan layanan.</p>
        </div>

        <form method="GET" action="{{ route('admin.pengguna.index') }}" class="flex flex-wrap items-center gap-2.5">
            <!-- Filter Status -->
            <select name="status" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Status</option>
                <option value="aktif" {{ request('status') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                <option value="banned" {{ request('status') === 'banned' ? 'selected' : '' }}>Diblokir</option>
            </select>

            <!-- Search Bar -->
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama, email, no HP..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-64">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>
        </form>
    </div>

    <!-- Table Pengguna -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Pelanggan</th>
                        <th class="px-5 py-3.5">Kontak & Email</th>
                        <th class="px-5 py-3.5">Total Pemesanan Jasa</th>
                        <th class="px-5 py-3.5">Terakhir Aktif</th>
                        <th class="px-5 py-3.5">Status Akun</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($users as $user)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-9 h-9 rounded-full bg-brand-surfaceLow text-brand-primary border border-brand-border font-bold flex items-center justify-center text-xs shrink-0">
                                        {{ strtoupper(substr($user->nama, 0, 1)) }}
                                    </div>
                                    <div>
                                        <p class="font-bold text-brand-text">{{ $user->nama }}</p>
                                        <p class="text-[11px] text-brand-muted">{{ $user->alamat ?? 'Alamat belum diatur' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 text-brand-text">
                                <p class="font-medium">{{ $user->email }}</p>
                                <p class="text-[11px] text-brand-muted">{{ $user->nomor_telepon ?? '-' }}</p>
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-1 rounded-full text-xs font-bold bg-brand-surfaceLow text-brand-primary border border-brand-border inline-flex items-center gap-1.5">
                                    <i data-lucide="shopping-bag" class="w-3 h-3 text-brand-muted"></i>
                                    <span>{{ $user->pesanan_sebagai_pengguna_count ?? 0 }} pesanan</span>
                                </span>
                            </td>
                            <td class="px-5 py-4">
                                @if($user->terakhir_aktif)
                                    @php
                                        $diffMinutes = \Carbon\Carbon::parse($user->terakhir_aktif)->diffInMinutes();
                                        $isOnlineRecently = $diffMinutes < 15;
                                    @endphp
                                    <div class="flex items-center gap-1.5">
                                        @if($isOnlineRecently)
                                            <span class="w-2 h-2 rounded-full bg-brand-success animate-pulse"></span>
                                            <span class="text-xs font-semibold text-brand-success">Sedang aktif</span>
                                        @else
                                            <span class="w-1.5 h-1.5 rounded-full bg-gray-400"></span>
                                            <span class="text-xs text-brand-muted">{{ \Carbon\Carbon::parse($user->terakhir_aktif)->diffForHumans() }}</span>
                                        @endif
                                    </div>
                                @else
                                    <span class="text-xs text-gray-400 italic">Belum tercatat</span>
                                @endif
                            </td>
                            <td class="px-5 py-4">
                                @if($user->status_mitra === 'banned')
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                                        Diblokir
                                    </span>
                                @else
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                        Aktif
                                    </span>
                                @endif
                            </td>
                            <td class="px-5 py-4 text-right">
                                <div class="relative inline-block text-left" x-data="{ dropdownOpen: false }">
                                    <button @click="dropdownOpen = !dropdownOpen" 
                                            @click.away="dropdownOpen = false" 
                                            type="button" 
                                            class="px-2.5 py-1.5 rounded-xl border border-brand-border bg-white hover:bg-gray-50 text-brand-text font-semibold text-xs inline-flex items-center gap-1.5 shadow-2xs cursor-pointer transition-colors">
                                        <span>Opsi</span>
                                        <i data-lucide="chevron-down" class="w-3.5 h-3.5 text-brand-muted"></i>
                                    </button>

                                    <div x-show="dropdownOpen" 
                                         x-cloak 
                                         class="absolute right-0 z-40 mt-1.5 w-44 rounded-2xl bg-white border border-brand-border shadow-xl py-1 text-xs divide-y divide-gray-100 text-left">
                                        <div class="py-1">
                                            <button type="button" 
                                                    @click="dropdownOpen = false; selectedUser = {{ json_encode([
                                                        'id' => $user->id_user,
                                                        'nama' => $user->nama,
                                                        'email' => $user->email,
                                                        'nomor_telepon' => $user->nomor_telepon ?? '-',
                                                        'alamat' => $user->alamat ?? 'Belum diatur',
                                                        'pesanan_count' => $user->pesanan_sebagai_pengguna_count ?? 0,
                                                        'status' => $user->status_mitra === 'banned' ? 'Diblokir' : 'Aktif',
                                                        'terakhir_aktif' => $user->terakhir_aktif ? \Carbon\Carbon::parse($user->terakhir_aktif)->diffForHumans() : 'Belum pernah aktif'
                                                    ]) }}; detailModalOpen = true"
                                                    class="w-full flex items-center gap-2 px-3.5 py-2 text-brand-text hover:bg-gray-50 transition-colors font-medium text-left">
                                                <i data-lucide="user" class="w-3.5 h-3.5 text-brand-muted"></i>
                                                <span>Detail Pengguna</span>
                                            </button>
                                        </div>

                                        <div class="py-1">
                                            <form action="{{ route('admin.pengguna.toggle_status', $user->id_user) }}" method="POST">
                                                @csrf
                                                <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 {{ $user->status_mitra === 'banned' ? 'text-emerald-600 hover:bg-emerald-50' : 'text-rose-600 hover:bg-rose-50' }} transition-colors font-medium text-left">
                                                    <i data-lucide="{{ $user->status_mitra === 'banned' ? 'check-circle' : 'ban' }}" class="w-3.5 h-3.5"></i>
                                                    <span>{{ $user->status_mitra === 'banned' ? 'Buka Blokir' : 'Blokir Akun' }}</span>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-5 py-8 text-center text-brand-muted">Tidak ada data pengguna ditemukan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($users->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $users->links() }}
            </div>
        @endif
    </div>

    <!-- Modal Detail Pengguna -->
    <div x-show="detailModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border" @click.away="detailModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="user" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Detail Informasi Pengguna</h3>
                        <p class="text-[11px] text-brand-muted">Profil akun pelanggan Ketok App</p>
                    </div>
                </div>
                <button @click="detailModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <template x-if="selectedUser">
                <div class="mt-4 space-y-4">
                    <div class="flex items-center gap-3 p-3 rounded-xl bg-gray-50/75 border border-brand-border">
                        <div class="w-12 h-12 rounded-full bg-brand-primary text-white flex items-center justify-center font-bold text-base shrink-0">
                            <span x-text="selectedUser.nama ? selectedUser.nama.substring(0, 1).toUpperCase() : 'U'"></span>
                        </div>
                        <div>
                            <h4 class="font-bold text-brand-text text-sm" x-text="selectedUser.nama"></h4>
                            <p class="text-xs text-brand-muted" x-text="selectedUser.email"></p>
                        </div>
                    </div>

                    <div class="grid grid-cols-2 gap-3 text-xs">
                        <div class="p-3 rounded-xl bg-gray-50 border border-brand-border">
                            <p class="text-brand-muted text-[10px]">Nomor Telepon</p>
                            <p class="font-bold text-brand-text mt-0.5" x-text="selectedUser.nomor_telepon"></p>
                        </div>
                        <div class="p-3 rounded-xl bg-gray-50 border border-brand-border">
                            <p class="text-brand-muted text-[10px]">Status Akun</p>
                            <span class="inline-block px-2 py-0.5 rounded-full text-[10px] font-bold mt-0.5"
                                  :class="selectedUser.status === 'Aktif' ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-rose-50 text-rose-700 border border-rose-200'"
                                  x-text="selectedUser.status"></span>
                        </div>
                    </div>

                    <div class="p-3 rounded-xl bg-gray-50 border border-brand-border text-xs">
                        <p class="text-brand-muted text-[10px]">Alamat Domisili</p>
                        <p class="font-medium text-brand-text mt-0.5" x-text="selectedUser.alamat"></p>
                    </div>

                    <div class="grid grid-cols-2 gap-3 text-xs">
                        <div class="p-3 rounded-xl bg-gray-50 border border-brand-border">
                            <p class="text-brand-muted text-[10px]">Terakhir Aktif</p>
                            <p class="font-bold text-brand-text mt-0.5" x-text="selectedUser.terakhir_aktif"></p>
                        </div>
                        <div class="p-3 rounded-xl bg-gray-50 border border-brand-border">
                            <p class="text-brand-muted text-[10px]">Total Booking Layanan</p>
                            <p class="font-bold text-brand-text mt-0.5" x-text="selectedUser.pesanan_count + ' Pesanan'"></p>
                        </div>
                    </div>

                    <div class="pt-3 border-t border-brand-border flex justify-end">
                        <button type="button" @click="detailModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">
                            Tutup
                        </button>
                    </div>
                </div>
            </template>
        </div>
    </div>

</div>
@endsection
