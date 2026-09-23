import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';
import 'pesanan_detail_screen.dart';

class PesananScreen extends StatefulWidget {
  final VoidCallback? onNotificationTap;

  const PesananScreen({
    super.key,
    this.onNotificationTap,
  });

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  int _selectedFilter = 0;
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];

  static const _background = KetokColors.bgColor;
  static const _primary = KetokColors.darkPrimary;
  static const _muted = KetokColors.onSurfaceVariant;
  static const _soft = KetokColors.surfaceLow;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant PesananScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        throw Exception('Sesi login tidak ditemukan.');
      }

      final profile = await client
          .from('users')
          .select('id_user, nama, foto_profil')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      final mitraId = profile?['id_user'];
      if (mitraId == null) {
        throw Exception('Profil Mitra belum terhubung ke akun ini.');
      }
      final rows = await client
          .from('pesanan')
          .select(
            'id_pesanan, pengguna_id, katagori_id, status, lokasi, jadwal, catatan, biaya_kunjungan, status_persetujuan_biaya',
          )
          .eq('mitra_id', mitraId)
          .order('jadwal', ascending: false);

      final loadedOrders = <Map<String, dynamic>>[];
      for (final row in rows) {
        final customer = await client
            .from('users')
            .select('nama')
            .eq('id_user', row['pengguna_id'])
            .maybeSingle();
        final category = await client
            .from('kategori_layanan')
            .select('nama_katagori')
            .eq('id_katagori', row['katagori_id'])
            .maybeSingle();
        final payment = await client
            .from('invoice')
            .select('jumlah_biaya, biaya_kunjungan, biaya_jasa, biaya_sparepart')
            .eq('pesanan_id', row['id_pesanan'])
            .maybeSingle();

        dynamic priceVal = payment?['jumlah_biaya'];
        if (priceVal == null && row['catatan'] != null) {
          final note = row['catatan'] as String;
          final match = RegExp(r'Biaya Kunjungan:\s*Rp\s*([\d\.]+)').firstMatch(note);
          if (match != null) {
            priceVal = num.tryParse(match.group(1)!.replaceAll('.', ''));
          }
        }

        loadedOrders.add({
          ...Map<String, dynamic>.from(row),
          'customer_name': customer?['nama'] ?? 'Pelanggan',
          'category_name': category?['nama_katagori'] ?? 'Layanan Ketok',
          'price': priceVal,
          'biaya_kunjungan': row['biaya_kunjungan'] ?? payment?['biaya_kunjungan'] ?? priceVal,
          'biaya_jasa': payment?['biaya_jasa'],
          'biaya_sparepart': payment?['biaya_sparepart'],
          'status_persetujuan_biaya': row['status_persetujuan_biaya'] ?? 'menunggu_estimasi',
        });
      }

      if (!mounted) return;
      setState(() {
        _orders = loadedOrders;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 0) return _orders;
    return _orders.where((order) {
      final status = order['status'] as String? ?? '';
      if (_selectedFilter == 1) {
        return !{'selesai', 'dibatalkan'}.contains(status);
      }
      if (_selectedFilter == 2) return status == 'selesai';
      return status == 'dibatalkan';
    }).toList();
  }

  String _formatPrice(dynamic value) {
    if (value == null) return 'Belum ditentukan';
    final number = (value as num).round().toString();
    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
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

  bool _isActive(String status) => !{'selesai', 'dibatalkan'}.contains(status);

  String _statusLabel(String status) {
    switch (status) {
      case 'diproses':
        return 'Diproses';
      case 'menuju_lokasi':
        return 'Menuju Lokasi';
      case 'dikerjakan':
        return 'Dalam Pengerjaan';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
        return 'Dibatalkan';
      default:
        return 'Menunggu Konfirmasi';
    }
  }

  Color _statusColor(String status) {
    if (status == 'selesai') return const Color(0xFF059669);
    if (status == 'dibatalkan') return const Color(0xFF64748B);
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadOrders,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilters(),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildErrorState()
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        child: _filteredOrders.isEmpty
                            ? _buildEmptyState()
                            : Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < _filteredOrders.length;
                                    index++
                                  ) ...[
                                    if (index > 0) const SizedBox(height: 14),
                                    _buildOrderCardFromData(
                                      _filteredOrders[index],
                                    ),
                                  ],
                                  const SizedBox(height: 42),
                                  const Icon(
                                    Icons.receipt_long_outlined,
                                    size: 45,
                                    color: Color(0xFFD1D5DB),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Menampilkan semua pesanan',
                                    style: TextStyle(
                                      color: Color(0xFF9CA3AF),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            const Icon(Icons.cloud_off_outlined, size: 42, color: _muted),
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _muted),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFD1D5DB)),
            SizedBox(height: 12),
            Text(
              'Belum ada pesanan pada filter ini',
              style: TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardFromData(Map<String, dynamic> order) {
    final status = order['status'] as String? ?? '';
    final active = _isActive(status);
    return _buildOrderCard(
      order: order,
      status: _statusLabel(status),
      statusColor: _statusColor(status),
      reference: active
          ? 'Pesanan #${order['id_pesanan']}'
          : _formatDate(order['jadwal']),
      title: order['category_name'] as String,
      customer: order['customer_name'] as String,
      price: _formatPrice(order['price']),
      location: order['lokasi'] as String? ?? 'Lokasi belum tersedia',
      active: active,
      orderId: order['id_pesanan'] as int,
    );
  }

  Future<void> _completeOrder(int orderId) async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception('Sesi login tidak ditemukan.');

      final profile = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      final mitraId = profile?['id_user'];
      if (mitraId == null) throw Exception('Profil Mitra tidak ditemukan.');

      final updated = await client
          .from('pesanan')
          .update({'status': 'selesai'})
          .eq('id_pesanan', orderId)
          .eq('mitra_id', mitraId)
          .neq('status', 'selesai')
          .neq('status', 'dibatalkan')
          .select('id_pesanan');
      if (updated.isEmpty) throw Exception('Pesanan tidak dapat diselesaikan.');

      await client
          .from('invoice')
          .update({'status_bayar': 'lunas'})
          .eq('pesanan_id', orderId);
      if (!mounted) return;
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil diselesaikan.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan gagal diselesaikan: $error')),
      );
    }
  }

  Widget _buildHeader() {
    return KetokAppBar(
      onNotificationTap: widget.onNotificationTap,
    );
  }

  Widget _buildFilters() {
    const filters = ['Semua', 'Berjalan', 'Selesai', 'Dibatalkan'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: List.generate(filters.length, (index) {
          final selected = _selectedFilter == index;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == filters.length - 1 ? 0 : 8,
              ),
              child: ChoiceChip(
                label: SizedBox(
                  width: double.infinity,
                  child: Text(
                    filters[index],
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                selected: selected,
                onSelected: (_) => setState(() => _selectedFilter = index),
                showCheckmark: false,
                labelStyle: TextStyle(
                  color: selected ? Colors.white : _muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
                backgroundColor: _soft,
                selectedColor: _primary,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 7),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildOrderCard({
    required Map<String, dynamic> order,
    required String status,
    required Color statusColor,
    required String reference,
    required String title,
    required String customer,
    required String price,
    required String location,
    required int orderId,
    bool active = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                active
                    ? Icons.schedule_rounded
                    : Icons.check_circle_outline_rounded,
                color: statusColor,
                size: 18,
              ),
              const SizedBox(width: 5),
              Text(
                status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                reference,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Divider(height: 1, color: Color(0xFFE5E7EB)),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _soft,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.ac_unit_rounded,
                  size: 30,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      active ? 'Pemesan: $customer' : customer,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: _muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: _muted),
                    ),
                    const SizedBox(height: 11),
                    Row(
                      children: [
                        Text(
                          active ? 'Biaya Kunjungan' : 'Total Biaya',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (active)
            LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 340;
                final isApproved =
                    order['status_persetujuan_biaya'] == 'disetujui';

                final buttons = [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PesananDetailScreen(
                              order: order,
                              onComplete: () => _completeOrder(orderId),
                            ),
                          ),
                        );
                        _loadOrders();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _primary,
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Detail'),
                    ),
                  ),
                  SizedBox(width: narrow ? 0 : 10, height: narrow ? 8 : 0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isApproved
                          ? () => _completeOrder(orderId)
                          : () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => PesananDetailScreen(
                                    order: order,
                                    openEstimasiOnStart: true,
                                    onComplete: () => _completeOrder(orderId),
                                  ),
                                ),
                              );
                              _loadOrders();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        isApproved ? 'Selesaikan' : 'Kirim Estimasi',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ];
                return narrow
                    ? Column(children: buttons)
                    : Row(children: buttons);
              },
            )
          else
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PesananDetailScreen(order: order),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  backgroundColor: _soft,
                  foregroundColor: _primary,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Lihat Rincian',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
