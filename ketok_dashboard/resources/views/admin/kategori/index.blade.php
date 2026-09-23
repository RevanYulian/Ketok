@extends('layouts.admin')

@section('title', 'Kategori Layanan')
@section('page_title', 'Kategori Layanan')

@section('content')
<div class="space-y-6" x-data="{ 
    searchKategori: '',
    filterKelompok: '',
    addKelompokOpen: false,
    addKategoriOpen: false,
    editKategoriOpen: false,
    currentKategori: {}
}">

    <!-- Header & Action Buttons -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 bg-white p-5 rounded-2xl border border-brand-border shadow-xs">
        <div>
            <div class="flex items-center gap-2 mb-1">
                <h2 class="text-xl font-bold text-brand-text">Kategori Layanan Marketplace</h2>
                <span class="px-2.5 py-0.5 rounded-full text-xs font-bold bg-brand-surfaceLow text-brand-primary border border-brand-border">
                    {{ $kategoriList->count() }} Kategori
                </span>
            </div>
            <p class="text-xs text-brand-muted">Daftar kategori dan kelompok utama sebagai wadah etalase jasa yang ditawarkan oleh mitra.</p>
        </div>

        <!-- Dua Tombol Aksi: Tambah Kategori Utama & Tambah Kategori Baru -->
        <div class="flex flex-wrap items-center gap-2.5 shrink-0">
            <!-- 1. Tombol Tambah Kategori Utama Baru -->
            <button @click="addKelompokOpen = true" class="px-4 py-2 rounded-xl bg-white border border-brand-border text-brand-text font-bold text-xs hover:bg-gray-50 transition-colors flex items-center justify-center gap-2 shadow-xs cursor-pointer">
                <i data-lucide="plus" class="w-4 h-4 text-brand-muted"></i>
                <span>Kategori Utama Baru</span>
            </button>

            <!-- 2. Tombol Tambah Kategori Layanan Baru -->
            <button @click="addKategoriOpen = true" class="px-4 py-2 rounded-xl bg-brand-dark text-white font-bold text-xs hover:bg-black transition-colors flex items-center justify-center gap-2 shadow-xs cursor-pointer">
                <i data-lucide="plus" class="w-4 h-4 text-white"></i>
                <span>Kategori Baru</span>
            </button>
        </div>
    </div>

    <!-- Filter & Search Toolbar -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-3 bg-white p-4 rounded-2xl border border-brand-border shadow-xs">
        <div class="flex flex-wrap items-center gap-2.5 flex-1">
            
            <!-- Search Bar -->
            <div class="relative flex-1 sm:max-w-xs">
                <input type="text" 
                       x-model="searchKategori" 
                       placeholder="Cari kategori atau kelompok..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-full">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>

            <!-- Filter Kelompok -->
            <select x-model="filterKelompok" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Kategori Utama</option>
                @foreach($kelompokList as $klp)
                    <option value="{{ $klp->nama_kelompok }}">{{ $klp->nama_kelompok }}</option>
                @endforeach
            </select>

            <button x-show="searchKategori || filterKelompok" 
                    @click="searchKategori = ''; filterKelompok = ''" 
                    class="text-xs text-brand-muted hover:text-brand-text underline transition-colors"
                    x-cloak>
                Reset Filter
            </button>
        </div>
    </div>

    <!-- Table Listing Kategori -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Kategori Layanan</th>
                        <th class="px-5 py-3.5">Kelompok / Kategori Utama</th>
                        <th class="px-5 py-3.5">Mitra Penyedia Aktif</th>
                        <th class="px-5 py-3.5">Total Pesanan</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($kategoriList as $kat)
                        <tr class="hover:bg-gray-50/50 transition-colors"
                            x-show="(!searchKategori || '{{ strtolower(addslashes($kat->nama_katagori . ' ' . $kat->kelompok . ' ' . $kat->deskripsi)) }}'.includes(searchKategori.toLowerCase())) && (!filterKelompok || '{{ addslashes($kat->kelompok) }}' === filterKelompok)">
                            <td class="px-5 py-4">
                                <div class="flex items-center gap-3">
                                    <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow border border-brand-border flex items-center justify-center text-brand-primary font-bold shrink-0">
                                        <i data-lucide="layers" class="w-5 h-5"></i>
                                    </div>
                                    <div class="min-w-0">
                                        <p class="font-bold text-brand-text">{{ $kat->nama_katagori }}</p>
                                        <p class="text-[11px] text-brand-muted truncate max-w-md">{{ $kat->deskripsi ?? 'Tidak ada deskripsi layanan.' }}</p>
                                    </div>
                                </div>
                            </td>
                            <td class="px-5 py-4">
                                <span class="px-2.5 py-1 rounded-full text-[10px] font-bold uppercase tracking-wider bg-brand-surfaceLow text-brand-primary border border-brand-border">
                                    {{ $kat->kelompok ?? 'Umum' }}
                                </span>
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                {{ $kat->mitra_layanan_count ?? 0 }} <span class="text-[10px] text-brand-muted font-normal">mitra penyedia</span>
                            </td>
                            <td class="px-5 py-4 font-semibold text-brand-text">
                                {{ $kat->pesanan_count ?? 0 }} <span class="text-[10px] text-brand-muted font-normal">booking</span>
                            </td>
                            <td class="px-5 py-4 text-right">
                                <div class="flex items-center justify-end gap-1.5">
                                    <button @click="currentKategori = {{ json_encode($kat) }}; editKategoriOpen = true" 
                                            class="p-1.5 rounded-lg text-brand-muted hover:text-brand-text hover:bg-gray-100" title="Edit Kategori">
                                        <i data-lucide="edit-2" class="w-4 h-4"></i>
                                    </button>
                                    <form action="{{ route('admin.kategori.destroy', $kat->id_katagori) }}" method="POST"
                                          data-confirm-title="Hapus Kategori Layanan"
                                          data-confirm-message="Apakah Anda yakin ingin menghapus kategori '{{ $kat->nama_kategori }}'?"
                                          data-confirm-button="Ya, Hapus"
                                          data-confirm-type="danger">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50" title="Hapus Kategori">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="5" class="px-5 py-8 text-center text-brand-muted">
                                Belum ada data kategori layanan.
                            </td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <!-- MODAL 1: Tambah Kategori Utama Baru -->
    <div x-show="addKelompokOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border" @click.away="addKelompokOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="folder-plus" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Tambah Kategori Utama Baru</h3>
                        <p class="text-[11px] text-brand-muted">Buat kelompok utama untuk menaungi kategori layanan</p>
                    </div>
                </div>
                <button @click="addKelompokOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form action="{{ route('admin.kategori.store_kelompok') }}" method="POST" class="mt-4 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Nama Kategori Utama</label>
                    <input type="text" name="nama_kelompok" required placeholder="Cth: Otomotif & Kendaraan, Acara & Katering" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <p class="text-[10px] text-brand-muted mt-1">Kategori utama ini nantinya akan menaungi berbagai sub-kategori layanan di aplikasi.</p>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="addKelompokOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Simpan Kategori Utama</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 2: Tambah Kategori Layanan Baru (Pilih Kategori Utama yang Ada) -->
    <div x-show="addKategoriOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border" @click.away="addKategoriOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-brand-primary text-white flex items-center justify-center font-bold text-xs shadow-xs">
                        <i data-lucide="plus" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Tambah Kategori Baru</h3>
                        <p class="text-[11px] text-brand-muted">Tambahkan kategori di bawah kategori utama</p>
                    </div>
                </div>
                <button @click="addKategoriOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form action="{{ route('admin.kategori.store') }}" method="POST" class="mt-4 space-y-4">
                @csrf
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Pilih Kategori Utama</label>
                    <select name="kelompok" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        <option value="">-- Pilih Kategori Utama --</option>
                        @foreach($kelompokList as $klp)
                            <option value="{{ $klp->nama_kelompok }}">{{ $klp->nama_kelompok }}</option>
                        @endforeach
                    </select>
                    <p class="text-[10px] text-brand-muted mt-1">Pilih kategori utama yang menaungi kategori ini.</p>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Nama Kategori Baru</label>
                    <input type="text" name="nama_katagori" required placeholder="Cth: Servis AC, Sedot WC, Tukang Kunci" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Deskripsi Layanan (Opsional)</label>
                    <textarea name="deskripsi" rows="3" placeholder="Deskripsi singkat jenis kategori layanan..." class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="addKategoriOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Simpan Kategori</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 3: Edit Kategori -->
    <div x-show="editKategoriOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border" @click.away="editKategoriOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <h3 class="font-bold text-brand-text text-base">Edit Data Kategori</h3>
                <button @click="editKategoriOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form :action="'/admin/kategori/' + currentKategori.id_katagori" method="POST" class="mt-4 space-y-4">
                @csrf
                @method('PUT')
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Nama Kategori</label>
                    <input type="text" name="nama_katagori" :value="currentKategori.nama_katagori" required class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 focus:ring-2 focus:ring-brand-dark focus:outline-none">
                </div>

                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Kategori Utama / Kelompok</label>
                    <select name="kelompok" x-model="currentKategori.kelompok" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2.5 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        <option value="">-- Pilih Kategori Utama --</option>
                        @foreach($kelompokList as $klp)
                            <option value="{{ $klp->nama_kelompok }}">{{ $klp->nama_kelompok }}</option>
                        @endforeach
                    </select>
                    <p class="text-[10px] text-brand-muted mt-1">Pilih kategori utama untuk menaungi kategori ini.</p>
                </div>

                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Deskripsi</label>
                    <textarea name="deskripsi" rows="3" :value="currentKategori.deskripsi" class="w-full text-xs rounded-xl border border-brand-border px-3 py-2 focus:ring-2 focus:ring-brand-dark focus:outline-none"></textarea>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="editKategoriOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-4 py-2 rounded-xl text-xs font-semibold bg-brand-dark text-white hover:bg-black">Perbarui Kategori</button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
