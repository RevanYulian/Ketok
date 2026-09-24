import 'package:flutter/material.dart';
import '../widgets/ketok_colors.dart';
import '../l10n/app_localizations.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isIndo ? 'Kebijakan Privasi' : 'Privacy Policy', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIndo ? 'Kebijakan Privasi Ketok' : 'Ketok Privacy Policy',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isIndo ? 'Terakhir diperbarui: 1 September 2026' : 'Last updated: September 1, 2026',
              style: const TextStyle(color: KetokColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSection(
              isIndo ? '1. Pengumpulan Data' : '1. Data Collection',
              isIndo
                  ? 'Kami mengumpulkan informasi pribadi yang Anda berikan, termasuk nama, nomor telepon, alamat email, dokumen identitas, dan data lokasi (GPS) untuk mendukung jalannya aplikasi.'
                  : 'We collect personal information you provide, including name, phone number, email address, identity documents, and location (GPS) data to support application operation.',
            ),
            _buildSection(
              isIndo ? '2. Penggunaan Data' : '2. Data Usage',
              isIndo
                  ? 'Data Anda digunakan untuk memverifikasi akun, menghubungkan Anda dengan pelanggan, memproses transaksi, dan meningkatkan layanan kami.'
                  : 'Your data is used to verify accounts, connect you with customers, process transactions, and improve our services.',
            ),
            _buildSection(
              isIndo ? '3. Berbagi Data' : '3. Data Sharing',
              isIndo
                  ? 'Kami tidak akan menjual data Anda kepada pihak ketiga. Namun, kami membagikan profil dan estimasi lokasi Anda kepada pelanggan saat Anda menerima pesanan mereka.'
                  : 'We do not sell your personal data. However, we share your profile and estimated location with customers when you accept their orders.',
            ),
            _buildSection(
              isIndo ? '4. Keamanan Data' : '4. Data Security',
              isIndo
                  ? 'Kami menggunakan standar enkripsi modern (Supabase) untuk melindungi data pribadi dan dokumen Anda dari akses yang tidak sah.'
                  : 'We utilize industry standard modern encryption (Supabase) to protect your personal data and documents from unauthorized access.',
            ),
            _buildSection(
              isIndo ? '5. Hak Anda' : '5. Your Rights',
              isIndo
                  ? 'Anda berhak meminta penghapusan akun beserta semua data pribadi Anda dari sistem kami dengan menghubungi tim dukungan pelanggan.'
                  : 'You have the right to request deletion of your account and all associated personal data from our systems by contacting customer support.',
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
