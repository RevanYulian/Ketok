-- Jalankan sekali di Supabase SQL Editor agar konten tips dapat dikelola dari database.
create table if not exists tips_artikel (
  id_tips serial primary key,
  judul varchar(150) not null,
  ringkasan text not null,
  aktif boolean not null default true,
  dibuat_pada timestamp not null default now()
);

create index if not exists idx_tips_artikel_aktif_dibuat
  on tips_artikel (aktif, dibuat_pada desc);

insert into tips_artikel (judul, ringkasan)
select 'Cara Merawat AC agar Awet',
       'Tips sederhana agar AC tetap dingin dan hemat listrik.'
where not exists (
  select 1 from tips_artikel where judul = 'Cara Merawat AC agar Awet'
);

insert into tips_artikel (judul, ringkasan)
select 'Alat Wajib Ada di Rumah',
       'Persiapan alat dasar untuk perbaikan kecil di hunian.'
where not exists (
  select 1 from tips_artikel where judul = 'Alat Wajib Ada di Rumah'
);

notify pgrst, 'reload schema';

create table if not exists pusat_bantuan (
  id_bantuan serial primary key,
  judul varchar(180) not null,
  jawaban text not null,
  kategori varchar(80),
  urutan integer not null default 0,
  aktif boolean not null default true,
  dibuat_pada timestamp not null default now()
);

create table if not exists panduan_sop (
  id_sop serial primary key,
  judul varchar(180) not null,
  isi text not null,
  kategori varchar(80),
  urutan integer not null default 0,
  aktif boolean not null default true,
  dibuat_pada timestamp not null default now()
);

insert into pusat_bantuan (judul, jawaban, kategori, urutan)
select 'Bagaimana menerima pesanan?', 'Buka Pesanan Tersedia, periksa detail layanan dan lokasi, lalu terima pesanan yang sesuai.', 'Pesanan', 1
where not exists (select 1 from pusat_bantuan where judul = 'Bagaimana menerima pesanan?');

insert into panduan_sop (judul, isi, kategori, urutan)
select 'Konfirmasi pekerjaan sebelum mulai', 'Pastikan detail layanan, lokasi, estimasi biaya, dan waktu kedatangan sudah dikonfirmasi dengan pelanggan.', 'Pelayanan', 1
where not exists (select 1 from panduan_sop where judul = 'Konfirmasi pekerjaan sebelum mulai');

notify pgrst, 'reload schema';

alter table users add column if not exists nomor_telepon varchar(30);
alter table users add column if not exists alamat text;

alter table kategori_layanan add column if not exists kelompok varchar(100);

insert into kategori_layanan (nama_katagori, deskripsi, kelompok)
select service_name, service_description, service_group
from (
  values
    ('Tukang listrik', 'Pemasangan dan perbaikan instalasi listrik rumah.', 'Perbaikan & Instalasi Rumah'),
    ('Tukang ledeng/pipa (plumbing)', 'Perbaikan saluran air, pipa, keran, dan sanitasi.', 'Perbaikan & Instalasi Rumah'),
    ('Tukang AC (service & instalasi)', 'Servis, perawatan, dan instalasi AC.', 'Perbaikan & Instalasi Rumah'),
    ('Tukang kayu/mebel', 'Pembuatan dan perbaikan furnitur serta pekerjaan kayu.', 'Perbaikan & Instalasi Rumah'),
    ('Tukang cat', 'Pengecatan interior dan eksterior rumah.', 'Perbaikan & Instalasi Rumah'),
    ('Tukang las', 'Pekerjaan pengelasan dan pembuatan konstruksi besi ringan.', 'Perbaikan & Instalasi Rumah'),
    ('Cleaning service rumah (harian/borongan)', 'Pembersihan rumah harian atau borongan.', 'Kebersihan'),
    ('Cuci sofa & karpet', 'Pembersihan sofa, karpet, dan upholstery.', 'Kebersihan'),
    ('Cuci AC', 'Pembersihan dan perawatan unit AC.', 'Kebersihan'),
    ('Pest control (basmi rayap, kecoa, tikus)', 'Pengendalian hama seperti rayap, kecoa, dan tikus.', 'Kebersihan'),
    ('Servis elektronik rumah tangga (TV, kulkas, mesin cuci)', 'Servis TV, kulkas, mesin cuci, dan elektronik rumah tangga lainnya.', 'Elektronik & Gadget'),
    ('Servis handphone/laptop', 'Perbaikan handphone, laptop, dan perangkat komputer.', 'Elektronik & Gadget'),
    ('Tukang bangunan/renovasi', 'Pekerjaan bangunan dan renovasi ringan.', 'Renovasi & Konstruksi Ringan'),
    ('Tukang keramik', 'Pemasangan dan perbaikan keramik lantai atau dinding.', 'Renovasi & Konstruksi Ringan'),
    ('Tukang atap/genteng', 'Perbaikan dan pemasangan atap atau genteng.', 'Renovasi & Konstruksi Ringan'),
    ('Tukang taman/kebun', 'Perawatan taman, kebun, dan ruang hijau.', 'Outdoor & Kendaraan'),
    ('Cuci mobil/motor panggilan', 'Layanan cuci kendaraan di lokasi pelanggan.', 'Outdoor & Kendaraan'),
    ('Pindahan (moving service)', 'Layanan membantu pindahan barang.', 'Outdoor & Kendaraan')
) as services(service_name, service_description, service_group)
where not exists (
  select 1 from kategori_layanan
  where nama_katagori = service_name
);

update kategori_layanan
set kelompok = 'Perbaikan & Instalasi Rumah'
where nama_katagori in ('Instalasi Listrik', 'Perbaikan AC')
  and kelompok is null;

update kategori_layanan
set kelompok = 'Elektronik & Gadget'
where nama_katagori = 'Servis Mesin Cuci'
  and kelompok is null;

notify pgrst, 'reload schema';