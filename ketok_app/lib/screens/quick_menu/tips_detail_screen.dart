import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ketok_colors.dart';
import 'cari_jasa_screen.dart';

class TipsDetailScreen extends StatelessWidget {
  final Map<String, dynamic> tip;

  const TipsDetailScreen({super.key, required this.tip});

  String _formatDate(dynamic dateVal, {bool isIndo = true}) {
    if (dateVal == null) return isIndo ? 'Edukasi Ketok' : 'Ketok Insights';
    try {
      final dt = DateTime.parse(dateVal.toString());
      final months = isIndo
          ? ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']
          : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return isIndo ? 'Edukasi Ketok' : 'Ketok Insights';
    }
  }

  IconData _iconForTip(String title) {
    final t = title.toLowerCase();
    if (t.contains('ac')) return Icons.ac_unit_rounded;
    if (t.contains('listrik') || t.contains('korsleting')) {
      return Icons.electrical_services_rounded;
    }
    if (t.contains('pipa') || t.contains('bocor') || t.contains('air')) {
      return Icons.plumbing_rounded;
    }
    if (t.contains('cat') || t.contains('dinding')) return Icons.format_paint_rounded;
    if (t.contains('mesin cuci') || t.contains('cuci')) {
      return Icons.local_laundry_service_rounded;
    }
    if (t.contains('kayu') || t.contains('furnitur')) {
      return Icons.chair_outlined;
    }
    if (t.contains('hujan') || t.contains('atap')) {
      return Icons.roofing_rounded;
    }
    if (t.contains('rayap') || t.contains('pest')) {
      return Icons.pest_control_rounded;
    }
    return Icons.lightbulb_outline_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    final judul = tip['judul'] as String? ?? (isIndo ? 'Tips Perawatan' : 'Maintenance Tips');
    final ringkasan = tip['ringkasan'] as String? ?? '';
    final dateStr = _formatDate(tip['dibuat_pada'], isIndo: isIndo);
    final tipIcon = _iconForTip(judul);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          isIndo ? 'Detail Tips & Artikel' : 'Tip & Article Details',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1E293B),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            color: const Color(0xFF1E293B),
            tooltip: isIndo ? 'Bagikan Tips' : 'Share Tip',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: '$judul\n\n$ringkasan\n\nTips via Ketok App'));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isIndo
                        ? 'Teks tips berhasil disalin ke papan klip.'
                        : 'Tip text copied to clipboard.',
                  ),
                  backgroundColor: KetokColors.primary,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge & Tanggal
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: KetokColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isIndo ? 'PANDUAN & TIPS' : 'GUIDE & TIPS',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: KetokColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 12,
                    color: KetokColors.textMuted,
                  ),
                ),
                const Spacer(),
                Text(
                  isIndo ? '2 Menit Baca' : '2 Min Read',
                  style: const TextStyle(
                    fontSize: 12,
                    color: KetokColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Judul Artikel
            Text(
              judul,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 18),

            // Hero Highlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      tipIcon,
                      color: const Color(0xFF38BDF8),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isIndo ? 'Solusi Praktis Rumah Tangga' : 'Practical Home Solutions',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isIndo
                              ? 'Dirangkum oleh teknisi profesional untuk penanganan yang tepat dan aman.'
                              : 'Curated by professional technicians for safe and proper handling.',
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Konten / Isi Panduan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.article_outlined, size: 20, color: KetokColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        isIndo ? 'Ringkasan & Langkah Penanganan' : 'Summary & Action Steps',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFFF1F5F9), height: 1),
                  ),
                  Text(
                    ringkasan,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF334155),
                      height: 1.7,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          color: Color(0xFF16A34A),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isIndo
                                ? 'Pemeriksaan rutin dapat mencegah kerusakan lebih parah dan menghemat biaya perawatan jangka panjang.'
                                : 'Routine inspection helps prevent severe damage and saves long-term repair costs.',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF166534),
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Card Bantuan / Teknisi Call to Action
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndo ? 'Kendala belum terselesaikan?' : 'Issue still unresolved?',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isIndo
                        ? 'Panggil teknisi atau tukang ahli terdekat langsung dari aplikasi Ketok.'
                        : 'Call a nearby expert technician or handyman directly from Ketok app.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: KetokColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CariJasaScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.handyman_outlined, size: 18),
                      label: Text(
                        isIndo ? 'Cari Teknisi Terkait' : 'Find Related Technician',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KetokColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
