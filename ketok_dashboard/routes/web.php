<?php

use App\Http\Controllers\Admin\AdminController;
use App\Http\Controllers\Admin\ArtikelController;
use App\Http\Controllers\Admin\AuthController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\KategoriController;
use App\Http\Controllers\Admin\KeuanganController;
use App\Http\Controllers\Admin\MitraController;
use App\Http\Controllers\Admin\MitraLayananController;
use App\Http\Controllers\Admin\NotifikasiController;
use App\Http\Controllers\Admin\PengaturanAplikasiController;
use App\Http\Controllers\Admin\PenggunaController;
use App\Http\Controllers\Admin\PesananController;
use App\Http\Controllers\Admin\UlasanController;
use App\Http\Controllers\Admin\WilayahController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Autentikasi Khusus Admin (Login Saja, Tidak Ada Registrasi)
|--------------------------------------------------------------------------
*/
Route::get('/login', [AuthController::class, 'showLoginForm'])->name('login');
Route::post('/login', [AuthController::class, 'login'])->name('login.submit');
Route::post('/logout', [AuthController::class, 'logout'])->name('logout');

/*
|--------------------------------------------------------------------------
| Panel Admin & Dashboard (Diproteksi Middleware admin.auth)
|--------------------------------------------------------------------------
*/
Route::middleware(['admin.auth'])->group(function () {
    // Dashboard Utama
    Route::get('/', [DashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/dashboard', [DashboardController::class, 'index'])->name('dashboard');

    Route::prefix('admin')->name('admin.')->group(function () {
        
        // --- A. Role: Operasional & Super Admin ---
        Route::middleware(['admin.role:Operasional,Super Admin'])->group(function () {
            // 1. Marketplace & Etalase Layanan Mitra
            Route::get('/mitra-layanan', [MitraLayananController::class, 'index'])->name('mitra_layanan.index');
            Route::post('/mitra-layanan/{id}/toggle', [MitraLayananController::class, 'toggleStatus'])->name('mitra_layanan.toggle');
            Route::put('/mitra-layanan/{id}', [MitraLayananController::class, 'update'])->name('mitra_layanan.update');
            Route::delete('/mitra-layanan/{id}', [MitraLayananController::class, 'destroy'])->name('mitra_layanan.destroy');

            // 2. Kategori Layanan & Master Jasa
            Route::get('/kategori', [KategoriController::class, 'index'])->name('kategori.index');
            Route::post('/kategori/kelompok', [KategoriController::class, 'storeKelompok'])->name('kategori.store_kelompok');
            Route::post('/kategori', [KategoriController::class, 'storeKategori'])->name('kategori.store');
            Route::put('/kategori/{id}', [KategoriController::class, 'updateKategori'])->name('kategori.update');
            Route::delete('/kategori/{id}', [KategoriController::class, 'destroyKategori'])->name('kategori.destroy');
            Route::post('/jasa', [KategoriController::class, 'storeJasa'])->name('jasa.store');
            Route::put('/jasa/{id}', [KategoriController::class, 'updateJasa'])->name('jasa.update');
            Route::delete('/jasa/{id}', [KategoriController::class, 'destroyJasa'])->name('jasa.destroy');

            // 3. Manajemen & Verifikasi Mitra
            Route::get('/mitra', [MitraController::class, 'index'])->name('mitra.index');
            Route::get('/mitra/{id}', [MitraController::class, 'show'])->name('mitra.show');
            Route::post('/mitra/{id}/approve-verification', [MitraController::class, 'approveVerification'])->name('mitra.approve_verification');
            Route::post('/mitra/{id}/reject-verification', [MitraController::class, 'rejectVerification'])->name('mitra.reject_verification');
            Route::post('/mitra/{id}/approve', [MitraController::class, 'approve'])->name('mitra.approve');
            Route::post('/mitra/{id}/reject', [MitraController::class, 'reject'])->name('mitra.reject');
            Route::post('/mitra/{id}/suspend', [MitraController::class, 'toggleSuspend'])->name('mitra.suspend');
            Route::post('/mitra/{id}/status/{status}', [MitraController::class, 'updateStatus'])->name('mitra.update_status');

            // 5. Artikel & Tips Mitra (Edukasi & SOP)
            Route::get('/artikel', [ArtikelController::class, 'index'])->name('artikel.index');
            Route::post('/artikel', [ArtikelController::class, 'store'])->name('artikel.store');
            Route::post('/artikel/{id}/toggle', [ArtikelController::class, 'toggleStatus'])->name('artikel.toggle');
            Route::put('/artikel/{id}', [ArtikelController::class, 'update'])->name('artikel.update');
            Route::delete('/artikel/{id}', [ArtikelController::class, 'destroy'])->name('artikel.destroy');

            // 6. Wilayah Operasional
            Route::get('/wilayah', [WilayahController::class, 'index'])->name('wilayah.index');
            Route::post('/wilayah', [WilayahController::class, 'store'])->name('wilayah.store');
            Route::put('/wilayah/{id}', [WilayahController::class, 'update'])->name('wilayah.update');
            Route::delete('/wilayah/{id}', [WilayahController::class, 'destroy'])->name('wilayah.destroy');
        });

        // --- B. Role: Customer Service & Super Admin ---
        Route::middleware(['admin.role:Customer Service,Super Admin'])->group(function () {
            // 8. Pelanggan / Customer
            Route::get('/pengguna', [PenggunaController::class, 'index'])->name('pengguna.index');
            Route::post('/pengguna/{id}/toggle-status', [PenggunaController::class, 'toggleStatus'])->name('pengguna.toggle_status');

            // 9. Moderasi Ulasan & Rating
            Route::get('/ulasan', [UlasanController::class, 'index'])->name('ulasan.index');
            Route::delete('/ulasan/{id}', [UlasanController::class, 'destroy'])->name('ulasan.destroy');
        });

        // --- C. Role: Keuangan & Super Admin ---
        Route::middleware(['admin.role:Keuangan,Super Admin'])->group(function () {
            // 7. Keuangan & Komisi Platform
            Route::get('/keuangan', [KeuanganController::class, 'index'])->name('keuangan.index');
            Route::put('/keuangan/invoice/{id}', [KeuanganController::class, 'updateStatus'])->name('keuangan.update_status');
            Route::get('/keuangan/export-csv', [KeuanganController::class, 'exportCsv'])->name('keuangan.export_csv');
        });

        // --- D. Role: Shared (Operasional, Customer Service, Keuangan, Super Admin) ---
        Route::middleware(['admin.role:Operasional,Customer Service,Keuangan,Super Admin'])->group(function () {
            // 4. Monitoring Pesanan Langsung & Quotation
            Route::get('/pesanan', [PesananController::class, 'index'])->name('pesanan.index');
            Route::get('/pesanan/{id}', [PesananController::class, 'show'])->name('pesanan.show');
            Route::post('/pesanan/{id}/reassign', [PesananController::class, 'reassign'])->name('pesanan.reassign');
            Route::post('/pesanan/{id}/status', [PesananController::class, 'updateStatus'])->name('pesanan.status');
            Route::post('/pesanan/{id}/cancel', [PesananController::class, 'cancel'])->name('pesanan.cancel');
        });

        // --- E. Role: Shared (Operasional, Customer Service, Super Admin) ---
        Route::middleware(['admin.role:Operasional,Customer Service,Super Admin'])->group(function () {
            // 10. Broadcast Push Notifikasi
            Route::get('/notifikasi', [NotifikasiController::class, 'index'])->name('notifikasi.index');
            Route::post('/notifikasi/broadcast', [NotifikasiController::class, 'broadcast'])->name('notifikasi.broadcast');
        });

        // --- F. Role: Super Admin Exclusive ---
        Route::middleware(['admin.role:Super Admin'])->group(function () {
            // 11. Manajemen Akun Admin
            Route::get('/admins', [AdminController::class, 'index'])->name('admins.index');
            Route::post('/admins', [AdminController::class, 'store'])->name('admins.store');
            Route::put('/admins/{id}', [AdminController::class, 'update'])->name('admins.update');
            Route::delete('/admins/{id}', [AdminController::class, 'destroy'])->name('admins.destroy');

            // 12. Tampilan & Branding Aplikasi (Ketok App & Ketok Mitra)
            Route::get('/tampilan-aplikasi', [PengaturanAplikasiController::class, 'index'])->name('tampilan_aplikasi.index');
            Route::post('/tampilan-aplikasi/{tipe}', [PengaturanAplikasiController::class, 'update'])->name('tampilan_aplikasi.update');
        });

    });
});
