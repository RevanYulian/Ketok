import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class KebijakanPrivasiScreen extends StatelessWidget {
  const KebijakanPrivasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isIndo ? 'Kebijakan Privasi' : 'Privacy Policy',
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
                  ? 'Kebijakan Privasi Pengguna Ketok'
                  : 'Ketok Customer Privacy Policy',
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
              isIndo ? '1. Pengumpulan Data Pribadi' : '1. Personal Data Collection',
              isIndo
                  ? 'Kami mengumpulkan informasi yang Anda berikan saat mendaftar dan menggunakan layanan, seperti nama lengkap, alamat email, nomor telepon, alamat lokasi rumah atau kantor, serta catatan pesanan.'
                  : 'We collect information you provide when registering and using services, including your full name, email address, phone number, home or office location addresses, and service booking notes.',
            ),
            _buildSection(
              isIndo ? '2. Data Lokasi & GPS' : '2. Location & GPS Data',
              isIndo
                  ? 'Aplikasi membutuhkan izin akses lokasi Anda untuk menentukan alamat pengerjaan secara akurat serta mencarikan mitra teknisi terdekat yang siap datang.'
                  : 'The application requires access to your location to accurately identify work addresses and locate nearby technician partners ready for dispatch.',
            ),
            _buildSection(
              isIndo
                  ? '3. Berbagi Informasi dengan Mitra'
                  : '3. Sharing Information with Partners',
              isIndo
                  ? 'Nama, nomor telepon, dan alamat yang Anda tentukan pada pesanan akan dibagikan kepada teknisi yang menerima pesanan tersebut semata-mata untuk koordinasi kedatangan dan pengerjaan.'
                  : 'Your specified order name, contact number, and address are shared with the technician who accepts the job solely for coordination of arrival and service execution.',
            ),
            _buildSection(
              isIndo ? '4. Keamanan & Enkripsi' : '4. Security & Encryption',
              isIndo
                  ? 'Data akun Anda disimpan dengan teknologi keamanan dan enkripsi database cloud (Supabase) untuk mencegah akses tidak sah, kebocoran data, atau penyalahgunaan pihak ketiga.'
                  : 'Your account data is stored with cloud database security and modern encryption standards (Supabase) to prevent unauthorized access, data leaks, or third-party misuse.',
            ),
            _buildSection(
              isIndo
                  ? '5. Hak Pengguna & Penghapusan Akun'
                  : '5. User Rights & Account Deletion',
              isIndo
                  ? 'Anda berhak meminta pembaharuan atau penghapusan seluruh data pribadi akun Anda kapan saja dengan menghubungi Customer Service Ketok.'
                  : 'You have the right to request updates or permanent deletion of your personal account data at any time by contacting Ketok Customer Support.',
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
