-- Seed data untuk Tips & Artikel (Dapat dijalankan di Supabase SQL Editor)

insert into tips_artikel (judul, ringkasan)
select 'Cara Mengatasi Pipa Air Bocor Sementara',
       'Gunakan selotip khusus pipa (seal tape) atau karet ban dalam sebagai penanganan darurat sebelum tukang ledeng tiba.'
where not exists (select 1 from tips_artikel where judul = 'Cara Mengatasi Pipa Air Bocor Sementara');

insert into tips_artikel (judul, ringkasan)
select 'Langkah Awal Saat Terjadi Korsleting Listrik',
       'Segera matikan MCB (Miniature Circuit Breaker) utama di rumah Anda dan hindari menyentuh stop kontak yang hangus.'
where not exists (select 1 from tips_artikel where judul = 'Langkah Awal Saat Terjadi Korsleting Listrik');

insert into tips_artikel (judul, ringkasan)
select 'Tips Memilih Cat Dinding Interior',
       'Pilih cat berjenis "easy clean" atau "washable" untuk area yang sering dilewati agar mudah dibersihkan dari noda.'
where not exists (select 1 from tips_artikel where judul = 'Tips Memilih Cat Dinding Interior');

insert into tips_artikel (judul, ringkasan)
select 'Merawat Furnitur Kayu Agar Tidak Berjamur',
       'Pastikan sirkulasi udara di dalam ruangan lancar dan gunakan kamper atau gel silika di dalam lemari kayu.'
where not exists (select 1 from tips_artikel where judul = 'Merawat Furnitur Kayu Agar Tidak Berjamur');

insert into tips_artikel (judul, ringkasan)
select 'Kapan Harus Memanggil Jasa Pest Control?',
       'Jika Anda melihat serbuk kayu di lantai (tanda rayap) atau bau kotoran tikus yang menyengat, segera hubungi profesional.'
where not exists (select 1 from tips_artikel where judul = 'Kapan Harus Memanggil Jasa Pest Control?');

insert into tips_artikel (judul, ringkasan)
select 'Trik Membersihkan Filter Mesin Cuci',
       'Bersihkan filter pada mesin cuci Anda setidaknya sebulan sekali agar aliran air tetap lancar dan cucian tidak bau.'
where not exists (select 1 from tips_artikel where judul = 'Trik Membersihkan Filter Mesin Cuci');

insert into tips_artikel (judul, ringkasan)
select 'Pentingnya Servis AC Secara Rutin',
       'Melakukan cuci AC setiap 3-4 bulan sekali dapat memperpanjang umur kompresor dan membuat tagihan listrik lebih hemat.'
where not exists (select 1 from tips_artikel where judul = 'Pentingnya Servis AC Secara Rutin');

insert into tips_artikel (judul, ringkasan)
select 'Persiapan Memasuki Musim Hujan',
       'Cek kondisi atap dan talang air rumah Anda. Bersihkan kotoran atau daun kering yang menyumbat aliran air hujan.'
where not exists (select 1 from tips_artikel where judul = 'Persiapan Memasuki Musim Hujan');

notify pgrst, 'reload schema';
