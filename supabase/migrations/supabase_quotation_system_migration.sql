-- Migration for Quotation System (Persetujuan Biaya)

-- 1. Tambah kolom di tabel pesanan
ALTER TABLE public.pesanan
ADD COLUMN IF NOT EXISTS biaya_kunjungan numeric(14,2) default 0,
ADD COLUMN IF NOT EXISTS status_persetujuan_biaya varchar(30) default 'menunggu_estimasi'
  check (status_persetujuan_biaya in ('menunggu_estimasi', 'menunggu_persetujuan', 'disetujui', 'ditolak'));

-- 2. Tambah kolom di tabel invoice
ALTER TABLE public.invoice
ADD COLUMN IF NOT EXISTS biaya_jasa numeric(14,2) default 0,
ADD COLUMN IF NOT EXISTS biaya_sparepart numeric(14,2) default 0;

NOTIFY pgrst, 'reload schema';
