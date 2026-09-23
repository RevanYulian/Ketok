import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import '../pesanan_detail_screen.dart';
import 'quick_menu_shared.dart';

class PesananTersediaScreen extends StatefulWidget {
  const PesananTersediaScreen({super.key});

  @override
  State<PesananTersediaScreen> createState() => _PesananTersediaScreenState();
}

class _PesananTersediaScreenState extends State<PesananTersediaScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final client = Supabase.instance.client;
      final mitraId = await loadMitraId(client);

      final rows = await client
          .from('pesanan')
          .select(
            'id_pesanan, pengguna_id, katagori_id, status, lokasi, jadwal, catatan, biaya_kunjungan, status_persetujuan_biaya',
          )
          .eq('mitra_id', mitraId)
          .inFilter('status', ['diproses', 'menuju_lokasi', 'dikerjakan'])
          .order('jadwal', ascending: false);

      final loaded = <Map<String, dynamic>>[];
      for (final order in rows) {
        final customer = await client
            .from('users')
            .select('nama')
            .eq('id_user', order['pengguna_id'])
            .maybeSingle();
        final category = await client
            .from('kategori_layanan')
            .select('nama_katagori')
            .eq('id_katagori', order['katagori_id'])
            .maybeSingle();
        final invoice = await client
            .from('invoice')
            .select('jumlah_biaya, biaya_kunjungan, biaya_jasa, biaya_sparepart')
            .eq('pesanan_id', order['id_pesanan'])
            .maybeSingle();

        loaded.add({
          ...Map<String, dynamic>.from(order),
          'customer_name': customer?['nama'] ?? 'Pelanggan',
          'category_name': category?['nama_katagori'] ?? 'Layanan Ketok',
          'price': invoice?['jumlah_biaya'] ?? order['biaya_kunjungan'] ?? 50000,
        });
      }
      if (!mounted) return;
      setState(() {
        _orders = loaded;
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

  Future<void> _openDetail(
    Map<String, dynamic> order, {
    bool openEstimasi = false,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PesananDetailScreen(
          order: order,
          openEstimasiOnStart: openEstimasi,
          onComplete: () async => _loadOrders(),
        ),
      ),
    );
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return QuickMenuScaffold(
      title: 'Pesanan Tersedia',
      icon: Icons.inventory_2_outlined,
      onRefresh: _loadOrders,
      child: QuickMenuContent(
        loading: _loading,
        errorMessage: _errorMessage,
        onRetry: _loadOrders,
        child: _orders.isEmpty
            ? const QuickMenuEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'Belum ada pesanan tersedia',
                subtitle: 'Pesanan baru untuk Anda akan muncul di sini.',
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                itemCount: _orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _buildOrderCard(_orders[index]),
              ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return QuickMenuCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order['category_name'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                formatQuickMenuCurrency(order['price']),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: KetokColors.darkPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _detail(
            Icons.person_outline_rounded,
            order['customer_name'] as String,
          ),
          _detail(
            Icons.location_on_outlined,
            order['lokasi'] as String? ?? 'Lokasi belum tersedia',
          ),
          _detail(Icons.event_outlined, formatQuickMenuDate(order['jadwal'])),
          if ((order['catatan'] as String?)?.isNotEmpty == true)
            _detail(Icons.notes_rounded, order['catatan'] as String),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _openDetail(order),
                  child: const Text('Cek Detail'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openDetail(order, openEstimasi: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KetokColors.darkPrimary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Kirim Estimasi',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _detail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: KetokColors.onSurfaceVariant),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: KetokColors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
