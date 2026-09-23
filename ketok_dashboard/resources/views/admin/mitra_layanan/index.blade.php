@extends('layouts.admin')

@section('title', 'Etalase Jasa Mitra')
@section('page_title', 'Marketplace & Jasa Mitra')

@section('content')
<div class="space-y-6" x-data="{ detailModalOpen: false, currentListing: {} }">

    <!-- Header & Filter -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-white p-5 rounded-2xl border border-brand-border shadow-xs">
        <div>
            <h2 class="text-xl font-bold text-brand-text">Etalase Jasa Mitra di Marketplace</h2>
            <p class="text-xs text-brand-muted mt-0.5">Daftar seluruh layanan yang dipublikasikan oleh mitra dan dapat dipesan langsung oleh pelanggan.</p>
        </div>

        <form method="GET" action="{{ route('admin.mitra_layanan.index') }}" class="flex flex-wrap items-center gap-2.5">
            <select name="kategori_id" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Kategori</option>
                @foreach($kategoriList as $kat)
                    <option value="{{ $kat->id_katagori }}" {{ request('kategori_id') == $kat->id_katagori ? 'selected' : '' }}>
                        {{ $kat->nama_katagori }}
                    </option>
                @endforeach
            </select>

            <select name="status" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Status</option>
                <option value="aktif" {{ request('status') === 'aktif' ? 'selected' : '' }}>Aktif</option>
                <option value="nonaktif" {{ request('status') === 'nonaktif' ? 'selected' : '' }}>Nonaktif</option>
            </select>

            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari jasa / mitra..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-44 sm:w-56">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>
        </form>
    </div>

    <!-- Table Listing -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Layanan & Foto</th>
                        <th class="px-5 py-3.5">Mitra / Usaha</th>
                        <th class="px-5 py-3.5">Kategori</th>
                        <th class="px-5 py-3.5">Tarif Mulai</th>
                        <th class="px-5 py-3.5">Biaya Kunjungan</th>
                        <th class="px-5 py-3.5">Status</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($listings as $item)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow border border-brand-border flex items-center justify-center text-brand-primary font-bold overflow-hidden shrink-0">
                                        @if($item->foto_url)
                                            <img src="{{ $item->foto_url }}" alt="" class="w-full h-full object-cover">
                                        @else
                                            <i data-lucide="wrench" class="w-5 h-5"></i>
                                        @endif
                                    </div>
                                    <div>
                                        <p class="font-bold text-brand-text">{{ $item->nama_jasa ?? $item->kategori->nama_katagori ?? 'Layanan' }}</p>
                                        <p class="text-[11px] text-brand-muted truncate max-w-xs">{{ $item->deskripsi ?? 'Tidak ada deskripsi' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4 font-medium text-brand-text">
                                {{ $item->mitra->nama ?? 'Mitra Ketok' }}
                                <p class="text-[11px] text-brand-muted">{{ $item->mitra->email ?? '-' }}</p>
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2 py-0.5 rounded-md bg-gray-100 text-brand-text font-medium text-[11px]">
                                    {{ $item->kategori->nama_katagori ?? '-' }}
                                </span>
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                Rp {{ number_format($item->tarif_mulai ?? 0, 0, ',', '.') }}
                                <span class="text-[10px] text-brand-muted font-normal">/ {{ $item->satuan_tarif ?? 'layanan' }}</span>
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                Rp {{ number_format($item->biaya_kunjungan ?? 50000, 0, ',', '.') }}
                            </td>
                            <td class="px-5 py-4">
                                <form action="{{ route('admin.mitra_layanan.toggle', $item->id_layanan_mitra) }}" method="POST">
                                    @csrf
                                    <button type="submit" class="px-2.5 py-1 rounded-full text-[11px] font-bold border transition-colors {{ $item->aktif ? 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100' : 'bg-gray-100 text-gray-500 border-gray-200 hover:bg-gray-200' }}">
                                        {{ $item->aktif ? '● Aktif' : '○ Nonaktif' }}
                                    </button>
                                </form>
                            </td>
                            <td class="px-5 py-4 text-right">
                                <div class="flex items-center justify-end gap-1.5">
                                    <button @click="currentListing = {{ json_encode($item) }}; detailModalOpen = true" 
                                            class="p-1.5 rounded-lg text-brand-muted hover:text-brand-text hover:bg-gray-100" title="Lihat Detail Layanan">
                                        <i data-lucide="eye" class="w-4 h-4"></i>
                                    </button>
                                    <form action="{{ route('admin.mitra_layanan.destroy', $item->id_layanan_mitra) }}" method="POST"
                                          data-confirm-title="Hapus Layanan Marketplace"
                                          data-confirm-message="Apakah Anda yakin ingin menghapus layanan ini dari marketplace?"
                                          data-confirm-button="Ya, Hapus"
                                          data-confirm-type="danger">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50" title="Hapus Layanan">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="7" class="px-5 py-8 text-center text-brand-muted">
                                Tidak ada etalase jasa yang ditemukan.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($listings->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $listings->links() }}
            </div>
        @endif
    </div>

    <!-- Modal Detail Layanan Jasa Mitra (Read-Only) -->
    <div x-show="detailModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-brand-border relative overflow-hidden" @click.away="detailModalOpen = false">
            
            <!-- Modal Header -->
            <div class="flex items-center justify-between pb-4 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-brand-primary text-white flex items-center justify-center font-bold text-xs shadow-xs">
                        <i data-lucide="store" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Detail Jasa Mitra</h3>
                        <p class="text-[11px] text-brand-muted">Informasi lengkap listing layanan mitra di marketplace Ketok</p>
                    </div>
                </div>
                <button @click="detailModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100 transition-colors">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <!-- Modal Content (Read-Only) -->
            <div class="mt-5 space-y-4 max-h-[70vh] overflow-y-auto pr-1 custom-scrollbar">
                
                <!-- Foto Banner / Thumbnail -->
                <div class="w-full h-44 rounded-2xl bg-gray-100 border border-brand-border overflow-hidden relative flex items-center justify-center">
                    <template x-if="currentListing.foto_url">
                        <img :src="currentListing.foto_url" alt="" class="w-full h-full object-cover">
                    </template>
                    <template x-if="!currentListing.foto_url">
                        <div class="flex flex-col items-center justify-center text-brand-muted gap-1.5">
                            <i data-lucide="image" class="w-8 h-8 opacity-40"></i>
                            <span class="text-xs">Tidak ada foto layanan</span>
                        </div>
                    </template>
                    
                    <!-- Status Badge Floating -->
                    <div class="absolute top-3 right-3">
                        <span class="px-3 py-1 rounded-full text-[11px] font-bold shadow-sm"
                              :class="currentListing.aktif ? 'bg-emerald-500 text-white' : 'bg-gray-500 text-white'"
                              x-text="currentListing.aktif ? '● Aktif di Marketplace' : '○ Nonaktif'">
                        </span>
                    </div>
                </div>

                <!-- Info Utama: Nama Jasa & Kategori -->
                <div>
                    <div class="flex items-center gap-2 mb-1">
                        <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-brand-surfaceLow text-brand-primary border border-brand-border"
                              x-text="currentListing.kategori ? currentListing.kategori.nama_katagori : 'Kategori Layanan'">
                        </span>
                    </div>
                    <h4 class="text-lg font-extrabold text-brand-text" x-text="currentListing.nama_jasa"></h4>
                    <p class="text-xs text-brand-muted mt-1 leading-relaxed" x-text="currentListing.deskripsi || 'Mitra belum menyertakan deskripsi rinci untuk layanan ini.'"></p>
                </div>

                <!-- Pricing Box -->
                <div class="grid grid-cols-2 gap-3 p-3.5 rounded-2xl bg-gray-50/80 border border-brand-border text-xs">
                    <div>
                        <p class="text-[11px] text-brand-muted font-medium">Tarif Mulai</p>
                        <p class="text-sm font-extrabold text-brand-text mt-0.5">
                            Rp <span x-text="Number(currentListing.tarif_mulai || 0).toLocaleString('id-ID')"></span>
                        </p>
                        <p class="text-[10px] text-brand-muted" x-text="'/ ' + (currentListing.satuan_tarif || 'layanan')"></p>
                    </div>
                    <div>
                        <p class="text-[11px] text-brand-muted font-medium">Biaya Kunjungan / Transport</p>
                        <p class="text-sm font-extrabold text-brand-text mt-0.5">
                            Rp <span x-text="Number(currentListing.biaya_kunjungan || 0).toLocaleString('id-ID')"></span>
                        </p>
                        <p class="text-[10px] text-brand-muted">tarif datang ke lokasi</p>
                    </div>
                </div>

                <!-- Mitra Info Box -->
                <div class="p-3.5 rounded-2xl bg-white border border-brand-border text-xs">
                    <p class="text-[11px] font-bold text-brand-text uppercase tracking-wider mb-2">Penyedia Jasa (Mitra)</p>
                    <div class="flex items-center gap-3">
                        <div class="w-9 h-9 rounded-xl bg-brand-surfaceLow text-brand-primary font-bold flex items-center justify-center border border-brand-border shrink-0 text-xs"
                             x-text="currentListing.mitra ? currentListing.mitra.nama.substring(0, 1).toUpperCase() : 'M'">
                        </div>
                        <div class="min-w-0 flex-1">
                            <p class="font-bold text-brand-text truncate" x-text="currentListing.mitra ? currentListing.mitra.nama : 'Mitra Ketok'"></p>
                            <p class="text-[11px] text-brand-muted truncate" x-text="currentListing.mitra ? currentListing.mitra.email : '-'"></p>
                        </div>
                    </div>
                </div>

            </div>

            <!-- Modal Footer -->
            <div class="mt-6 pt-4 border-t border-brand-border flex items-center justify-between">
                <span class="text-[11px] text-brand-muted">Mode Pratinjau Admin (Read-Only)</span>
                <button type="button" @click="detailModalOpen = false" class="px-5 py-2 rounded-xl text-xs font-semibold bg-brand-primary text-white hover:bg-black transition-colors">
                    Tutup
                </button>
            </div>

        </div>
    </div>

</div>
@endsection
