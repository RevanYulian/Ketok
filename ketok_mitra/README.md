# Ketok Mitra

Aplikasi Flutter untuk Mitra Ketok (project lengkap, sudah termasuk folder
native android/ios/web/dll — hasil clone dari struktur `ketok_app`).
Terhubung ke backend Supabase yang sama dengan `ketok_app` (aplikasi Pengguna).

## Cara menjalankan

```bash
cd ketok_mitra
flutter pub get
flutter run
```

Tekan tombol **"Test Koneksi Supabase"** di halaman utama untuk memastikan
koneksi ke database berhasil.

## Struktur

```
lib/
  main.dart          # Inisialisasi Supabase & entry point
  screens/
    app.dart         # Halaman awal + tombol test koneksi Supabase
.env                 # Kredensial Supabase (JANGAN di-commit ke Git publik)
.env.example         # Contoh format .env
```

## Catatan

- `SUPABASE_ANON_KEY` aman disematkan di sisi client (dilindungi Row Level
  Security/RLS di Supabase), tapi `.env` tetap sudah dimasukkan ke
  `.gitignore` sebagai praktik yang baik.
- App ID Android: `com.example.ketok_mitra`, Bundle ID iOS/macOS:
  `com.example.ketokMitra` — sudah dipisah dari `ketok_app` supaya bisa
  di-install berdampingan di device yang sama saat testing.

## Roadmap pengembangan (sesuai activity diagram project)

1. Login/Register Mitra (Diagram 1)
2. Ajukan & Persetujuan Mitra (Diagram 2)
3. Terima Broadcast Pesanan (Diagram 3, bagian Mitra)

Lihat `../SKEMA_DATABASE.md` di root project untuk referensi skema database
sebelum menambah/mengubah query ke Supabase.
