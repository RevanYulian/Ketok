import 'package:flutter/material.dart';
import '../widgets/ketok_colors.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Kebijakan Privasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kebijakan Privasi Ketok',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Terakhir diperbarui: 1 September 2026',
              style: TextStyle(color: KetokColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSection(
              '1. Pengumpulan Data',
              'Kami mengumpulkan informasi pribadi yang Anda berikan, termasuk nama, nomor telepon, alamat email, dokumen identitas, dan data lokasi (GPS) untuk mendukung jalannya aplikasi.',
            ),
            _buildSection(
              '2. Penggunaan Data',
              'Data Anda digunakan untuk memverifikasi akun, menghubungkan Anda dengan pelanggan, memproses transaksi, dan meningkatkan layanan kami.',
            ),
            _buildSection(
              '3. Berbagi Data',
              'Kami tidak akan menjual data Anda kepada pihak ketiga. Namun, kami membagikan profil dan estimasi lokasi Anda kepada pelanggan saat Anda menerima pesanan mereka.',
            ),
            _buildSection(
              '4. Keamanan Data',
              'Kami menggunakan standar enkripsi modern (Supabase) untuk melindungi data pribadi dan dokumen Anda dari akses yang tidak sah.',
            ),
            _buildSection(
              '5. Hak Anda',
              'Anda berhak meminta penghapusan akun beserta semua data pribadi Anda dari sistem kami dengan menghubungi tim dukungan pelanggan.',
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
