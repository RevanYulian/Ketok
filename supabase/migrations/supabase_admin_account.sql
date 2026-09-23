-- ==============================================================================
-- AKUN SUPER ADMIN KETOK PLATFORM (SUPABASE SQL)
-- ==============================================================================
-- File ini digunakan untuk membuat dan memastikan akun Super Admin resmi 
-- terdaftar langsung di tabel `admins` pada database Supabase beserta password login.
--
-- KREDENSIAL DEFAULT LOGIN:
-- Email    : admin@ketok.id
-- Password : admin123
--
-- CARA MENJALANKAN:
-- 1. Buka Supabase Dashboard -> SQL Editor
-- 2. Paste seluruh isi file ini, lalu klik "Run"
-- ==============================================================================

-- 1. Pastikan tabel admins sudah ada
CREATE TABLE IF NOT EXISTS public.admins (
    id_admin     SERIAL PRIMARY KEY,
    nama         VARCHAR(150) NOT NULL,
    email        VARCHAR(150) NOT NULL UNIQUE,
    level_akses  VARCHAR(50) DEFAULT 'Super Admin',
    password     VARCHAR(255)
);

-- 2. Tambahkan kolom password jika sebelumnya belum ada
ALTER TABLE public.admins ADD COLUMN IF NOT EXISTS password VARCHAR(255);

-- 3. Masukkan / perbarui data Akun Super Admin Utama (Idempotent)
-- Hash '$2y$12$9yy8Jpm18QkUvyux9/p9gunNhhD79f2MI9RkbGSfxxsrohRYIh7Du' adalah bcrypt dari 'admin123'
INSERT INTO public.admins (nama, email, level_akses, password)
VALUES (
    'Administrator Ketok',
    'admin@ketok.id',
    'Super Admin',
    '$2y$12$9yy8Jpm18QkUvyux9/p9gunNhhD79f2MI9RkbGSfxxsrohRYIh7Du'
)
ON CONFLICT (email) 
DO UPDATE SET 
    nama = EXCLUDED.nama,
    level_akses = EXCLUDED.level_akses,
    password = EXCLUDED.password;

-- 4. Verifikasi data
SELECT id_admin, nama, email, level_akses, (password IS NOT NULL) AS has_password 
FROM public.admins 
WHERE email = 'admin@ketok.id';

-- 5. Muat ulang skema PostgREST Supabase
NOTIFY pgrst, 'reload schema';
