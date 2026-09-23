@extends('layouts.admin')

@section('title', 'Pesanan Direct Booking')
@section('page_title', 'Monitoring Pesanan')

@section('content')
<div class="space-y-6">

    <!-- Header & Filter -->
    <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex flex-col lg:flex-row lg:items-center justify-between gap-4">
        <div>
            <h2 class="text-xl font-bold text-brand-text">Monitoring Pesanan (Direct Booking)</h2>
            <p class="text-xs text-brand-muted mt-0.5">Pemantauan pesanan langsung antara pelanggan dan mitra pilihan mereka.</p>
        </div>

        <form method="GET" action="{{ route('admin.pesanan.index') }}" class="flex flex-wrap items-center gap-2.5">
            <select name="status" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="semua">Semua Status</option>
                <option value="menunggu_konfirmasi" {{ request('status') === 'menunggu_konfirmasi' ? 'selected' : '' }}>Menunggu Konfirmasi</option>
                <option value="estimasi_biaya" {{ request('status') === 'estimasi_biaya' ? 'selected' : '' }}>Estimasi Biaya</option>
                <option value="diproses" {{ request('status') === 'diproses' ? 'selected' : '' }}>Diproses</option>
                <option value="menuju_lokasi" {{ request('status') === 'menuju_lokasi' ? 'selected' : '' }}>Menuju Lokasi</option>
                <option value="dikerjakan" {{ request('status') === 'dikerjakan' ? 'selected' : '' }}>Dikerjakan</option>
                <option value="selesai" {{ request('status') === 'selesai' ? 'selected' : '' }}>Selesai</option>
                <option value="dibatalkan" {{ request('status') === 'dibatalkan' ? 'selected' : '' }}>Dibatalkan</option>
            </select>

            <select name="kategori_id" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Kategori</option>
                @foreach($kategoriList as $kat)
                    <option value="{{ $kat->id_katagori }}" {{ request('kategori_id') == $kat->id_katagori ? 'selected' : '' }}>
                        {{ $kat->nama_katagori }}
                    </option>
                @endforeach
            </select>

            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari pelanggan / mitra / lokasi..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-56">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>
        </form>
    </div>

    <!-- Table Pesanan -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">ID & Kategori</th>
                        <th class="px-5 py-3.5">Pelanggan</th>
                        <th class="px-5 py-3.5">Mitra Terpilih</th>
                        <th class="px-5 py-3.5">Lokasi / Jadwal</th>
                        <th class="px-5 py-3.5">Biaya Kunjungan</th>
                        <th class="px-5 py-3.5">Quotation Biaya</th>
                        <th class="px-5 py-3.5">Status</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($orders as $ord)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4 font-medium text-brand-text">
                                <span class="font-bold text-brand-primary">#KTK-{{ $ord->id_pesanan }}</span>
                                <p class="text-brand-muted text-[11px]">{{ $ord->kategori->nama_katagori ?? 'Layanan' }}</p>
                            </td>
                            <td class="px-5 py-4 text-brand-text">
                                <p class="font-bold">{{ $ord->pengguna->nama ?? 'Pelanggan' }}</p>
                                <p class="text-[11px] text-brand-muted">{{ $ord->pengguna->email ?? '-' }}</p>
                            </td>
                            <td class="px-5 py-4 text-brand-text">
                                <p class="font-bold">{{ $ord->mitra->nama ?? 'Belum Ditentukan' }}</p>
                                <p class="text-[11px] text-brand-muted">{{ $ord->mitra->mitraProfil->nama_usaha ?? 'Mitra Pilihan' }}</p>
                            </td>
                            <td class="px-5 py-4 text-brand-text max-w-xs truncate">
                                <p class="font-medium truncate">{{ $ord->lokasi ?? 'Alamat Pelanggan' }}</p>
                                <p class="text-[11px] text-brand-muted">{{ $ord->jadwal ? date('d M Y, H:i', strtotime($ord->jadwal)) : 'Segera' }}</p>
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                Rp {{ number_format($ord->biaya_kunjungan ?? 50000, 0, ',', '.') }}
                            </td>
                            <td class="px-5 py-4">
                                @if($ord->status_persetujuan_biaya)
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold {{ $ord->status_persetujuan_biaya === 'disetujui' ? 'bg-emerald-100 text-emerald-800' : 'bg-purple-100 text-purple-800' }}">
                                        {{ ucfirst(str_replace('_', ' ', $ord->status_persetujuan_biaya)) }}
                                    </span>
                                @else
                                    <span class="text-brand-muted text-[11px]">Belum Ada</span>
                                @endif
                            </td>
                            <td class="px-5 py-4">
                                @php
                                    $badgeStyles = [
                                        'mencari_mitra' => 'bg-brand-surfaceLow text-brand-text border-brand-border',
                                        'menunggu_konfirmasi' => 'bg-brand-surfaceLow text-brand-text border-brand-border',
                                        'estimasi_biaya' => 'bg-purple-50 text-purple-700 border-purple-200',
                                        'diproses' => 'bg-blue-50 text-blue-700 border-blue-200',
                                        'menuju_lokasi' => 'bg-indigo-50 text-indigo-700 border-indigo-200',
                                        'dikerjakan' => 'bg-blue-100 text-blue-800 border-blue-300',
                                        'selesai' => 'bg-emerald-50 text-emerald-700 border-emerald-200',
                                        'dibatalkan' => 'bg-rose-50 text-rose-700 border-rose-200',
                                    ];
                                    $style = $badgeStyles[$ord->status] ?? 'bg-gray-50 text-gray-700 border-gray-200';
                                @endphp
                                <span class="px-2.5 py-1 rounded-full text-[11px] font-bold border {{ $style }}">
                                    {{ ucfirst(str_replace('_', ' ', $ord->status)) }}
                                </span>
                            </td>
                            <td class="px-5 py-4 text-right">
                                <a href="{{ route('admin.pesanan.show', $ord->id_pesanan) }}" 
                                   class="px-3 py-1.5 rounded-lg bg-gray-100 hover:bg-brand-primary hover:text-white text-brand-text font-semibold text-xs transition-colors inline-flex items-center gap-1">
                                    <span>Detail</span>
                                    <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
                                </a>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-5 py-8 text-center text-brand-muted">
                                Tidak ada data pesanan yang sesuai filter.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($orders->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $orders->links() }}
            </div>
        @endif
    </div>

</div>
@endsection
