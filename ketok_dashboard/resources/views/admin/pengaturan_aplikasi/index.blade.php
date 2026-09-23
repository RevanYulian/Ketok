@extends('layouts.admin')

@section('title', 'Tampilan & Branding Aplikasi')
@section('page_title', 'Tampilan & Branding')

@section('content')
<div class="space-y-6" x-data="{ 
    activeTab: '{{ session('active_tab', 'ketok_app') }}',
    
    // Preview states for Ketok App
    appLogoPreview: '{{ $ketokAppConfig->logo_url ? url($ketokAppConfig->logo_url) : asset('ketok.png') }}',
    appBannerPreview: '{{ $ketokAppConfig->banner_promo_url ? url($ketokAppConfig->banner_promo_url) : '' }}',
    appNama: '{{ addslashes($ketokAppConfig->nama_aplikasi) }}',
    appTagline: '{{ addslashes($ketokAppConfig->tagline ?? '') }}',
    appCs: '{{ addslashes($ketokAppConfig->kontak_cs ?? '') }}',
    appEmail: '{{ addslashes($ketokAppConfig->email_bantuan ?? '') }}',
    appVersi: '{{ addslashes($ketokAppConfig->versi_aplikasi ?? '1.0.0') }}',
    appMaintenance: {{ $ketokAppConfig->status_maintenance ? 'true' : 'false' }},

    // Preview states for Ketok Mitra
    mitraLogoPreview: '{{ $ketokMitraConfig->logo_url ? url($ketokMitraConfig->logo_url) : asset('ketok.png') }}',
    mitraBannerPreview: '{{ $ketokMitraConfig->banner_promo_url ? url($ketokMitraConfig->banner_promo_url) : '' }}',
    mitraNama: '{{ addslashes($ketokMitraConfig->nama_aplikasi) }}',
    mitraTagline: '{{ addslashes($ketokMitraConfig->tagline ?? '') }}',
    mitraCs: '{{ addslashes($ketokMitraConfig->kontak_cs ?? '') }}',
    mitraEmail: '{{ addslashes($ketokMitraConfig->email_bantuan ?? '') }}',
    mitraVersi: '{{ addslashes($ketokMitraConfig->versi_aplikasi ?? '1.0.0') }}',
    mitraMaintenance: {{ $ketokMitraConfig->status_maintenance ? 'true' : 'false' }},

    handleLogoChange(event, target) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                if (target === 'app') this.appLogoPreview = e.target.result;
                if (target === 'mitra') this.mitraLogoPreview = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    },

    handleBannerChange(event, target) {
        const file = event.target.files[0];
        if (file) {
            const reader = new FileReader();
            reader.onload = (e) => {
                if (target === 'app') this.appBannerPreview = e.target.result;
                if (target === 'mitra') this.mitraBannerPreview = e.target.result;
            };
            reader.readAsDataURL(file);
        }
    }
}">

    <!-- Header & Tab Switcher -->
    <div class="bg-white p-5 rounded-2xl border border-brand-border shadow-xs flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
        <div>
            <h2 class="text-xl font-bold text-brand-text">Tampilan & Branding Aplikasi</h2>
            <p class="text-xs text-brand-muted mt-0.5">Kelola logo, banner promosi, identitas brand, dan kontak bantuan secara terpisah.</p>
        </div>

        <!-- Tab Pills (Ketok App vs Ketok Mitra) -->
        <div class="flex items-center p-1 bg-gray-100 rounded-2xl border border-brand-border shrink-0">
            <button type="button" 
                    @click="activeTab = 'ketok_app'"
                    :class="activeTab === 'ketok_app' ? 'bg-white text-brand-text font-bold shadow-xs' : 'text-brand-muted hover:text-brand-text font-medium'"
                    class="flex items-center gap-2 px-4 py-2 rounded-xl text-xs transition-all cursor-pointer">
                <i data-lucide="smartphone" class="w-4 h-4"></i>
                <span>Ketok App</span>
            </button>

            <button type="button" 
                    @click="activeTab = 'ketok_mitra'"
                    :class="activeTab === 'ketok_mitra' ? 'bg-white text-brand-text font-bold shadow-xs' : 'text-brand-muted hover:text-brand-text font-medium'"
                    class="flex items-center gap-2 px-4 py-2 rounded-xl text-xs transition-all cursor-pointer">
                <i data-lucide="hard-hat" class="w-4 h-4"></i>
                <span>Ketok Mitra</span>
            </button>
        </div>
    </div>

    <!-- ========================================================================= -->
    <!-- TAB 1: KETOK APP (PELANGGAN) -->
    <!-- ========================================================================= -->
    <div x-show="activeTab === 'ketok_app'" x-cloak class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <!-- Kolom Pratinjau (Mockup) -->
        <div class="lg:col-span-4 space-y-4">
            <div class="bg-white rounded-2xl border border-brand-border p-5 shadow-xs sticky top-24">
                <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                    <span class="text-xs font-bold text-brand-text uppercase tracking-wider flex items-center gap-1.5">
                        <i data-lucide="eye" class="w-3.5 h-3.5 text-brand-muted"></i>
                        Pratinjau Ketok App
                    </span>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-bold"
                          :class="appMaintenance ? 'bg-rose-50 text-rose-700 border border-rose-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'"
                          x-text="appMaintenance ? 'Maintenance' : 'Aktif'"></span>
                </div>

                <!-- Phone Screen Simulation -->
                <div class="mt-4 rounded-2xl border-2 border-brand-border bg-gray-50 p-4 shadow-inner space-y-4">
                    <!-- App Bar / Brand Header -->
                    <div class="bg-white rounded-xl p-3 border border-brand-border shadow-xs flex items-center gap-3">
                        <div class="w-12 h-12 rounded-xl bg-black border border-white/20 overflow-hidden flex items-center justify-center shrink-0 p-1">
                            <img :src="appLogoPreview" alt="Logo" class="w-full h-full object-contain">
                        </div>
                        <div class="min-w-0">
                            <p class="font-extrabold text-sm text-brand-text truncate" x-text="appNama || 'Ketok'"></p>
                            <p class="text-[10px] text-brand-muted truncate" x-text="appTagline || 'Solusi Cepat Tukang Pertukangan'"></p>
                        </div>
                    </div>

                    <!-- Banner Promo Preview -->
                    <div>
                        <p class="text-[10px] font-bold text-brand-muted uppercase mb-1">Banner Beranda</p>
                        <div class="rounded-xl overflow-hidden border border-brand-border bg-gray-200 aspect-16/9 flex items-center justify-center relative">
                            <template x-if="appBannerPreview">
                                <img :src="appBannerPreview" alt="Banner" class="w-full h-full object-cover">
                            </template>
                            <template x-if="!appBannerPreview">
                                <div class="text-center p-3 text-gray-400">
                                    <i data-lucide="image" class="w-6 h-6 mx-auto mb-1 opacity-50"></i>
                                    <span class="text-[10px]">Belum ada banner promosi</span>
                                </div>
                            </template>
                        </div>
                    </div>

                    <!-- Kontak & Info -->
                    <div class="p-3 bg-white rounded-xl border border-brand-border space-y-1.5 text-[11px]">
                        <div class="flex items-center justify-between text-brand-muted">
                            <span>WhatsApp CS:</span>
                            <span class="font-bold text-brand-text font-mono" x-text="appCs || '-'"></span>
                        </div>
                        <div class="flex items-center justify-between text-brand-muted">
                            <span>Email Bantuan:</span>
                            <span class="font-medium text-brand-text truncate ml-2" x-text="appEmail || '-'"></span>
                        </div>
                        <div class="flex items-center justify-between text-brand-muted pt-1 border-t border-brand-border">
                            <span>Versi Rilis:</span>
                            <span class="font-mono text-brand-text font-bold" x-text="'v' + (appVersi || '1.0.0')"></span>
                        </div>
                    </div>
                </div>

                <p class="text-[11px] text-brand-muted text-center mt-3">
                    Pratinjau tampilan di atas diperbarui secara langsung mengikuti form.
                </p>
            </div>
        </div>

        <!-- Kolom Form Pengaturan -->
        <div class="lg:col-span-8">
            <form action="{{ route('admin.tampilan_aplikasi.update', 'ketok_app') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
                @csrf

                <!-- 1. Identitas Brand & Logo -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="image" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Logo & Identitas Ketok App</h3>
                            <p class="text-[11px] text-brand-muted">Atur nama aplikasi, tagline slogan, dan logo resmi</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Nama Aplikasi</label>
                            <input type="text" name="nama_aplikasi" x-model="appNama" value="{{ old('nama_aplikasi', $ketokAppConfig->nama_aplikasi) }}" required 
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>

                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Tagline / Slogan</label>
                            <input type="text" name="tagline" x-model="appTagline" value="{{ old('tagline', $ketokAppConfig->tagline) }}" 
                                   placeholder="Cth: Solusi Cepat Tukang Pertukangan Rumah"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Unggah Berkas Logo Baru (PNG/JPG/WEBP/SVG)</label>
                        <input type="file" name="logo_file" @change="handleLogoChange($event, 'app')" accept="image/*"
                               class="w-full text-xs text-brand-text file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-primary file:text-white hover:file:bg-black file:cursor-pointer border border-brand-border rounded-xl p-1 bg-white">
                        <p class="text-[11px] text-brand-muted mt-1">Rekomendasi rasio 1:1 (persegi), resolusi minimal 512x512 piksel.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Atau Gunakan URL Logo Langsung</label>
                        <input type="text" name="logo_url" x-model="appLogoPreview" value="{{ old('logo_url', $ketokAppConfig->logo_url) }}" placeholder="https://..."
                               class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>
                </div>

                <!-- 2. Banner Promosi Beranda -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="layout-template" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Banner Promosi Beranda</h3>
                            <p class="text-[11px] text-brand-muted">Banner yang tampil pada bagian atas beranda Ketok App pelanggan</p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Unggah Berkas Banner Baru</label>
                        <input type="file" name="banner_file" @change="handleBannerChange($event, 'app')" accept="image/*"
                               class="w-full text-xs text-brand-text file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-primary file:text-white hover:file:bg-black file:cursor-pointer border border-brand-border rounded-xl p-1 bg-white">
                        <p class="text-[11px] text-brand-muted mt-1">Rekomendasi rasio 16:9 atau landscape lebar.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Atau Gunakan URL Banner</label>
                        <input type="text" name="banner_promo_url" x-model="appBannerPreview" value="{{ old('banner_promo_url', $ketokAppConfig->banner_promo_url) }}" placeholder="https://..."
                               class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>
                </div>

                <!-- 3. Kontak Bantuan Customer Service -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="phone" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Kontak Bantuan & Layanan</h3>
                            <p class="text-[11px] text-brand-muted">Kontak yang dihubungi pelanggan saat menekan tombol bantuan</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Nomor WhatsApp Customer Service</label>
                            <input type="text" name="kontak_cs" x-model="appCs" value="{{ old('kontak_cs', $ketokAppConfig->kontak_cs) }}" placeholder="Cth: 081234567890"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>

                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Email Layanan Pelanggan</label>
                            <input type="email" name="email_bantuan" x-model="appEmail" value="{{ old('email_bantuan', $ketokAppConfig->email_bantuan) }}" placeholder="support@ketok.id"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>
                    </div>
                </div>

                <!-- 4. Versi & Mode Maintenance -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="shield-alert" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Versi Aplikasi & Status Pemeliharaan</h3>
                            <p class="text-[11px] text-brand-muted">Kontrol versi rilis dan mode maintenance darurat</p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Versi Aplikasi Terkini</label>
                        <input type="text" name="versi_aplikasi" x-model="appVersi" value="{{ old('versi_aplikasi', $ketokAppConfig->versi_aplikasi) }}" placeholder="1.0.0"
                               class="w-48 text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>

                    <div class="p-4 rounded-xl bg-gray-50 border border-brand-border space-y-3">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-xs font-bold text-brand-text">Mode Pemeliharaan (Maintenance)</p>
                                <p class="text-[11px] text-brand-muted">Jika diaktifkan, pengguna aplikasi Ketok App akan melihat layar pemeliharaan sistem.</p>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="status_maintenance" value="1" x-model="appMaintenance" class="sr-only peer">
                                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-rose-600"></div>
                            </label>
                        </div>

                        <div x-show="appMaintenance" class="pt-2 border-t border-brand-border">
                            <label class="block text-xs font-semibold text-brand-text mb-1">Pesan Pemeliharaan untuk Pengguna</label>
                            <textarea name="pesan_maintenance" rows="2" placeholder="Kami sedang meningkatkan layanan untuk pengalaman terbaik Anda..."
                                      class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">{{ old('pesan_maintenance', $ketokAppConfig->pesan_maintenance) }}</textarea>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end">
                    <button type="submit" class="px-6 py-3 rounded-xl bg-brand-primary text-white font-bold text-xs hover:bg-black transition-colors shadow-xs flex items-center gap-2 cursor-pointer">
                        <i data-lucide="check" class="w-4 h-4 text-white"></i>
                        <span>Simpan Pengaturan Ketok App</span>
                    </button>
                </div>
            </form>
        </div>
    </div>


    <!-- ========================================================================= -->
    <!-- TAB 2: KETOK MITRA (TUKANG) -->
    <!-- ========================================================================= -->
    <div x-show="activeTab === 'ketok_mitra'" x-cloak class="grid grid-cols-1 lg:grid-cols-12 gap-6">
        <!-- Kolom Pratinjau (Mockup) -->
        <div class="lg:col-span-4 space-y-4">
            <div class="bg-white rounded-2xl border border-brand-border p-5 shadow-xs sticky top-24">
                <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                    <span class="text-xs font-bold text-brand-text uppercase tracking-wider flex items-center gap-1.5">
                        <i data-lucide="eye" class="w-3.5 h-3.5 text-brand-muted"></i>
                        Pratinjau Ketok Mitra
                    </span>
                    <span class="px-2 py-0.5 rounded-full text-[10px] font-bold"
                          :class="mitraMaintenance ? 'bg-rose-50 text-rose-700 border border-rose-200' : 'bg-emerald-50 text-emerald-700 border border-emerald-200'"
                          x-text="mitraMaintenance ? 'Maintenance' : 'Aktif'"></span>
                </div>

                <!-- Phone Screen Simulation -->
                <div class="mt-4 rounded-2xl border-2 border-brand-border bg-gray-50 p-4 shadow-inner space-y-4">
                    <!-- App Bar / Brand Header -->
                    <div class="bg-brand-primary text-white rounded-xl p-3 border border-white/10 shadow-xs flex items-center gap-3">
                        <div class="w-12 h-12 rounded-xl bg-black border border-white/20 overflow-hidden flex items-center justify-center shrink-0 p-1">
                            <img :src="mitraLogoPreview" alt="Logo Mitra" class="w-full h-full object-contain">
                        </div>
                        <div class="min-w-0">
                            <p class="font-extrabold text-sm text-white truncate" x-text="mitraNama || 'Ketok Mitra'"></p>
                            <p class="text-[10px] text-gray-300 truncate" x-text="mitraTagline || 'Aplikasi Mitra Tukang Profesional'"></p>
                        </div>
                    </div>

                    <!-- Banner Info Mitra Preview -->
                    <div>
                        <p class="text-[10px] font-bold text-brand-muted uppercase mb-1">Banner Pengumuman Mitra</p>
                        <div class="rounded-xl overflow-hidden border border-brand-border bg-gray-200 aspect-16/9 flex items-center justify-center relative">
                            <template x-if="mitraBannerPreview">
                                <img :src="mitraBannerPreview" alt="Banner Mitra" class="w-full h-full object-cover">
                            </template>
                            <template x-if="!mitraBannerPreview">
                                <div class="text-center p-3 text-gray-400">
                                    <i data-lucide="image" class="w-6 h-6 mx-auto mb-1 opacity-50"></i>
                                    <span class="text-[10px]">Belum ada banner pengumuman</span>
                                </div>
                            </template>
                        </div>
                    </div>

                    <!-- Kontak & Info -->
                    <div class="p-3 bg-white rounded-xl border border-brand-border space-y-1.5 text-[11px]">
                        <div class="flex items-center justify-between text-brand-muted">
                            <span>CS Mitra (WhatsApp):</span>
                            <span class="font-bold text-brand-text font-mono" x-text="mitraCs || '-'"></span>
                        </div>
                        <div class="flex items-center justify-between text-brand-muted">
                            <span>Email Khusus Mitra:</span>
                            <span class="font-medium text-brand-text truncate ml-2" x-text="mitraEmail || '-'"></span>
                        </div>
                        <div class="flex items-center justify-between text-brand-muted pt-1 border-t border-brand-border">
                            <span>Versi Rilis:</span>
                            <span class="font-mono text-brand-text font-bold" x-text="'v' + (mitraVersi || '1.0.0')"></span>
                        </div>
                    </div>
                </div>

                <p class="text-[11px] text-brand-muted text-center mt-3">
                    Pratinjau tampilan di atas diperbarui secara langsung mengikuti form.
                </p>
            </div>
        </div>

        <!-- Kolom Form Pengaturan -->
        <div class="lg:col-span-8">
            <form action="{{ route('admin.tampilan_aplikasi.update', 'ketok_mitra') }}" method="POST" enctype="multipart/form-data" class="space-y-6">
                @csrf

                <!-- 1. Identitas Brand & Logo -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="hard-hat" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Logo & Identitas Ketok Mitra</h3>
                            <p class="text-[11px] text-brand-muted">Atur nama aplikasi, tagline, dan logo khusus aplikasi mitra tukang</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Nama Aplikasi</label>
                            <input type="text" name="nama_aplikasi" x-model="mitraNama" value="{{ old('nama_aplikasi', $ketokMitraConfig->nama_aplikasi) }}" required 
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>

                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Tagline / Slogan Mitra</label>
                            <input type="text" name="tagline" x-model="mitraTagline" value="{{ old('tagline', $ketokMitraConfig->tagline) }}" 
                                   placeholder="Cth: Aplikasi Khusus Tukang & Mitra Profesional"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Unggah Berkas Logo Mitra Baru (PNG/JPG/WEBP/SVG)</label>
                        <input type="file" name="logo_file" @change="handleLogoChange($event, 'mitra')" accept="image/*"
                               class="w-full text-xs text-brand-text file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-primary file:text-white hover:file:bg-black file:cursor-pointer border border-brand-border rounded-xl p-1 bg-white">
                        <p class="text-[11px] text-brand-muted mt-1">Rekomendasi rasio 1:1 (persegi), resolusi minimal 512x512 piksel.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Atau Gunakan URL Logo Langsung</label>
                        <input type="text" name="logo_url" x-model="mitraLogoPreview" value="{{ old('logo_url', $ketokMitraConfig->logo_url) }}" placeholder="https://..."
                               class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>
                </div>

                <!-- 2. Banner Pengumuman Mitra -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="megaphone" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Banner Pengumuman / Edukasi Mitra</h3>
                            <p class="text-[11px] text-brand-muted">Banner pengumuman penting atau edukasi yang tampil di aplikasi mitra</p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Unggah Berkas Banner Baru</label>
                        <input type="file" name="banner_file" @change="handleBannerChange($event, 'mitra')" accept="image/*"
                               class="w-full text-xs text-brand-text file:mr-4 file:py-2 file:px-4 file:rounded-xl file:border-0 file:text-xs file:font-semibold file:bg-brand-primary file:text-white hover:file:bg-black file:cursor-pointer border border-brand-border rounded-xl p-1 bg-white">
                        <p class="text-[11px] text-brand-muted mt-1">Rekomendasi rasio 16:9 landscape.</p>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Atau Gunakan URL Banner</label>
                        <input type="text" name="banner_promo_url" x-model="mitraBannerPreview" value="{{ old('banner_promo_url', $ketokMitraConfig->banner_promo_url) }}" placeholder="https://..."
                               class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>
                </div>

                <!-- 3. Kontak Bantuan CS Mitra -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="phone" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Kontak Bantuan & Support Mitra</h3>
                            <p class="text-[11px] text-brand-muted">Kontak CS khusus untuk mitra/tukang berkonsultasi seputar pesanan atau pencairan</p>
                        </div>
                    </div>

                    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Nomor WhatsApp CS Mitra</label>
                            <input type="text" name="kontak_cs" x-model="mitraCs" value="{{ old('kontak_cs', $ketokMitraConfig->kontak_cs) }}" placeholder="Cth: 081234567891"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>

                        <div>
                            <label class="block text-xs font-semibold text-brand-text mb-1">Email Support Mitra</label>
                            <input type="email" name="email_bantuan" x-model="mitraEmail" value="{{ old('email_bantuan', $ketokMitraConfig->email_bantuan) }}" placeholder="mitra@ketok.id"
                                   class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                        </div>
                    </div>
                </div>

                <!-- 4. Versi & Mode Maintenance -->
                <div class="bg-white rounded-2xl border border-brand-border p-6 shadow-xs space-y-4">
                    <div class="flex items-center gap-2.5 pb-3 border-b border-brand-border">
                        <div class="w-8 h-8 rounded-xl bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                            <i data-lucide="shield-alert" class="w-4 h-4"></i>
                        </div>
                        <div>
                            <h3 class="font-bold text-brand-text text-sm">Versi Aplikasi & Status Pemeliharaan</h3>
                            <p class="text-[11px] text-brand-muted">Kontrol versi rilis dan mode maintenance aplikasi mitra</p>
                        </div>
                    </div>

                    <div>
                        <label class="block text-xs font-semibold text-brand-text mb-1">Versi Aplikasi Terkini</label>
                        <input type="text" name="versi_aplikasi" x-model="mitraVersi" value="{{ old('versi_aplikasi', $ketokMitraConfig->versi_aplikasi) }}" placeholder="1.0.0"
                               class="w-48 text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">
                    </div>

                    <div class="p-4 rounded-xl bg-gray-50 border border-brand-border space-y-3">
                        <div class="flex items-center justify-between">
                            <div>
                                <p class="text-xs font-bold text-brand-text">Mode Pemeliharaan (Maintenance)</p>
                                <p class="text-[11px] text-brand-muted">Jika diaktifkan, mitra akan melihat layar pemeliharaan sistem.</p>
                            </div>
                            <label class="relative inline-flex items-center cursor-pointer">
                                <input type="checkbox" name="status_maintenance" value="1" x-model="mitraMaintenance" class="sr-only peer">
                                <div class="w-11 h-6 bg-gray-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-rose-600"></div>
                            </label>
                        </div>

                        <div x-show="mitraMaintenance" class="pt-2 border-t border-brand-border">
                            <label class="block text-xs font-semibold text-brand-text mb-1">Pesan Pemeliharaan untuk Mitra</label>
                            <textarea name="pesan_maintenance" rows="2" placeholder="Sistem kemitraan sedang dalam pemeliharaan berkala..."
                                      class="w-full text-xs rounded-xl border border-brand-border px-3.5 py-2.5 bg-white focus:ring-2 focus:ring-brand-dark focus:outline-none">{{ old('pesan_maintenance', $ketokMitraConfig->pesan_maintenance) }}</textarea>
                        </div>
                    </div>
                </div>

                <div class="flex justify-end">
                    <button type="submit" class="px-6 py-3 rounded-xl bg-brand-primary text-white font-bold text-xs hover:bg-black transition-colors shadow-xs flex items-center gap-2 cursor-pointer">
                        <i data-lucide="check" class="w-4 h-4 text-white"></i>
                        <span>Simpan Pengaturan Ketok Mitra</span>
                    </button>
                </div>
            </form>
        </div>
    </div>

</div>
@endsection
