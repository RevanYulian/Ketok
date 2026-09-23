-- ============================================================
-- Migration: Sistem Voucher & Voucher Pengguna Ketok
-- ============================================================

create table if not exists voucher (
  id_voucher serial primary key,
  kode_voucher varchar(50) unique not null,
  judul varchar(150) not null,
  deskripsi text,
  tipe_diskon varchar(20) not null default 'nominal', -- 'nominal' | 'persen'
  nilai_diskon numeric not null,
  maksimal_diskon numeric,
  minimal_transaksi numeric default 0,
  berlaku_sampai timestamp default (now() + interval '90 days'),
  aktif boolean default true,
  kategori varchar(50) default 'semua'
);

create table if not exists pengguna_voucher (
  id_pengguna_voucher serial primary key,
  user_id integer not null references users(id_user) on delete cascade,
  voucher_id integer not null references voucher(id_voucher) on delete cascade,
  status varchar(20) default 'aktif', -- 'aktif' | 'terpakai' | 'kedaluwarsa'
  diklaim_pada timestamp default now(),
  digunakan_pada timestamp,
  pesanan_id integer references pesanan(id_pesanan) on delete set null
);

create index if not exists idx_pengguna_voucher_user on pengguna_voucher(user_id);
create index if not exists idx_pengguna_voucher_status on pengguna_voucher(status);

-- Seed initial master vouchers
insert into voucher (kode_voucher, judul, deskripsi, tipe_diskon, nilai_diskon, maksimal_diskon, minimal_transaksi, berlaku_sampai, aktif, kategori)
values
  ('KETOKBARU', 'Diskon 30% Pengguna Baru', 'Potongan 30% hingga Rp 50.000 untuk pemesanan pertama semua layanan.', 'persen', 30, 50000, 30000, now() + interval '90 days', true, 'semua'),
  ('BEBASONGKIR', 'Gratis Biaya Kunjungan', 'Potongan biaya kunjungan teknisi s/d Rp 20.000 untuk seluruh area.', 'nominal', 20000, 20000, 25000, now() + interval '60 days', true, 'semua'),
  ('ACBERSIH', 'Cashback Rp 25.000 Servis AC', 'Potongan langsung Rp 25.000 untuk perbaikan dan cuci AC.', 'nominal', 25000, 25000, 50000, now() + interval '45 days', true, 'ac')
on conflict (kode_voucher) do update set
  judul = excluded.judul,
  deskripsi = excluded.deskripsi,
  tipe_diskon = excluded.tipe_diskon,
  nilai_diskon = excluded.nilai_diskon,
  maksimal_diskon = excluded.maksimal_diskon,
  minimal_transaksi = excluded.minimal_transaksi,
  aktif = excluded.aktif;

-- Assign initial vouchers to existing users if they don't have them yet
insert into pengguna_voucher (user_id, voucher_id, status)
select u.id_user, v.id_voucher, 'aktif'
from users u
cross join voucher v
where v.aktif = true
and not exists (
  select 1 from pengguna_voucher pv
  where pv.user_id = u.id_user and pv.voucher_id = v.id_voucher
);

notify pgrst, 'reload schema';
