-- ==============================================================================
-- Migration: Cleanup Tabel Tahap 1 & 2
-- Menghapus tabel mati (pesanan_penawaran, pesanan_broadcast_log)
-- dan menyatukan verifikasi mitra sepenuhnya ke tabel mitra_profil (hapus pengajuan_mitra)
-- ==============================================================================

-- 1. Hapus tabel pesanan_penawaran & pesanan_broadcast_log
DROP TABLE IF EXISTS pesanan_penawaran CASCADE;
DROP TABLE IF EXISTS pesanan_broadcast_log CASCADE;

-- 2. Pastikan kolom catatan_verifikasi dan alasan penolakan ada di mitra_profil
ALTER TABLE mitra_profil ADD COLUMN IF NOT EXISTS catatan_verifikasi TEXT;

-- 3. Hapus tabel pengajuan_mitra
DROP TABLE IF EXISTS pengajuan_mitra CASCADE;
