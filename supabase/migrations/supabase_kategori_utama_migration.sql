-- ==============================================================================
-- TABEL KATEGORI UTAMA / KELOMPOK INDUK (SUPABASE SQL)
-- ==============================================================================

CREATE TABLE IF NOT EXISTS public.kategori_utama (
    id_kelompok   SERIAL PRIMARY KEY,
    nama_kelompok VARCHAR(150) NOT NULL UNIQUE
);

-- Migrasikan kelompok unik yang sudah ada dari kategori_layanan
INSERT INTO public.kategori_utama (nama_kelompok)
SELECT DISTINCT kelompok
FROM public.kategori_layanan
WHERE kelompok IS NOT NULL AND TRIM(kelompok) != ''
ON CONFLICT (nama_kelompok) DO NOTHING;

-- Muat ulang skema PostgREST
NOTIFY pgrst, 'reload schema';
