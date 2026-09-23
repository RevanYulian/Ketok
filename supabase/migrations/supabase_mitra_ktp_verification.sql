-- Migration penambahan kolom KTP dan NIK pada mitra_profil
-- Serta penyesuaian status verifikasi dan status mitra

ALTER TABLE mitra_profil 
  ADD COLUMN IF NOT EXISTS foto_ktp TEXT,
  ADD COLUMN IF NOT EXISTS nik VARCHAR(20),
  ADD COLUMN IF NOT EXISTS catatan_verifikasi TEXT,
  ADD COLUMN IF NOT EXISTS status_pengajuan_akun VARCHAR(50) DEFAULT 'aktif'::character varying;

-- Pastikan default status_verifikasi adalah 'menunggu' jika belum terisi
UPDATE mitra_profil 
SET status_verifikasi = 'menunggu' 
WHERE status_verifikasi IS NULL;

-- Notifikasi pgrst untuk reload schema Supabase
NOTIFY pgrst, 'reload schema';
