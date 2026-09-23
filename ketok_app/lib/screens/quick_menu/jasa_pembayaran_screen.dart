import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../app.dart';
import 'quick_menu_shared.dart';

class JasaPembayaranScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final String categoryName;
  final IconData icon;
  final String location;
  final DateTime schedule;
  final String note;
  final Map<String, dynamic>? selectedVoucher;
  final double visitPriceRaw;
  final double discountAmount;
  final double finalVisitPrice;

  const JasaPembayaranScreen({
    super.key,
    required this.service,
    required this.categoryName,
    required this.icon,
    required this.location,
    required this.schedule,
    required this.note,
    this.selectedVoucher,
    required this.visitPriceRaw,
    required this.discountAmount,
    required this.finalVisitPrice,
  });

  @override
  State<JasaPembayaranScreen> createState() => _JasaPembayaranScreenState();
}

class _JasaPembayaranScreenState extends State<JasaPembayaranScreen> {
  String _selectedMethod = 'ketokpay'; // 'ketokpay', 'bca_va', 'mandiri_va', 'qris', 'tunai'
  bool _loading = false;
  final double _saldoKetokPay = 150000.0; // Demo saldo KetokPay aktif

  String get _serviceName =>
      widget.service['nama_jasa'] as String? ?? 'Jasa Ketok';

