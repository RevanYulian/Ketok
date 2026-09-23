@extends('layouts.admin')

@section('title', 'Manajemen & Verifikasi Mitra')
@section('page_title', 'Manajemen Mitra')

@section('content')
<div class="space-y-6" x-data="{ 
    previewKtpModalOpen: false,
    selectedMitra: null,
    rejectKtpModalOpen: false
}">

    <!-- Tabel Daftar Mitra -->
    <div class="space-y-4">
        <div class="bg-white rounded-2xl border border-brand-border shadow-xs overflow-hidden">
            <div class="p-4 border-b border-brand-border flex flex-col sm:flex-row sm:items-center justify-between gap-3">
                <form method="GET" action="{{ route('admin.mitra.index') }}" class="flex flex-wrap items-center gap-2.5">
                    <select name="status_mitra" onchange="this.form.submit()" class="text-xs rounded-xl border border-brand-border px-3 py-2 bg-white text-brand-text font-medium">
                        <option value="">Semua Status</option>
                        <option value="menunggu" {{ request('status_mitra') === 'menunggu' ? 'selected' : '' }}>Menunggu ({{ $menungguCount ?? 0 }})</option>
                        <option value="disetujui" {{ request('status_mitra') === 'disetujui' ? 'selected' : '' }}>Disetujui</option>
                        <option value="suspended" {{ request('status_mitra') === 'suspended' ? 'selected' : '' }}>Suspend</option>
                        <option value="blokir" {{ request('status_mitra') === 'blokir' ? 'selected' : '' }}>Blokir</option>
                    </select>

                    <div class="relative">
                        <input type="text" name="search" value="{{ request('search') }}" placeholder="Cari nama mitra / email..." 
                               class="text-xs rounded-xl border border-brand-border pl-8 pr-3 py-2 bg-white text-brand-text placeholder-gray-400 focus:ring-2 focus:ring-brand-dark focus:outline-none w-56">
                        <i data-lucide="search" class="w-3.5 h-3.5 text-brand-muted absolute left-2.5 top-2.5"></i>
                    </div>
                </form>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left text-xs">
                    <thead class="bg-gray-50/75 text-brand-muted font-semibold border-b border-brand-border">
                        <tr>
                            <th class="px-5 py-3.5">Nama & Profil</th>
                            <th class="px-5 py-3.5">Keahlian & Usaha</th>
                            <th class="px-5 py-3.5">Wilayah Operasional</th>
                            <th class="px-5 py-3.5">Status Online</th>
                            <th class="px-5 py-3.5">Status Akun</th>
                            <th class="px-5 py-3.5">Dokumen KTP</th>
                            <th class="px-5 py-3.5 text-right">Aksi</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-brand-border">
                        @forelse($mitraList as $mitra)
                            <tr class="hover:bg-gray-50/50 transition-colors">
                                <td class="px-5 py-4">
                                    <div class="flex items-center gap-3">
                                        <div class="w-9 h-9 rounded-full bg-brand-surfaceLow text-brand-primary border border-brand-border font-bold flex items-center justify-center text-xs shrink-0">
                                            {{ strtoupper(substr($mitra->nama, 0, 1)) }}
                                        </div>
                                        <div>
                                            <p class="font-bold text-brand-text">{{ $mitra->nama }}</p>
                                            <p class="text-[11px] text-brand-muted">{{ $mitra->email }}</p>
                                        </div>
                                    </div>
                                </td>
                                <td class="px-5 py-4 text-brand-text">
                                    <p class="font-medium">{{ $mitra->mitraProfil->nama_usaha ?? 'Perorangan' }}</p>
                                    <p class="text-[11px] text-brand-muted">{{ $mitra->mitraProfil->keahlian ?? '-' }}</p>
                                </td>
                                <td class="px-5 py-4">
                                    @if($mitra->mitraProfil && ($mitra->mitraProfil->kecamatan || $mitra->mitraProfil->kelurahan))
                                        <p class="font-medium text-brand-text text-xs">{{ $mitra->mitraProfil->kelurahan ? $mitra->mitraProfil->kelurahan . ', ' : '' }}{{ $mitra->mitraProfil->kecamatan ? 'Kec. ' . $mitra->mitraProfil->kecamatan : '' }}</p>
                                        <p class="text-[11px] text-brand-muted">{{ $mitra->mitraProfil->kota ?? 'Malang' }}</p>
                                    @else
                                        <span class="text-brand-muted text-xs">{{ $mitra->mitraProfil?->wilayah_tampil ?? ($mitra->mitraProfil->wilayah_operasional ?? 'Malang Raya') }}</span>
                                    @endif
                                </td>
                                <td class="px-5 py-4">
                                    @if($mitra->mitraProfil && $mitra->mitraProfil->status_online)
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200 flex items-center gap-1 w-max">
                                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-500"></span> Online
                                        </span>
                                    @else
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-bold bg-gray-100 text-gray-500 border border-gray-200 w-max">
                                            Offline
                                        </span>
                                    @endif
                                </td>
                                <td class="px-5 py-4">
                                    @if(in_array($mitra->status_mitra, ['disetujui', 'aktif']))
                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-emerald-50 text-emerald-700 border border-emerald-200">
                                            Disetujui
                                        </span>
                                    @elseif($mitra->status_mitra === 'suspended')
                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                            Suspend
                                        </span>
                                    @elseif(in_array($mitra->status_mitra, ['blokir', 'banned']))
                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-rose-50 text-rose-700 border border-rose-200">
                                            Blokir
                                        </span>
                                    @elseif($mitra->status_mitra === 'ditolak')
                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-gray-100 text-gray-700 border border-gray-200">
                                            Ditolak
                                        </span>
                                    @else
                                        <span class="px-2.5 py-1 rounded-full text-[10px] font-bold bg-amber-50 text-amber-700 border border-amber-200">
                                            Menunggu
                                        </span>
                                    @endif
                                </td>
                                <td class="px-5 py-4">
                                    @if($mitra->mitraProfil && $mitra->mitraProfil->foto_ktp)
                                        <button type="button" 
                                                @click="selectedMitra = {{ json_encode([
                                                    'id' => $mitra->id_user,
                                                    'nama' => $mitra->nama,
                                                    'email' => $mitra->email,
                                                    'telepon' => $mitra->nomor_telepon ?? '-',
                                                    'status_mitra' => $mitra->status_mitra,
                                                    'nik' => $mitra->mitraProfil->nik ?? '-',
                                                    'foto_ktp' => $mitra->mitraProfil->foto_ktp,
                                                    'status_verifikasi' => $mitra->mitraProfil->status_verifikasi ?? 'menunggu',
                                                    'catatan_verifikasi' => $mitra->mitraProfil->catatan_verifikasi ?? ''
                                                ]) }}; previewKtpModalOpen = true; rejectKtpModalOpen = false"
                                                class="px-2.5 py-1 rounded-lg text-xs font-semibold bg-brand-primary text-white hover:bg-black transition-colors inline-flex items-center gap-1.5 shadow-xs cursor-pointer">
                                            <i data-lucide="file-badge" class="w-3.5 h-3.5 text-white"></i>
                                            <span>Lihat KTP</span>
                                        </button>
                                    @else
                                        <span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-gray-100 text-gray-400 border border-gray-200">
                                            Belum Upload
                                        </span>
                                    @endif
                                </td>
                                <td class="px-5 py-4 text-right">
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
                                                <a href="{{ route('admin.mitra.show', $mitra->id_user) }}" 
                                                   class="flex items-center gap-2 px-3.5 py-2 text-brand-text hover:bg-gray-50 transition-colors font-medium">
                                                    <i data-lucide="user" class="w-3.5 h-3.5 text-brand-muted"></i>
                                                    <span>Lihat Profil</span>
                                                </a>

                                                @if($mitra->mitraProfil && $mitra->mitraProfil->foto_ktp)
                                                    <button type="button" 
                                                            @click="dropdownOpen = false; selectedMitra = {{ json_encode([
                                                                'id' => $mitra->id_user,
                                                                'nama' => $mitra->nama,
                                                                'email' => $mitra->email,
                                                                'telepon' => $mitra->nomor_telepon ?? '-',
                                                                'status_mitra' => $mitra->status_mitra,
                                                                'nik' => $mitra->mitraProfil->nik ?? '-',
                                                                'foto_ktp' => $mitra->mitraProfil->foto_ktp,
                                                                'status_verifikasi' => $mitra->mitraProfil->status_verifikasi ?? 'menunggu',
                                                                'catatan_verifikasi' => $mitra->mitraProfil->catatan_verifikasi ?? ''
                                                            ]) }}; previewKtpModalOpen = true; rejectKtpModalOpen = false"
                                                            class="w-full flex items-center gap-2 px-3.5 py-2 text-brand-text hover:bg-gray-50 transition-colors font-medium text-left">
                                                        <i data-lucide="file-badge" class="w-3.5 h-3.5 text-brand-muted"></i>
                                                        <span>Tinjau KTP</span>
                                                    </button>
                                                @endif
                                            </div>

                                            <div class="py-1">
                                                <!-- Opsi Disetujui -->
                                                <form action="{{ route('admin.mitra.update_status', ['id' => $mitra->id_user, 'status' => 'disetujui']) }}" method="POST">
                                                    @csrf
                                                    <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 text-emerald-600 hover:bg-emerald-50 transition-colors font-semibold text-left">
                                                        <i data-lucide="check-circle-2" class="w-3.5 h-3.5 text-emerald-600"></i>
                                                        <span>Disetujui</span>
                                                    </button>
                                                </form>

                                                <!-- Opsi Suspend -->
                                                <form action="{{ route('admin.mitra.update_status', ['id' => $mitra->id_user, 'status' => 'suspended']) }}" method="POST">
                                                    @csrf
                                                    <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 text-amber-600 hover:bg-amber-50 transition-colors font-medium text-left">
                                                        <i data-lucide="pause-circle" class="w-3.5 h-3.5 text-amber-600"></i>
                                                        <span>Suspend</span>
                                                    </button>
                                                </form>

                                                <!-- Opsi Blokir -->
                                                <form action="{{ route('admin.mitra.update_status', ['id' => $mitra->id_user, 'status' => 'blokir']) }}" method="POST"
                                                      data-confirm-title="Blokir Akun Mitra"
                                                      data-confirm-message="Apakah Anda yakin ingin memblokir akun mitra {{ $mitra->nama }}? Mitra ini tidak akan dapat menerima pesanan."
                                                      data-confirm-button="Ya, Blokir"
                                                      data-confirm-type="danger">
                                                    @csrf
                                                    <button type="submit" class="w-full flex items-center gap-2 px-3.5 py-2 text-rose-600 hover:bg-rose-50 transition-colors font-medium text-left">
                                                        <i data-lucide="ban" class="w-3.5 h-3.5 text-rose-600"></i>
                                                        <span>Blokir</span>
                                                    </button>
                                                </form>
                                            </div>
                                        </div>
                                    </div>
                                </td>
                            </tr>
                        @empty
                            <tr>
                                <td colspan="7" class="px-5 py-8 text-center text-brand-muted">Tidak ada data mitra ditemukan.</td>
                            </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>

            @if($mitraList->hasPages())
                <div class="p-4 border-t border-brand-border">
                    {{ $mitraList->links() }}
                </div>
            @endif
        </div>
    </div>


    <!-- Modal Preview KTP & Verifikasi Mitra -->
    <div x-show="previewKtpModalOpen" class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-xs" x-cloak>
        <div class="bg-white rounded-3xl max-w-lg w-full p-6 sm:p-7 shadow-2xl border border-brand-border max-h-[90vh] overflow-y-auto" @click.away="previewKtpModalOpen = false">
            <div class="flex items-center justify-between pb-3 border-b border-brand-border">
                <div class="flex items-center gap-2.5">
                    <div class="w-8 h-8 rounded-lg bg-brand-surfaceLow text-brand-primary border border-brand-border flex items-center justify-center font-bold text-xs">
                        <i data-lucide="shield-check" class="w-4 h-4"></i>
                    </div>
                    <div>
                        <h3 class="font-bold text-brand-text text-base">Verifikasi Berkas KTP Mitra</h3>
                        <p class="text-[11px] text-brand-muted">Tinjau kesesuaian identitas calon mitra</p>
                    </div>
                </div>
                <button @click="previewKtpModalOpen = false" class="text-brand-muted hover:text-brand-text p-1 rounded-lg hover:bg-gray-100">
                    <i data-lucide="x" class="w-5 h-5"></i>
                </button>
            </div>

            <template x-if="selectedMitra">
                <div class="mt-4 space-y-4">
                    <!-- Data Ringkas Mitra -->
                    <div class="grid grid-cols-2 gap-3 p-3 rounded-xl bg-gray-50/75 border border-brand-border text-xs">
                        <div>
                            <p class="text-brand-muted text-[10px]">Nama Lengkap</p>
                            <p class="font-bold text-brand-text" x-text="selectedMitra.nama"></p>
                        </div>
                        <div>
                            <p class="text-brand-muted text-[10px]">NIK KTP</p>
                            <p class="font-bold font-mono text-brand-text" x-text="selectedMitra.nik || '-'"></p>
                        </div>
                        <div>
                            <p class="text-brand-muted text-[10px]">Email</p>
                            <p class="font-medium text-brand-text truncate" x-text="selectedMitra.email"></p>
                        </div>
                        <div>
                            <p class="text-brand-muted text-[10px]">Status Akun</p>
                            <span class="inline-block px-2 py-0.5 rounded-full text-[10px] font-bold capitalize"
                                  :class="{
                                      'bg-amber-50 text-amber-700 border border-amber-200': !selectedMitra.status_mitra || ['menunggu', 'pengajuan', 'pending'].includes(selectedMitra.status_mitra),
                                      'bg-emerald-50 text-emerald-700 border border-emerald-200': ['disetujui', 'aktif'].includes(selectedMitra.status_mitra),
                                      'bg-amber-50 text-amber-700 border border-amber-200': selectedMitra.status_mitra === 'suspended',
                                      'bg-rose-50 text-rose-700 border border-rose-200': ['blokir', 'banned', 'ditolak'].includes(selectedMitra.status_mitra)
                                  }"
                                  x-text="(!selectedMitra.status_mitra || ['menunggu', 'pengajuan', 'pending'].includes(selectedMitra.status_mitra)) ? 'Menunggu' : (['disetujui', 'aktif'].includes(selectedMitra.status_mitra) ? 'Disetujui' : (selectedMitra.status_mitra === 'suspended' ? 'Suspend' : (['blokir', 'banned'].includes(selectedMitra.status_mitra) ? 'Blokir' : selectedMitra.status_mitra)))"></span>
                        </div>
                    </div>

                    <!-- Catatan Verifikasi Jika Pernah Ditolak -->
                    <template x-if="selectedMitra.catatan_verifikasi">
                        <div class="p-3 rounded-xl bg-rose-50 border border-rose-200 text-xs text-rose-800">
                            <p class="font-bold text-[11px] mb-0.5">Catatan Penolakan Sebelumnya:</p>
                            <p x-text="selectedMitra.catatan_verifikasi"></p>
                        </div>
                    </template>

                    <!-- Foto KTP -->
                    <div>
                        <p class="text-xs font-semibold text-brand-text mb-2">Foto KTP Mitra:</p>
                        <div class="rounded-2xl overflow-hidden border border-brand-border bg-gray-100 flex items-center justify-center max-h-72 p-1">
                            <img :src="selectedMitra.foto_ktp" alt="Foto KTP" class="w-full h-auto object-contain max-h-72 rounded-xl">
                        </div>
                    </div>

                    <!-- Form Aksi Approve / Reject -->
                    <div class="pt-3 border-t border-brand-border flex flex-col gap-2">
                        <div class="flex items-center justify-end gap-2" x-show="!rejectKtpModalOpen">
                            <button type="button" @click="rejectKtpModalOpen = true" class="px-4 py-2 rounded-xl text-xs font-semibold bg-rose-50 text-rose-700 hover:bg-rose-100 border border-rose-200">
                                Tolak Verifikasi
                            </button>
                            <form :action="'/admin/mitra/' + selectedMitra.id + '/approve-verification'" method="POST">
                                @csrf
                                <button type="submit" class="px-5 py-2 rounded-xl text-xs font-bold bg-emerald-600 hover:bg-emerald-700 text-white shadow-xs">
                                    Setujui & Aktifkan Mitra
                                </button>
                            </form>
                        </div>

                        <!-- Sub-form alasan penolakan -->
                        <div x-show="rejectKtpModalOpen" class="space-y-3 p-3 rounded-xl bg-rose-50/60 border border-rose-200" x-cloak>
                            <form :action="'/admin/mitra/' + selectedMitra.id + '/reject-verification'" method="POST" class="space-y-3">
                                @csrf
                                <div>
                                    <label class="block text-xs font-semibold text-rose-900 mb-1">Alasan Penolakan KTP</label>
                                    <input type="text" name="catatan_verifikasi" required placeholder="Cth: Foto KTP buram / NIK tidak cocok" class="w-full text-xs rounded-xl border border-rose-300 px-3 py-2 bg-white focus:ring-2 focus:ring-rose-500 focus:outline-none">
                                </div>
                                <div class="flex justify-end gap-2">
                                    <button type="button" @click="rejectKtpModalOpen = false" class="px-3 py-1.5 rounded-lg text-xs font-semibold text-gray-600 hover:bg-gray-100">Batal</button>
                                    <button type="submit" class="px-3 py-1.5 rounded-lg text-xs font-bold bg-rose-600 text-white hover:bg-rose-700">Kirim Penolakan</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </template>
        </div>
    </div>

</div>
@endsection
