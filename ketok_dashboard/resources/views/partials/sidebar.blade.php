<!-- Sidebar Navigasi Ketok Admin -->
<aside class="fixed inset-y-0 left-0 z-50 w-64 bg-brand-primary text-white flex flex-col transition-transform duration-300 ease-in-out lg:translate-x-0 shadow-xl"
       :class="sidebarOpen ? 'translate-x-0' : '-translate-x-full'">
    
    <!-- Logo & Header -->
    <div class="h-16 flex items-center justify-between px-6 border-b border-white/10">
        <a href="{{ route('admin.dashboard') }}" class="flex items-center gap-3">
            <div class="w-9 h-9 rounded-lg bg-black border border-white/15 overflow-hidden flex items-center justify-center shrink-0 shadow-md">
                <img src="{{ asset('ketok.png') }}" alt="Ketok" class="w-full h-full object-cover scale-125">
            </div>
            <div class="flex items-center gap-2">
                <span class="text-xl font-extrabold tracking-tight text-white">
                    Ketok
                </span>
                <span class="text-[10px] px-1.5 py-0.5 rounded bg-brand-surfaceLow text-brand-primary font-black tracking-wider border border-brand-border">
                    ADMIN
                </span>
            </div>
        </a>
        <button @click="sidebarOpen = false" class="text-gray-400 hover:text-white lg:hidden">
            <i data-lucide="x" class="w-5 h-5"></i>
        </button>
    </div>

    @php
        $currentAdmin = null;
        try {
            $currentAdmin = \Illuminate\Support\Facades\Auth::guard('admin')->user();
            if (!$currentAdmin) {
                $currentAdmin = \Illuminate\Support\Facades\Cache::remember('sidebar_first_admin', 300, function () {
                    return \App\Models\Admin::first();
                });
            }
        } catch (\Throwable $e) {}
        $adminNama = $currentAdmin->nama ?? 'Administrator Ketok';
        $adminLevel = $currentAdmin->level_akses ?? 'Super Admin';
        $adminInitial = strtoupper(substr($adminNama, 0, 1));
    @endphp

    <!-- Navigation Links -->
    <div class="flex-1 overflow-y-auto px-4 py-4 space-y-1 custom-scrollbar">
        <!-- 1. Dashboard & Analitik (Semua Role) -->
        <a href="{{ route('admin.dashboard') }}" 
           class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.dashboard') || request()->is('/') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
            <i data-lucide="layout-dashboard" class="w-4 h-4"></i>
            <span>Dashboard & Analitik</span>
        </a>

        <!-- 2. Manajemen Admin (Super Admin Only) -->
        @if(!$currentAdmin || $currentAdmin->hasRole('Super Admin'))
            <a href="{{ route('admin.admins.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.admins.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="shield-check" class="w-4 h-4"></i>
                <span>Manajemen Admin</span>
            </a>
        @endif

        <!-- 3. Manajemen Pengguna (Customer Service & Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Customer Service', 'Super Admin']))
            <a href="{{ route('admin.pengguna.index') }}" 
               class="flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.pengguna.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <div class="flex items-center gap-3">
                    <i data-lucide="users" class="w-4 h-4"></i>
                    <span>Manajemen Pengguna</span>
                </div>
            </a>
        @endif

        <!-- 4. Manajemen Mitra (Operasional & Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Operasional', 'Super Admin']))
            <a href="{{ route('admin.mitra.index') }}" 
               class="flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.mitra.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <div class="flex items-center gap-3">
                    <i data-lucide="hard-hat" class="w-4 h-4"></i>
                    <span>Manajemen Mitra</span>
                </div>
                @php
                    $pendingCount = 0;
                    try {
                        $pendingCount = \Illuminate\Support\Facades\Cache::remember('sidebar_pending_mitra_count', 30, function () {
                            return \App\Models\MitraProfil::where('status_verifikasi', 'menunggu')->count();
                        });
                    } catch (\Throwable $e) {
                        $pendingCount = 0;
                    }
                @endphp
                @if($pendingCount > 0)
                    <span class="px-2 py-0.5 text-xs font-bold rounded-full bg-brand-danger text-white">{{ $pendingCount }}</span>
                @endif
            </a>

            <!-- 5. Etalase Jasa Mitra (Operasional & Super Admin) -->
            <a href="{{ route('admin.mitra_layanan.index') }}" 
               class="flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.mitra_layanan.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <div class="flex items-center gap-3">
                    <i data-lucide="store" class="w-4 h-4"></i>
                    <span>Etalase Jasa Mitra</span>
                </div>
            </a>

            <!-- 6. Kategori Layanan (Operasional & Super Admin) -->
            <a href="{{ route('admin.kategori.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.kategori.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="layers" class="w-4 h-4"></i>
                <span>Kategori Layanan</span>
            </a>
        @endif

        <!-- 7. Pesanan Direct Booking (Operasional, CS, Keuangan, Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Operasional', 'Customer Service', 'Keuangan', 'Super Admin']))
            <a href="{{ route('admin.pesanan.index') }}" 
               class="flex items-center justify-between px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.pesanan.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <div class="flex items-center gap-3">
                    <i data-lucide="shopping-bag" class="w-4 h-4"></i>
                    <span>Pesanan (Direct Booking)</span>
                </div>
            </a>
        @endif

        <!-- 8. Tips & SOP Mitra (Operasional & Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Operasional', 'Super Admin']))
            <a href="{{ route('admin.artikel.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.artikel.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="book-open" class="w-4 h-4"></i>
                <span>Tips & SOP Mitra</span>
            </a>

            <!-- 9. Wilayah Operasional (Operasional & Super Admin) -->
            <a href="{{ route('admin.wilayah.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.wilayah.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="map-pin" class="w-4 h-4"></i>
                <span>Wilayah Operasional</span>
            </a>
        @endif

        <!-- 10. Komisi Platform (Keuangan & Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Keuangan', 'Super Admin']))
            <a href="{{ route('admin.keuangan.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.keuangan.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="badge-percent" class="w-4 h-4"></i>
                <span>Komisi</span>
            </a>
        @endif

        <!-- 11. Moderasi Ulasan (Customer Service & Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Customer Service', 'Super Admin']))
            <a href="{{ route('admin.ulasan.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.ulasan.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="star" class="w-4 h-4"></i>
                <span>Moderasi Ulasan</span>
            </a>
        @endif

        <!-- 12. Broadcast Notifikasi (Operasional, Customer Service, Super Admin) -->
        @if(!$currentAdmin || $currentAdmin->hasRole(['Operasional', 'Customer Service', 'Super Admin']))
            <a href="{{ route('admin.notifikasi.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.notifikasi.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="bell" class="w-4 h-4"></i>
                <span>Broadcast Notifikasi</span>
            </a>
        @endif

        <!-- 13. Tampilan & Branding Aplikasi (Super Admin Only) -->
        @if(!$currentAdmin || $currentAdmin->hasRole('Super Admin'))
            <a href="{{ route('admin.tampilan_aplikasi.index') }}" 
               class="flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors {{ request()->routeIs('admin.tampilan_aplikasi.*') ? 'bg-brand-surface text-brand-primary font-bold shadow-sm' : 'text-gray-300 hover:bg-white/10 hover:text-white' }}">
                <i data-lucide="palette" class="w-4 h-4"></i>
                <span>Tampilan & Branding</span>
            </a>
        @endif
    </div>

    <!-- User Profile Footer -->
    <div class="p-4 border-t border-white/10 bg-black/40">
        <div class="flex items-center justify-between gap-3">
            @if(!$currentAdmin || $currentAdmin->hasRole('Super Admin'))
                <a href="{{ route('admin.admins.index') }}" class="flex items-center gap-3 group min-w-0 flex-1 hover:opacity-90 transition-opacity" title="Kelola Akun Admin">
            @else
                <div class="flex items-center gap-3 min-w-0 flex-1">
            @endif
                <div class="w-9 h-9 rounded-lg bg-brand-text border border-white/15 flex items-center justify-center text-white font-bold text-sm shrink-0">
                    {{ $adminInitial }}
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-semibold text-white truncate">{{ $adminNama }}</p>
                    <p class="text-xs text-gray-400 truncate">{{ $adminLevel }}</p>
                </div>
            @if(!$currentAdmin || $currentAdmin->hasRole('Super Admin'))
                </a>
            @else
                </div>
            @endif
            <form action="{{ route('logout') }}" method="POST" class="shrink-0"
                  data-confirm-title="Keluar dari Panel Admin"
                  data-confirm-message="Apakah Anda yakin ingin keluar dari sesi admin Ketok?"
                  data-confirm-button="Ya, Keluar"
                  data-confirm-type="danger">
                @csrf
                <button type="submit" title="Keluar dari sesi admin" class="p-2 rounded-lg text-gray-400 hover:text-white hover:bg-white/10 transition-colors cursor-pointer">
                    <i data-lucide="log-out" class="w-4 h-4"></i>
                </button>
            </form>
        </div>
    </div>

</aside>
