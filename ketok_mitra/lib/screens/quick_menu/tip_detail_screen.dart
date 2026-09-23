import 'package:flutter/material.dart';
import '../../widgets/ketok_colors.dart';
import 'quick_menu_shared.dart';

class TipDetailScreen extends StatelessWidget {
  final Map<String, dynamic> tip;

  const TipDetailScreen({super.key, required this.tip});

  @override
  Widget build(BuildContext context) {
    final title = tip['judul'] as String? ?? 'Tip & Artikel';
    final content = (tip['isi'] as String?) ?? tip['ringkasan'] as String? ?? '';
    final date = tip['dibuat_pada'];

    String formattedDate = '';
    if (date != null) {
      formattedDate = formatQuickMenuDate(date);
    }

    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        title: const Text('Detail Artikel'),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: KetokColors.darkPrimary,
                height: 1.3,
              ),
            ),
            if (formattedDate.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 16,
                    color: KetokColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 13,
                      color: KetokColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            const Divider(color: KetokColors.borderColor),
            const SizedBox(height: 24),
            Text(
              content,
              style: const TextStyle(
                fontSize: 16,
                color: KetokColors.onSurface,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
