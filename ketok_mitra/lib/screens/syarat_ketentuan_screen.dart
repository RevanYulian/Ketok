import 'package:flutter/material.dart';
import '../widgets/ketok_colors.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Syarat & Ketentuan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syarat dan Ketentuan Layanan Ketok Mitra',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terakhir diperbarui: 1 September 2026',
              style: TextStyle(color: KetokColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Pendahuluan',
              'Selamat datang di Ketok Mitra. Dengan menggunakan aplikasi ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Harap baca dengan cermat.',
            ),
            _buildSection(
              '2. Pendaftaran Akun',
              'Anda harus memberikan informasi yang akurat dan lengkap saat mendaftar. Anda bertanggung jawab menjaga kerahasiaan kata sandi Anda.',
            ),
            _buildSection(
              '3. Kewajiban Mitra',
              'Sebagai mitra, Anda diwajibkan untuk:\n- Menyediakan layanan sesuai standar profesional.\n- Tidak meminta pembayaran tambahan di luar aplikasi tanpa persetujuan pelanggan.\n- Bersikap sopan dan menghargai privasi pelanggan.',
            ),
            _buildSection(
              '4. Sistem Pembayaran',
              'Mitra akan menerima pembayaran dari pelanggan sesuai tarif yang tertera di aplikasi. Potongan komisi platform (jika ada) akan dijelaskan secara terpisah.',
            ),
            _buildSection(
              '5. Penghentian Akun',
              'Ketok berhak membekukan atau menghapus akun Mitra apabila ditemukan pelanggaran terhadap syarat dan ketentuan ini, atau mendapat keluhan serius dari pelanggan.',
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(color: KetokColors.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
    );
  }
}
