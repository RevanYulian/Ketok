import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../services/app_config_service.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isIndo ? 'Pusat Bantuan & FAQ' : 'Help Center & FAQ',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            isIndo ? 'PERTANYAAN SERING DIAJUKAN' : 'FREQUENTLY ASKED QUESTIONS',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          _FaqItem(
            question: isIndo
                ? 'Bagaimana cara memesan jasa teknisi di Ketok?'
                : 'How do I order technician services on Ketok?',
            answer: isIndo
                ? 'Pilih kategori layanan yang Anda butuhkan (misal: AC, Listrik, Kebersihan), tentukan tanggal & waktu pengerjaan, masukkan alamat Anda, lalu klik "Panggil & Cek". Mitra teknisi profesional kami akan segera mengonfirmasi dan meluncur ke lokasi Anda.'
                : 'Select the service category you need (e.g., AC, Electricity, Cleaning), choose the date & time, enter your address, then click "Call & Check". Our professional technician partner will confirm and head to your location.',
          ),
          _FaqItem(
            question: isIndo
                ? 'Berapa biaya kunjungan dan sistem pembayarannya?'
                : 'What are the visit fees and payment options?',
            answer: isIndo
                ? 'Biaya kunjungan berkisar mulai Rp 25.000 - Rp 50.000 tergantung jarak dan jenis layanan. Biaya jasa perbaikan ditentukan transparan setelah teknisi memeriksa kondisi di lokasi. Pembayaran dapat dilakukan tunai (COD) langsung ke teknisi atau non-tunai via KetokPay & QRIS.'
                : 'Visit fees start from Rp 25,000 - Rp 50,000 depending on distance and service type. Repair service fees are determined transparently after the technician inspects on site. Payment can be made in cash (COD) directly to the technician or cashless via KetokPay & QRIS.',
          ),
          _FaqItem(
            question: isIndo
                ? 'Apakah layanan teknisi Ketok bergaransi?'
                : 'Are Ketok technician services guaranteed?',
            answer: isIndo
                ? 'Ya! Semua layanan yang diselesaikan melalui aplikasi Ketok dilengkapi jaminan garansi pengerjaan hingga 14-30 hari (tergantung jenis perbaikan). Jika kendala yang sama terulang dalam masa garansi, teknisi akan memperbaiki kembali tanpa biaya jasa tambahan.'
                : 'Yes! All services completed through the Ketok app include a workmanship warranty of 14-30 days (depending on repair type). If the same issue recurs within the warranty period, the technician will fix it again without extra service fee.',
          ),
          _FaqItem(
            question: isIndo
                ? 'Bagaimana jika teknisi terlambat atau tidak datang?'
                : 'What if the technician is late or does not show up?',
            answer: isIndo
                ? 'Anda dapat melacak status mitra secara realtime di menu Pesanan dan menghubungi teknisi langsung melalui fitur Chat. Jika teknisi berhalangan, sistem kami siap mencarikan teknisi pengganti terdekat.'
                : 'You can track partner status in real-time in the Orders menu and contact the technician directly via Chat. If the technician is unavailable, our system is ready to find the nearest replacement technician.',
          ),
          _FaqItem(
            question: isIndo
                ? 'Apakah saya bisa membatalkan pesanan?'
                : 'Can I cancel an order?',
            answer: isIndo
                ? 'Pembatalan dapat dilakukan sebelum teknisi menuju ke lokasi Anda tanpa dikenakan biaya penalti apapun.'
                : 'Cancellation can be done before the technician heads to your location without any penalty fee.',
          ),
          const SizedBox(height: 28),
          Text(
            isIndo ? 'HUBUNGI KAMI' : 'CONTACT US',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF64748B),
            ),
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
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
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
                                  ? 'Nomor CS WhatsApp berhasil disalin: $kontakCs'
                                  : 'WhatsApp CS number copied: $kontakCs',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.phone_outlined, size: 20, color: Color(0xFF0284C7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Customer Service (WhatsApp)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                Text(kontakCs, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                          const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF94A3B8)),
                        ],
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
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
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.mail_outline_rounded, size: 20, color: Color(0xFF0284C7)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isIndo ? 'Email Bantuan' : 'Support Email',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                Text(emailBantuan, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                              ],
                            ),
                          ),
                          const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF94A3B8)),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: const Border(),
        title: Text(
          question,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        children: [
          Text(
            answer,
            style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45),
          ),
        ],
      ),
    );
  }
}
