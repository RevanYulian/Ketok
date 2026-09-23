-- Migration & Seed for Artikel
CREATE TABLE IF NOT EXISTS public.artikel (
  id_artikel UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  judul TEXT NOT NULL,
  ringkasan TEXT NOT NULL,
  isi TEXT NOT NULL,
  gambar_url TEXT,
  aktif BOOLEAN DEFAULT true,
  dibuat_pada TIMESTAMPTZ DEFAULT now()
);

-- RLS
ALTER TABLE public.artikel ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Enable read access for all users" ON public.artikel FOR SELECT USING (true);

-- Seed Data
INSERT INTO public.artikel (judul, ringkasan, isi) VALUES
(
  'Pentingnya Keselamatan Kerja (K3) bagi Tukang', 
  'Keselamatan adalah prioritas utama. Ketahui perlengkapan yang wajib Anda bawa sebelum mulai bekerja.', 
  'Dalam setiap pekerjaan pertukangan, baik itu skala kecil maupun besar, keselamatan kerja (K3) adalah hal yang tidak boleh ditawar. Banyak kecelakaan kerja terjadi karena kelalaian kecil, seperti tidak memakai sarung tangan pelindung atau kacamata kerja.\n\nBerikut adalah beberapa perlengkapan standar yang sebaiknya selalu Anda siapkan di tas perkakas Anda:\n1. Kacamata Pelindung: Melindungi mata dari debu, percikan api, atau serpihan material saat memotong atau mengebor.\n2. Sarung Tangan: Sangat penting saat menangani material kasar, bahan kimia, atau instalasi listrik.\n3. Sepatu Safety: Mencegah cedera kaki akibat tertimpa benda berat atau tertusuk paku.\n4. Masker: Wajib saat melakukan pengecatan, pengamplasan, atau bekerja di area berdebu.\n\nSelain perlengkapan, selalu pastikan kondisi tubuh Anda fit sebelum menerima pekerjaan berat. Jangan ragu untuk meminta bantuan rekan jika pekerjaan membutuhkan lebih dari satu orang. Keselamatan Anda menentukan masa depan karir Anda!'
),
(
  'Cara Meningkatkan Rating dan Ulasan Pelanggan', 
  'Ulasan positif dapat meningkatkan peluang Anda mendapatkan lebih banyak pesanan setiap harinya.', 
  'Sebagai Mitra, rating dan ulasan (review) dari pelanggan adalah "nyawa" dari akun Anda. Semakin tinggi rating yang Anda miliki, semakin besar kemungkinan Anda diprioritaskan saat ada pesanan baru yang masuk.\n\nLalu, bagaimana cara memastikan pelanggan memberikan ulasan Bintang 5?\n\n1. Ketepatan Waktu: Datanglah sesuai jadwal yang telah disepakati. Jika Anda terlambat karena macet atau cuaca, selalu kabari pelanggan dari jauh-jauh hari.\n2. Komunikasi yang Sopan: Sapa pelanggan dengan ramah. Sebelum memulai kerja, jelaskan masalah yang Anda temukan dan apa yang akan Anda lakukan.\n3. Transparansi Harga: Jika ada biaya tambahan untuk suku cadang, bicarakan dan minta persetujuan pelanggan sebelum Anda membelinya.\n4. Kebersihan: Ini yang sering dilupakan! Setelah pekerjaan selesai, sapu atau bersihkan area tempat Anda bekerja. Pelanggan sangat menyukai tukang yang tidak meninggalkan jejak kotoran.\n\nDengan menerapkan 4 poin di atas, pelanggan tidak hanya akan memberikan ulasan yang bagus, tapi kemungkinan besar mereka akan menjadikan Anda sebagai tukang langganan mereka.'
),
(
  'Manajemen Keuangan Dasar untuk Pekerja Harian', 
  'Pisahkan uang hasil kerja dengan uang belanja pribadi agar arus kas usaha Anda lebih teratur dan berkembang.', 
  'Banyak mitra atau pekerja harian yang kesulitan mengembangkan usahanya atau membeli peralatan baru karena satu kesalahan fatal: mencampur uang pribadi dan uang usaha.\n\nKetika Anda menerima bayaran dari pelanggan, uang tersebut sebaiknya tidak langsung dihabiskan semua untuk kebutuhan sehari-hari. Berikut adalah panduan sederhana mengelola pendapatan Anda:\n\n1. Alokasikan untuk Operasional (Bensin, makan siang, parkir).\n2. Sisihkan untuk "Dana Alat": Tabung sekitar 10-15% dari pendapatan Anda ke celengan atau rekening khusus. Dana ini nantinya digunakan untuk membeli mesin baru, memperbaiki alat yang rusak, atau upgrade perlengkapan.\n3. Pisahkan Modal Bahan: Jika pelanggan membayar uang muka untuk bahan/material, JANGAN PERNAH memakai uang tersebut untuk keperluan lain.\n\nDengan memisahkan keuangan dengan disiplin, Anda bisa menabung untuk membeli perlengkapan yang lebih canggih, yang pada akhirnya akan membuat pekerjaan Anda lebih cepat selesai dan mendatangkan lebih banyak uang!'
);

NOTIFY pgrst, 'reload schema';
