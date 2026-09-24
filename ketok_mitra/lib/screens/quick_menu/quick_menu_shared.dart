import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import '../../l10n/app_localizations.dart';

Future<Map<String, dynamic>?> showMitraOfferDialog(
  BuildContext context,
  Map<String, dynamic> order,
) async {
  final isIndo = context.l10n.isIndonesian;
  final priceController = TextEditingController(
    text: (order['offer_price'] ?? order['price'] ?? '').toString(),
  );
  final detailController = TextEditingController(
    text: order['offer_detail'] as String? ?? '',
  );
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(isIndo ? 'Ajukan Penawaran' : 'Submit Offer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: isIndo ? 'Harga penawaran' : 'Offer price',
                prefixText: 'Rp ',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: detailController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: isIndo ? 'Yang Anda tawarkan' : 'What you offer',
                hintText: isIndo
                    ? 'Contoh: termasuk pengecekan dan garansi 7 hari'
                    : 'e.g. includes inspection and 7-day warranty',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(isIndo ? 'Batal' : 'Cancel'),
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
          child: Text(isIndo ? 'Kirim Penawaran' : 'Send Offer'),
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
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        backgroundColor: KetokColors.bgColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: isIndo ? 'Kembali' : 'Back',
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
            tooltip: isIndo ? 'Muat ulang' : 'Refresh',
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
  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
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
              label: Text(isIndo ? 'Coba Lagi' : 'Retry'),
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

String formatQuickMenuDate(dynamic value, [bool isIndo = true]) {
  final date = DateTime.tryParse(value?.toString() ?? '');
  if (date == null) return '-';
  final months = isIndo
      ? ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des']
      : ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatQuickMenuCurrency(dynamic value, [bool isIndo = true]) {
  if (value == null) return isIndo ? 'Belum ditentukan' : 'Not specified';
  final number = (value as num).round().toString();
  final formatted = number.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );
  return 'Rp $formatted';
}

/// Extracts the specific service name from the order's `catatan` field.
///
/// When a customer places an order in Ketok App, the first line of `catatan`
/// is formatted as `Jasa: <service name>`. This function parses that line and
/// returns the service name. If the field is absent or doesn't match, returns
/// [fallback] (typically the category name from `kategori_layanan`).
String extractServiceName(String? catatan, String fallback) {
  if (catatan == null || catatan.isEmpty) return fallback;
  final firstLine = catatan.split('\n').first;
  if (firstLine.startsWith('Jasa: ')) {
    final name = firstLine.replaceFirst('Jasa: ', '').trim();
    if (name.isNotEmpty) return name;
  }
  return fallback;
}