  String _formatDate(DateTime dt) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final minuteStr = dt.minute.toString().padLeft(2, '0');
    final hourStr = dt.hour.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year} • $hourStr:$minuteStr WIB';
  }

  Future<void> _processPaymentAndSubmitOrder() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      _showMessage('Sesi login tidak ditemukan.', isError: true);
      return;
    }

    final categoryId = widget.service['katagori_id'];
    if (categoryId is! int) {
      _showMessage('Kategori jasa tidak valid.', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final profile = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', user.id)
          .maybeSingle();

      final userId = profile?['id_user'];
      if (userId is! int) throw Exception('Profil pengguna belum terdaftar.');

      final voucherCode =
          widget.selectedVoucher?['voucher']?['kode_voucher'] as String?;

      final noteLines = [
        'Jasa: $_serviceName',
        'Biaya Kunjungan: ${formatFixedPrice(widget.finalVisitPrice)}',
        if (voucherCode != null)
          'Promo Digunakan: $voucherCode (Hemat ${formatFixedPrice(widget.discountAmount)})',
        'Metode Pembayaran: ${_getMethodLabel(_selectedMethod)}',
        if (widget.note.isNotEmpty) 'Catatan Pelanggan: ${widget.note}',
      ];

      // 1. Insert ke tabel pesanan
      Map<String, dynamic> orderRes;
      try {
        orderRes = await client
            .from('pesanan')
            .insert({
              'pengguna_id': userId,
              'katagori_id': categoryId,
              'mitra_id': widget.service['mitra_id'],
              'status': 'diproses',
              'lokasi': widget.location,
              'jadwal': widget.schedule.toIso8601String(),
              'catatan': noteLines.join('\n'),
              'biaya_kunjungan': widget.finalVisitPrice,
            })
            .select('id_pesanan')
            .single();
      } catch (err) {
        if (err.toString().contains('biaya_kunjungan')) {
          orderRes = await client
              .from('pesanan')
              .insert({
                'pengguna_id': userId,
                'katagori_id': categoryId,
                'mitra_id': widget.service['mitra_id'],
                'status': 'diproses',
                'lokasi': widget.location,
                'jadwal': widget.schedule.toIso8601String(),
                'catatan': noteLines.join('\n'),
              })
              .select('id_pesanan')
              .single();
        } else {
          rethrow;
        }
      }

      final orderId = orderRes['id_pesanan'] as int;

      final isLunas = _selectedMethod == 'ketokpay' || _selectedMethod == 'qris';

      // 2. Insert ke tabel invoice
      try {
        await client.from('invoice').insert({
          'pesanan_id': orderId,
          'jumlah_biaya': widget.finalVisitPrice,
          'biaya_kunjungan': widget.visitPriceRaw,
          'diskon_voucher': widget.discountAmount,
          'metode_bayar': _selectedMethod,
          'status_bayar': isLunas ? 'lunas' : 'menunggu',
          'dibayar_pada': isLunas ? DateTime.now().toIso8601String() : null,
        });
      } catch (_) {
        try {
          await client.from('invoice').insert({
            'pesanan_id': orderId,
            'jumlah_biaya': widget.finalVisitPrice,
            'status_bayar': isLunas ? 'lunas' : 'menunggu',
          });
        } catch (_) {}
      }

      // 3. Tandai voucher sebagai terpakai di database jika menggunakan voucher
      if (widget.selectedVoucher != null &&
          widget.selectedVoucher!['id_pengguna_voucher'] != null) {
        try {
          await client
              .from('pengguna_voucher')
              .update({
                'status': 'terpakai',
                'digunakan_pada': DateTime.now().toIso8601String(),
                'pesanan_id': orderId,
              })
              .eq('id_pengguna_voucher', widget.selectedVoucher!['id_pengguna_voucher']);
        } catch (_) {}
      }

      // 4. Catat notifikasi untuk pelanggan
      try {
        await client.from('notifikasi').insert({
          'user_id': userId,
          'judul': isLunas
              ? 'Pembayaran Berhasil! Pesanan #KTK-$orderId sedang diproses'
              : 'Pesanan #KTK-$orderId Berhasil Dibuat, Menunggu Pembayaran',
          'status_baca': 'belum',
        });
      } catch (_) {}

      if (!mounted) return;
      setState(() => _loading = false);

      _showSuccessDialog(orderId, isLunas);
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        _showMessage('Gagal memproses pesanan: $e', isError: true);
      }
    }
  }

  String _getMethodLabel(String key) {
    switch (key) {
      case 'ketokpay':
        return 'Saldo KetokPay';
      case 'bca_va':
        return 'BCA Virtual Account';
      case 'mandiri_va':
        return 'Mandiri Virtual Account';
      case 'qris':
        return 'QRIS Instant';
      case 'tunai':
        return 'Tunai ke Teknisi (COD)';
      default:
        return 'KetokPay';
    }
  }

  void _showSuccessDialog(int orderId, bool isLunas) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                size: 48,
                color: Color(0xFF059669),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isLunas ? 'Pembayaran Berhasil!' : 'Pesanan Berhasil Dibuat!',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nomor Pesanan: #KTK-$orderId\n'
              '${isLunas ? "Pembayaran Anda sebesar ${formatFixedPrice(widget.finalVisitPrice)} berhasil dikonfirmasi. Mitra teknisi akan meluncur sesuai jadwal yang Anda pilih." : "Pesanan Anda telah diteruskan ke mitra teknisi. Silakan bayar sesuai metode yang Anda pilih."}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  // Kembali ke halaman utama
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const KetokMainScreen()),
                    (route) => false,
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Pembayaran',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
              children: [
                _buildOrderOverviewCard(),
                const SizedBox(height: 18),
                _sectionTitle('METODE PEMBAYARAN'),
                _buildPaymentMethodSection(),
                const SizedBox(height: 18),
                _sectionTitle('RINGKASAN PEMBAYARAN'),
                _buildPaymentSummaryCard(),
                const SizedBox(height: 14),
                _buildSafetyBadge(),
              ],
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: FilledButton.icon(
                onPressed: _loading ? null : _processPaymentAndSubmitOrder,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.verified_user_rounded),
                label: Text(
                  _loading
                      ? 'Memproses Pesanan...'
                      : 'Bayar ${formatFixedPrice(widget.finalVisitPrice)} & Konfirmasi',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF171717),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Color(0xFF64748B),
        letterSpacing: 0.8,
      ),
    ),
  );

  Widget _buildOrderOverviewCard() => QuickMenuCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, size: 24, color: const Color(0xFF0F172A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.categoryName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _serviceName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(height: 20, color: Color(0xFFF1F5F9)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.event_outlined, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _formatDate(widget.schedule),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF334155),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.location,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF475569),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildPaymentMethodSection() => QuickMenuCard(
    child: Column(
      children: [
        // 1. Saldo KetokPay
        _buildMethodItem(
          id: 'ketokpay',
          title: 'Saldo KetokPay',
          subtitle: 'Saldo Anda: ${formatFixedPrice(_saldoKetokPay)}',
          icon: Icons.account_balance_wallet_rounded,
          badge: 'Cepat & Bebas Admin',
          badgeColor: const Color(0xFF059669),
        ),
        const Divider(height: 18, color: Color(0xFFF1F5F9)),

        // 2. BCA Virtual Account
        _buildMethodItem(
          id: 'bca_va',
          title: 'BCA Virtual Account',
          subtitle: 'Verifikasi instan 24 jam',
          icon: Icons.account_balance_rounded,
        ),
        const Divider(height: 18, color: Color(0xFFF1F5F9)),

        // 3. Mandiri Virtual Account
        _buildMethodItem(
          id: 'mandiri_va',
          title: 'Mandiri Virtual Account',
          subtitle: 'Transfer via Livin\' by Mandiri / ATM',
          icon: Icons.account_balance_rounded,
        ),
        const Divider(height: 18, color: Color(0xFFF1F5F9)),

        // 4. QRIS Instant
        _buildMethodItem(
          id: 'qris',
          title: 'QRIS Instant',
          subtitle: 'GoPay, OVO, Dana, ShopeePay, LinkAja',
          icon: Icons.qr_code_2_rounded,
        ),
        const Divider(height: 18, color: Color(0xFFF1F5F9)),

        // 5. Tunai / COD
        _buildMethodItem(
          id: 'tunai',
          title: 'Tunai di Tempat (COD)',
          subtitle: 'Bayar langsung ke teknisi setelah tiba',
          icon: Icons.handshake_outlined,
        ),
      ],
    ),
  );

  Widget _buildMethodItem({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    String? badge,
    Color? badgeColor,
  }) {
    final isSelected = _selectedMethod == id;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = id),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFECFDF5)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? const Color(0xFF059669)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF334155),
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: (badgeColor ?? const Color(0xFF059669))
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: badgeColor ?? const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? const Color(0xFF059669)
                  : const Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    final hasDiscount = widget.discountAmount > 0;
    final voucherCode =
        widget.selectedVoucher?['voucher']?['kode_voucher'] as String?;

    return QuickMenuCard(
      child: Column(
        children: [
          _summaryRow(
            'Biaya Kunjungan Dasar',
            formatFixedPrice(widget.visitPriceRaw),
          ),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Diskon Voucher (${voucherCode ?? "Promo"})',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
                Text(
                  '-${formatFixedPrice(widget.discountAmount)}',
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _summaryRow('Biaya Layanan Sistem', 'Gratis', valueColor: const Color(0xFF059669)),
          const Divider(height: 22, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Pembayaran',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
              Text(
                formatFixedPrice(widget.finalVisitPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? valueColor}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      ),
      Text(
        value,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: valueColor ?? const Color(0xFF1E293B),
        ),
      ),
    ],
  );

  Widget _buildSafetyBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: const [
        Icon(Icons.shield_outlined, size: 18, color: Color(0xFF64748B)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            'Transaksi Anda dilindungi sistem garansi Ketok. Biaya teknisi aman sampai pengerjaan selesai.',
            style: TextStyle(fontSize: 11, color: Color(0xFF475569), height: 1.3),
          ),
        ),
      ],
    ),
  );
}
