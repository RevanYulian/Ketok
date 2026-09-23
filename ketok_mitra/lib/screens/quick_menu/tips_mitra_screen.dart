import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'quick_menu_shared.dart';

class TipsMitraScreen extends StatefulWidget {
  const TipsMitraScreen({super.key});

  @override
  State<TipsMitraScreen> createState() => _TipsMitraScreenState();
}

class _TipsMitraScreenState extends State<TipsMitraScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _tips = [];

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  Future<void> _loadTips() async {
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
        _tips = rows.map((row) => Map<String, dynamic>.from(row)).toList();
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
      title: 'Tips Mitra',
      icon: Icons.lightbulb_outline,
      onRefresh: _loadTips,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadTips,
        child: _tips.isEmpty
            ? const QuickMenuEmptyState(
                icon: Icons.lightbulb_outline,
                title: 'Belum ada tips',
                subtitle: 'Tips ringan untuk mitra akan muncul di sini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _tips.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildTip(_tips[index]),
              ),
      ),
    );
  }

  Widget _buildTip(Map<String, dynamic> tip) {
    return QuickMenuCard(
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: const Icon(
          Icons.lightbulb_outline,
          color: KetokColors.darkPrimary,
        ),
        title: Text(
          tip['judul'] as String,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          tip['dibuat_pada'] != null ? formatQuickMenuDate(tip['dibuat_pada']) : tip['ringkasan'] as String,
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Text(
            (tip['isi'] as String?) ?? tip['ringkasan'] as String,
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
