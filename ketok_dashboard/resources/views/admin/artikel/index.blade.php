@extends('layouts.admin')

@section('title', 'Tips & Panduan SOP Mitra')
@section('page_title', 'Artikel & SOP Mitra')

@section('content')
<div class="space-y-6" x-data="{ 
    addModalOpen: false, 
    editModalOpen: false, 
    previewModalOpen: false,
    currentArtikel: {
        id_artikel: '',
        judul: '',
        ringkasan: '',
        isi: '',
        gambar_url: '',
        aktif: true,
        dibuat_pada: ''
    }
}">

    <!-- Ringkasan Metrik Artikel -->
    <div class="grid grid-cols-1 sm:grid-cols-3 gap-4">
        <!-- 1. Total Artikel -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold shrink-0">
                <i data-lucide="book-open" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Total Artikel & SOP</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($totalArtikel ?? 0) }}</p>
                <p class="text-[10px] text-brand-muted mt-0.5">Panduan untuk mitra</p>
            </div>
        </div>

        <!-- 2. Artikel Tayang -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="check-circle" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Sedang Tayang</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($tayangCount ?? 0) }}</p>
                <p class="text-[10px] text-emerald-600 font-semibold mt-0.5">Tampil di aplikasi mitra</p>
            </div>
        </div>

        <!-- 3. Draft / Nonaktif -->
        <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex items-center gap-4">
            <div class="w-12 h-12 rounded-2xl bg-gray-100 text-gray-600 border border-gray-200 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="file-text" class="w-6 h-6"></i>
            </div>
            <div>
                <p class="text-xs text-brand-muted font-medium">Draft / Disimpan</p>
                <p class="text-xl font-extrabold text-brand-text">{{ number_format($draftCount ?? 0) }}</p>
                <p class="text-[10px] text-brand-muted mt-0.5">Belum dipublikasikan</p>
            </div>
        </div>
    </div>

    <!-- Toolbar & Filter -->
    <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <form method="GET" action="{{ route('admin.artikel.index') }}" class="flex flex-wrap items-center gap-2.5">
            <!-- Filter Status -->
            <select name="status" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Status</option>
                <option value="tayang" {{ request('status') === 'tayang' ? 'selected' : '' }}>Tayang ({{ $tayangCount ?? 0 }})</option>
                <option value="draft" {{ request('status') === 'draft' ? 'selected' : '' }}>Draft ({{ $draftCount ?? 0 }})</option>
            </select>

            <!-- Search Bar -->
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari judul / ringkasan artikel..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-64">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>
        </form>

        <button @click="addModalOpen = true" class="px-4 py-2 rounded-xl bg-brand-primary text-white font-semibold text-xs hover:bg-black transition-colors flex items-center gap-2 shadow-xs shrink-0 cursor-pointer">
            <i data-lucide="plus" class="w-4 h-4 text-white"></i>
            <span>Tulis Tips / SOP Baru</span>
        </button>
    </div>

    <!-- Table Daftar Artikel & SOP -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Artikel & Panduan</th>
                        <th class="px-5 py-3.5">Tanggal Rilis</th>
                        <th class="px-5 py-3.5">Status Tayang</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($artikels as $art)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <!-- Judul & Ringkasan -->
                            <td class="px-5 py-4 max-w-md">
                                <div class="flex items-start gap-3">
                                    @if($art->gambar_url)
                                        <img src="{{ $art->gambar_url }}" alt="{{ $art->judul }}" 
                                             class="w-12 h-12 rounded-xl object-cover border border-brand-border shrink-0 bg-gray-50"
                                             onerror="this.onerror=null; this.src=''; this.classList.add('hidden');">
                                    @else
                                        <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs shrink-0">
                                            <i data-lucide="file-text" class="w-5 h-5 text-brand-muted"></i>
                                        </div>
                                    @endif
                                    <div>
                                        <p class="font-bold text-brand-text text-sm hover:underline cursor-pointer"
                                           @click="currentArtikel = {{ json_encode($art) }}; previewModalOpen = true">
                                            {{ $art->judul }}
                                        </p>
                                        <p class="text-[11px] text-brand-muted mt-0.5 line-clamp-2 leading-relaxed">
                                            {{ $art->ringkasan }}
                                        </p>
                                    </div>
                                </div>
                            </td>

                            <!-- Tanggal Rilis -->
                            <td class="px-5 py-4 whitespace-nowrap text-brand-muted">
                                <div class="flex items-center gap-1.5">
                                    <i data-lucide="calendar" class="w-3.5 h-3.5 text-brand-muted"></i>
                                    <span>{{ $art->dibuat_pada ? date('d M Y', strtotime($art->dibuat_pada)) : 'Baru saja' }}</span>
                                </div>
                            </td>

                            <!-- Status Tayang -->
                            <td class="px-5 py-4 whitespace-nowrap">
                                @if($art->aktif)
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 inline-flex items-center gap-1">
                                        <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Tayang
                                    </span>
                                @else
                                    <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-gray-100 text-gray-500 border border-gray-200 inline-flex items-center gap-1">
                                        <span class="w-1.5 h-1.5 rounded-full bg-gray-400"></span> Draft / Nonaktif
                                    </span>
                                @endif
                            </td>

                            <!-- Aksi / Opsi Dropdown -->
                            <td class="px-5 py-4 text-right whitespace-nowrap">
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
                                            <!-- Pratinjau Detail -->
                                            <button type="button" 
                                                    @click="dropdownOpen = false; currentArtikel = {{ json_encode($art) }}; previewModalOpen = true"
                                                    class="w-full flex items-center gap-2 px-3.5 py-2 text-brand-text hover:bg-gray-50 transition-colors font-medium">
                                                <i data-lucide="eye" class="w-3.5 h-3.5 text-brand-muted"></i>
                                                <span>Lihat Detail</span>
                                            </button>

                                            <!-- Edit Konten -->
                                            <button type="button" 
                                                    @click="dropdownOpen = false; currentArtikel = {{ json_encode($art) }}; editModalOpen = true"
                                                    class="w-full flex items-center gap-2 px-3.5 py-2 text-brand-text hover:bg-gray-50 transition-colors font-medium">
                                                <i data-lucide="edit-3" class="w-3.5 h-3.5 text-brand-muted"></i>
                                                <span>Edit Artikel</span>
                                            </button>
                                        </div>

                                        <div class="py-1">
                                            <!-- Toggle Status Tayang / Draft -->
                                            <form action="{{ route('admin.artikel.toggle', $art->id_artikel) }}" method="POST">
                                                @csrf
                                                <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 {{ $art->aktif ? 'text-amber-600 hover:bg-amber-50' : 'text-emerald-600 hover:bg-emerald-50' }} transition-colors font-medium">
                                                    @if($art->aktif)
                                                        <i data-lucide="pause-circle" class="w-3.5 h-3.5"></i>
                                                        <span>Jadikan Draft</span>
                                                    @else
                                                        <i data-lucide="play-circle" class="w-3.5 h-3.5"></i>
                                                        <span>Tayangkan</span>
                                                    @endif
                                                </button>
                                            </form>

                                            <!-- Hapus Artikel -->
                                            <form action="{{ route('admin.artikel.destroy', $art->id_artikel) }}" method="POST"
                                                  data-confirm-title="Hapus Artikel"
                                                  data-confirm-message="Apakah Anda yakin ingin menghapus artikel '{{ $art->judul }}'?"
                                                  data-confirm-button="Ya, Hapus"
                                                  data-confirm-type="danger">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 text-rose-600 hover:bg-rose-50 transition-colors font-medium">
                                                    <i data-lucide="trash-2" class="w-3.5 h-3.5"></i>
                                                    <span>Hapus Artikel</span>
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-8 text-center text-brand-muted">
                                Tidak ada data artikel atau panduan SOP ditemukan.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($artikels->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $artikels->links() }}
            </div>
        @endif
    </div>

    <!-- Modal Pratinjau Detail Artikel -->
    <div x-show="previewModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-xl w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="previewModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2">
                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold"
                          :class="currentArtikel.aktif ? 'bg-emerald-50 text-emerald-700 border border-emerald-200' : 'bg-gray-100 text-gray-500 border border-gray-200'"
                          x-text="currentArtikel.aktif ? 'Tayang' : 'Draft / Nonaktif'"></span>
                    <span class="text-xs text-brand-muted" x-text="currentArtikel.dibuat_pada ? currentArtikel.dibuat_pada.substring(0, 10) : ''"></span>
                </div>
                <button @click="previewModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <div class="mt-4 space-y-4">
                <template x-if="currentArtikel.gambar_url">
                    <div class="rounded-2xl overflow-hidden border border-brand-border max-h-56 bg-gray-50">
                        <img :src="currentArtikel.gambar_url" alt="Header" class="w-full h-full object-cover">
                    </div>
                </template>

                <div>
                    <h2 class="text-lg font-bold text-brand-text" x-text="currentArtikel.judul"></h2>
                    <p class="text-xs text-brand-muted mt-1 italic" x-text="currentArtikel.ringkasan"></p>
                </div>

                <div class="p-4 rounded-2xl bg-gray-50/75 border border-brand-border text-xs text-brand-text leading-relaxed whitespace-pre-line" x-text="currentArtikel.isi"></div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="previewModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Tutup</button>
                    <button type="button" @click="previewModalOpen = false; editModalOpen = true" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-primary text-white hover:bg-black">Edit Konten</button>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal Tambah Artikel -->
    <div x-show="addModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="addModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="plus-circle" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Tulis Tips / SOP Baru</h3>
                        <p class="text-[11px] text-brand-muted">Publikasikan panduan materi baru untuk mitra</p>
                    </div>
                </div>
                <button @click="addModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form action="{{ route('admin.artikel.store') }}" method="POST" class="mt-4 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Judul Artikel / SOP</label>
                    <input type="text" name="judul" required placeholder="Cth: Standar Keselamatan Kerja (K3) Tukang" class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Ringkasan Singkat</label>
                    <textarea name="ringkasan" rows="2" required placeholder="Ringkasan 1-2 kalimat untuk pratinjau daftar..." class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Isi Lengkap Panduan</label>
                    <textarea name="isi" rows="6" required placeholder="Tuliskan materi panduan lengkap langkah demi langkah..." class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">URL Gambar Header (Opsional)</label>
                    <input type="url" name="gambar_url" placeholder="https://..." class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>

                <div class="flex items-center gap-2 pt-1">
                    <input type="checkbox" name="aktif" value="1" id="aktif_add" checked class="rounded border-brand-border text-brand-dark focus:ring-brand-dark">
                    <label for="aktif_add" class="text-xs font-medium text-brand-text">Langsung publikasikan (Tayang di aplikasi mitra)</label>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="addModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-primary text-white hover:bg-black shadow-xs">Publikasikan</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Artikel -->
    <div x-show="editModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="editModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="edit-3" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Edit Artikel / SOP</h3>
                        <p class="text-[11px] text-brand-muted">Perbarui isi konten dan status artikel</p>
                    </div>
                </div>
                <button @click="editModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form :action="'/admin/artikel/' + currentArtikel.id_artikel" method="POST" class="mt-4 space-y-4">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Judul Artikel</label>
                    <input type="text" name="judul" :value="currentArtikel.judul" required class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Ringkasan</label>
                    <textarea name="ringkasan" rows="2" :value="currentArtikel.ringkasan" required class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Isi Lengkap</label>
                    <textarea name="isi" rows="6" :value="currentArtikel.isi" required class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">URL Gambar</label>
                    <input type="url" name="gambar_url" :value="currentArtikel.gambar_url" class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>

                <div class="flex items-center gap-2 pt-1">
                    <input type="checkbox" name="aktif" value="1" id="aktif_edit" :checked="currentArtikel.aktif" class="rounded border-brand-border text-brand-dark focus:ring-brand-dark">
                    <label for="aktif_edit" class="text-xs font-medium text-brand-text">Status Tayang (Aktif di aplikasi mitra)</label>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="editModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-primary text-white hover:bg-black shadow-xs">Simpan Perubahan</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
