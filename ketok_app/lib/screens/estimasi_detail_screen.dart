import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/ketok_order_repository.dart';
import '../widgets/ketok_colors.dart';

class EstimasiDetailScreen extends StatefulWidget {
  final KetokOrder order;
  final VoidCallback? onRefresh;

  const EstimasiDetailScreen({
    super.key,
    required this.order,
    this.onRefresh,
  });

  @override
  State<EstimasiDetailScreen> createState() => _EstimasiDetailScreenState();
}

class _EstimasiDetailScreenState extends State<EstimasiDetailScreen> {
  late KetokOrder _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  String _formatPrice(num value) {
    final text = value.round().toString();
    final formatted = text.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  String _formatDate(String? raw, {bool isIndo = true}) {
    if (raw == null) return '-';
    final date = DateTime.tryParse(raw);
    if (date == null) return raw;
    final months = isIndo
        ? [
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
        : [
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

  Future<void> _handleApproval(bool approve) async {
    final isIndo = context.l10n.isIndonesian;
    final orderId = _order.id;
    if (orderId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            approve
                ? (isIndo ? 'Estimasi biaya disetujui!' : 'Cost estimate approved!')
                : (isIndo ? 'Estimasi biaya ditolak.' : 'Cost estimate declined.'),
          ),
        ),
      );
      Navigator.pop(context);
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final client = Supabase.instance.client;
      final newStatus = approve ? 'disetujui' : 'ditolak';

      // 1. Update tabel pesanan
      await client
          .from('pesanan')
          .update({'status_persetujuan_biaya': newStatus})
          .eq('id_pesanan', orderId);

      // 2. Beri notifikasi ke mitra jika mitra_id ada
      if (_order.mitraId != null) {
        try {
          await client.from('notifikasi').insert({
            'user_id': _order.mitraId,
            'judul': approve
                ? 'Pelanggan telah MENYETUJUI estimasi biaya pesanan ${_order.invoice} (${_formatPrice(_order.totalCost)}). Silakan lanjutkan pengerjaan.'
                : 'Pelanggan MENOLAK estimasi biaya pesanan ${_order.invoice}. Silakan diskusikan lebih lanjut dengan pelanggan.',
            'status_baca': 'belum',
          });
        } catch (_) {}
      }

      widget.onRefresh?.call();

      if (!mounted) return;
      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor:
              approve ? const Color(0xFF059669) : Colors.redAccent,
          content: Text(
            approve
                ? (isIndo
                    ? 'Estimasi biaya disetujui! Mitra akan segera melanjutkan perbaikan.'
                    : 'Cost estimate approved! The partner will proceed with repairs.')
                : (isIndo
                    ? 'Estimasi biaya ditolak. Anda hanya berkewajiban membayar biaya kunjungan.'
                    : 'Cost estimate declined. You are only required to pay the call-out fee.'),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(isIndo ? 'Terjadi kesalahan: $e' : 'An error occurred: $e'),
        ),
      );
    }
  }

