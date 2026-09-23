import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'quick_menu_shared.dart';

class PusatBantuanScreen extends StatefulWidget {
  const PusatBantuanScreen({super.key});

  @override
  State<PusatBantuanScreen> createState() => _PusatBantuanScreenState();
}

class _PusatBantuanScreenState extends State<PusatBantuanScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _articles = [];

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final rows = await Supabase.instance.client
          .from('pusat_bantuan')
          .select('id_bantuan, judul, jawaban, kategori')
          .eq('aktif', true)
          .order('urutan');
      if (!mounted) return;
      setState(() {
        _articles = rows.map((row) => Map<String, dynamic>.from(row)).toList();
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
      title: 'Pusat Bantuan',
      icon: Icons.support_agent_outlined,
      onRefresh: _loadArticles,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadArticles,
        child: _articles.isEmpty
            ? const QuickMenuEmptyState(
                icon: Icons.support_agent_outlined,
                title: 'Belum ada artikel bantuan',
                subtitle: 'Pertanyaan umum dari tim akan ditampilkan di sini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _articles.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildArticle(_articles[index]),
              ),
      ),
    );
  }

  Widget _buildArticle(Map<String, dynamic> article) {
    return QuickMenuCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(
          Icons.help_outline_rounded,
          color: KetokColors.darkPrimary,
        ),
        title: Text(
          article['judul'] as String,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: article['kategori'] == null
            ? null
            : Text(article['kategori'] as String),
        children: [
          Text(
            article['jawaban'] as String,
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
