-- Migration untuk kebutuhan profil mitra baru.
-- Jalankan di Supabase SQL Editor.

alter table mitra_profil
  add column if not exists nama_usaha text,
  add column if not exists sub_kategori text,
  add column if not exists provinsi text,
  add column if not exists kota text,
  add column if not exists kecamatan text,
  add column if not exists kelurahan text,
  add column if not exists status_verifikasi varchar(30) default 'menunggu'
    check (status_verifikasi in ('menunggu', 'terverifikasi', 'ditolak'));

-- Pastikan data lama tidak terpaksa error saat dipakai.
update mitra_profil
set status_verifikasi = 'menunggu'
where status_verifikasi is null;

-- Opsional: default wilayah Malang untuk mitra yang belum punya data.
update mitra_profil
set provinsi = 'Jawa Timur', kota = 'Malang'
where provinsi is null and kota is null;

-- Pastikan semua mitra yang sudah lengkap tetap bisa masuk ke flow persetujuan.
-- Status default menunggu persetujuan berarti pesanan tidak akan muncul sampai admin menyetujui.
