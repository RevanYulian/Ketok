@extends('layouts.admin')

@section('title', 'Dashboard Operasional Marketplace')
@section('page_title', 'Ringkasan Platform')

@section('content')
<div class="space-y-6">

    <!-- 4 KPI Metrics Card (Monochrome & KetokColors) -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4 sm:gap-6">
        
        <!-- Card 1: Total GMV -->
        <div class="bg-brand-surface rounded-2xl p-5 border border-brand-border shadow-xs hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Total GMV (Lunas)</span>
                <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary flex items-center justify-center">
                    <i data-lucide="wallet" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="mt-3">
                <h3 class="text-2xl font-black text-brand-text">Rp {{ number_format($totalGmv, 0, ',', '.') }}</h3>
                <p class="text-xs text-brand-success font-medium mt-1 flex items-center gap-1">
                    <i data-lucide="trending-up" class="w-3.5 h-3.5"></i>
                    <span>+14.8% dari bulan lalu</span>
                </p>
            </div>
        </div>

        <!-- Card 2: Pesanan Aktif -->
        <div class="bg-brand-surface rounded-2xl p-5 border border-brand-border shadow-xs hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Pesanan Berjalan</span>
                <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary flex items-center justify-center">
                    <i data-lucide="activity" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="mt-3">
                <h3 class="text-2xl font-black text-brand-text">{{ $pesananAktif }} <span class="text-xs font-normal text-brand-muted">pesanan</span></h3>
                <p class="text-xs text-brand-muted mt-1">
                    Total {{ $totalPesanan }} pesanan terdaftar
                </p>
            </div>
        </div>

        <!-- Card 3: Mitra Aktif & Online -->
        <div class="bg-brand-surface rounded-2xl p-5 border border-brand-border shadow-xs hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Mitra Terdaftar</span>
                <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary flex items-center justify-center">
                    <i data-lucide="hard-hat" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="mt-3">
                <h3 class="text-2xl font-black text-brand-text">{{ $mitraAktif }} <span class="text-xs font-normal text-brand-muted">mitra</span></h3>
                <p class="text-xs text-brand-muted mt-1 flex items-center gap-1">
                    <span class="w-2 h-2 rounded-full bg-brand-success inline-block"></span>
                    <span class="text-brand-success font-semibold">{{ $mitraOnline }} online</span> saat ini
                </p>
            </div>
        </div>

        <!-- Card 4: Etalase Jasa Marketplace -->
        <div class="bg-brand-surface rounded-2xl p-5 border border-brand-border shadow-xs hover:shadow-md transition-shadow">
            <div class="flex items-center justify-between">
                <span class="text-xs font-semibold text-brand-muted uppercase tracking-wider">Etalase Marketplace</span>
                <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary flex items-center justify-center">
                    <i data-lucide="layers" class="w-5 h-5"></i>
                </div>
            </div>
            <div class="mt-3">
                <h3 class="text-2xl font-black text-brand-text">{{ $listingAktif }} <span class="text-xs font-normal text-brand-muted">layanan aktif</span></h3>
                <p class="text-xs text-brand-muted mt-1">
                    Dari total {{ $totalListingJasa }} katalog jasa mitra
                </p>
            </div>
        </div>

    </div>

    <!-- Charts Row -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        <!-- Left: Line Chart Tren Booking & Pendapatan -->
        <div class="lg:col-span-2 bg-white rounded-2xl p-6 border border-brand-border shadow-xs">
            <div class="flex items-center justify-between mb-4">
                <div>
                    <h3 class="font-bold text-brand-text text-base">Tren Booking Jasa & Pendapatan</h3>
                    <p class="text-xs text-brand-muted">Statistik performa transaksi platform 6 bulan terakhir</p>
                </div>
                <span class="px-2.5 py-1 rounded-lg bg-brand-surfaceLow text-brand-text text-xs font-semibold">
                    Tahun 2026
                </span>
            </div>
            <div class="h-64 sm:h-72 w-full">
                <canvas id="revenueChart"></canvas>
            </div>
        </div>

        <!-- Right: Donut Chart Kategori Populer -->
        <div class="bg-brand-surface rounded-2xl p-6 border border-brand-border shadow-xs flex flex-col justify-between">
            <div>
                <h3 class="font-bold text-brand-text text-base">Kategori Terpopuler</h3>
                <p class="text-xs text-brand-muted mb-4">Sebaran pemesanan jasa per kategori</p>
                <div class="h-48 relative flex items-center justify-center">
                    @if(count($topKategoriData) > 0)
                        <canvas id="categoryChart"></canvas>
                    @else
                        <div class="flex flex-col items-center justify-center text-center text-brand-muted">
                            <i data-lucide="pie-chart" class="w-8 h-8 mb-2 opacity-40"></i>
                            <p class="text-xs">Belum ada pesanan jasa</p>
                        </div>
                    @endif
                </div>
            </div>
            <div class="mt-4 pt-4 border-t border-brand-border space-y-2">
                @forelse($topKategoriList as $kat)
                    <div class="flex items-center justify-between text-xs">
                        <span class="flex items-center gap-1.5 truncate max-w-[70%]">
                            <span class="w-2.5 h-2.5 rounded-full shrink-0" style="background-color: {{ $kat['color'] }}"></span>
                            <span class="truncate">{{ $kat['nama'] }}</span>
                        </span>
                        <span class="font-bold text-brand-text">{{ $kat['persen'] }}% <span class="text-[10px] text-brand-muted font-normal">({{ $kat['total'] }})</span></span>
                    </div>
                @empty
                    <p class="text-xs text-brand-muted text-center py-2">Belum ada pesanan per kategori</p>
                @endforelse
            </div>
        </div>

    </div>

    <!-- 2 Column Section: Pesanan Terbaru & Antrean Mitra Pending -->
    <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
        
        <!-- Left: Pesanan Direct Booking Terbaru (2 Cols) -->
        <div class="lg:col-span-2 bg-brand-surface rounded-2xl border border-brand-border shadow-xs overflow-hidden">
            <div class="p-5 border-b border-brand-border flex items-center justify-between">
                <div>
                    <h3 class="font-bold text-brand-text text-base">Pesanan Terkini (Direct Booking)</h3>
                    <p class="text-xs text-brand-muted">Daftar booking langsung dari pelanggan ke mitra pilihan</p>
                </div>
                <a href="{{ route('admin.pesanan.index') }}" class="text-xs font-bold text-brand-primary hover:underline flex items-center gap-1">
                    <span>Lihat Semua</span>
                    <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
                </a>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs">
                    <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                        <tr>
                            <th class="px-5 py-3">ID & Layanan</th>
                            <th class="px-5 py-3">Pelanggan</th>
                            <th class="px-5 py-3">Mitra Terpilih</th>
                            <th class="px-5 py-3">Biaya Kunjungan</th>
                            <th class="px-5 py-3">Status</th>
                            <th class="px-5 py-3 text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-brand-border">
                        @forelse($recentOrders as $ord)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="px-5 py-3.5 font-medium text-brand-text">
                                    <span class="font-bold text-brand-primary">#KTK-{{ $ord->id_pesanan }}</span>
                                    <p class="text-brand-muted text-[11px]">{{ $ord->kategori->nama_katagori ?? 'Layanan' }}</p>
                                </td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">
                                    {{ $ord->pengguna->nama ?? 'Pelanggan' }}
                                </td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">
                                    {{ $ord->mitra->nama ?? 'Belum Ditentukan' }}
                                </td>
                                <td class="px-5 py-3.5 text-brand-text font-semibold">
                                    Rp {{ number_format($ord->biaya_kunjungan ?? 50000, 0, ',', '.') }}
                                </td>
                                <td class="px-5 py-3.5">
                                    <span class="px-2.5 py-1 rounded-full text-[11px] font-bold border bg-brand-surfaceLow text-brand-text border-brand-border">
                                        {{ ucfirst(str_replace('_', ' ', $ord->status)) }}
                                    </span>
                                </td>
                                <td class="px-5 py-3.5 text-right">
                                    <a href="{{ route('admin.pesanan.show', $ord->id_pesanan) }}" 
                                       class="p-1.5 rounded-lg text-brand-muted hover:text-brand-text hover:bg-gray-100 inline-flex">
                                       <i data-lucide="eye" class="w-4 h-4"></i>
                                    </a>
                                </td>
                            </tr>
                        @empty
                            <tr class="hover:bg-gray-50/50">
                                <td class="px-5 py-3.5 font-medium text-brand-text">
                                    <span class="font-bold text-brand-primary">#KTK-1092</span>
                                    <p class="text-brand-muted text-[11px]">Perbaikan AC Split</p>
                                </td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">Budi Prasetyo</td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">Agus Hendra (Teknisi AC)</td>
                                <td class="px-5 py-3.5 text-brand-text font-semibold">Rp 50.000</td>
                                <td class="px-5 py-3.5">
                                    <span class="px-2.5 py-1 rounded-full text-[11px] font-bold border bg-brand-surfaceLow text-brand-text border-brand-border">
                                        Diproses
                                    </span>
                                </td>
                                <td class="px-5 py-3.5 text-right">
                                    <a href="{{ route('admin.pesanan.index') }}" class="text-brand-text font-bold text-xs hover:underline">Detail</a>
                                </td>
                            </tr>
                            <tr class="hover:bg-gray-50/50">
                                <td class="px-5 py-3.5 font-medium text-brand-text">
                                    <span class="font-bold text-brand-primary">#KTK-1093</span>
                                    <p class="text-brand-muted text-[11px]">Instalasi Titik Listrik</p>
                                </td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">Siti Rahma</td>
                                <td class="px-5 py-3.5 text-brand-text font-medium">Dedi Kurniawan</td>
                                <td class="px-5 py-3.5 text-brand-text font-semibold">Rp 50.000</td>
                                <td class="px-5 py-3.5">
                                    <span class="px-2.5 py-1 rounded-full text-[11px] font-bold border bg-brand-surfaceLow text-brand-text border-brand-border">
                                        Estimasi Biaya
                                    </span>
                                </td>
                                <td class="px-5 py-3.5 text-right">
                                    <a href="{{ route('admin.pesanan.index') }}" class="text-brand-text font-bold text-xs hover:underline">Detail</a>
                                </td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Right: Antrean Verifikasi Dokumen Calon Mitra (1 Col) -->
        <div class="bg-brand-surface rounded-2xl border border-brand-border shadow-xs p-5 flex flex-col justify-between">
            <div>
                <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Antrean Mitra Baru</h3>
                        <p class="text-xs text-brand-muted">Verifikasi berkas KTP & Keahlian</p>
                    </div>
                    <span class="px-2 py-0.5 rounded bg-brand-surfaceLow text-brand-text font-bold text-xs border border-brand-border">
                        {{ $pendingVerifikasi }} Pending
                    </span>
                </div>

                <div class="mt-4 space-y-3">
                    @forelse($recentApplications as $app)
                        <div class="p-3.5 rounded-xl border border-brand-border bg-gray-50/60 hover:bg-gray-50 transition-colors">
                            <div class="flex items-start justify-between gap-2">
                                <div>
                                    <p class="text-xs font-bold text-brand-text">{{ $app->nama ?? 'Calon Mitra' }}</p>
                                    <p class="text-[11px] text-brand-muted">{{ $app->mitraProfil->kategori->nama_katagori ?? ($app->mitraProfil->sub_kategori ?? ($app->mitraProfil->nama_usaha ?? 'Keahlian belum diatur')) }}</p>
                                    <p class="text-[10px] text-brand-muted mt-0.5">{{ $app->email ?? '-' }}</p>
                                </div>
                                @if($app->mitraProfil && $app->mitraProfil->foto_ktp)
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 shrink-0">
                                        KTP Ada
                                    </span>
                                @else
                                    <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200 shrink-0">
                                        Menunggu KTP
                                    </span>
                                @endif
                            </div>
                            <div class="mt-3 flex items-center gap-2">
                                <form action="{{ route('admin.mitra.approve_verification', $app->id_user) }}" method="POST" class="inline">
                                    @csrf
                                    <button type="submit" class="px-2.5 py-1 bg-brand-primary hover:bg-brand-darkSec text-white rounded-lg text-[11px] font-semibold transition-colors cursor-pointer">
                                        Setujui
                                    </button>
                                </form>
                                <a href="{{ route('admin.mitra.show', $app->id_user) }}" class="px-2.5 py-1 bg-brand-surfaceLow hover:bg-gray-200 text-brand-text rounded-lg text-[11px] font-semibold transition-colors border border-brand-border">
                                    Tinjau Berkas
                                </a>
                            </div>
                        </div>
                    @empty
                        <div class="p-6 rounded-xl border border-dashed border-brand-border text-center">
                            <div class="w-8 h-8 rounded-full bg-emerald-50 text-emerald-600 flex items-center justify-center mx-auto mb-2">
                                <i data-lucide="check" class="w-4 h-4"></i>
                            </div>
                            <p class="text-xs font-bold text-brand-text">Tidak Ada Antrean</p>
                            <p class="text-[11px] text-brand-muted mt-0.5">Semua pendaftaran dan verifikasi telah diproses.</p>
                        </div>
                    @endforelse
                </div>
            </div>

            <div class="mt-4 pt-3 border-t border-brand-border text-center">
                <a href="{{ route('admin.mitra.index') }}" class="text-xs font-bold text-brand-primary hover:underline inline-flex items-center gap-1">
                    <span>Kelola Semua Mitra</span>
                    <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
                </a>
            </div>
        </div>

    </div>

