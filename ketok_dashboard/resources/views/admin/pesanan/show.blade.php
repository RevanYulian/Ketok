@extends('layouts.admin')

@section('title', 'Detail Pesanan #KTK-' . $order->id_pesanan)
@section('page_title', 'Detail Pesanan')

@section('content')
<div class="space-y-6" x-data="{ reassignModalOpen: false, cancelModalOpen: false }">

    <!-- Header & Back Button -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
        <a href="{{ route('admin.pesanan.index') }}" class="inline-flex items-center gap-1.5 text-xs font-semibold text-brand-muted hover:text-brand-text">
            <i data-lucide="arrow-left" class="w-4 h-4"></i>
            <span>Kembali ke Daftar Pesanan</span>
        </a>

        <div class="flex items-center gap-2">
            <!-- Tombol Re-assign Mitra -->
            <button @click="reassignModalOpen = true" class="px-3 py-1.5 rounded-xl bg-brand-dark text-white font-semibold text-xs hover:bg-black transition-colors flex items-center gap-1.5 shadow-xs">
                <i data-lucide="user-check" class="w-4 h-4"></i>
                <span>Ganti / Re-assign Mitra</span>
            </button>

            <!-- Tombol Batalkan Pesanan -->
            @if($order->status !== 'dibatalkan' && $order->status !== 'selesai')
                <button @click="cancelModalOpen = true" class="px-3 py-1.5 rounded-xl bg-rose-50 text-rose-700 border border-rose-200 font-semibold text-xs hover:bg-rose-100 transition-colors flex items-center gap-1.5">
                    <i data-lucide="x-circle" class="w-4 h-4"></i>
                    <span>Batalkan Pesanan</span>
                </button>
            @endif
        </div>
    </div>

    <!-- Order Overview Header -->
    <div class="bg-white rounded-2xl p-6 border border-brand-border shadow-xs">
        <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 pb-4 border-b border-brand-border">
            <div>
                <div class="flex items-center gap-2">
                    <h2 class="text-2xl font-black text-brand-text">#KTK-{{ $order->id_pesanan }}</h2>
                    <span class="px-3 py-1 rounded-full text-xs font-bold border bg-brand-surfaceLow text-brand-text border-brand-border">
                        {{ ucfirst(str_replace('_', ' ', $order->status)) }}
                    </span>
                </div>
                <p class="text-xs text-brand-muted mt-1">Kategori: {{ $order->kategori->nama_katagori ?? 'Layanan' }}</p>
            </div>

            <!-- Update Status Form -->
            <form action="{{ route('admin.pesanan.status', $order->id_pesanan) }}" method="POST" class="flex items-center gap-2">
                @csrf
                <select name="status" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium">
                    <option value="menunggu_konfirmasi" {{ $order->status === 'menunggu_konfirmasi' ? 'selected' : '' }}>Menunggu Konfirmasi</option>
                    <option value="estimasi_biaya" {{ $order->status === 'estimasi_biaya' ? 'selected' : '' }}>Estimasi Biaya</option>
                    <option value="diproses" {{ $order->status === 'diproses' ? 'selected' : '' }}>Diproses</option>
                    <option value="menuju_lokasi" {{ $order->status === 'menuju_lokasi' ? 'selected' : '' }}>Menuju Lokasi</option>
                    <option value="dikerjakan" {{ $order->status === 'dikerjakan' ? 'selected' : '' }}>Dikerjakan</option>
                    <option value="selesai" {{ $order->status === 'selesai' ? 'selected' : '' }}>Selesai</option>
                    <option value="dibatalkan" {{ $order->status === 'dibatalkan' ? 'selected' : '' }}>Dibatalkan</option>
                </select>
                <button type="submit" class="px-3 py-2 bg-brand-dark text-white rounded-xl text-xs font-semibold hover:bg-gray-800">
                    Update
                </button>
            </form>
        </div>

        <!-- 2 Column: Pelanggan & Mitra -->
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mt-5">
            <!-- Pelanggan -->
            <div class="p-4 rounded-xl bg-gray-50/70 border border-brand-border">
                <p class="text-xs font-bold uppercase tracking-wider text-brand-muted mb-2">Pelanggan</p>
                <h4 class="font-bold text-brand-text text-sm">{{ $order->pengguna->nama ?? 'Pelanggan' }}</h4>
                <p class="text-xs text-brand-muted">{{ $order->pengguna->email ?? '-' }}</p>
                <p class="text-xs text-brand-text mt-2 font-medium">Alamat / Lokasi:</p>
                <p class="text-xs text-brand-muted mt-0.5">{{ $order->lokasi ?? 'Tidak ada lokasi tercantum' }}</p>
                <p class="text-xs text-brand-text mt-2 font-medium">Catatan:</p>
                <p class="text-xs text-brand-muted mt-0.5">{{ $order->catatan ?? '-' }}</p>
            </div>

            <!-- Mitra Pilihan -->
            <div class="p-4 rounded-xl bg-gray-50/70 border border-brand-border">
                <p class="text-xs font-bold uppercase tracking-wider text-brand-muted mb-2">Mitra Terpilih (Direct Booking)</p>
                @if($order->mitra)
                    <h4 class="font-bold text-brand-text text-sm">{{ $order->mitra->nama }}</h4>
                    <p class="text-xs text-brand-muted">{{ $order->mitra->email }}</p>
                    <p class="text-xs text-brand-text mt-2 font-medium">Nama Usaha:</p>
                    <p class="text-xs text-brand-muted mt-0.5">{{ $order->mitra->mitraProfil->nama_usaha ?? 'Usaha Mandiri' }}</p>
                    <p class="text-xs text-brand-text mt-2 font-medium">Keahlian:</p>
                    <p class="text-xs text-brand-muted mt-0.5">{{ $order->mitra->mitraProfil->keahlian ?? '-' }}</p>
                @else
                    <p class="text-xs text-rose-600 font-semibold">Belum ada mitra yang ditugaskan.</p>
                    <button @click="reassignModalOpen = true" class="mt-2 text-xs font-bold text-brand-dark hover:underline">
                        + Pilih Mitra Sekarang
                    </button>
                @endif
            </div>
        </div>
    </div>

    <!-- Quotation System: Rincian Biaya & Invoice -->
    <div class="bg-white rounded-2xl p-6 border border-brand-border shadow-xs">
        <div class="flex items-center justify-between pb-3 border-b border-brand-border">
            <div>
                <h3 class="font-bold text-brand-text text-base">Quotation System (Persetujuan Biaya)</h3>
                <p class="text-xs text-brand-muted">Rincian transparansi biaya kunjungan, jasa, dan sparepart sesuai kesepakatan.</p>
            </div>
            @if($order->status_persetujuan_biaya)
                <span class="px-3 py-1 rounded-full text-xs font-bold {{ $order->status_persetujuan_biaya === 'disetujui' ? 'bg-emerald-100 text-emerald-800' : 'bg-brand-surfaceLow text-brand-text border border-brand-border' }}">
                    Status: {{ ucfirst(str_replace('_', ' ', $order->status_persetujuan_biaya)) }}
                </span>
            @endif
        </div>

        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mt-4">
            <div class="p-4 rounded-xl bg-gray-50 border border-brand-border">
                <p class="text-xs text-brand-muted font-semibold">Biaya Kunjungan (Transport)</p>
                <h4 class="text-xl font-black text-brand-text mt-1">
                    Rp {{ number_format($order->biaya_kunjungan ?? 50000, 0, ',', '.') }}
                </h4>
            </div>

            <div class="p-4 rounded-xl bg-gray-50 border border-brand-border">
                <p class="text-xs text-brand-muted font-semibold">Estimasi Biaya Jasa</p>
                <h4 class="text-xl font-black text-brand-text mt-1">
                    Rp {{ number_format($order->invoice->biaya_jasa ?? 0, 0, ',', '.') }}
                </h4>
            </div>

            <div class="p-4 rounded-xl bg-gray-50 border border-brand-border">
                <p class="text-xs text-brand-muted font-semibold">Biaya Sparepart / Material</p>
                <h4 class="text-xl font-black text-brand-text mt-1">
                    Rp {{ number_format($order->invoice->biaya_sparepart ?? 0, 0, ',', '.') }}
                </h4>
            </div>
        </div>

        <!-- Total Invoice -->
        <div class="mt-4 p-4 rounded-xl bg-gray-50 border border-brand-border flex items-center justify-between">
            <div>
                <span class="text-xs text-brand-muted">Total Tagihan (Invoice):</span>
                <p class="text-lg font-black text-brand-text">
                    Rp {{ number_format(($order->invoice->jumlah_biaya ?? (($order->biaya_kunjungan ?? 50000) + ($order->invoice->biaya_jasa ?? 0) + ($order->invoice->biaya_sparepart ?? 0))), 0, ',', '.') }}
                </p>
            </div>
            <div>
                <span class="px-2.5 py-1 rounded-full text-xs font-bold {{ ($order->invoice && $order->invoice->status_bayar === 'lunas') ? 'bg-emerald-100 text-emerald-800' : 'bg-brand-surfaceLow text-brand-text border border-brand-border' }}">
                    Status Bayar: {{ ucfirst($order->invoice->status_bayar ?? 'Menunggu') }}
                </span>
            </div>
        </div>
    </div>

    <!-- Modal Re-assign Mitra -->
    <div x-show="reassignModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-brand-border" @click.away="reassignModalOpen = false">
            <h3 class="font-bold text-brand-text text-base pb-3 border-b border-brand-border">Pindahkan Pesanan ke Mitra Lain</h3>
            <p class="text-xs text-brand-muted mt-2">Pilih mitra aktif yang setara di wilayah yang sama untuk menggantikan mitra yang berhalangan.</p>
            
            <form action="{{ route('admin.pesanan.reassign', $order->id_pesanan) }}" method="POST" class="mt-4 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Pilih Mitra Baru</label>
                    <select name="mitra_id" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        @foreach($availableMitras as $m)
                            <option value="{{ $m->id_user }}">
                                {{ $m->nama }} - {{ $m->mitraProfil->nama_usaha ?? 'Usaha Mandiri' }} ({{ $m->mitraProfil?->wilayah_tampil ?? ($m->mitraProfil->wilayah_operasional ?? 'Malang') }})
                            </option>
                        @endforeach
                    </select>
                </div>
                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="reassignModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Tugaskan Mitra Baru</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Batalkan Pesanan -->
    <div x-show="cancelModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-2xl max-w-md w-full p-6 shadow-2xl border border-brand-border" @click.away="cancelModalOpen = false">
            <h3 class="font-bold text-brand-text text-base pb-3 border-b border-brand-border text-rose-600">Konfirmasi Pembatalan</h3>
            <p class="text-xs text-brand-muted mt-2">Apakah Anda yakin ingin membatalkan pesanan #KTK-{{ $order->id_pesanan }}? Tindakan ini akan menghentikan proses transaksi.</p>
            
            <form action="{{ route('admin.pesanan.cancel', $order->id_pesanan) }}" method="POST" class="mt-4">
                @csrf
                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="cancelModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Kembali</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-rose-600 text-white hover:bg-rose-700">Batalkan Pesanan</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
