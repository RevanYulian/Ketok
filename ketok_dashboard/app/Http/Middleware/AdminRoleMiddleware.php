<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Symfony\Component\HttpFoundation\Response;

class AdminRoleMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     * @param  string  ...$roles
     */
    public function handle(Request $request, Closure $next, ...$roles): Response
    {
        $admin = Auth::guard('admin')->user();

        if (!$admin) {
            return redirect()->route('login')->with('warning', 'Silakan masuk terlebih dahulu.');
        }

        // Super Admin memiliki akses penuh ke seluruh fitur
        if ($admin->level_akses === 'Super Admin') {
            return $next($request);
        }

        // Cek apakah level_akses admin cocok dengan salah satu role yang diizinkan
        $allowedRoles = array_map('trim', $roles);
        if (in_array($admin->level_akses, $allowedRoles)) {
            return $next($request);
        }

        return redirect()->route('admin.dashboard')->with('error', "Akses Ditolak: Akun Anda dengan level '{$admin->level_akses}' tidak memiliki wewenang untuk membuka halaman tersebut.");
    }
}
