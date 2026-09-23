-- Migrasi menambahkan kolom biaya_kunjungan ke tabel mitra_layanan

ALTER TABLE mitra_layanan
ADD COLUMN IF NOT EXISTS biaya_kunjungan numeric(14,2) not null default 50000;
