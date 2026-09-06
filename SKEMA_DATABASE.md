# Skema Database Ketok

Dokumen ini adalah rujukan bersama untuk `ketok_app`, `ketok_mitra`, dan
`ketok_dashboard`. **Sebelum mengubah tabel di Supabase**, cek dulu:

1. Apakah `ketok_app` (Pengguna) pakai tabel/kolom ini?
2. Apakah `ketok_mitra` pakai?
3. Apakah `ketok_dashboard` (Laravel) query tabel ini?

Kalau salah satu jawabannya iya, update juga dokumen ini + kode di project
terkait, jangan cuma ubah di Supabase Dashboard.

File SQL sumber schema ada di `supabase/migrations/20260101000000_baseline_schema.sql`.

---

## Daftar Tabel

| Tabel | Fungsi |
|---|---|
| `kategori_layanan` | Daftar kategori/jenis jasa yang tersedia di platform |
| `admin` | Data admin platform & level aksesnya |
| `users` | Tabel utama semua pengguna (role `pengguna` / `mitra`, dibedakan lewat kolom `role` & `status_mitra`) |
| `mitra_profil` | Profil tambahan mitra: keahlian & wilayah operasional |
| `pengajuan_mitra` | Proses pengajuan user menjadi mitra untuk kategori tertentu |
| `pesanan` | Inti transaksi — pesanan dari pengguna ke mitra |
| `pesanan_broadcast_log` | **Baru**: mencatat mitra mana saja yang menerima broadcast pesanan & responsnya (untuk logic "mitra pertama yang accept yang menang") |
| `notifikasi` | Notifikasi ke user (judul, isi, status baca) |
| `invoice` | Tagihan dari sebuah pesanan |
| `ulasan` | Rating & komentar pengguna terhadap pesanan selesai |
| `chat` | Riwayat percakapan pengguna-mitra per pesanan |

---

## Relasi Utama

- `kategori_layanan` → `mitra_profil`, `pengajuan_mitra`, `pesanan` (satu kategori dipakai banyak mitra/pengajuan/pesanan)
- `admin` → `pengajuan_mitra` (satu admin bisa mereview banyak pengajuan)
- `users` → `mitra_profil` (satu user ber-role mitra punya satu profil mitra)
- `users` → `pengajuan_mitra` (satu user bisa mengajukan diri jadi mitra)
- `users` → `pesanan` **dua kali**: sebagai `pengguna_id` (yang memesan) dan `mitra_id` (yang menerima, diisi setelah proses broadcast selesai — **null selama masih dicari mitra**)
- `pesanan` → `pesanan_broadcast_log` (satu pesanan bisa broadcast ke banyak mitra sekaligus, dicatat satu baris per mitra)
- `pesanan` → `invoice` (satu pesanan menghasilkan satu invoice)
- `pesanan` → `ulasan` (satu pesanan bisa dapat satu ulasan)
- `pesanan` → `chat` (satu pesanan punya riwayat chat)
- `users` → `notifikasi` (satu user terima banyak notifikasi)

---

## Catatan Khusus: Alur Broadcast Pesanan

Sesuai activity diagram "Pemesanan Jasa", `pesanan.mitra_id` **tidak langsung
diisi saat pesanan dibuat**. Urutannya:

1. Pesanan dibuat → `status = 'mencari_mitra'`, `mitra_id = null`.
2. Sistem cari mitra sesuai kategori & wilayah yang `status_online = true`.
3. Kalau ada, sistem insert satu baris `pesanan_broadcast_log` untuk **setiap**
   mitra yang menerima broadcast (`status = 'terkirim'`).
4. Mitra pertama yang tekan "Terima" → baris log mitra itu diupdate jadi
   `status = 'diterima'`, lalu `pesanan.mitra_id` diisi & `status` pesanan
   jadi `'diproses'`.
5. Baris log mitra lain yang belum sempat merespons diupdate jadi
   `status = 'kalah_cepat'` (dipakai untuk menampilkan pesan "Pesanan sudah
   diambil mitra lain" di app mereka).

**Penting untuk yang develop app Mitra**: jangan query `pesanan` langsung
untuk menampilkan daftar pesanan masuk — query lewat `pesanan_broadcast_log`
yang `mitra_id` = mitra yang login DAN `status = 'terkirim'`, supaya mitra
hanya melihat pesanan yang memang di-broadcast ke dia dan belum diambil
orang lain.

---

## Cara update dokumen ini

Kalau kamu ubah skema lewat Supabase Dashboard atau SQL editor:
1. Tulis perubahannya sebagai file baru di `supabase/migrations/` (beri nama
   `YYYYMMDDHHMMSS_deskripsi_singkat.sql`).
2. Update tabel & catatan di file ini biar tetap jadi rujukan yang akurat.
3. Kalau perubahan itu breaking (mengubah nama kolom, hapus kolom, dll.),
   catat juga di `CHANGELOG.md` masing-masing project yang terdampak.
