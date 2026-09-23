-- Migration: Enhance notifikasi table
-- 1. Ubah tipe data kolom judul menjadi TEXT agar pesan panjang (alasan penolakan dll) tidak error
ALTER TABLE notifikasi ALTER COLUMN judul TYPE text;

-- 2. Tambahkan kolom dibuat_pada jika belum ada
ALTER TABLE notifikasi ADD COLUMN IF NOT EXISTS dibuat_pada timestamp default now();

-- Reload postgREST schema cache
NOTIFY pgrst, 'reload schema';
