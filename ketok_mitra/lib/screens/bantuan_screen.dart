import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_config_service.dart';
import '../widgets/ketok_colors.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Pusat Bantuan & FAQ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _FaqItem(
            question: 'Bagaimana cara menerima pesanan?',
            answer: 'Anda akan menerima notifikasi pesanan baru. Buka aplikasi, lihat detail pesanan, dan klik "Terima" jika Anda bersedia mengerjakannya.',
          ),
          _FaqItem(
            question: 'Bagaimana sistem pembayaran Ketok?',
            answer: 'Pembayaran dilakukan secara tunai oleh pelanggan setelah pekerjaan selesai, atau ditransfer ke rekening yang terdaftar di aplikasi Anda.',
          ),
          _FaqItem(
            question: 'Mengapa akun saya masih berstatus Menunggu Persetujuan?',
            answer: 'Tim kami sedang memverifikasi data dan sertifikat Anda. Proses ini biasanya memakan waktu 1-2 hari kerja.',
          ),
          _FaqItem(
            question: 'Apa yang harus dilakukan jika pelanggan membatalkan pesanan?',
            answer: 'Jika pembatalan terjadi sebelum Anda berangkat, tidak ada penalti. Jika sudah dalam perjalanan, silakan hubungi tim dukungan.',
          ),
          const SizedBox(height: 24),
          const Text(
            'Butuh Bantuan Lebih Lanjut?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          ValueListenableBuilder<AppConfig?>(
            valueListenable: AppConfigService.instance.configNotifier,
            builder: (context, config, _) {
              final kontakCs = config?.kontakCs ?? '081234567890';
              final emailBantuan = config?.emailBantuan ?? 'support@ketok.id';

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: kontakCs));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Nomor CS Mitra berhasil disalin: $kontakCs'),
                            backgroundColor: KetokColors.darkPrimary,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF0284C7)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Layanan WhatsApp / CS', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                Text(kontakCs, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                    const Divider(height: 20),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: emailBantuan));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email bantuan berhasil disalin: $emailBantuan'),
                            backgroundColor: KetokColors.darkPrimary,
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, size: 20, color: Color(0xFF0284C7)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Email Dukungan Mitra', style: TextStyle(fontSize: 11, color: Colors.black54)),
                                Text(emailBantuan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          const Icon(Icons.copy_rounded, size: 18, color: Colors.grey),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              answer,
              style: const TextStyle(color: KetokColors.onSurfaceVariant, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
