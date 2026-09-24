import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ketok_colors.dart';
import 'tips_detail_screen.dart';

class TipsArtikelScreen extends StatefulWidget {
  const TipsArtikelScreen({super.key});

  @override
  State<TipsArtikelScreen> createState() => _TipsArtikelScreenState();
}

class _TipsArtikelScreenState extends State<TipsArtikelScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _tips = [];

  @override
  void initState() {
    super.initState();
    _loadAllTips();
  }

  Future<void> _loadAllTips() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final rows = await Supabase.instance.client
          .from('tips_artikel')
          .select('id_tips, judul, ringkasan, dibuat_pada')
          .eq('aktif', true)
          .order('dibuat_pada', ascending: false);

      if (!mounted) return;
      setState(() {
        _tips = rows;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      final isIndo = context.l10n.isIndonesian;
      setState(() {
        _loading = false;
        _errorMessage = isIndo
            ? 'Gagal memuat tips & artikel: $error'
            : 'Failed to load tips & articles: $error';
      });
    }
  }

  void _showTipDetail(Map<String, dynamic> tip) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TipsDetailScreen(tip: tip)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: Text(
          isIndo ? 'Tips & Artikel' : 'Tips & Articles',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadAllTips,
                      child: Text(isIndo ? 'Coba Lagi' : 'Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAllTips,
              child: _tips.isEmpty
                  ? Center(
                      child: Text(
                        isIndo
                            ? 'Belum ada tips & artikel saat ini.'
                            : 'No tips & articles available yet.',
                        style: const TextStyle(color: KetokColors.textMuted),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _tips.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final tip = _tips[index];
                        final judul = tip['judul'] as String? ?? (isIndo ? 'Tips' : 'Tip');
                        final ringkasan = tip['ringkasan'] as String? ?? '';

                        return InkWell(
                          onTap: () => _showTipDetail(tip),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF3F4F6),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.lightbulb_rounded,
                                        size: 18,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        judul,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1E293B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  ringkasan,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: KetokColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Text(
                                      isIndo ? 'Baca selengkapnya' : 'Read more',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: KetokColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: KetokColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