  Widget _buildStatusBanner(bool isIndo) {
    final status = _order.approvalStatus;

    if (status == 'disetujui') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndo ? 'Estimasi Biaya Disetujui' : 'Cost Estimate Approved',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isIndo
                        ? 'Anda telah menyetujui total estimasi ${_formatPrice(_order.totalCost)}. Mitra dapat melanjutkan pengerjaan.'
                        : 'You have approved the total estimate of ${_formatPrice(_order.totalCost)}. The partner may proceed with the work.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF047857)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'ditolak') {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndo ? 'Estimasi Biaya Ditolak' : 'Cost Estimate Declined',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isIndo
                        ? 'Anda tidak menyetujui estimasi biaya ini. Anda hanya perlu membayar biaya kunjungan teknisi.'
                        : 'You declined this cost estimate. You only need to pay the technician call-out fee.',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: menunggu_persetujuan
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KetokColors.surfaceLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: KetokColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.hourglass_top_rounded,
            color: KetokColors.primary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isIndo ? 'Menunggu Persetujuan Anda' : 'Awaiting Your Approval',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: KetokColors.primary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isIndo
                      ? 'Teknisi telah memeriksa kondisi unit dan mengirimkan rincian estimasi biaya perbaikan. Harap periksa sebelum menyetujui.'
                      : 'The technician has inspected the unit and sent detailed repair cost estimates. Please review before approving.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;
    final isWaiting = _order.approvalStatus == 'menunggu_persetujuan';

    return Scaffold(
      backgroundColor: KetokColors.background,
      appBar: AppBar(
        title: Text(isIndo ? 'Detail Estimasi Biaya' : 'Cost Estimate Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: KetokColors.primary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusBanner(isIndo),

              // Card Informasi Pesanan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: KetokColors.surfaceLow,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(_order.icon, color: KetokColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _order.title,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _order.invoice,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: Color(0xFFF1F5F9)),
                    _infoRow(
                      Icons.person_outline_rounded,
                      isIndo ? 'Teknisi / Mitra' : 'Technician / Partner',
                      _order.mitraName,
                    ),
                    _infoRow(
                      Icons.location_on_outlined,
                      isIndo ? 'Lokasi' : 'Location',
                      _order.location,
                    ),
                    _infoRow(
                      Icons.calendar_month_outlined,
                      isIndo ? 'Jadwal Kunjungan' : 'Scheduled Visit',
                      _formatDate(_order.jadwal, isIndo: isIndo),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Card Rincian Estimasi Biaya
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.receipt_long_rounded,
                          size: 20,
                          color: KetokColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isIndo ? 'Rincian Estimasi Biaya' : 'Cost Estimate Breakdown',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: KetokColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _costRow(
                      isIndo ? 'Biaya Kunjungan (Kedatangan)' : 'Call-out Fee (Arrival)',
                      _formatPrice(_order.biayaKunjungan),
                      subtitle: isIndo ? 'Sudah disepakati saat pemesanan' : 'Agreed upon booking',
                    ),
                    const SizedBox(height: 10),
                    _costRow(
                      isIndo ? 'Biaya Jasa / Tenaga Kerja' : 'Service / Labor Fee',
                      _formatPrice(_order.biayaJasa),
                    ),
                    const SizedBox(height: 10),
                    _costRow(
                      isIndo ? 'Biaya Sparepart / Komponen' : 'Spare Parts / Components Fee',
                      _formatPrice(_order.biayaSparepart),
                      subtitle: _order.biayaSparepart == 0
                          ? (isIndo ? 'Tidak ada pergantian suku cadang' : 'No replacement parts')
                          : null,
                    ),
                    const Divider(height: 24, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isIndo ? 'Total Estimasi Biaya' : 'Total Estimated Cost',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: KetokColors.primary,
                          ),
                        ),
                        Text(
                          _formatPrice(_order.totalCost),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: KetokColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if ((_order.rincianEstimasi ?? '').isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.notes_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isIndo ? 'Catatan Pekerjaan dari Teknisi' : 'Work Notes from Technician',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: KetokColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _order.rincianEstimasi!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Card Transparansi & Kebijakan
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.shield_outlined,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isIndo
                            ? 'Jaminan Bebas Biaya Tersembunyi: Pekerjaan perbaikan menyeluruh baru akan dikerjakan setelah Anda menyetujui estimasi ini. Jika ditolak, Anda hanya berkewajiban membayar biaya kunjungan awal.'
                            : 'No Hidden Fees Guarantee: Comprehensive repair work will only proceed after you approve this estimate. If declined, you are only obligated to pay the initial visit fee.',
                        style: const TextStyle(
                          fontSize: 11,
                          height: 1.4,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Konfirmasi jika menunggu persetujuan
              if (isWaiting) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading ? null : () => _handleApproval(false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          isIndo ? 'Tolak Estimasi' : 'Decline Estimate',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : () => _handleApproval(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KetokColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isIndo ? 'Setujui Estimasi' : 'Approve Estimate',
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KetokColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isIndo ? 'Kembali ke Pesanan' : 'Back to Order',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: KetokColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value, {String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: KetokColors.primary,
          ),
        ),
      ],
    );
  }
}
