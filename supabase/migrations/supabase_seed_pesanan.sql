-- Seed data pesanan untuk Ketok Mitra.
-- Jalankan di Supabase SQL Editor setelah RESTORE_SKEMA_KETOK.sql.
-- Data pesanan akan dimiliki oleh user pertama dengan role = 'mitra'.

DO $$
DECLARE
  v_mitra_id integer;
  v_customer_1 integer;
  v_customer_2 integer;
  v_customer_3 integer;
  v_ac_id integer;
  v_laundry_id integer;
  v_electric_id integer;
  v_order_id integer;
BEGIN
  SELECT id_user
    INTO v_mitra_id
    FROM users
   WHERE role = 'mitra'
   ORDER BY id_user
   LIMIT 1;

  IF v_mitra_id IS NULL THEN
    RAISE EXCEPTION 'Belum ada user dengan role mitra. Daftarkan akun Mitra terlebih dahulu.';
  END IF;

  INSERT INTO users (nama, email, role, status_mitra)
  VALUES ('Anisa Wijaya', 'anisa.seed@ketok.local', 'pengguna', NULL)
  ON CONFLICT (email) DO NOTHING;
  SELECT id_user INTO v_customer_1 FROM users WHERE email = 'anisa.seed@ketok.local';

  INSERT INTO users (nama, email, role, status_mitra)
  VALUES ('Rian Hidayat', 'rian.seed@ketok.local', 'pengguna', NULL)
  ON CONFLICT (email) DO NOTHING;
  SELECT id_user INTO v_customer_2 FROM users WHERE email = 'rian.seed@ketok.local';

  INSERT INTO users (nama, email, role, status_mitra)
  VALUES ('Siti Maryam', 'siti.seed@ketok.local', 'pengguna', NULL)
  ON CONFLICT (email) DO NOTHING;
  SELECT id_user INTO v_customer_3 FROM users WHERE email = 'siti.seed@ketok.local';

  INSERT INTO kategori_layanan (nama_katagori, deskripsi)
  SELECT 'Perbaikan AC', 'Perbaikan dan perawatan pendingin ruangan'
   WHERE NOT EXISTS (
     SELECT 1 FROM kategori_layanan WHERE nama_katagori = 'Perbaikan AC'
   );
  SELECT id_katagori INTO v_ac_id FROM kategori_layanan WHERE nama_katagori = 'Perbaikan AC' LIMIT 1;

  INSERT INTO kategori_layanan (nama_katagori, deskripsi)
  SELECT 'Servis Mesin Cuci', 'Perbaikan mesin cuci dan pengering'
   WHERE NOT EXISTS (
     SELECT 1 FROM kategori_layanan WHERE nama_katagori = 'Servis Mesin Cuci'
   );
  SELECT id_katagori INTO v_laundry_id FROM kategori_layanan WHERE nama_katagori = 'Servis Mesin Cuci' LIMIT 1;

  INSERT INTO kategori_layanan (nama_katagori, deskripsi)
  SELECT 'Instalasi Listrik', 'Pemasangan dan perbaikan instalasi listrik'
   WHERE NOT EXISTS (
     SELECT 1 FROM kategori_layanan WHERE nama_katagori = 'Instalasi Listrik'
   );
  SELECT id_katagori INTO v_electric_id FROM kategori_layanan WHERE nama_katagori = 'Instalasi Listrik' LIMIT 1;

  -- Hapus data seed lama saja sebelum memasukkan ulang contoh yang sama.
  -- Pesanan pengguna lain tidak tersentuh.
  DELETE FROM invoice
   WHERE pesanan_id IN (
     SELECT id_pesanan FROM pesanan
      WHERE mitra_id = v_mitra_id
        AND pengguna_id IN (v_customer_1, v_customer_2, v_customer_3)
        AND catatan IN (
          'Perbaikan AC Split 1 PK',
          'Cuci AC dan tambah freon untuk 2 unit',
          'Servis mesin cuci dan pengering',
          'Pemasangan titik listrik baru',
          'Perbaikan AC dibatalkan oleh pelanggan'
        )
   );
  DELETE FROM pesanan_broadcast_log
   WHERE mitra_id = v_mitra_id
     AND pesanan_id IN (
       SELECT id_pesanan FROM pesanan
        WHERE pengguna_id IN (v_customer_1, v_customer_2, v_customer_3)
          AND catatan IN (
            'Perbaikan AC Split 1 PK',
            'Cuci AC dan tambah freon (2 unit)'
          )
     );
  DELETE FROM pesanan
   WHERE mitra_id = v_mitra_id
     AND pengguna_id IN (v_customer_1, v_customer_2, v_customer_3)
     AND catatan IN (
       'Perbaikan AC Split 1 PK',
       'Cuci AC dan tambah freon untuk 2 unit',
       'Servis mesin cuci dan pengering',
       'Pemasangan titik listrik baru',
       'Perbaikan AC dibatalkan oleh pelanggan'
     );
  DELETE FROM invoice
   WHERE pesanan_id IN (
     SELECT id_pesanan FROM pesanan
      WHERE mitra_id IS NULL
        AND pengguna_id IN (v_customer_1, v_customer_2)
        AND catatan IN (
          'Perbaikan AC Split 1 PK',
          'Cuci AC dan tambah freon (2 unit)'
        )
   );
  DELETE FROM pesanan_broadcast_log
   WHERE mitra_id = v_mitra_id
     AND pesanan_id IN (
       SELECT id_pesanan FROM pesanan
        WHERE mitra_id IS NULL
          AND pengguna_id IN (v_customer_1, v_customer_2)
          AND catatan IN (
            'Perbaikan AC Split 1 PK',
            'Cuci AC dan tambah freon (2 unit)'
          )
     );
  DELETE FROM pesanan
   WHERE mitra_id IS NULL
     AND pengguna_id IN (v_customer_1, v_customer_2)
     AND catatan IN (
       'Perbaikan AC Split 1 PK',
       'Cuci AC dan tambah freon (2 unit)'
     );

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_1, v_mitra_id, v_ac_id, 'menuju_lokasi',
    'Jl. Tebet Barat Dalam No. 12, Jakarta Selatan',
    now() + interval '2 hours',
    'Perbaikan AC Split 1 PK'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 150000, 'menunggu');

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_2, v_mitra_id, v_ac_id, 'diproses',
    'Apartemen Kalibata City Tower B',
    now() + interval '1 day',
    'Cuci AC dan tambah freon untuk 2 unit'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 220000, 'menunggu');

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_3, v_mitra_id, v_laundry_id, 'selesai',
    'Cluster Palm Spring Blok B3, Tangerang Selatan',
    now() - interval '3 days',
    'Servis mesin cuci dan pengering'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 350000, 'lunas');

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_1, v_mitra_id, v_electric_id, 'selesai',
    'Jl. Cilandak Barat Kav. 14, Jakarta Selatan',
    now() - interval '10 days',
    'Pemasangan titik listrik baru'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 185000, 'lunas');

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_2, v_mitra_id, v_ac_id, 'dibatalkan',
    'Jl. Kemang Raya No. 8, Jakarta Selatan',
    now() - interval '14 days',
    'Perbaikan AC dibatalkan oleh pelanggan'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 125000, 'menunggu');

  -- Pesanan baru untuk diuji melalui tombol Terima/Tolak di Beranda Mitra.
  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_1, NULL, v_ac_id, 'mencari_mitra',
    'Jl. Tebet Barat Dalam No. 12, Jakarta Selatan',
    now() + interval '4 hours',
    'Perbaikan AC Split 1 PK'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 150000, 'menunggu');
  INSERT INTO pesanan_broadcast_log (pesanan_id, mitra_id, status)
  VALUES (v_order_id, v_mitra_id, 'terkirim');

  INSERT INTO pesanan (pengguna_id, mitra_id, katagori_id, status, lokasi, jadwal, catatan)
  VALUES (
    v_customer_2, NULL, v_laundry_id, 'mencari_mitra',
    'Apartemen Kalibata City Tower B',
    now() + interval '1 day',
    'Cuci AC dan tambah freon (2 unit)'
  ) RETURNING id_pesanan INTO v_order_id;
  INSERT INTO invoice (pesanan_id, jumlah_biaya, status_bayar)
  VALUES (v_order_id, 220000, 'menunggu');
  INSERT INTO pesanan_broadcast_log (pesanan_id, mitra_id, status)
  VALUES (v_order_id, v_mitra_id, 'terkirim');

  RAISE NOTICE 'Seed pesanan selesai untuk mitra id_user = %', v_mitra_id;
END $$;

NOTIFY pgrst, 'reload schema';
