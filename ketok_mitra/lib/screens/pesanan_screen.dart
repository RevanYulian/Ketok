import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';
import 'pesanan_detail_screen.dart';
import 'quick_menu/quick_menu_shared.dart';

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
            .select('nama, foto_profil')
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

        final catName = category?['nama_katagori'] as String? ?? 'Layanan Ketok';
        final serviceName = extractServiceName(
          row['catatan'] as String?,
          catName,
        );
        loadedOrders.add({
          ...Map<String, dynamic>.from(row),
          'customer_name': customer?['nama'] ?? 'Pelanggan',
          'customer_photo': customer?['foto_profil'],
          'category_name': serviceName,
          'raw_category': catName,
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

  String _formatPrice(BuildContext context, dynamic value) {
    if (value == null) {
      return context.l10n.isIndonesian ? 'Belum ditentukan' : 'To be determined';
    }
    final number = (value as num).round().toString();
    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(dynamic value, [bool isIndo = true]) {
    if (value == null) return '-';
    final date = DateTime.tryParse(value.toString());
    if (date == null) return value.toString();
    final months = isIndo
        ? const [
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
          ]
        : const [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  bool _isActive(String status) => !{'selesai', 'dibatalkan'}.contains(status);

  String _statusLabel(BuildContext context, String status) {
    final l10n = context.l10n;
    switch (status) {
      case 'diproses':
        return l10n.isIndonesian ? 'Diproses' : 'In Process';
      case 'menuju_lokasi':
        return l10n.isIndonesian ? 'Menuju Lokasi' : 'On The Way';
      case 'dikerjakan':
        return l10n.isIndonesian ? 'Dalam Pengerjaan' : 'In Progress';
      case 'selesai':
        return l10n.isIndonesian ? 'Selesai' : 'Completed';
      case 'dibatalkan':
        return l10n.isIndonesian ? 'Dibatalkan' : 'Cancelled';
      default:
        return l10n.isIndonesian ? 'Menunggu Konfirmasi' : 'Awaiting Confirmation';
    }
  }

  Color _statusColor(String status) {
    if (status == 'selesai') return const Color(0xFF059669);
    if (status == 'dibatalkan') return const Color(0xFF64748B);
    return const Color(0xFFD97706);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                    _buildFilters(context),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (_errorMessage != null)
                      _buildErrorState(context)
                    else
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        child: _filteredOrders.isEmpty
                            ? _buildEmptyState(context)
                            : Column(
                                children: [
                                  for (
                                    var index = 0;
                                    index < _filteredOrders.length;
                                    index++
                                  ) ...[
                                    if (index > 0) const SizedBox(height: 14),
                                    _buildOrderCardFromData(
                                      context,
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
                                  Text(
                                    l10n.isIndonesian
                                        ? 'Menampilkan semua pesanan'
                                        : 'Showing all orders',
                                    style: const TextStyle(
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

  Widget _buildErrorState(BuildContext context) {
    final l10n = context.l10n;
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
              label: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const Icon(Icons.receipt_long_outlined, size: 48, color: Color(0xFFD1D5DB)),
            const SizedBox(height: 12),
            Text(
              l10n.isIndonesian
                  ? 'Belum ada pesanan pada filter ini'
                  : 'No orders found for this filter',
              style: const TextStyle(color: _muted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCardFromData(BuildContext context, Map<String, dynamic> order) {
    final l10n = context.l10n;
    final status = order['status'] as String? ?? '';
    final active = _isActive(status);
    return _buildOrderCard(
      context: context,
      order: order,
      status: _statusLabel(context, status),
      statusColor: _statusColor(status),
      reference: active
          ? '${l10n.navOrders} #${order['id_pesanan']}'
          : _formatDate(order['jadwal'], l10n.isIndonesian),
      title: order['category_name'] as String,
      customer: order['customer_name'] as String,
      price: _formatPrice(context, order['price']),
      location: order['lokasi'] as String? ?? (l10n.isIndonesian ? 'Lokasi belum tersedia' : 'Location not available'),
      active: active,
      orderId: order['id_pesanan'] as int,
    );
  }

  Future<void> _completeOrder(int orderId) async {
    final l10n = context.l10n;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception(l10n.isIndonesian ? 'Sesi login tidak ditemukan.' : 'Login session not found.');

      final profile = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      final mitraId = profile?['id_user'];
      if (mitraId == null) throw Exception(l10n.isIndonesian ? 'Profil Mitra tidak ditemukan.' : 'Partner profile not found.');

      final updated = await client
          .from('pesanan')
          .update({'status': 'selesai'})
          .eq('id_pesanan', orderId)
          .eq('mitra_id', mitraId)
          .neq('status', 'selesai')
          .neq('status', 'dibatalkan')
          .select('id_pesanan');
      if (updated.isEmpty) throw Exception(l10n.isIndonesian ? 'Pesanan tidak dapat diselesaikan.' : 'Order could not be completed.');

      await client
          .from('invoice')
          .update({'status_bayar': 'lunas'})
          .eq('pesanan_id', orderId);
      if (!mounted) return;
      await _loadOrders();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.isIndonesian ? 'Pesanan berhasil diselesaikan.' : 'Order completed successfully.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.isIndonesian ? 'Pesanan gagal diselesaikan: $error' : 'Failed to complete order: $error')),
      );
    }
  }

  Widget _buildHeader() {
    return KetokAppBar(
      onNotificationTap: widget.onNotificationTap,
    );
  }

  Widget _buildFilters(BuildContext context) {
    final l10n = context.l10n;
    final filters = [l10n.tabAll, l10n.tabInProgress, l10n.tabCompleted, l10n.tabCancelled];
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
    required BuildContext context,
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
    final l10n = context.l10n;
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
              OrderCustomerAvatar(
                customerName: customer,
                photoUrl: order['customer_photo'] as String?,
                size: 64,
                borderRadius: 11,
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
                      active ? '${l10n.customerLabel}: $customer' : customer,
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
                          active
                              ? l10n.visitFeeLabel
                              : (l10n.isIndonesian ? 'Total Biaya' : 'Total Fee'),
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
                      child: Text(l10n.isIndonesian ? 'Detail' : 'Details'),
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
                        isApproved
                            ? (l10n.isIndonesian ? 'Selesaikan' : 'Complete')
                            : (l10n.isIndonesian ? 'Kirim Estimasi' : 'Send Estimate'),
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
                child: Text(
                  l10n.isIndonesian ? 'Lihat Rincian' : 'View Details',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
