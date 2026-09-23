import 'package:flutter/material.dart';


class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kebijakan Privasi',
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
              'Kebijakan Privasi Pengguna Ketok',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Terakhir diperbarui: 1 September 2026',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Pengumpulan Data Pribadi',
              'Kami mengumpulkan informasi yang Anda berikan saat mendaftar dan menggunakan layanan, seperti nama lengkap, alamat email, nomor telepon, alamat lokasi rumah atau kantor, serta catatan pesanan.',
            ),
            _buildSection(
              '2. Data Lokasi & GPS',
              'Aplikasi membutuhkan izin akses lokasi Anda untuk menentukan alamat pengerjaan secara akurat serta mencarikan mitra teknisi terdekat yang siap datang.',
            ),
            _buildSection(
              '3. Berbagi Informasi dengan Mitra',
              'Nama, nomor telepon, dan alamat yang Anda tentukan pada pesanan akan dibagikan kepada teknisi yang menerima pesanan tersebut semata-mata untuk koordinasi kedatangan dan pengerjaan.',
            ),
            _buildSection(
              '4. Keamanan & Enkripsi',
              'Data akun Anda disimpan dengan teknologi keamanan dan enkripsi database cloud (Supabase) untuk mencegah akses tidak sah, kebocoran data, atau penyalahgunaan pihak ketiga.',
            ),
            _buildSection(
              '5. Hak Pengguna & Penghapusan Akun',
              'Anda berhak meminta pembaharuan atau penghapusan seluruh data pribadi akun Anda kapan saja dengan menghubungi Customer Service Ketok.',
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
