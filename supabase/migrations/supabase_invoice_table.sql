-- ============================================================
-- Migration: Tabel Invoice & Pembayaran
-- ============================================================

CREATE TABLE IF NOT EXISTS invoice (
  id_invoice SERIAL PRIMARY KEY,
  pesanan_id INTEGER NOT NULL REFERENCES pesanan(id_pesanan) ON DELETE CASCADE,
  jumlah_biaya NUMERIC(14,2) NOT NULL,
  biaya_kunjungan NUMERIC(14,2) DEFAULT 0,
  diskon_voucher NUMERIC(14,2) DEFAULT 0,
  biaya_jasa NUMERIC(14,2) DEFAULT 0,
  biaya_sparepart NUMERIC(14,2) DEFAULT 0,
  metode_bayar VARCHAR(50) DEFAULT 'tunai', -- 'ketokpay', 'bca_va', 'mandiri_va', 'qris', 'tunai'
  status_bayar VARCHAR(20) DEFAULT 'menunggu', -- 'menunggu' | 'lunas' | 'dibatalkan'
  dibayar_pada TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_invoice_pesanan ON invoice(pesanan_id);

NOTIFY pgrst, 'reload schema';
