<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">

    <title>Login Administrator - Ketok Platform</title>

    <!-- Google Fonts: Plus Jakarta Sans -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">

    <!-- Favicon -->
    <link rel="icon" type="image/png" href="{{ asset('ketok.png') }}">

    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <!-- Theme Colors Configuration (Centralized) -->
    @include('partials.theme_colors')

    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.14.8/dist/cdn.min.js"></script>

    <!-- Lucide Icons -->
    <script src="https://unpkg.com/lucide@latest"></script>

    <style>
        body {
            font-family: 'Plus Jakarta Sans', sans-serif;
            background-color: var(--color-brand-bg, #F8F9FB);
            color: var(--color-brand-text, #191C1E);
        }
        [x-cloak] { display: none !important; }

        /* Sembunyikan ikon mata bawaan peramban (Edge/Chrome/Windows) */
        input::-ms-reveal,
        input::-ms-clear {
            display: none !important;
            width: 0 !important;
            height: 0 !important;
        }
    </style>
</head>
<body class="min-h-screen bg-brand-bg flex items-center justify-center p-4 sm:p-6 antialiased selection:bg-brand-primary selection:text-white">

    <div class="w-full max-w-md" x-data="{ showPassword: false, isSubmitting: false }">
        
        <!-- Main Card Container -->
        <div class="bg-brand-surface rounded-3xl border border-brand-border shadow-xl p-8 sm:p-10 relative overflow-hidden">
            
            <!-- Subtle Top Accent Line -->
            <div class="absolute top-0 left-0 right-0 h-1.5 bg-brand-primary"></div>

            <!-- Logo & Brand Header (Inspired by Ketok App) -->
            <div class="text-center mb-8">
                <div class="w-16 h-16 rounded-2xl bg-brand-primary border border-white/15 overflow-hidden flex items-center justify-center mx-auto shadow-md mb-4 group">
                    <img src="{{ asset('ketok.png') }}" alt="Ketok" class="w-full h-full object-cover scale-125 transition-transform duration-300 group-hover:scale-135">
                </div>

                <div class="flex items-center justify-center gap-2 mb-1.5">
                    <h1 class="text-2xl font-extrabold tracking-tight text-brand-primary">Ketok</h1>
                    <span class="text-[10px] uppercase tracking-wider font-black px-2 py-0.5 rounded-md bg-brand-surfaceLow text-brand-primary border border-brand-border">
                        ADMIN
                    </span>
                </div>
            </div>

            <!-- Notification / Alert Badges -->
            @if(session('success'))
                <div class="mb-5 p-3.5 rounded-xl bg-emerald-50 border border-emerald-200 text-emerald-800 text-xs flex items-center gap-2.5">
                    <i data-lucide="check-circle" class="w-4 h-4 text-emerald-600 shrink-0"></i>
                    <span>{{ session('success') }}</span>
                </div>
            @endif

            @if(session('warning'))
                <div class="mb-5 p-3.5 rounded-xl bg-amber-50 border border-amber-200 text-amber-900 text-xs flex items-center gap-2.5">
                    <i data-lucide="alert-circle" class="w-4 h-4 text-amber-600 shrink-0"></i>
                    <span>{{ session('warning') }}</span>
                </div>
            @endif

            @if(session('info'))
                <div class="mb-5 p-3.5 rounded-xl bg-blue-50 border border-blue-200 text-blue-900 text-xs flex items-center gap-2.5">
                    <i data-lucide="info" class="w-4 h-4 text-blue-600 shrink-0"></i>
                    <span>{{ session('info') }}</span>
                </div>
            @endif

            @if($errors->any())
                <div class="mb-5 p-3.5 rounded-xl bg-rose-50 border border-rose-200 text-brand-danger text-xs space-y-1">
                    @foreach($errors->all() as $error)
                        <div class="flex items-center gap-2">
                            <i data-lucide="alert-triangle" class="w-4 h-4 shrink-0 text-brand-danger"></i>
                            <span>{{ $error }}</span>
                        </div>
                    @endforeach
                </div>
            @endif

            <!-- Login Form (Login Only - No Register) -->
            <form action="{{ route('login.submit') }}" method="POST" class="space-y-4" @submit="isSubmitting = true">
                @csrf

                <!-- Email Input -->
                <div>
                    <label for="email" class="block text-xs font-bold text-brand-text mb-1.5">
                        Email
                    </label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                            <i data-lucide="mail" class="w-4 h-4"></i>
                        </div>
                        <input type="email" 
                               id="email" 
                               name="email" 
                               value="{{ old('email') }}" 
                               required 
                               autocomplete="email" 
                               autofocus
                               placeholder="Masukkan email"
                               class="w-full text-xs pl-10 pr-3.5 py-3 rounded-xl border border-brand-border bg-brand-surface text-brand-text placeholder:text-gray-400 focus:outline-none focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/10 transition-all">
                    </div>
                </div>

                <!-- Password Input with Toggle Visibility -->
                <div>
                    <label for="password" class="block text-xs font-bold text-brand-text mb-1.5">
                        Kata Sandi
                    </label>
                    <div class="relative">
                        <div class="absolute inset-y-0 left-0 pl-3.5 flex items-center pointer-events-none text-brand-muted">
                            <i data-lucide="lock" class="w-4 h-4"></i>
                        </div>
                        <input :type="showPassword ? 'text' : 'password'" 
                               id="password" 
                               name="password" 
                               required 
                               autocomplete="current-password"
                               placeholder="Masukkan kata sandi"
                               class="w-full text-xs pl-10 pr-10 py-3 rounded-xl border border-brand-border bg-brand-surface text-brand-text placeholder:text-gray-400 focus:outline-none focus:border-brand-primary focus:ring-2 focus:ring-brand-primary/10 transition-all">
                        
                        <button type="button" 
                                @click="showPassword = !showPassword"
                                class="absolute inset-y-0 right-0 pr-3.5 flex items-center text-brand-muted hover:text-brand-text transition-colors cursor-pointer"
                                :title="showPassword ? 'Sembunyikan kata sandi' : 'Tampilkan kata sandi'">
                            <span x-show="!showPassword" class="flex items-center">
                                <i data-lucide="eye" class="w-4 h-4"></i>
                            </span>
                            <span x-show="showPassword" x-cloak class="flex items-center">
                                <i data-lucide="eye-off" class="w-4 h-4"></i>
                            </span>
                        </button>
                    </div>
                </div>

                <!-- Remember Me & Security Status -->
                <div class="flex items-center justify-between pt-1">
                    <label class="flex items-center gap-2 cursor-pointer select-none">
                        <input type="checkbox" name="remember" class="w-4 h-4 rounded border-brand-border text-brand-primary focus:ring-brand-primary/20">
                        <span class="text-xs text-brand-muted">Ingat sesi di perangkat ini</span>
                    </label>
                </div>

                <!-- Submit Button -->
                <div class="pt-2">
                    <button type="submit" 
                            :disabled="isSubmitting"
                            class="w-full py-3.5 px-4 rounded-xl bg-brand-primary hover:bg-brand-darkSec text-white text-xs font-bold transition-all shadow-md hover:shadow-lg flex items-center justify-center gap-2 disabled:opacity-75 disabled:cursor-not-allowed cursor-pointer">
                        <span x-show="!isSubmitting">Masuk ke Panel Admin</span>
                        <span x-show="isSubmitting" x-cloak class="flex items-center gap-2">
                            <svg class="animate-spin h-4 w-4 text-white" fill="none" viewBox="0 0 24 24">
                                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
                            </svg>
                            <span>Memproses Autentikasi...</span>
                        </span>
                    </button>
                </div>

            </form>

            <!-- Security Footer Note (Strictly No Register) -->
            <div class="mt-8 pt-6 border-t border-brand-border text-center">
                <div class="inline-flex items-center gap-1.5 text-[11px] text-brand-muted font-medium bg-brand-surfaceLow px-3 py-1.5 rounded-full border border-brand-border">
                    <i data-lucide="shield-check" class="w-3.5 h-3.5 text-brand-success"></i>
                    <span>Akses khusus staf &amp; administrator Ketok</span>
                </div>
            </div>

        </div>

        <!-- Footnote copyright -->
        <p class="text-center text-[11px] text-brand-muted mt-6">
            &copy; {{ date('Y') }} Ketok Platform &bull; Malang Raya
        </p>

    </div>

    <!-- Initialize Lucide Icons -->
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            if (window.lucide) {
                window.lucide.createIcons();
            }
        });
    </script>
</body>
</html>
