-- Jalankan sekali di Supabase SQL Editor.
-- Pesanan tetap mencari mitra sampai pelanggan memilih salah satu penawaran.
create table if not exists pesanan_penawaran (
  id_penawaran serial primary key,
  pesanan_id integer not null references pesanan(id_pesanan) on delete cascade,
  mitra_id integer not null references users(id_user) on delete cascade,
  harga numeric(12, 2) not null check (harga >= 0),
  detail_penawaran text not null default '',
  status varchar(30) not null default 'diajukan'
    check (status in ('diajukan', 'dipilih', 'ditolak', 'dibatalkan')),
  dibuat_pada timestamp not null default now(),
  diperbarui_pada timestamp not null default now(),
  unique (pesanan_id, mitra_id)
);

create index if not exists idx_pesanan_penawaran_pesanan_status
  on pesanan_penawaran (pesanan_id, status);

create index if not exists idx_pesanan_penawaran_mitra
  on pesanan_penawaran (mitra_id, status);

notify pgrst, 'reload schema';