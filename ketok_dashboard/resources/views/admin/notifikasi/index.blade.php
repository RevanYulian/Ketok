@extends('layouts.admin')

@section('title', 'Broadcast Notifikasi')
@section('page_title', 'Broadcast Notifikasi')

@section('content')
<div class="grid grid-cols-1 lg:grid-cols-3 gap-6">

    <!-- Form Broadcast (1 Col) -->
    <div class="bg-white rounded-2xl p-6 border border-brand-border shadow-xs">
        <h2 class="text-base font-bold text-brand-text pb-3 border-b border-brand-border">Kirim Pengumuman Massal</h2>
        <p class="text-xs text-brand-muted mt-2">Kirim push notification langsung ke aplikasi Ketok Mitra atau Ketok App (Pengguna).</p>

        <form action="{{ route('admin.notifikasi.broadcast') }}" method="POST" class="mt-5 space-y-4">
            @csrf
            <div>
                <label class="block text-xs font-semibold text-brand-text mb-1">Target Penerima</label>
                <select name="target_role" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <option value="semua">Semua Pengguna & Mitra</option>
                    <option value="mitra">Khusus Semua Mitra Kerja</option>
                    <option value="pengguna">Khusus Semua Pelanggan</option>
                </select>
            </div>

            <div>
                <label class="block text-xs font-semibold text-brand-text mb-1">Judul Notifikasi / Pengumuman</label>
                <input type="text" name="judul" required placeholder="Cth: Info Pembaruan Tarif Kunjungan" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
            </div>

            <button type="submit" class="w-full py-2.5 bg-brand-dark hover:bg-black text-white font-bold text-xs rounded-xl transition-colors shadow-sm flex items-center justify-center gap-2">
                <i data-lucide="send" class="w-4 h-4"></i>
                <span>Broadcast Sekarang</span>
            </button>
        </form>
    </div>

    <!-- Riwayat Notifikasi Terkirim (2 Cols) -->
    <div class="lg:col-span-2 bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="p-5 border-b border-brand-border">
            <h3 class="font-bold text-brand-text text-base">Riwayat Notifikasi Terkirim</h3>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Penerima</th>
                        <th class="px-5 py-3.5">Judul Pengumuman</th>
                        <th class="px-5 py-3.5">Status Baca</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($notifications as $notif)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-3.5 font-medium text-brand-text">
                                {{ $notif->user->nama ?? 'Pengguna' }}
                                <span class="text-[10px] text-brand-muted">({{ $notif->user->role ?? '-' }})</span>
                            </td>
                            <td class="px-5 py-3.5 text-brand-text font-semibold">
                                {{ $notif->judul }}
                            </td>
                            <td class="px-5 py-3.5">
                                <span class="px-2 py-0.5 rounded-full text-[10px] font-bold {{ $notif->status_baca === 'sudah' ? 'bg-emerald-50 text-emerald-700' : 'bg-gray-100 text-gray-500' }}">
                                    {{ ucfirst($notif->status_baca) }}
                                </span>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="3" class="px-5 py-8 text-center text-brand-muted">Belum ada riwayat notifikasi.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($notifications->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $notifications->links() }}
            </div>
        @endif
    </div>

</div>
@endsection
