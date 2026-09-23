<!-- Toast Feedback Notifications -->
<div class="fixed bottom-5 right-5 z-50 flex flex-col gap-3 max-w-sm w-full pointer-events-none" x-data="{ show: true }">
    @if(session('success'))
        <div x-show="show" 
             x-init="setTimeout(() => show = false, 4000)"
             x-transition:enter="transition ease-out duration-300 transform"
             x-transition:enter-start="opacity-0 translate-y-4"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-200 transform"
             x-transition:leave-start="opacity-100 translate-y-0"
             x-transition:leave-end="opacity-0 translate-y-4"
             class="pointer-events-auto bg-emerald-900/90 text-white backdrop-blur-md px-4 py-3 rounded-xl shadow-xl border border-emerald-500/30 flex items-start gap-3">
            <div class="p-1 bg-emerald-500 rounded-lg text-white mt-0.5">
                <i data-lucide="check" class="w-4 h-4"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-emerald-200">Berhasil!</p>
                <p class="text-xs text-white/90 mt-0.5">{{ session('success') }}</p>
            </div>
            <button @click="show = false" class="text-emerald-300 hover:text-white">
                <i data-lucide="x" class="w-4 h-4"></i>
            </button>
        </div>
    @endif

    @if(session('error'))
        <div x-show="show" 
             x-init="setTimeout(() => show = false, 5000)"
             x-transition:enter="transition ease-out duration-300 transform"
             x-transition:enter-start="opacity-0 translate-y-4"
             x-transition:enter-end="opacity-100 translate-y-0"
             x-transition:leave="transition ease-in duration-200 transform"
             x-transition:leave-start="opacity-100 translate-y-0"
             x-transition:leave-end="opacity-0 translate-y-4"
             class="pointer-events-auto bg-rose-900/90 text-white backdrop-blur-md px-4 py-3 rounded-xl shadow-xl border border-rose-500/30 flex items-start gap-3">
            <div class="p-1 bg-rose-500 rounded-lg text-white mt-0.5">
                <i data-lucide="alert-circle" class="w-4 h-4"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-rose-200">Terjadi Kesalahan</p>
                <p class="text-xs text-white/90 mt-0.5">{{ session('error') }}</p>
            </div>
            <button @click="show = false" class="text-rose-300 hover:text-white">
                <i data-lucide="x" class="w-4 h-4"></i>
            </button>
        </div>
    @endif

    @if($errors->any())
        <div x-show="show" 
             x-init="setTimeout(() => show = false, 6000)"
             class="pointer-events-auto bg-rose-900/90 text-white backdrop-blur-md px-4 py-3 rounded-xl shadow-xl border border-rose-500/30 flex items-start gap-3">
            <div class="p-1 bg-rose-500 rounded-lg text-white mt-0.5">
                <i data-lucide="alert-triangle" class="w-4 h-4"></i>
            </div>
            <div class="flex-1 min-w-0">
                <p class="text-xs font-semibold text-rose-200">Validasi Gagal</p>
                <ul class="text-xs text-white/90 mt-0.5 list-disc list-inside">
                    @foreach($errors->all() as $err)
                        <li>{{ $err }}</li>
                    @endforeach
                </ul>
            </div>
            <button @click="show = false" class="text-rose-300 hover:text-white">
                <i data-lucide="x" class="w-4 h-4"></i>
            </button>
        </div>
    @endif
</div>
