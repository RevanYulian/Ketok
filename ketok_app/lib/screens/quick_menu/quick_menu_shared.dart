import 'package:flutter/material.dart';

import '../../widgets/ketok_colors.dart';

const _quickMenuBackground = Color(0xFFF8F9FB);

class QuickMenuScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final Future<void> Function() onRefresh;
  final Widget child;

  const QuickMenuScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _quickMenuBackground,
    appBar: AppBar(
      backgroundColor: _quickMenuBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Kembali',
      ),
      title: Row(
        children: [
          Icon(icon, size: 21),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
          tooltip: 'Muat ulang',
        ),
      ],
    ),
    body: SafeArea(child: child),
  );
}

class QuickMenuCard extends StatelessWidget {
  final Widget child;

  const QuickMenuCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: KetokColors.border),
      boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
    ),
    child: child,
  );
}

class QuickMenuEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const QuickMenuEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 52, color: const Color(0xFFD1D5DB)),
          const SizedBox(height: 14),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(color: KetokColors.textMuted),
          ),
        ],
      ),
    ),
  );
}

String formatServicePrice(dynamic value) {
  if (value == null) return 'Harga menyesuaikan layanan';
  final number = (value as num).round().toString();
  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Mulai Rp $formatted';
}

String formatFixedPrice(dynamic value) {
  if (value == null) return 'Rp 0';
  final number = (value as num).round().toString();
  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $formatted';
}
