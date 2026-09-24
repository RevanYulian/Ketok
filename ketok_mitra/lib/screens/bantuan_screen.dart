import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../services/app_config_service.dart';
import '../widgets/ketok_colors.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;

    final faqs = [
      (
        isIndo
            ? 'Bagaimana cara menerima pesanan?'
            : 'How do I accept orders?',
        isIndo
            ? 'Anda akan menerima notifikasi pesanan baru. Buka aplikasi, lihat detail pesanan, dan klik "Terima" jika Anda bersedia mengerjakannya.'
            : 'You will receive notifications for new orders. Open the app, view order details, and tap "Accept" if you are available to fulfill it.',
      ),
      (
        isIndo
            ? 'Bagaimana sistem pembayaran Ketok?'
            : 'How does Ketok payment system work?',
        isIndo
            ? 'Pembayaran dilakukan secara tunai oleh pelanggan setelah pekerjaan selesai, atau ditransfer ke rekening yang terdaftar di aplikasi Anda.'
            : 'Payments can be made in cash by the customer upon job completion, or transferred directly to your registered bank account.',
      ),
      (
        isIndo
            ? 'Mengapa akun saya masih berstatus Menunggu Persetujuan?'
            : 'Why is my account still Awaiting Approval?',
        isIndo
            ? 'Tim kami sedang memverifikasi data dan sertifikat Anda. Proses ini biasanya memakan waktu 1-2 hari kerja.'
            : 'Our team is reviewing your profile and verification documents. This usually takes 1-2 business days.',
      ),
      (
        isIndo
            ? 'Apa yang harus dilakukan jika pelanggan membatalkan pesanan?'
            : 'What should I do if a customer cancels an order?',
        isIndo
            ? 'Jika pembatalan terjadi sebelum Anda berangkat, tidak ada penalti. Jika sudah dalam perjalanan, silakan hubungi tim dukungan.'
            : 'If cancellation happens before you depart, there is no penalty. If you are already en route, please contact our support team.',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isIndo ? 'Pusat Bantuan & FAQ' : 'Help Center & FAQ',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.map((f) => _FaqItem(question: f.$1, answer: f.$2)),
          const SizedBox(height: 24),
          Text(
            isIndo ? 'Butuh Bantuan Lebih Lanjut?' : 'Need Further Assistance?',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
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
                            content: Text(
                              isIndo
                                  ? 'Nomor CS Mitra berhasil disalin: $kontakCs'
                                  : 'Partner CS number copied: $kontakCs',
                            ),
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
                                Text(
                                  isIndo ? 'Layanan WhatsApp / CS' : 'WhatsApp Support / CS',
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                ),
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
                            content: Text(
                              isIndo
                                  ? 'Email bantuan berhasil disalin: $emailBantuan'
                                  : 'Support email copied: $emailBantuan',
                            ),
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
                                Text(
                                  isIndo ? 'Email Dukungan Mitra' : 'Partner Support Email',
                                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                                ),
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
