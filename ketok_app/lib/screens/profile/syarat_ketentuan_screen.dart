import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class SyaratKetentuanScreen extends StatelessWidget {
  const SyaratKetentuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isIndo ? 'Syarat & Ketentuan' : 'Terms & Conditions',
          style: const TextStyle(
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
            Text(
              isIndo
                  ? 'Syarat dan Ketentuan Layanan Ketok'
                  : 'Ketok Customer Terms & Conditions',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              isIndo
                  ? 'Terakhir diperbarui: 1 September 2026'
                  : 'Last updated: September 1, 2026',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
            ),
            const SizedBox(height: 24),
            _buildSection(
              isIndo ? '1. Ketentuan Umum' : '1. General Terms',
              isIndo
                  ? 'Selamat datang di Ketok. Dengan menggunakan aplikasi ini, Anda menyatakan setuju untuk mematuhi Syarat dan Ketentuan berikut. Aplikasi Ketok berfungsi menghubungkan pelanggan dengan mitra teknisi profesional.'
                  : 'Welcome to Ketok. By using this application, you agree to comply with the following Terms and Conditions. The Ketok app connects customers with verified professional technicians.',
            ),
            _buildSection(
              isIndo ? '2. Pemesanan Layanan' : '2. Service Booking',
              isIndo
                  ? 'Pelanggan wajib memberikan alamat yang benar, nomor kontak aktif, serta deskripsi keluhan atau kebutuhan jasa secara jelas agar mitra teknisi dapat mempersiapkan perkakas dan material yang tepat.'
                  : 'Customers must provide an accurate address, active contact number, and clear description of issues or service requirements so technician partners can prepare the right tools and materials.',
            ),
            _buildSection(
              isIndo
                  ? '3. Biaya Kunjungan & Tarif Pengerjaan'
                  : '3. Visit Fees & Service Rates',
              isIndo
                  ? 'Biaya kunjungan dikenakan saat teknisi tiba di lokasi Anda untuk melakukan pengecekan. Estimasi biaya perbaikan menyeluruh akan disampaikan oleh teknisi sebelum pekerjaan dimulai. Anda berhak menolak pengerjaan jika tidak menyetujui estimasi biaya, dengan hanya membayar biaya kunjungan.'
                  : 'A visit fee is charged upon technician arrival at your premises to inspect the issue. The full repair cost estimate will be submitted by the technician before work begins. You reserve the right to decline repair if you do not agree with the estimate, paying only the visit fee.',
            ),
            _buildSection(
              isIndo ? '4. Pembatalan Pesanan' : '4. Order Cancellation',
              isIndo
                  ? 'Pembatalan pesanan dapat dilakukan tanpa biaya sebelum mitra teknisi bergerak menuju ke lokasi Anda. Apabila teknisi sudah berada dalam perjalanan menuju alamat Anda, biaya kunjungan dasar tetap berlaku.'
                  : 'Order cancellation is free of charge before the technician partner commences travel to your location. Once the technician is en route to your address, the standard visit fee applies.',
            ),
            _buildSection(
              isIndo
                  ? '5. Garansi Pengerjaan Layanan'
                  : '5. Workmanship Warranty',
              isIndo
                  ? 'Ketok memberikan jaminan garansi pengerjaan selama 14 hingga 30 hari untuk pekerjaan yang diselesaikan melalui sistem aplikasi resmi. Klaim garansi dapat diajukan dengan menghubungi layanan pelanggan.'
                  : 'Ketok provides a 14 to 30-day workmanship warranty for jobs completed through the official app system. Warranty claims can be submitted by reaching out to customer support.',
            ),
            _buildSection(
              isIndo ? '6. Keamanan & Tanggung Jawab' : '6. Safety & Responsibility',
              isIndo
                  ? 'Pelanggan diharapkan mendampingi atau memastikan ada perwakilan di lokasi selama proses pengerjaan oleh teknisi berlangsung demi kenyamanan dan keamanan bersama.'
                  : 'Customers are advised to accompany or ensure an adult representative is on-site while work is being conducted for mutual safety and convenience.',
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
