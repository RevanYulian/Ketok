# Ketok — Monorepo

Satu folder berisi 3 project yang berbagi 1 backend Supabase yang sama.

```
ketok-project/
├── ketok_app/               Flutter — aplikasi Pengguna
├── ketok_mitra/             Flutter — aplikasi Mitra
├── ketok_dashboard/         Laravel — dashboard Admin
├── supabase/
│   └── migrations/          Riwayat perubahan skema database (SQL)
└── SKEMA_DATABASE.md         Dokumentasi tabel & relasi (baca ini dulu
                               sebelum ubah skema database)
```

## Sebelum mulai kerja

1. Baca `SKEMA_DATABASE.md` untuk memahami struktur data & alur broadcast pesanan.
2. Kalau mau ubah tabel di Supabase, catat perubahannya sebagai file baru di
   `supabase/migrations/`, lalu update `SKEMA_DATABASE.md`.
3. Cek 3 project (`ketok_app`, `ketok_mitra`, `ketok_dashboard`) — mana saja
   yang pakai tabel/kolom yang kamu ubah — sebelum eksekusi perubahan.

## Menjalankan masing-masing project

**ketok_app** / **ketok_mitra** (Flutter):
```bash
cd ketok_app   # atau ketok_mitra
flutter pub get
flutter run
```

**ketok_dashboard** (Laravel):
```bash
cd ketok_dashboard
composer install
php artisan serve
```

## Kredensial

Ketiga project sudah dikonfigurasi menyambung ke Supabase project yang sama
lewat `.env` masing-masing. Jangan commit file `.env` ke repository publik.
