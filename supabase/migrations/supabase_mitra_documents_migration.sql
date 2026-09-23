-- Buat bucket baru untuk mitra_documents
INSERT INTO storage.buckets (id, name, public) 
VALUES ('mitra_documents', 'mitra_documents', true)
ON CONFLICT (id) DO NOTHING;

-- Kebijakan (Policy) agar semua orang (publik) dapat melihat dokumen (diperlukan pelanggan untuk melihat sertifikasi)
DROP POLICY IF EXISTS "Public Access Mitra Docs" ON storage.objects;
CREATE POLICY "Public Access Mitra Docs" 
ON storage.objects FOR SELECT 
USING (bucket_id = 'mitra_documents');

-- Kebijakan (Policy) agar pengguna yang login (Mitra) dapat mengunggah dokumen
DROP POLICY IF EXISTS "Auth users upload Mitra Docs" ON storage.objects;
CREATE POLICY "Auth users upload Mitra Docs" 
ON storage.objects FOR INSERT 
WITH CHECK (
  bucket_id = 'mitra_documents' 
  AND auth.role() = 'authenticated'
);

-- Kebijakan (Policy) agar pengguna dapat memperbarui/menghapus dokumen mereka sendiri
DROP POLICY IF EXISTS "Auth users update Mitra Docs" ON storage.objects;
CREATE POLICY "Auth users update Mitra Docs" 
ON storage.objects FOR UPDATE 
USING (
  bucket_id = 'mitra_documents' 
  AND auth.role() = 'authenticated'
);

DROP POLICY IF EXISTS "Auth users delete Mitra Docs" ON storage.objects;
CREATE POLICY "Auth users delete Mitra Docs" 
ON storage.objects FOR DELETE 
USING (
  bucket_id = 'mitra_documents' 
  AND auth.role() = 'authenticated'
);

NOTIFY pgrst, 'reload schema';
