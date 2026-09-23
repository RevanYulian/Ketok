import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';

Future<Map<String, dynamic>?> showMitraOfferDialog(
  BuildContext context,
  Map<String, dynamic> order,
) async {
  final priceController = TextEditingController(
    text: (order['offer_price'] ?? order['price'] ?? '').toString(),
  );
  final detailController = TextEditingController(
    text: order['offer_detail'] as String? ?? '',
  );
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Ajukan Penawaran'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Harga penawaran',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Yang Anda tawarkan',
                hintText: 'Contoh: termasuk pengecekan dan garansi 7 hari',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () {
            final price = int.tryParse(
              priceController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            );
            if (price == null || price <= 0) return;
            Navigator.pop(dialogContext, {
              'harga': price,
              'detail': detailController.text.trim(),
            });
          },
          child: const Text('Kirim Penawaran'),
        ),
      ],
    ),
  );
  priceController.dispose();
  detailController.dispose();
  return result;
}

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        backgroundColor: KetokColors.bgColor,
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
}

class QuickMenuContent extends StatelessWidget {
  final bool loading;
  final String? errorMessage;
  final Future<void> Function() onRetry;
  final Widget child;

  const QuickMenuContent({
    super.key,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (errorMessage != null) {
      return QuickMenuErrorState(message: errorMessage!, onRetry: onRetry);
    }
    return child;
  }
}

class QuickMenuErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const QuickMenuErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 46,
              color: KetokColors.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return Center(
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
              style: const TextStyle(color: KetokColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class QuickMenuCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const QuickMenuCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KetokColors.borderColor),
      ),
      child: child,
    );
  }
}

Future<int> loadMitraId(SupabaseClient client) async {
  final authUser = client.auth.currentUser;
  if (authUser == null) throw Exception('Sesi login tidak ditemukan.');
  final profile = await client
      .from('users')
      .select('id_user')
      .eq('auth_uid', authUser.id)
      .maybeSingle();
  final mitraId = profile?['id_user'];
  if (mitraId is! int) {
    throw Exception('Profil Mitra belum terhubung ke akun ini.');
  }
  return mitraId;
}

Future<int> loadMitraCategoryId(SupabaseClient client, int mitraId) async {
  final profile = await client
      .from('mitra_profil')
      .select('katagori_id')
      .eq('user_id', mitraId)
      .maybeSingle();
  final categoryId = profile?['katagori_id'];
  if (categoryId is! int) {
    throw Exception('Keahlian layanan Mitra belum diatur.');
  }
  return categoryId;
}

String quickMenuError(Object error) =>
    error.toString().replaceFirst('Exception: ', '');

String formatQuickMenuDate(dynamic value) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatQuickMenuCurrency(dynamic value) {
  if (value == null) return 'Belum ditentukan';
  final number = (value as num).round().toString();
  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $formatted';
}
