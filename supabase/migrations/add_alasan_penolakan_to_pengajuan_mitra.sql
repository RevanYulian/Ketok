-- Menambahkan kolom alasan_penolakan ke tabel pengajuan_mitra jika belum ada
ALTER TABLE pengajuan_mitra ADD COLUMN IF NOT EXISTS alasan_penolakan TEXT;
