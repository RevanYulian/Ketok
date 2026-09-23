-- 1. Tambahkan kolom foto_url ke tabel mitra_layanan (jika belum ada)
ALTER TABLE public.mitra_layanan 
ADD COLUMN IF NOT EXISTS foto_url TEXT;

-- 2. Buat bucket baru untuk layanan_fotos
INSERT INTO storage.buckets (id, name, public) 
VALUES ('layanan_fotos', 'layanan_fotos', true)
ON CONFLICT (id) DO NOTHING;

-- 3. Kebijakan (Policy) agar semua orang (publik) dapat melihat gambar
DROP POLICY IF EXISTS "Public Access Layanan Fotos" ON storage.objects;
CREATE POLICY "Public Access Layanan Fotos" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'layanan_fotos');

-- 4. Kebijakan (Policy) agar pengguna yang login (Mitra) dapat mengunggah gambar
DROP POLICY IF EXISTS "Auth users upload Layanan Fotos" ON storage.objects;
CREATE POLICY "Auth users upload Layanan Fotos" 
ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'layanan_fotos' 
  AND auth.role() = 'authenticated'
);

-- 5. Kebijakan (Policy) agar pengguna dapat memperbarui/menghapus foto mereka sendiri (Opsional tapi direkomendasikan)
DROP POLICY IF EXISTS "Auth users update Layanan Fotos" ON storage.objects;
CREATE POLICY "Auth users update Layanan Fotos" 
ON storage.objects FOR UPDATE 
USING (
  bucket_id = 'layanan_fotos' 
  AND auth.role() = 'authenticated'
);

DROP POLICY IF EXISTS "Auth users delete Layanan Fotos" ON storage.objects;
CREATE POLICY "Auth users delete Layanan Fotos" 
ON storage.objects FOR DELETE 
USING (
  bucket_id = 'layanan_fotos' 
  AND auth.role() = 'authenticated'
);

NOTIFY pgrst, 'reload schema';
