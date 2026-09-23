@extends('layouts.admin')

@section('title', 'Moderasi Ulasan & Rating')
@section('page_title', 'Ulasan Pelanggan')

@section('content')
<div class="space-y-6">

    <!-- Header & Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 sm:gap-6">
        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs sm:col-span-2 flex flex-col justify-between">
            <div>
                <h2 class="text-xl font-bold text-brand-text">Moderasi Ulasan & Penilaian Pelanggan</h2>
                <p class="text-xs text-brand-muted mt-1">Pantau umpan balik pengguna terhadap mitra dan kualitas layanan. Hapus komentar yang melanggar norma / spam.</p>
            </div>
            <div class="mt-4 flex items-center gap-2">
                <a href="{{ route('admin.ulasan.index') }}" class="px-3 py-1.5 rounded-lg text-xs font-semibold {{ !request('rating') ? 'bg-brand-primary text-white' : 'bg-gray-100 text-brand-muted hover:text-brand-text' }}">Semua</a>
                @for($i = 5; $i >= 1; $i--)
                    <a href="{{ route('admin.ulasan.index', ['rating' => $i]) }}" class="px-3 py-1.5 rounded-lg text-xs font-semibold {{ request('rating') == $i ? 'bg-brand-primary text-white' : 'bg-gray-100 text-brand-muted hover:text-brand-text' }}">
                        ★ {{ $i }}
                    </a>
                @endfor
            </div>
        </div>

        <div class="bg-white rounded-2xl p-5 border border-brand-border shadow-xs flex flex-col items-center justify-center text-center">
            <span class="text-3xl font-black text-brand-primary flex items-center gap-1.5">
                <i data-lucide="star" class="w-7 h-7 fill-brand-primary text-brand-primary"></i>
                {{ number_format($avgRating, 1) }}
            </span>
            <p class="text-xs font-semibold text-brand-text mt-1">Rating Rata-rata Platform</p>
            <p class="text-[11px] text-brand-muted">Dari total {{ $totalReviews }} ulasan</p>
        </div>
    </div>

    <!-- Table Ulasan -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Pesanan</th>
                        <th class="px-5 py-3.5">Pelanggan</th>
                        <th class="px-5 py-3.5">Mitra</th>
                        <th class="px-5 py-3.5">Rating</th>
                        <th class="px-5 py-3.5">Komentar</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($reviews as $rev)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4 font-bold text-brand-primary">
                                #KTK-{{ $rev->pesanan_id }}
                            </td>
                            <td class="px-5 py-4 text-brand-text font-medium">
                                {{ $rev->pesanan->pengguna->nama ?? 'Pelanggan' }}
                            </td>
                            <td class="px-5 py-4 text-brand-text font-medium">
                                {{ $rev->pesanan->mitra->nama ?? 'Mitra' }}
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-1 rounded-full text-xs font-black bg-brand-surfaceLow text-brand-primary border border-brand-border inline-flex items-center gap-1">
                                    <i data-lucide="star" class="w-3.5 h-3.5 fill-brand-primary text-brand-primary"></i>
                                    {{ $rev->rating }}/5
                                </span>
                            </td>
                            <td class="px-5 py-4 text-brand-text max-w-sm">
                                "{{ $rev->komentar ?? 'Tidak ada komentar' }}"
                            </td>
                            <td class="px-5 py-4 text-right">
                                <form action="{{ route('admin.ulasan.destroy', $rev->id_ulasan) }}" method="POST"
                                      data-confirm-title="Hapus Ulasan Pelanggan"
                                      data-confirm-message="Apakah Anda yakin ingin menghapus ulasan ini dari sistem?"
                                      data-confirm-button="Ya, Hapus"
                                      data-confirm-type="danger">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50" title="Hapus Ulasan">
                                        <i data-lucide="trash-2" class="w-4 h-4"></i>
                                    </button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="6" class="px-5 py-8 text-center text-brand-muted">Tidak ada ulasan ditemukan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($reviews->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $reviews->links() }}
            </div>
        @endif
    </div>

</div>
@endsection
