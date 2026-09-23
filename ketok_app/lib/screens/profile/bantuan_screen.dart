import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/app_config_service.dart';

class BantuanScreen extends StatelessWidget {
  const BantuanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pusat Bantuan & FAQ',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'PERTANYAAN SERING DIAJUKAN',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          const _FaqItem(
            question: 'Bagaimana cara memesan jasa teknisi di Ketok?',
            answer: 'Pilih kategori layanan yang Anda butuhkan (misal: AC, Listrik, Kebersihan), tentukan tanggal & waktu pengerjaan, masukkan alamat Anda, lalu klik "Panggil & Cek". Mitra teknisi profesional kami akan segera mengonfirmasi dan meluncur ke lokasi Anda.',
          ),
          const _FaqItem(
            question: 'Berapa biaya kunjungan dan sistem pembayarannya?',
            answer: 'Biaya kunjungan berkisar mulai Rp 25.000 - Rp 50.000 tergantung jarak dan jenis layanan. Biaya jasa perbaikan ditentukan transparan setelah teknisi memeriksa kondisi di lokasi. Pembayaran dapat dilakukan tunai (COD) langsung ke teknisi atau non-tunai via KetokPay & QRIS.',
          ),
          const _FaqItem(
            question: 'Apakah layanan teknisi Ketok bergaransi?',
            answer: 'Ya! Semua layanan yang diselesaikan melalui aplikasi Ketok dilengkapi jaminan garansi pengerjaan hingga 14-30 hari (tergantung jenis perbaikan). Jika kendala yang sama terulang dalam masa garansi, teknisi akan memperbaiki kembali tanpa biaya jasa tambahan.',
          ),
          const _FaqItem(
            question: 'Bagaimana jika teknisi terlambat atau tidak datang?',
            answer: 'Anda dapat melacak status mitra secara realtime di menu Pesanan dan menghubungi teknisi langsung melalui fitur Chat. Jika teknisi berhalangan, sistem kami siap mencarikan teknisi pengganti terdekat.',
          ),
          const _FaqItem(
            question: 'Apakah saya bisa membatalkan pesanan?',
            answer: 'Pembatalan dapat dilakukan sebelum teknisi menuju ke lokasi Anda tanpa dikenakan biaya penalti apapun.',
          ),
          const SizedBox(height: 28),
          const Text(
            'HUBUNGI KAMI',
            style: TextStyle(
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
                            content: Text('Nomor CS WhatsApp berhasil disalin: $kontakCs'),
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
                            content: Text('Email bantuan berhasil disalin: $emailBantuan'),
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
                                const Text('Email Bantuan', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
