@extends('layouts.admin')

@section('title', 'Wilayah Operasional')
@section('page_title', 'Wilayah Operasional')

@section('content')
<div class="space-y-6" x-data="{ 
    addModalOpen: false, 
    editModalOpen: false, 
    
    // Add Form State
    addTipe: 'kelurahan',
    addProvinsi: '',
    addKota: '',
    addKecamatan: '',
    addNama: '',

    // Edit Form State
    editId: null,
    editTipe: 'kelurahan',
    editProvinsi: '',
    editKota: '',
    editKecamatan: '',
    editNama: '',

    // Master Data from DB
    allWilayah: {{ json_encode($allWilayah) }},

    // Computed / Helper Lists
    get provinsiList() {
        const set = new Set();
        this.allWilayah.filter(w => w.tipe === 'provinsi').forEach(w => set.add(w.nama));
        return Array.from(set).sort();
    },

    get kotaListAdd() {
        const set = new Set();
        this.allWilayah.filter(w => {
            if (w.tipe !== 'kota') return false;
            if (this.addProvinsi && w.parent_nama && w.parent_nama.toLowerCase() !== this.addProvinsi.toLowerCase()) return false;
            return true;
        }).forEach(w => set.add(w.nama));
        return Array.from(set).sort();
    },

    get kecamatanListAdd() {
        const set = new Set();
        this.allWilayah.filter(w => {
            if (w.tipe !== 'kecamatan') return false;
            if (this.addKota && w.parent_nama && w.parent_nama.toLowerCase() !== this.addKota.toLowerCase()) return false;
            return true;
        }).forEach(w => set.add(w.nama));
        return Array.from(set).sort();
    },

    get kotaListEdit() {
        const set = new Set();
        this.allWilayah.filter(w => {
            if (w.tipe !== 'kota') return false;
            if (this.editProvinsi && w.parent_nama && w.parent_nama.toLowerCase() !== this.editProvinsi.toLowerCase()) return false;
            return true;
        }).forEach(w => set.add(w.nama));
        return Array.from(set).sort();
    },

    get kecamatanListEdit() {
        const set = new Set();
        this.allWilayah.filter(w => {
            if (w.tipe !== 'kecamatan') return false;
            if (this.editKota && w.parent_nama && w.parent_nama.toLowerCase() !== this.editKota.toLowerCase()) return false;
            return true;
        }).forEach(w => set.add(w.nama));
        return Array.from(set).sort();
    },

    openAddModal(defaultTipe = 'kelurahan') {
        this.addTipe = defaultTipe;
        this.addProvinsi = '';
        this.addKota = '';
        this.addKecamatan = '';
        this.addNama = '';
        this.addModalOpen = true;
    },

    openEditModal(wil) {
        this.editId = wil.id_wilayah;
        this.editTipe = wil.tipe;
        this.editNama = wil.nama;
        this.editProvinsi = '';
        this.editKota = '';
        this.editKecamatan = '';

        if (wil.tipe === 'kota') {
            this.editProvinsi = wil.parent_nama || '';
        } else if (wil.tipe === 'kecamatan') {
            this.editKota = wil.parent_nama || '';
            const parentKota = this.allWilayah.find(w => w.tipe === 'kota' && w.nama.toLowerCase() === this.editKota.toLowerCase());
            if (parentKota) this.editProvinsi = parentKota.parent_nama || '';
        } else if (wil.tipe === 'kelurahan') {
            this.editKecamatan = wil.parent_nama || '';
            const parentKec = this.allWilayah.find(w => w.tipe === 'kecamatan' && w.nama.toLowerCase() === this.editKecamatan.toLowerCase());
            if (parentKec) {
                this.editKota = parentKec.parent_nama || '';
                const parentKota = this.allWilayah.find(w => w.tipe === 'kota' && w.nama.toLowerCase() === this.editKota.toLowerCase());
                if (parentKota) this.editProvinsi = parentKota.parent_nama || '';
            }
        }

        this.editModalOpen = true;
    }
}">

    <!-- Ringkasan Metrik Wilayah -->
    <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-5 gap-3.5">
        <!-- 1. Total Wilayah -->
        <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold shrink-0">
                <i data-lucide="map" class="w-5 h-5"></i>
            </div>
            <div>
                <p class="text-[11px] text-brand-muted font-medium">Total Wilayah</p>
                <p class="text-lg font-extrabold text-brand-text">{{ number_format($totalWilayah ?? 0) }}</p>
            </div>
        </div>

        <!-- 2. Provinsi -->
        <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-indigo-50 text-indigo-600 border border-indigo-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="globe" class="w-5 h-5"></i>
            </div>
            <div>
                <p class="text-[11px] text-brand-muted font-medium">Provinsi</p>
                <p class="text-lg font-extrabold text-brand-text">{{ number_format($provinsiCount ?? 0) }}</p>
            </div>
        </div>

        <!-- 3. Kota / Kab -->
        <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-sky-50 text-sky-600 border border-sky-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="building-2" class="w-5 h-5"></i>
            </div>
            <div>
                <p class="text-[11px] text-brand-muted font-medium">Kota / Kab</p>
                <p class="text-lg font-extrabold text-brand-text">{{ number_format($kotaCount ?? 0) }}</p>
            </div>
        </div>

        <!-- 4. Kecamatan -->
        <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-emerald-50 text-emerald-600 border border-emerald-100 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="navigation" class="w-5 h-5"></i>
            </div>
            <div>
                <p class="text-[11px] text-brand-muted font-medium">Kecamatan</p>
                <p class="text-lg font-extrabold text-brand-text">{{ number_format($kecamatanCount ?? 0) }}</p>
            </div>
        </div>

        <!-- 5. Kelurahan -->
        <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex items-center gap-3">
            <div class="w-10 h-10 rounded-xl bg-slate-100 text-slate-600 border border-slate-200 flex items-center justify-center font-bold shrink-0">
                <i data-lucide="map-pin" class="w-5 h-5"></i>
            </div>
            <div>
                <p class="text-[11px] text-brand-muted font-medium">Kelurahan / Desa</p>
                <p class="text-lg font-extrabold text-brand-text">{{ number_format($kelurahanCount ?? 0) }}</p>
            </div>
        </div>
    </div>

    <!-- Toolbar & Filter -->
    <div class="bg-white p-4 rounded-2xl border border-brand-border shadow-xs flex flex-col sm:flex-row sm:items-center justify-between gap-3">
        <form method="GET" action="{{ route('admin.wilayah.index') }}" class="flex flex-wrap items-center gap-2.5">
            <!-- Filter Tingkat / Tipe -->
            <select name="tipe" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium focus:ring-2 focus:ring-brand-dark focus:outline-none">
                <option value="">Semua Tingkat</option>
                <option value="provinsi" {{ request('tipe') === 'provinsi' ? 'selected' : '' }}>Provinsi ({{ $provinsiCount ?? 0 }})</option>
                <option value="kota" {{ request('tipe') === 'kota' ? 'selected' : '' }}>Kota / Kabupaten ({{ $kotaCount ?? 0 }})</option>
                <option value="kecamatan" {{ request('tipe') === 'kecamatan' ? 'selected' : '' }}>Kecamatan ({{ $kecamatanCount ?? 0 }})</option>
                <option value="kelurahan" {{ request('tipe') === 'kelurahan' ? 'selected' : '' }}>Kelurahan / Desa ({{ $kelurahanCount ?? 0 }})</option>
            </select>

            <!-- Search Bar -->
            <div class="relative">
                <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama wilayah atau induk..." 
                       class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-64">
                <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
            </div>
        </form>

        <button @click="openAddModal('kelurahan')" class="px-4 py-2 rounded-xl bg-brand-primary text-white font-semibold text-xs hover:bg-black transition-colors flex items-center gap-2 shadow-xs shrink-0 cursor-pointer">
            <i data-lucide="plus" class="w-4 h-4 text-white"></i>
            <span>Tambah Wilayah Baru</span>
        </button>
    </div>

    <!-- Table Wilayah -->
    <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-left text-xs">
                <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                    <tr>
                        <th class="px-5 py-3.5">Nama Wilayah</th>
                        <th class="px-5 py-3.5">Tingkat / Tipe</th>
                        <th class="px-5 py-3.5">Wilayah Induk (Parent)</th>
                        <th class="px-5 py-3.5 text-right">Aksi</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-brand-border">
                    @forelse($wilayahList as $wil)
                        <tr class="hover:bg-gray-50/50 transition-colors">
                            <td class="px-5 py-4 font-bold text-brand-text">
                                <div class="flex items-center gap-2">
                                    @if($wil->tipe === 'provinsi')
                                        <i data-lucide="globe" class="w-4 h-4 text-indigo-600"></i>
                                    @elseif($wil->tipe === 'kota')
                                        <i data-lucide="building-2" class="w-4 h-4 text-sky-600"></i>
                                    @elseif($wil->tipe === 'kecamatan')
                                        <i data-lucide="navigation" class="w-4 h-4 text-emerald-600"></i>
                                    @else
                                        <i data-lucide="map-pin" class="w-4 h-4 text-slate-500"></i>
                                    @endif
                                    <span>{{ $wil->nama }}</span>
                                </div>
                            </td>
                            <td class="px-5 py-4">
                                @if($wil->tipe === 'provinsi')
                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-indigo-50 text-indigo-700 border border-indigo-200">
                                        Provinsi
                                    </span>
                                @elseif($wil->tipe === 'kota')
                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-sky-50 text-sky-700 border border-sky-200">
                                        Kota / Kab
                                    </span>
                                @elseif($wil->tipe === 'kecamatan')
                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-emerald-50 text-emerald-700 border border-emerald-200">
                                        Kecamatan
                                    </span>
                                @else
                                    <span class="px-2.5 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wider bg-slate-100 text-slate-700 border border-slate-200">
                                        Kelurahan
                                    </span>
                                @endif
                            </td>
                            <td class="px-5 py-4 text-brand-muted">
                                @if($wil->parent_nama)
                                    <span class="font-medium text-brand-text">{{ $wil->parent_nama }}</span>
                                @else
                                    <span class="text-gray-400 italic">- (Tingkat Teratas)</span>
                                @endif
                            </td>
                            <td class="px-5 py-4 text-right">
                                <div class="flex items-center justify-end gap-1.5">
                                    <button @click="openEditModal({{ json_encode($wil) }})" 
                                            class="p-1.5 rounded-lg text-brand-muted hover:text-brand-text hover:bg-gray-100 transition-colors"
                                            title="Edit Wilayah">
                                        <i data-lucide="edit-2" class="w-4 h-4"></i>
                                    </button>
                                    <form action="{{ route('admin.wilayah.destroy', $wil->id_wilayah) }}" method="POST"
                                          data-confirm-title="Hapus Wilayah Operasional"
                                          data-confirm-message="Apakah Anda yakin ingin menghapus wilayah {{ $wil->nama }}?"
                                          data-confirm-button="Ya, Hapus"
                                          data-confirm-type="danger">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="p-1.5 rounded-lg text-rose-500 hover:text-rose-700 hover:bg-rose-50 transition-colors" title="Hapus">
                                            <i data-lucide="trash-2" class="w-4 h-4"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="4" class="px-5 py-8 text-center text-brand-muted">Tidak ada data wilayah ditemukan.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>

        @if($wilayahList->hasPages())
            <div class="p-4 border-t border-brand-border">
                {{ $wilayahList->links() }}
            </div>
        @endif
    </div>

    <!-- Modal Tambah Wilayah Baru -->
    <div x-show="addModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="addModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="plus-circle" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Tambah Wilayah Baru</h3>
                        <p class="text-[11px] text-brand-muted">Tambah cakupan wilayah operasional layanan</p>
                    </div>
                </div>
                <button @click="addModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form action="{{ route('admin.wilayah.store') }}" method="POST" class="mt-4 space-y-4">
                @csrf

                <!-- 1. TINGKAT / TIPE WILAYAH (Paling Atas) -->
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Tingkat / Tipe Wilayah</label>
                    <select name="tipe" x-model="addTipe" required class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none font-semibold">
                        <option value="kelurahan">Kelurahan / Desa</option>
                        <option value="kecamatan">Kecamatan</option>
                        <option value="kota">Kota / Kabupaten</option>
                        <option value="provinsi">Provinsi</option>
                    </select>
                </div>

                <!-- 2. FIELD PROVINSI (Jika Kelurahan, Kecamatan, atau Kota) -->
                <div x-show="['kelurahan', 'kecamatan', 'kota'].includes(addTipe)">
                    <label class="block text-xs font-semibold text-brand-text mb-1">
                        Provinsi
                        <span class="text-rose-500">*</span>
                    </label>
                    <input type="text" name="provinsi" x-model="addProvinsi" list="provinsi_list_add"
                           placeholder="Pilih atau ketik nama provinsi (Cth: Jawa Timur)"
                           :required="['kelurahan', 'kecamatan', 'kota'].includes(addTipe)"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="provinsi_list_add">
                        <template x-for="p in provinsiList" :key="p">
                            <option :value="p"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 3. FIELD KOTA / KABUPATEN (Jika Kelurahan atau Kecamatan) -->
                <div x-show="['kelurahan', 'kecamatan'].includes(addTipe)">
                    <label class="block text-xs font-semibold text-brand-text mb-1">
                        Kota / Kabupaten
                        <span class="text-rose-500">*</span>
                    </label>
                    <input type="text" name="kota" x-model="addKota" list="kota_list_add"
                           placeholder="Pilih atau ketik nama kota (Cth: Kota Malang, Surabaya)"
                           :required="['kelurahan', 'kecamatan'].includes(addTipe)"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="kota_list_add">
                        <template x-for="k in kotaListAdd" :key="k">
                            <option :value="k"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 4. FIELD KECAMATAN (Jika Kelurahan) -->
                <div x-show="addTipe === 'kelurahan'">
                    <label class="block text-xs font-semibold text-brand-text mb-1">
                        Kecamatan
                        <span class="text-rose-500">*</span>
                    </label>
                    <input type="text" name="kecamatan" x-model="addKecamatan" list="kecamatan_list_add"
                           placeholder="Pilih atau ketik nama kecamatan (Cth: Lowokwaru)"
                           :required="addTipe === 'kelurahan'"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="kecamatan_list_add">
                        <template x-for="c in kecamatanListAdd" :key="c">
                            <option :value="c"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 5. NAMA WILAYAH YANG DITAMBAHKAN -->
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">
                        <span x-text="addTipe === 'kelurahan' ? 'Nama Kelurahan / Desa' : (addTipe === 'kecamatan' ? 'Nama Kecamatan' : (addTipe === 'kota' ? 'Nama Kota / Kabupaten' : 'Nama Provinsi'))"></span>
                        <span class="text-rose-500">*</span>
                    </label>
                    <input type="text" name="nama" x-model="addNama" required 
                           :placeholder="addTipe === 'kelurahan' ? 'Cth: Dinoyo, Jatimulyo, Tulusrejo' : (addTipe === 'kecamatan' ? 'Cth: Lowokwaru, Klojen, Blimbing' : (addTipe === 'kota' ? 'Cth: Kota Malang, Surabaya, Kota Batu' : 'Cth: Jawa Timur, Jawa Tengah'))" 
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none font-medium">
                    <p class="text-[11px] text-brand-muted mt-1">
                        <span x-show="addTipe === 'kelurahan'">Sistem akan otomatis menghubungkan kelurahan ini ke kecamatan, kota, dan provinsi terkait.</span>
                        <span x-show="addTipe === 'kecamatan'">Sistem akan otomatis menghubungkan kecamatan ini ke kota dan provinsi terkait.</span>
                        <span x-show="addTipe === 'kota'">Sistem akan otomatis menghubungkan kota ini ke provinsi terkait.</span>
                        <span x-show="addTipe === 'provinsi'">Provinsi adalah tingkat wilayah tertinggi.</span>
                    </p>
                </div>

                <div class="pt-3 border-t border-brand-border flex justify-end gap-2">
                    <button type="button" @click="addModalOpen = false" class="px-4 py-2 rounded-xl text-xs font-semibold text-brand-muted hover:bg-gray-100">Batal</button>
                    <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-brand-primary text-white hover:bg-black shadow-xs">Simpan Wilayah</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Modal Edit Wilayah -->
    <div x-show="editModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-md w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="editModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="edit-3" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Edit Data Wilayah</h3>
                        <p class="text-[11px] text-brand-muted">Perbarui nama atau keterkaitan wilayah</p>
                    </div>
                </div>
                <button @click="editModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <form :action="'/admin/wilayah/' + editId" method="POST" class="mt-4 space-y-4">
                @csrf
                @method('PUT')

                <!-- 1. TINGKAT / TIPE WILAYAH -->
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">Tingkat / Tipe Wilayah</label>
                    <select name="tipe" x-model="editTipe" required class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none font-semibold">
                        <option value="kelurahan">Kelurahan / Desa</option>
                        <option value="kecamatan">Kecamatan</option>
                        <option value="kota">Kota / Kabupaten</option>
                        <option value="provinsi">Provinsi</option>
                    </select>
                </div>

                <!-- 2. FIELD PROVINSI -->
                <div x-show="['kelurahan', 'kecamatan', 'kota'].includes(editTipe)">
                    <label class="block text-xs font-semibold text-brand-text mb-1">Provinsi</label>
                    <input type="text" name="provinsi" x-model="editProvinsi" list="provinsi_list_edit"
                           placeholder="Pilih atau ketik nama provinsi"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="provinsi_list_edit">
                        <template x-for="p in provinsiList" :key="p">
                            <option :value="p"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 3. FIELD KOTA / KABUPATEN -->
                <div x-show="['kelurahan', 'kecamatan'].includes(editTipe)">
                    <label class="block text-xs font-semibold text-brand-text mb-1">Kota / Kabupaten</label>
                    <input type="text" name="kota" x-model="editKota" list="kota_list_edit"
                           placeholder="Pilih atau ketik nama kota"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="kota_list_edit">
                        <template x-for="k in kotaListEdit" :key="k">
                            <option :value="k"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 4. FIELD KECAMATAN -->
                <div x-show="editTipe === 'kelurahan'">
                    <label class="block text-xs font-semibold text-brand-text mb-1">Kecamatan</label>
                    <input type="text" name="kecamatan" x-model="editKecamatan" list="kecamatan_list_edit"
                           placeholder="Pilih atau ketik nama kecamatan"
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    <datalist id="kecamatan_list_edit">
                        <template x-for="c in kecamatanListEdit" :key="c">
                            <option :value="c"></option>
                        </template>
                    </datalist>
                </div>

                <!-- 5. NAMA WILAYAH -->
                <div>
                    <label class="block text-xs font-semibold text-brand-text mb-1">
                        <span x-text="editTipe === 'kelurahan' ? 'Nama Kelurahan / Desa' : (editTipe === 'kecamatan' ? 'Nama Kecamatan' : (editTipe === 'kota' ? 'Nama Kota / Kabupaten' : 'Nama Provinsi'))"></span>
                    </label>
                    <input type="text" name="nama" x-model="editNama" required 
                           class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none font-medium">
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
