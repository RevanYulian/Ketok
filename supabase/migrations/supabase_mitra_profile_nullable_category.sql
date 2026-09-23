-- Migration to make katagori_id nullable in mitra_profil and pengajuan_mitra
-- because we are removing the "Keahlian Layanan" from the Profile Setup screen.

ALTER TABLE mitra_profil ALTER COLUMN katagori_id DROP NOT NULL;
ALTER TABLE pengajuan_mitra ALTER COLUMN katagori_id DROP NOT NULL;
