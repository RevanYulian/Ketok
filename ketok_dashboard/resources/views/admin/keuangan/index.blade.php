@extends('layouts.admin')

@section('title', 'Komisi Platform')
@section('page_title', 'Komisi')

@section('content')
<div class="space-y-6">

    <!-- KPI Komisi & Keuangan Cards -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs">
            <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Total Nilai Transaksi</span>
            <h3 class="text-2xl font-black text-brand-text mt-2">Rp {{ number_format($totalPendapatan, 0, ',', '.') }}</h3>
            <p class="text-xs text-emerald-600 mt-1 flex items-center gap-1 font-medium">
                <i data-lucide="check-circle-2" class="w-3.5 h-3.5"></i>
                <span>Transaksi sukses & lunas</span>
            </p>
        </div>

        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs">
            <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Komisi Platform (10%)</span>
            <h3 class="text-2xl font-black text-brand-primary mt-2">Rp {{ number_format($totalKomisi, 0, ',', '.') }}</h3>
            <p class="text-xs text-brand-muted mt-1">Pendapatan bersih Ketok</p>
        </div>

        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs">
            <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Hak Bersih Mitra (90%)</span>
            <h3 class="text-2xl font-black text-brand-text mt-2">Rp {{ number_format($totalPendapatanMitra, 0, ',', '.') }}</h3>
            <p class="text-xs text-brand-muted mt-1">Penyaluran ke saldo mitra</p>
        </div>

        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs">
            <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Transaksi Menunggu</span>
            <h3 class="text-2xl font-black text-brand-text mt-2">Rp {{ number_format($pendingBayar, 0, ',', '.') }}</h3>
            <p class="text-xs text-brand-muted mt-1 font-medium">Belum diselesaikan pengguna</p>
        </div>
    </div>

    <!-- Table Komisi Transaksi & Action -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="p-5 border-b border-brand-border flex flex-col sm:flex-row sm:items-center justify-between gap-4">
            <div>
                <h3 class="font-bold text-brand-text text-base">Rekapitulasi Komisi Transaksi</h3>
                <p class="text-xs text-brand-muted mt-0.5">Daftar transaksi pesanan, rincian biaya, komisi platform, dan status pembayaran.</p>
            </div>

            <div class="flex items-center gap-2.5">
                <form method="GET" action="{{ route('admin.keuangan.index') }}" class="flex items-center gap-2">
                    <select name="status_bayar" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        <option value="">Semua Status</option>
                        <option value="lunas" {{ request('status_bayar') === 'lunas' ? 'selected' : '' }}>Lunas</option>
                        <option value="menunggu" {{ request('status_bayar') === 'menunggu' ? 'selected' : '' }}>Menunggu</option>
                    </select>
                </form>

                <a href="{{ route('admin.keuangan.export_csv') }}" 
                   class="px-3.5 py-2 rounded-xl bg-brand-primary text-white text-xs font-semibold hover:bg-black transition-colors flex items-center gap-1.5 shadow-xs">
                    <i data-lucide="download" class="w-3.5 h-3.5 text-white"></i>
                    <span>Ekspor CSV</span>
                </a>
            </div>
        </div>

        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">ID Pesanan</th>
                        <th class="px-5 py-3.5">Pelanggan</th>
                        <th class="px-5 py-3.5">Mitra</th>
                        <th class="px-5 py-3.5">Total Biaya</th>
                        <th class="px-5 py-3.5">Komisi Ketok (10%)</th>
                        <th class="px-5 py-3.5">Hak Mitra (90%)</th>
                        <th class="px-5 py-3.5">Status Bayar</th>
                        <th class="px-5 py-3.5 text-right">Ubah Status</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($invoices as $inv)
                        @php
                            $total = $inv->jumlah_biaya ?? 0;
                            $komisi = $total * 0.10;
                            $mitraFee = $total * 0.90;
                        @endphp
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4 font-bold text-brand-text">
                                <span class="font-mono text-xs text-brand-primary">#KTK-{{ $inv->pesanan_id }}</span>
                            </td>
                            <td class="px-5 py-4 text-brand-text font-medium">
                                {{ $inv->pesanan->pengguna->nama ?? 'Pelanggan' }}
                            </td>
                            <td class="px-5 py-4 text-brand-text font-medium">
                                {{ $inv->pesanan->mitra->nama ?? 'Mitra' }}
                            </td>
                            <td class="px-5 py-4 font-bold text-brand-text">
                                Rp {{ number_format($total, 0, ',', '.') }}
                            </td>
                            <td class="px-5 py-4 font-semibold text-emerald-700 bg-emerald-50/50">
                                + Rp {{ number_format($komisi, 0, ',', '.') }}
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                Rp {{ number_format($mitraFee, 0, ',', '.') }}
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold border {{ $inv->status_bayar === 'lunas' ? 'bg-emerald-50 text-emerald-700 border-emerald-200' : 'bg-amber-50 text-amber-700 border-amber-200' }}">
                                    {{ ucfirst($inv->status_bayar ?? 'Menunggu') }}
                                </span>
                            </td>
                            <td class="px-5 py-4 text-right">
                                <form action="{{ route('admin.keuangan.update_status', $inv->id_invoice) }}" method="POST" class="inline-flex items-center gap-1">
                                    @csrf
                                    @method('PUT')
                                    <input type="hidden" name="status_bayar" value="{{ $inv->status_bayar === 'lunas' ? 'menunggu' : 'lunas' }}">
                                    <button type="submit" class="px-2.5 py-1 rounded-lg text-[11px] font-semibold border border-brand-border hover:bg-gray-100 transition-colors cursor-pointer">
                                        Set {{ $inv->status_bayar === 'lunas' ? 'Menunggu' : 'Lunas' }}
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="8" class="px-5 py-8 text-center text-brand-muted">Belum ada riwayat transaksi dan komisi.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($invoices->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $invoices->links() }}
            </div>
        @endif
    </div>

</div>
@endsection
