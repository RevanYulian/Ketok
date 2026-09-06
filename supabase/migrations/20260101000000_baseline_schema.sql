-- Baseline schema untuk Ketok, berdasarkan ERD di PRD (Bab 12).
-- File ini adalah CATATAN struktur yang sudah ada di Supabase saat ini,
-- BUKAN migration yang otomatis dijalankan. Kalau kamu mengubah skema
-- lewat Supabase Dashboard, catat perubahannya di sini juga (atau buat
-- file migration baru dengan `supabase migration new <nama_perubahan>`)
-- supaya riwayat perubahan skema selalu tersinkron dengan dokumentasi.

-- ============================================================
-- 1. kategori_layanan
-- ============================================================
create table if not exists kategori_layanan (
  id           uuid primary key default gen_random_uuid(),
  nama         text not null,
  deskripsi    text,
  created_at   timestamptz default now()
);

-- ============================================================
-- 2. admin
-- ============================================================
create table if not exists admin (
  id           uuid primary key default gen_random_uuid(),
  nama         text not null,
  email        text unique not null,
  level_akses  text not null default 'admin',
  created_at   timestamptz default now()
);

-- ============================================================
-- 3. users (menampung role pengguna & mitra dalam satu tabel)
-- ============================================================
create table if not exists users (
  id             uuid primary key default gen_random_uuid(),
  nama           text not null,
  email          text unique not null,
  no_hp          text,
  role           text not null default 'pengguna', -- 'pengguna' | 'mitra'
  status_mitra   text,                              -- null | 'pending' | 'aktif' | 'ditolak'
  created_at     timestamptz default now()
);

-- ============================================================
-- 4. mitra_profil (hanya terisi jika users.role = 'mitra')
-- ============================================================
create table if not exists mitra_profil (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references users(id),
  kategori_layanan_id   uuid not null references kategori_layanan(id),
  wilayah_operasional   text,
  status_online         boolean default false,
  rating_rata2          numeric(2,1) default 0,
  created_at            timestamptz default now()
);

-- ============================================================
-- 5. pengajuan_mitra
-- ============================================================
create table if not exists pengajuan_mitra (
  id                    uuid primary key default gen_random_uuid(),
  user_id               uuid not null references users(id),
  kategori_layanan_id   uuid not null references kategori_layanan(id),
  no_ktp                text not null,
  foto_ktp_url          text,
  status                text not null default 'pending', -- 'pending' | 'disetujui' | 'ditolak'
  catatan_admin         text,
  direview_oleh         uuid references admin(id),
  created_at            timestamptz default now()
);

-- ============================================================
-- 6. pesanan (inti transaksi, mendukung broadcast first-accept)
-- ============================================================
create table if not exists pesanan (
  id                    uuid primary key default gen_random_uuid(),
  pengguna_id           uuid not null references users(id),
  mitra_id              uuid references users(id), -- null selama masih di-broadcast
  kategori_layanan_id   uuid not null references kategori_layanan(id),
  lokasi                text not null,
  jadwal                timestamptz,
  catatan               text,
  status                text not null default 'mencari_mitra',
    -- 'mencari_mitra' | 'diproses' | 'menuju_lokasi' | 'dikerjakan'
    -- | 'selesai' | 'dibatalkan' | 'tidak_ada_mitra'
  created_at            timestamptz default now()
);

-- Tabel pendukung broadcast: mencatat mitra mana saja yang menerima
-- notifikasi broadcast untuk satu pesanan, dan bagaimana mereka merespons.
-- Dipakai untuk logic "mitra pertama yang accept yang menang".
create table if not exists pesanan_broadcast_log (
  id           uuid primary key default gen_random_uuid(),
  pesanan_id   uuid not null references pesanan(id),
  mitra_id     uuid not null references users(id),
  status       text not null default 'terkirim', -- 'terkirim' | 'diterima' | 'diabaikan' | 'kalah_cepat'
  responded_at timestamptz,
  created_at   timestamptz default now()
);

-- ============================================================
-- 7. notifikasi
-- ============================================================
create table if not exists notifikasi (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references users(id),
  judul        text not null,
  isi          text,
  sudah_dibaca boolean default false,
  created_at   timestamptz default now()
);

-- ============================================================
-- 8. invoice
-- ============================================================
create table if not exists invoice (
  id             uuid primary key default gen_random_uuid(),
  pesanan_id     uuid not null references pesanan(id),
  jumlah_biaya   numeric(12,2) not null,
  metode_bayar   text, -- 'tunai' | 'digital'
  status_bayar   text not null default 'menunggu', -- 'menunggu' | 'lunas'
  created_at     timestamptz default now()
);

-- ============================================================
-- 9. ulasan
-- ============================================================
create table if not exists ulasan (
  id           uuid primary key default gen_random_uuid(),
  pesanan_id   uuid not null references pesanan(id),
  rating       int not null check (rating between 1 and 5),
  komentar     text,
  created_at   timestamptz default now()
);

-- ============================================================
-- 10. chat
-- ============================================================
create table if not exists chat (
  id           uuid primary key default gen_random_uuid(),
  pesanan_id   uuid not null references pesanan(id),
  pengirim_id  uuid not null references users(id),
  pesan        text not null,
  created_at   timestamptz default now()
);
