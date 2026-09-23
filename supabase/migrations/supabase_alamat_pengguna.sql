-- ============================================================
-- Migration: Tabel Alamat Pengguna (Alamat Tersimpan)
-- ============================================================

CREATE TABLE IF NOT EXISTS alamat_pengguna (
  id_alamat SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id_user) ON DELETE CASCADE,
  label VARCHAR(50) NOT NULL DEFAULT 'Rumah',
  nama_penerima VARCHAR(150),
  nomor_telepon VARCHAR(50),
  alamat_lengkap TEXT NOT NULL,
  catatan TEXT,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_alamat_pengguna_user ON alamat_pengguna(user_id);

-- Seed initial sample saved address for existing users if none exist
INSERT INTO alamat_pengguna (user_id, label, nama_penerima, nomor_telepon, alamat_lengkap, catatan, is_default)
SELECT 
  u.id_user,
  'Rumah Utama',
  u.nama,
  COALESCE(u.nomor_telepon, '081234567890'),
  'Jl. Ijen No. 45, Klojen, Kota Malang, Jawa Timur 65115',
  'Pagar hitam, dekat pos satpam perumahan',
  TRUE
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM alamat_pengguna ap WHERE ap.user_id = u.id_user
);

-- Seed second address (Kantor) for demo/convenience
INSERT INTO alamat_pengguna (user_id, label, nama_penerima, nomor_telepon, alamat_lengkap, catatan, is_default)
SELECT 
  u.id_user,
  'Kantor',
  u.nama,
  COALESCE(u.nomor_telepon, '081234567890'),
  'Jl. Soekarno Hatta No. 88, Lowokwaru, Kota Malang, Jawa Timur',
  'Lantai 2 Ruang Tech Support',
  FALSE
FROM users u
WHERE (
  SELECT COUNT(*) FROM alamat_pengguna ap WHERE ap.user_id = u.id_user
) = 1;

NOTIFY pgrst, 'reload schema';
