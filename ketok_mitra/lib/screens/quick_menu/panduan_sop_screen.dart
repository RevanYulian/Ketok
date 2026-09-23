import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'quick_menu_shared.dart';

class PanduanSopScreen extends StatefulWidget {
  const PanduanSopScreen({super.key});

  @override
  State<PanduanSopScreen> createState() => _PanduanSopScreenState();
}

class _PanduanSopScreenState extends State<PanduanSopScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _guides = [];

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from('panduan_sop')
          .select('id_sop, judul, isi, kategori')
          .eq('aktif', true)
          .order('urutan');
      if (!mounted) return;
      setState(() {
        _guides = rows.map((row) => Map<String, dynamic>.from(row)).toList();
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = quickMenuError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return QuickMenuScaffold(
      title: 'Panduan SOP',
      icon: Icons.verified_user_outlined,
      onRefresh: _loadGuides,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadGuides,
        child: _guides.isEmpty
            ? const QuickMenuEmptyState(
                icon: Icons.verified_user_outlined,
                title: 'Belum ada panduan SOP',
                subtitle: 'Panduan kerja mitra akan ditampilkan di sini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _guides.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildGuide(_guides[index]),
              ),
      ),
    );
  }

  Widget _buildGuide(Map<String, dynamic> guide) {
    return QuickMenuCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(
          Icons.verified_user_outlined,
          color: KetokColors.darkPrimary,
        ),
        title: Text(
          guide['judul'] as String,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: guide['kategori'] == null
            ? null
            : Text(guide['kategori'] as String),
        children: [
          Text(
            guide['isi'] as String,
            style: const TextStyle(
              color: KetokColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
