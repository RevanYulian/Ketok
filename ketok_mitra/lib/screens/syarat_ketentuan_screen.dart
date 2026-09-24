import 'package:flutter/material.dart';
import '../widgets/ketok_colors.dart';
import '../l10n/app_localizations.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(isIndo ? 'Syarat & Ketentuan' : 'Terms & Conditions', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isIndo
                  ? 'Syarat dan Ketentuan Layanan Ketok Mitra'
                  : 'Ketok Partner Service Terms & Conditions',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isIndo ? 'Terakhir diperbarui: 1 September 2026' : 'Last updated: September 1, 2026',
              style: const TextStyle(color: KetokColors.onSurfaceVariant, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildSection(
              isIndo ? '1. Pendahuluan' : '1. Introduction',
              isIndo
                  ? 'Selamat datang di Ketok Mitra. Dengan menggunakan aplikasi ini, Anda setuju untuk terikat oleh Syarat dan Ketentuan berikut. Harap baca dengan cermat.'
                  : 'Welcome to Ketok Partner. By using this application, you agree to be bound by the following Terms and Conditions. Please read carefully.',
            ),
            _buildSection(
              isIndo ? '2. Pendaftaran Akun' : '2. Account Registration',
              isIndo
                  ? 'Anda harus memberikan informasi yang akurat dan lengkap saat mendaftar. Anda bertanggung jawab menjaga kerahasiaan kata sandi Anda.'
                  : 'You must provide accurate and complete information during registration. You are responsible for maintaining the confidentiality of your password.',
            ),
            _buildSection(
              isIndo ? '3. Kewajiban Mitra' : '3. Partner Obligations',
              isIndo
                  ? 'Sebagai mitra, Anda diwajibkan untuk:\n- Menyediakan layanan sesuai standar profesional.\n- Tidak meminta pembayaran tambahan di luar aplikasi tanpa persetujuan pelanggan.\n- Bersikap sopan dan menghargai privasi pelanggan.'
                  : 'As a partner, you are required to:\n- Provide services meeting professional standards.\n- Not request unauthorized payments outside the app without customer consent.\n- Maintain courtesy and respect customer privacy.',
            ),
            _buildSection(
              isIndo ? '4. Sistem Pembayaran' : '4. Payment System',
              isIndo
                  ? 'Mitra akan menerima pembayaran dari pelanggan sesuai tarif yang tertera di aplikasi. Potongan komisi platform (jika ada) akan dijelaskan secara terpisah.'
                  : 'Partners will receive customer payments according to the rates stated in the application. Platform commission deductions (if any) will be specified separately.',
            ),
            _buildSection(
              isIndo ? '5. Penghentian Akun' : '5. Account Termination',
              isIndo
                  ? 'Ketok berhak membekukan atau menghapus akun Mitra apabila ditemukan pelanggaran terhadap syarat dan ketentuan ini, atau mendapat keluhan serius dari pelanggan.'
                  : 'Ketok reserves the right to suspend or terminate Partner accounts in the event of violation of these terms or verified critical complaints.',
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