</div>
@endsection

@push('scripts')
<script>
    document.addEventListener('DOMContentLoaded', () => {
        const brandPrimary = getComputedStyle(document.documentElement).getPropertyValue('--color-brand-primary').trim() || '#030813';
        const brandMuted = getComputedStyle(document.documentElement).getPropertyValue('--color-brand-muted').trim() || '#76777C';

        // Line Chart: Revenue & Booking Trend (Monochrome Ketok)
        const ctxRev = document.getElementById('revenueChart');
        if (ctxRev) {
            new Chart(ctxRev, {
                type: 'line',
                data: {
                    labels: @json($trendMonths),
                    datasets: [{
                        label: 'Pendapatan (Rp)',
                        data: @json($trendRevenue),
                        borderColor: brandPrimary,
                        backgroundColor: 'rgba(3, 8, 19, 0.04)',
                        borderWidth: 2.5,
                        fill: true,
                        tension: 0.3,
                        pointRadius: 4,
                        pointBackgroundColor: brandPrimary,
                        yAxisID: 'y',
                    }, {
                        label: 'Volume Pesanan',
                        data: @json($trendOrders),
                        borderColor: brandMuted,
                        backgroundColor: 'transparent',
                        borderWidth: 1.5,
                        borderDash: [4, 4],
                        tension: 0.3,
                        pointRadius: 3,
                        pointBackgroundColor: brandMuted,
                        yAxisID: 'y1',
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    interaction: {
                        mode: 'index',
                        intersect: false,
                    },
                    plugins: {
                        legend: {
                            position: 'top',
                            labels: {
                                font: { family: 'Plus Jakarta Sans', size: 11 },
                                usePointStyle: true,
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    if (context.datasetIndex === 0) {
                                        return ` Pendapatan: Rp ${new Intl.NumberFormat('id-ID').format(context.raw)}`;
                                    }
                                    return ` Volume Pesanan: ${context.raw} pesanan`;
                                }
                            }
                        }
                    },
                    scales: {
                        y: {
                            type: 'linear',
                            display: true,
                            position: 'left',
                            beginAtZero: true,
                            grid: { color: '#F1F5F9' },
                            ticks: {
                                font: { family: 'Plus Jakarta Sans', size: 10 },
                                callback: function(value) {
                                    if (value >= 1000000) return (value / 1000000) + 'jt';
                                    if (value >= 1000) return (value / 1000) + 'rb';
                                    return value;
                                }
                            }
                        },
                        y1: {
                            type: 'linear',
                            display: true,
                            position: 'right',
                            beginAtZero: true,
                            grid: { drawOnChartArea: false },
                            ticks: {
                                font: { family: 'Plus Jakarta Sans', size: 10 },
                                precision: 0,
                                stepSize: 1
                            }
                        },
                        x: {
                            grid: { display: false },
                            ticks: { font: { family: 'Plus Jakarta Sans', size: 10 } }
                        }
                    }
                }
            });
        }

        // Donut Chart: Kategori Populer (Monochrome Shades)
        const ctxCat = document.getElementById('categoryChart');
        if (ctxCat) {
            const catLabels = @json($topKategoriLabels);
            const catData = @json($topKategoriData);
            const catColors = @json($topKategoriColors);

            if (catData && catData.length > 0) {
                new Chart(ctxCat, {
                    type: 'doughnut',
                    data: {
                        labels: catLabels,
                        datasets: [{
                            data: catData,
                            backgroundColor: catColors,
                            borderWidth: 0,
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        cutout: '72%',
                        plugins: {
                            legend: { display: false },
                            tooltip: {
                                callbacks: {
                                    label: function(context) {
                                        return ` ${context.label}: ${context.raw}%`;
                                    }
                                }
                            }
                        }
                    }
                });
            }
        }
    });
</script>
@endpush
