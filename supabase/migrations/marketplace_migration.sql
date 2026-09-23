-- Migrasi ke arsitektur marketplace murni

-- 1. Tambahkan kolom nama_jasa dan deskripsi ke mitra_layanan
ALTER TABLE mitra_layanan 
ADD COLUMN IF NOT EXISTS nama_jasa varchar(150),
ADD COLUMN IF NOT EXISTS deskripsi text;

-- 2. Hapus aturan RLS lama yang hanya mengizinkan mitra melihat layanan miliknya sendiri
DROP POLICY IF EXISTS "Mitra melihat layanan sendiri" ON mitra_layanan;
DROP POLICY IF EXISTS "Pengguna melihat layanan mitra aktif" ON mitra_layanan;

-- 3. Buat aturan baru: Semua orang (termasuk pengguna yang belum login) bisa melihat layanan yang aktif
CREATE POLICY "Publik melihat layanan mitra aktif"
ON mitra_layanan FOR SELECT
USING (aktif = true);

-- (Opsional) Jika diperlukan policy terpisah untuk mitra melihat seluruh layanannya (termasuk yang tidak aktif)
CREATE POLICY "Mitra melihat layanannya sendiri"
ON mitra_layanan FOR SELECT
USING (mitra_id = public.current_mitra_id());
