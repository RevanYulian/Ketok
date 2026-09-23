<!-- Topbar Header -->
<header class="h-16 bg-white border-b border-brand-border flex items-center justify-between px-4 sm:px-6 lg:px-8 sticky top-0 z-30 shadow-xs">
    
    <!-- Left: Hamburger & Breadcrumb -->
    <div class="flex items-center gap-4">
        <button @click="sidebarOpen = true" class="text-brand-muted hover:text-brand-text lg:hidden p-1.5 rounded-lg hover:bg-gray-100">
            <i data-lucide="menu" class="w-6 h-6"></i>
        </button>

        <div class="hidden sm:flex items-center gap-2 text-xs text-brand-muted">
            <span class="font-medium text-brand-text">Ketok Admin</span>
            <span>/</span>
            <span class="text-brand-text font-bold">@yield('page_title', 'Dashboard')</span>
        </div>
    </div>

    <!-- Right: Supabase Connection Status -->
    @php
        $isSupabaseConnected = false;
        try {
            $isSupabaseConnected = \Illuminate\Support\Facades\Cache::remember('topbar_db_connected', 15, function () {
                \Illuminate\Support\Facades\DB::connection()->getPdo();
                return true;
            });
        } catch (\Throwable $e) {
            $isSupabaseConnected = false;
        }
    @endphp
    <div>
        @if($isSupabaseConnected)
            <div class="flex items-center gap-2 px-3 py-1.5 rounded-full bg-emerald-50 border border-emerald-200 text-xs font-medium text-emerald-700 shadow-2xs">
                <span class="relative flex h-2 w-2">
                    <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                    <span class="relative inline-flex rounded-full h-2 w-2 bg-emerald-500"></span>
                </span>
                <span>Database Connected</span>
            </div>
        @else
            <div class="flex items-center gap-2 px-3 py-1.5 rounded-full bg-rose-50 border border-rose-200 text-xs font-medium text-rose-700 shadow-2xs" title="Koneksi database terputus">
                <span class="relative flex h-2 w-2">
                    <span class="relative inline-flex rounded-full h-2 w-2 bg-rose-500"></span>
                </span>
                <span>Database Disconnected</span>
            </div>
        @endif
    </div>

</header>
