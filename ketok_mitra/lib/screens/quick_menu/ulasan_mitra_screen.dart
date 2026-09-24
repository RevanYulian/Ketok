import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import '../../l10n/app_localizations.dart';
import 'quick_menu_shared.dart';

class UlasanMitraScreen extends StatefulWidget {
  const UlasanMitraScreen({super.key});

  @override
  State<UlasanMitraScreen> createState() => _UlasanMitraScreenState();
}

class _UlasanMitraScreenState extends State<UlasanMitraScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final client = Supabase.instance.client;
      final mitraId = await loadMitraId(client);
      final orders = await client
          .from('pesanan')
          .select('id_pesanan, pengguna_id')
          .eq('mitra_id', mitraId)
          .eq('status', 'selesai');
      final orderIds = orders.map((row) => row['id_pesanan']).toList();
      final loaded = <Map<String, dynamic>>[];
      if (orderIds.isNotEmpty) {
        final reviews = await client
            .from('ulasan')
            .select('id_ulasan, pesanan_id, rating, komentar')
            .inFilter('pesanan_id', orderIds)
            .order('id_ulasan', ascending: false);
        for (final review in reviews) {
          final order = orders
              .cast<Map<String, dynamic>>()
              .where((row) => row['id_pesanan'] == review['pesanan_id'])
              .firstOrNull;
          final customer = order == null
              ? null
              : await client
                    .from('users')
                    .select('nama')
                    .eq('id_user', order['pengguna_id'])
                    .maybeSingle();
          loaded.add({
            ...Map<String, dynamic>.from(review),
            'customer_name': customer?['nama'] ?? 'Pelanggan',
          });
        }

        // Tandai seluruh ulasan yang ada sebagai sudah dilihat
        if (reviews.isNotEmpty) {
          int maxId = 0;
          for (final r in reviews) {
            final id = (r['id_ulasan'] as num?)?.toInt() ?? 0;
            if (id > maxId) maxId = id;
          }
          if (maxId > 0) {
            try {
              final prefs = await SharedPreferences.getInstance();
              final currentSaved = prefs.getInt('last_seen_review_id_$mitraId') ?? 0;
              if (maxId > currentSaved) {
                await prefs.setInt('last_seen_review_id_$mitraId', maxId);
              }
              await prefs.setBool('has_seen_reviews_$mitraId', true);
            } catch (_) {}
          }
        }
      } else {
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('has_seen_reviews_$mitraId', true);
        } catch (_) {}
      }
      if (!mounted) return;
      setState(() {
        _reviews = loaded;
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
    final isIndo = context.l10n.isIndonesian;
    return QuickMenuScaffold(
      title: isIndo ? 'Ulasan Mitra' : 'Customer Reviews',
      icon: Icons.rate_review_outlined,
      onRefresh: _loadReviews,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadReviews,
        child: _reviews.isEmpty
            ? QuickMenuEmptyState(
                icon: Icons.rate_review_outlined,
                title: isIndo ? 'Belum ada ulasan' : 'No reviews yet',
                subtitle: isIndo
                    ? 'Ulasan pelanggan akan tampil setelah pesanan selesai.'
                    : 'Customer reviews will appear once orders are completed.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _reviews.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildReview(_reviews[index], isIndo),
              ),
      ),
    );
  }

  Widget _buildReview(Map<String, dynamic> review, bool isIndo) {
    final rating = (review['rating'] as num?)?.toDouble() ?? 0;
    return QuickMenuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: KetokColors.surfaceLow,
                child: Icon(
                  Icons.person_outline_rounded,
                  color: KetokColors.darkPrimary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  review['customer_name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: Color(0xFFF59E0B),
                    size: 19,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    rating.toStringAsFixed(1),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (review['komentar'] as String?)?.isNotEmpty == true
                ? review['komentar'] as String
                : (isIndo ? 'Pelanggan tidak menulis komentar.' : 'Customer did not write a comment.'),
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
