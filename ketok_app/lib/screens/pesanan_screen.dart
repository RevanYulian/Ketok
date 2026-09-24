import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/ketok_order_repository.dart';
import '../widgets/ketok_colors.dart';
import 'app.dart';
import 'chat_screen.dart';
import 'estimasi_detail_screen.dart';
import 'pesanan_detail_screen.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({super.key});

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> {
  late Future<List<KetokOrder>> _ordersFuture;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    _ordersFuture = KetokOrderRepository().getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = KetokOrderRepository().getOrders();
    });
  }

  Future<void> _handleRefresh() async {
    _refreshOrders();
    await _ordersFuture;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: KetokResponsiveContent(
      child: Column(
        children: [
          const KetokScreenHeader(),
          _FilterChips(
            selected: _filter,
            onSelected: (value) => setState(() => _filter = value),
          ),
          Expanded(
            child: FutureBuilder<List<KetokOrder>>(
              future: _ordersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final orders = _filterOrders(snapshot.data ?? const []);
                return RefreshIndicator(
                  onRefresh: _handleRefresh,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      if (snapshot.hasError) const _BackendNotice(),
                      ...orders.map(
                        (order) => _OrderCard(
                          order: order,
                          onRefresh: _refreshOrders,
                        ),
                      ),
                      if (orders.isEmpty) const _EmptyOrders(),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );

  List<KetokOrder> _filterOrders(List<KetokOrder> orders) {
    if (_filter == 'all' || _filter == 'Semua') {
      return orders;
    }
    if (_filter == 'active' || _filter == 'Berjalan') {
      return orders.where((order) => order.isActive).toList();
    }
    if (_filter == 'completed' || _filter == 'Selesai') {
      return orders.where((order) => order.status == 'selesai').toList();
    }
    return orders.where((order) => order.status == 'dibatalkan').toList();
  }
}

class _FilterChips extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final options = [
      ('all', l10n.tabAll),
      ('active', l10n.tabInProgress),
      ('completed', l10n.tabCompleted),
      ('cancelled', l10n.tabCancelled),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: options
            .map(
              (opt) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: opt.$1 == 'cancelled' ? 0 : 8),
                  child: ChoiceChip(
                    label: SizedBox(
                      width: double.infinity,
                      child: Text(
                        opt.$2,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    selected: selected == opt.$1 || selected == opt.$2,
                    onSelected: (_) => onSelected(opt.$1),
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: (selected == opt.$1 || selected == opt.$2)
                          ? Colors.white
                          : KetokColors.textMuted,
                      fontSize: 11,
                      fontWeight: (selected == opt.$1 || selected == opt.$2)
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                    backgroundColor: KetokColors.surfaceLow,
                    selectedColor: KetokColors.primary,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 7,
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final KetokOrder order;
  final VoidCallback? onRefresh;

  const _OrderCard({required this.order, this.onRefresh});

  void _openDetail(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PesananDetailScreen(
          order: order,
          onRefresh: onRefresh,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor = order.status == 'selesai'
        ? KetokColors.success
        : order.status == 'dibatalkan'
        ? Colors.redAccent
        : KetokColors.primary;
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      margin: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Row(
              children: [
                Icon(
                  order.status == 'selesai'
                      ? Icons.check_circle_outline
                      : Icons.access_time_rounded,
                  color: statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  order.localizedStatusLabel(l10n.isIndonesian),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Flexible(
                  child: Text(
                    order.invoice,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: KetokColors.textMuted),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    color: KetokColors.surfaceLow,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(order.icon, size: 30),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.mitraName,
                        style: const TextStyle(color: KetokColors.textMuted),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        order.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: KetokColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Text(
                  order.approvalStatus == 'disetujui' || order.status == 'selesai'
                      ? (l10n.isIndonesian ? 'Total Biaya' : 'Total Cost')
                      : (l10n.isIndonesian ? 'Biaya Kunjungan' : 'Call-out Fee'),
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const Spacer(),
                Text(
                  order.price,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (order.approvalStatus == 'menunggu_estimasi') ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.isIndonesian
                            ? 'Estimasi Biaya: Menunggu teknisi memeriksa kondisi di lokasi.'
                            : 'Cost Estimate: Waiting for technician inspection on site.',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (order.approvalStatus == 'menunggu_persetujuan') ...[
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.request_quote_rounded,
                          size: 18,
                          color: Color(0xFFD97706),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.isIndonesian ? 'Estimasi Biaya Masuk' : 'Cost Estimation Received',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ),
                        Text(
                          'Rp ${order.totalCost.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.isIndonesian
                          ? 'Mitra telah mengirimkan rincian estimasi biaya (jasa & sparepart). Buka halaman detail untuk meninjau dan memberi persetujuan.'
                          : 'Partner technician has submitted cost estimation (service & parts). Open details to review and approve.',
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF78350F), height: 1.3),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EstimasiDetailScreen(
                                order: order,
                                onRefresh: onRefresh,
                              ),
                            ),
                          );
                          onRefresh?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KetokColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.assignment_outlined, size: 16),
                        label: Text(
                          l10n.isIndonesian
                              ? 'Lihat Detail Estimasi & Konfirmasi'
                              : 'View Estimation Details & Confirm',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (order.approvalStatus == 'disetujui') ...[
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EstimasiDetailScreen(
                        order: order,
                        onRefresh: onRefresh,
                      ),
                    ),
                  );
                  onRefresh?.call();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 16, color: Color(0xFF059669)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.isIndonesian ? 'Estimasi Biaya Disetujui' : 'Cost Estimation Approved',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      Text(
                        l10n.isIndonesian ? 'Lihat Rincian' : 'View Details',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF059669),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF059669)),
                    ],
                  ),
                ),
              ),
            ] else if (order.approvalStatus == 'ditolak') ...[
              InkWell(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EstimasiDetailScreen(
                        order: order,
                        onRefresh: onRefresh,
                      ),
                    ),
                  );
                  onRefresh?.call();
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFDC2626)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.isIndonesian ? 'Estimasi Biaya Ditolak' : 'Cost Estimation Rejected',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF991B1B),
                          ),
                        ),
                      ),
                      Text(
                        l10n.isIndonesian ? 'Lihat Rincian' : 'View Details',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFDC2626),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFFDC2626)),
                    ],
                  ),
                ),
              ),
            ],
            Row(
              children: [
                // Tombol 1/4 (flex: 1) untuk Chat Mitra
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            initialMitraName: order.mitraName,
                            initialMitraPhotoUrl: order.mitraPhotoUrl,
                            initialServiceName: order.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: Text(
                      l10n.navChat,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF171717),
                      side: const BorderSide(color: Color(0xFF171717)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Tombol 3/4 (flex: 3) untuk Detail / Rating
                Expanded(
                  flex: 3,
                  child: FilledButton.icon(
                    onPressed: () => _openDetail(context),
                    icon: Icon(
                      order.status == 'selesai'
                          ? (order.hasReviewed
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded)
                          : Icons.receipt_long_rounded,
                      size: 18,
                      color: order.status == 'selesai'
                          ? Colors.amber
                          : Colors.white,
                    ),
                    label: Text(
                      order.status == 'selesai'
                          ? (order.hasReviewed
                              ? (l10n.isIndonesian
                                  ? 'Ulasan (★ ${order.rating}) • Detail'
                                  : 'Review (★ ${order.rating}) • Details')
                              : (l10n.isIndonesian
                                  ? 'Beri Rating & Ulasan'
                                  : 'Leave Rating & Review'))
                          : (l10n.isIndonesian
                              ? 'Detail Pesanan'
                              : 'Order Details'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF171717),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}

class _BackendNotice extends StatelessWidget {
  const _BackendNotice();
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4D6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.isIndonesian
            ? 'Menampilkan pesanan contoh. Hubungkan tabel Supabase untuk data langsung.'
            : 'Showing sample orders. Connect Supabase table for live data.',
        style: const TextStyle(fontSize: 12),
      ),
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 12),
          Text(
            l10n.emptyOrders,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.emptyOrdersDesc,
            style: const TextStyle(color: KetokColors.textMuted),
          ),
        ],
      ),
    );
  }
}
