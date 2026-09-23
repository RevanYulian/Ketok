@extends('layouts.admin')

@section('title', 'Detail Profil Mitra: ' . $mitra->nama)
@section('page_title', 'Detail Profil Mitra')

@section('content')
<div class="space-y-6">

    <!-- Header & Back Button -->
    <div class="flex items-center justify-between">
        <a href="{{ route('admin.mitra.index') }}" class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-muted hover:text-brand-text">
            <i data-lucide="arrow-left" class="w-4 h-4"></i>
            <span>Kembali ke Daftar Mitra</span>
        </a>
        <div class="flex items-center gap-2">
            <form action="{{ route('admin.mitra.suspend', $mitra->id_user) }}" method="POST">
                @csrf
                <button type="submit" class="px-3 py-1.5 rounded-xl text-xs font-semibold {{ $mitra->status_mitra === 'aktif' ? 'bg-rose-50 text-rose-700 border border-rose-200 hover:bg-rose-100' : 'bg-emerald-50 text-emerald-700 border border-emerald-200 hover:bg-emerald-100' }}">
                    {{ $mitra->status_mitra === 'aktif' ? 'Suspend Akun' : 'Aktifkan Akun' }}
                </button>
            </form>
        </div>
    </div>

    <!-- Mitra Info Card -->
    <div class="bg-white rounded-2xl p-6 border border-brand-border shadow-xs">
        <div class="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
            <div class="flex items-center gap-4">
                <div class="w-16 h-16 rounded-2xl bg-brand-surfaceLow text-brand-primary font-bold text-2xl flex items-center justify-center border border-brand-border">
                    {{ strtoupper(substr($mitra->nama, 0, 1)) }}
                </div>
                <div>
                    <h2 class="text-xl font-extrabold text-brand-text flex items-center gap-2">
                        {{ $mitra->nama }}
                        <span class="px-2.5 py-0.5 rounded-full text-xs font-bold border {{ $mitra->status_mitra === 'aktif' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-rose-50 text-rose-700 border-rose-200' }}">
                            {{ ucfirst($mitra->status_mitra ?? 'Aktif') }}
                        </span>
                    </h2>
                    <p class="text-xs text-brand-text font-medium mt-1">Wilayah Operasional: <span class="font-bold text-brand-primary">{{ $mitra->mitraProfil?->wilayah_tampil ?? ($mitra->mitraProfil->wilayah_operasional ?? 'Malang Raya') }}</span></p>
                </div>
            </div>

            <div class="flex items-center gap-6">
                <div class="text-center">
                    <span class="text-2xl font-black text-brand-text">{{ $mitra->pesananSebagaiMitra->count() }}</span>
                    <p class="text-[11px] text-brand-muted font-medium">Total Pesanan</p>
                </div>
                <div class="text-center">
                    <span class="text-2xl font-black text-brand-primary flex items-center gap-1">
                        <i data-lucide="star" class="w-5 h-5 fill-brand-primary text-brand-primary"></i>
                        4.9
                    </span>
                    <p class="text-[11px] text-brand-muted font-medium">Rating Rata-rata</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Etalase Layanan yang Ditawarkan Mitra -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs p-6">
        <h3 class="font-bold text-brand-text text-base mb-4">Etalase Layanan Mitra di Marketplace ({{ $mitra->mitraLayanan->count() }})</h3>
        
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
            @forelse($mitra->mitraLayanan as $layanan)
                <div class="p-4 rounded-xl border border-brand-border bg-gray-50/50 hover:bg-gray-50 transition-colors">
                    <div class="flex items-start justify-between">
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-brand-surfaceLow text-brand-primary border border-brand-border">
                            {{ $layanan->kategori->nama_katagori ?? 'Layanan' }}
                        </span>
                        <span class="text-xs font-bold text-emerald-600">
                            {{ $layanan->aktif ? '● Aktif' : '○ Nonaktif' }}
                        </span>
                    </div>
                    <h4 class="font-bold text-brand-text text-sm mt-2">{{ $layanan->nama_jasa }}</h4>
                    <p class="text-xs text-brand-muted mt-1 truncate">{{ $layanan->deskripsi ?? 'Tidak ada rincian' }}</p>
                    <div class="mt-3 pt-3 border-t border-brand-border flex items-center justify-between text-xs">
                        <span class="text-brand-muted">Mulai dari:</span>
                        <span class="font-bold text-brand-text">Rp {{ number_format($layanan->tarif_mulai, 0, ',', '.') }}</span>
                    </div>
                    <div class="mt-1 flex items-center justify-between text-xs">
                        <span class="text-brand-muted">Biaya Kunjungan:</span>
                        <span class="font-semibold text-brand-text">Rp {{ number_format($layanan->biaya_kunjungan, 0, ',', '.') }}</span>
                    </div>
                </div>
            @empty
                <div class="col-span-3 text-center py-6 text-brand-muted text-xs">
                    Mitra ini belum mempublikasikan layanan di marketplace.
                </div>
            @endforelse
        </div>
    </div>

    <!-- Riwayat Pekerjaan / Pesanan Selesai -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="p-5 border-b border-brand-border">
            <h3 class="font-bold text-brand-text text-base">Riwayat Pesanan yang Ditangani</h3>
        </div>
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3">ID Pesanan</th>
                        <th class="px-5 py-3">Pelanggan</th>
                        <th class="px-5 py-3">Status</th>
                        <th class="px-5 py-3">Ulasan & Rating</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($mitra->pesananSebagaiMitra as $order)
                        <tr>
                            <td class="px-5 py-3.5 font-bold text-brand-primary">#KTK-{{ $order->id_pesanan }}</td>
                            <td class="px-5 py-3.5 text-brand-text">{{ $order->pengguna->nama ?? 'Pelanggan' }}</td>
                            <td class="px-5 py-3.5">
                                <span class="px-2 py-0.5 rounded-full text-[10px] font-bold border bg-gray-100 text-gray-700">
                                    {{ ucfirst(str_replace('_', ' ', $order->status)) }}
                                </span>
                            </td>
                            <td class="px-5 py-3.5 text-brand-text">
                                @if($order->ulasan)
                                    <span class="text-brand-primary font-bold">★ {{ $order->ulasan->rating }}/5</span> - "{{ $order->ulasan->komentar }}"
                                @else
                                    <span class="text-brand-muted">-</span>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-6 text-center text-brand-muted">Belum ada riwayat pesanan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

</div>
@endsection
