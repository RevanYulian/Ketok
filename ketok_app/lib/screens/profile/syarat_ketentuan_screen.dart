import 'package:flutter/material.dart';


class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Syarat & Ketentuan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syarat dan Ketentuan Layanan Ketok',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Terakhir diperbarui: 1 September 2026',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Ketentuan Umum',
              'Selamat datang di Ketok. Dengan menggunakan aplikasi ini, Anda menyatakan setuju untuk mematuhi Syarat dan Ketentuan berikut. Aplikasi Ketok berfungsi menghubungkan pelanggan dengan mitra teknisi profesional.',
            ),
            _buildSection(
              '2. Pemesanan Layanan',
              'Pelanggan wajib memberikan alamat yang benar, nomor kontak aktif, serta deskripsi keluhan atau kebutuhan jasa secara jelas agar mitra teknisi dapat mempersiapkan perkakas dan material yang tepat.',
            ),
            _buildSection(
              '3. Biaya Kunjungan & Tarif Pengerjaan',
              'Biaya kunjungan dikenakan saat teknisi tiba di lokasi Anda untuk melakukan pengecekan. Estimasi biaya perbaikan menyeluruh akan disampaikan oleh teknisi sebelum pekerjaan dimulai. Anda berhak menolak pengerjaan jika tidak menyetujui estimasi biaya, dengan hanya membayar biaya kunjungan.',
            ),
            _buildSection(
              '4. Pembatalan Pesanan',
              'Pembatalan pesanan dapat dilakukan tanpa biaya sebelum mitra teknisi bergerak menuju ke lokasi Anda. Apabila teknisi sudah berada dalam perjalanan menuju alamat Anda, biaya kunjungan dasar tetap berlaku.',
            ),
            _buildSection(
              '5. Garansi Pengerjaan Layanan',
              'Ketok memberikan jaminan garansi pengerjaan selama 14 hingga 30 hari untuk pekerjaan yang diselesaikan melalui sistem aplikasi resmi. Klaim garansi dapat diajukan dengan menghubungi layanan pelanggan.',
            ),
            _buildSection(
              '6. Keamanan & Tanggung Jawab',
              'Pelanggan diharapkan mendampingi atau memastikan ada perwakilan di lokasi selama proses pengerjaan oleh teknisi berlangsung demi kenyamanan dan keamanan bersama.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
