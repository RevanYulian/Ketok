import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'quick_menu_shared.dart';

class TagihanMarketingScreen extends StatefulWidget {
  const TagihanMarketingScreen({super.key});

  @override
  State<TagihanMarketingScreen> createState() => _TagihanMarketingScreenState();
}

class _TagihanMarketingScreenState extends State<TagihanMarketingScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _invoices = [];

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final client = Supabase.instance.client;
      final mitraId = await loadMitraId(client);
      final orders = await client
          .from('pesanan')
          .select('id_pesanan, katagori_id, jadwal, status')
          .eq('mitra_id', mitraId)
          .order('jadwal', ascending: false);
      final loaded = <Map<String, dynamic>>[];
      for (final order in orders) {
        final invoice = await client
            .from('invoice')
            .select('jumlah_biaya, status_bayar')
            .eq('pesanan_id', order['id_pesanan'])
            .maybeSingle();
        if (invoice == null) continue;
        final category = await client
            .from('kategori_layanan')
            .select('nama_katagori')
            .eq('id_katagori', order['katagori_id'])
            .maybeSingle();
        loaded.add({
          ...Map<String, dynamic>.from(order),
          ...Map<String, dynamic>.from(invoice),
          'category_name': category?['nama_katagori'] ?? 'Layanan Ketok',
        });
      }
      if (!mounted) return;
      setState(() {
        _invoices = loaded;
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
      title: 'Tagihan Marketing',
      icon: Icons.receipt_long_outlined,
      onRefresh: _loadInvoices,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadInvoices,
        child: _invoices.isEmpty
            ? const QuickMenuEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Belum ada tagihan',
                subtitle:
                    'Data tagihan akan tampil setelah tersedia di database.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _invoices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildInvoice(_invoices[index]),
              ),
      ),
    );
  }

  Widget _buildInvoice(Map<String, dynamic> invoice) {
    final paid = invoice['status_bayar'] == 'lunas';
    return QuickMenuCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: KetokColors.surfaceLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: KetokColors.darkPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice['category_name'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  formatQuickMenuDate(invoice['jadwal']),
                  style: const TextStyle(
                    color: KetokColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  formatQuickMenuCurrency(invoice['jumlah_biaya']),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: paid ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              paid ? 'Lunas' : 'Menunggu',
              style: TextStyle(
                color: paid ? const Color(0xFF2E7D32) : const Color(0xFFC2410C),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
