-- Katalog jasa untuk quick menu pengguna.
-- Jalankan setelah RESTORE_SKEMA_KETOK.sql.

create table if not exists jasa_layanan (
  id_jasa       serial primary key,
  katagori_id   integer references kategori_layanan(id_katagori),
  kategori_menu varchar(100) not null,
  nama_jasa    varchar(150) not null,
  deskripsi    text not null,
  harga_mulai  numeric(12, 2),
  aktif        boolean not null default true,
  dibuat_pada  timestamptz not null default now()
);

alter table jasa_layanan
  add column if not exists katagori_id integer references kategori_layanan(id_katagori);

insert into kategori_layanan (nama_katagori, deskripsi, kelompok)
select kategori_menu, deskripsi, 'Quick Menu Pengguna'
from (
  values
    ('Teknisi & Perbaikan', 'Perbaikan dan instalasi rumah.'),
    ('Kebersihan & Laundry', 'Kebersihan rumah dan layanan laundry.'),
    ('Pertukangan & Bangunan', 'Pertukangan, bangunan, dan renovasi.'),
    ('Elektronik & Gadget', 'Perbaikan elektronik dan gadget.'),
    ('Gaya Hidup & Perawatan', 'Layanan perawatan dan gaya hidup.'),
    ('Logistik & Lainnya', 'Logistik, pindahan, dan layanan lainnya.')
) as menu(kategori_menu, deskripsi)
where not exists (
  select 1 from kategori_layanan existing
  where existing.nama_katagori = menu.kategori_menu
);

create index if not exists idx_jasa_layanan_kategori_menu
  on jasa_layanan(kategori_menu);

insert into jasa_layanan (kategori_menu, nama_jasa, deskripsi, harga_mulai)
select kategori_menu, nama_jasa, deskripsi, harga_mulai
from (
  values
    ('Teknisi & Perbaikan', 'Perbaikan AC', 'Cuci AC, isi freon, dan perbaikan unit untuk rumah atau kantor.', 75000),
    ('Teknisi & Perbaikan', 'Instalasi Listrik', 'Pemasangan titik listrik baru dan pemeriksaan gangguan listrik.', 100000),
    ('Teknisi & Perbaikan', 'Perbaikan Pipa dan Keran', 'Perbaikan kebocoran pipa, keran, dan saluran air rumah.', 85000),
    ('Kebersihan & Laundry', 'Deep Cleaning Rumah', 'Pembersihan menyeluruh untuk ruangan, dapur, dan kamar mandi.', 150000),
    ('Kebersihan & Laundry', 'Cuci Sofa dan Karpet', 'Pembersihan sofa, karpet, dan upholstery dengan peralatan profesional.', 120000),
    ('Kebersihan & Laundry', 'Laundry Kiloan', 'Jemput dan antar laundry pakaian harian dengan proses praktis.', 10000),
    ('Pertukangan & Bangunan', 'Perbaikan Atap', 'Pemeriksaan dan perbaikan genteng atau atap yang bocor.', 150000),
    ('Pertukangan & Bangunan', 'Pemasangan Keramik', 'Pemasangan atau penggantian keramik lantai dan dinding.', 175000),
    ('Pertukangan & Bangunan', 'Perbaikan Furnitur', 'Perbaikan meja, kursi, lemari, dan furnitur rumah lainnya.', 100000),
    ('Elektronik & Gadget', 'Servis Mesin Cuci', 'Pemeriksaan dan perbaikan mesin cuci berbagai merek.', 100000),
    ('Elektronik & Gadget', 'Servis TV dan Kulkas', 'Diagnosa dan perbaikan elektronik rumah tangga.', 125000),
    ('Elektronik & Gadget', 'Servis Laptop dan Komputer', 'Perbaikan perangkat, instalasi ulang, dan pemeriksaan komponen.', 150000),
    ('Gaya Hidup & Perawatan', 'Barber Panggilan', 'Potong rambut profesional langsung di rumah pelanggan.', 75000),
    ('Gaya Hidup & Perawatan', 'Pijat Relaksasi', 'Layanan pijat relaksasi oleh mitra berpengalaman.', 150000),
    ('Gaya Hidup & Perawatan', 'Perawatan Kecantikan', 'Perawatan kecantikan praktis yang dapat dilakukan di rumah.', 125000),
    ('Logistik & Lainnya', 'Pindahan Barang', 'Bantuan angkut dan pindahan barang untuk rumah atau kantor.', 250000),
    ('Logistik & Lainnya', 'Kurir Instan', 'Pengiriman barang dan dokumen dalam area kota.', 20000),
    ('Logistik & Lainnya', 'Jasa Angkut', 'Bantuan mengangkut barang besar atau perlengkapan rumah.', 150000)
) as seed(kategori_menu, nama_jasa, deskripsi, harga_mulai)
where not exists (
  select 1
  from jasa_layanan existing
  where existing.kategori_menu = seed.kategori_menu
    and existing.nama_jasa = seed.nama_jasa
);

update jasa_layanan jasa
set katagori_id = kategori.id_katagori
from kategori_layanan kategori
where kategori.nama_katagori = jasa.kategori_menu
  and jasa.katagori_id is null;

-- Pelanggan perlu membaca layanan aktif mitra untuk halaman Jasa Populer.
alter table mitra_layanan enable row level security;
drop policy if exists "Pengguna melihat layanan mitra aktif" on mitra_layanan;
create policy "Pengguna melihat layanan mitra aktif"
  on mitra_layanan for select
  to authenticated
  using (aktif = true);

notify pgrst, 'reload schema';
