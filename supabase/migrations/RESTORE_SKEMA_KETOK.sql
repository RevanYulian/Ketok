-- ============================================================
-- RESTORE SKEMA KETOK -- dijalankan setelah tabel custom hilang
-- akibat `php artisan migrate:fresh` di Laravel.
--
-- Aman dijalankan langsung: tabel bawaan Laravel (cache, jobs,
-- sessions, migrations, dst.) TIDAK disentuh sama sekali oleh
-- script ini -- hanya membuat ulang tabel-tabel khusus Ketok.
-- ============================================================

create table if not exists admins (
  id_admin     serial primary key,
  nama         varchar(150) not null,
  email        varchar(150) not null unique,
  level_akses  varchar(50)
);

create table if not exists kategori_layanan (
  id_katagori    serial primary key,
  nama_katagori  varchar(150) not null,
  deskripsi      text
);

create table if not exists users (
  id_user        serial primary key,
  nama           varchar(150) not null,
  email          varchar(150) not null unique,
  role           varchar(30) not null default 'pengguna', -- 'pengguna' | 'mitra'
  status_mitra   varchar(30),                              -- null | 'pending' | 'aktif' | 'ditolak'
  auth_uid       uuid unique                               -- link ke Supabase Auth (auth.users.id)
);
create index if not exists idx_users_auth_uid on users(auth_uid);

create table if not exists mitra_profil (
  id_profil             serial primary key,
  user_id               integer not null references users(id_user),
  katagori_id           integer not null references kategori_layanan(id_katagori),
  keahlian              varchar(150),
  wilayah_operasional   varchar(150),
  status_online         boolean default false
);

create table if not exists pengajuan_mitra (
  id_pengajuan   serial primary key,
  user_id        integer not null references users(id_user),
  katagori_id    integer not null references kategori_layanan(id_katagori),
  direview_oleh  integer references admins(id_admin),
  status         varchar(30) default 'pending' -- 'pending' | 'disetujui' | 'ditolak'
);

create table if not exists pesanan (
  id_pesanan    serial primary key,
  pengguna_id   integer not null references users(id_user),
  mitra_id      integer references users(id_user), -- nullable: kosong selama masih dicari mitra
  katagori_id   integer not null references kategori_layanan(id_katagori),
  status        varchar(30) default 'mencari_mitra',
    -- 'mencari_mitra' | 'diproses' | 'menuju_lokasi' | 'dikerjakan'
    -- | 'selesai' | 'dibatalkan' | 'tidak_ada_mitra'
  lokasi        text,
  jadwal        timestamp,
  catatan       text
);

create table if not exists pesanan_broadcast_log (
  id_log        serial primary key,
  pesanan_id    integer not null references pesanan(id_pesanan),
  mitra_id      integer not null references users(id_user),
  status        varchar(20) not null default 'terkirim',
    -- 'terkirim' | 'diterima' | 'diabaikan' | 'kalah_cepat'
  responded_at  timestamp,
  dibuat_pada   timestamp default now()
);

create table if not exists notifikasi (
  id_notif     serial primary key,
  user_id      integer not null references users(id_user),
  judul        varchar(150) not null,
  status_baca  varchar(20) default 'belum'
);

create table if not exists invoice (
  id_invoice    serial primary key,
  pesanan_id    integer not null references pesanan(id_pesanan),
  jumlah_biaya  double precision not null,
  status_bayar  varchar(20) default 'menunggu' -- 'menunggu' | 'lunas'
);

create table if not exists ulasan (
  id_ulasan    serial primary key,
  pesanan_id   integer not null references pesanan(id_pesanan),
  rating       integer check (rating between 1 and 5),
  komentar     text
);

create table if not exists chat (
  id_chat       serial primary key,
  pesanan_id    integer not null references pesanan(id_pesanan),
  dibuat_pada   timestamp default now()
);

-- Refresh schema cache PostgREST supaya langsung dikenali Supabase API.
NOTIFY pgrst, 'reload schema';
