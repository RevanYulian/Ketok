import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';

class PesananDetailScreen extends StatefulWidget {
  final Map<String, dynamic> order;
  final Future<void> Function()? onComplete;
  final bool openEstimasiOnStart;

  const PesananDetailScreen({
    super.key,
    required this.order,
    this.onComplete,
    this.openEstimasiOnStart = false,
  });

  @override
  State<PesananDetailScreen> createState() => _PesananDetailScreenState();
}

class _PesananDetailScreenState extends State<PesananDetailScreen> {
  late Map<String, dynamic> _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = Map<String, dynamic>.from(widget.order);
    _refreshDetailFromSupabase();

    if (widget.openEstimasiOnStart &&
        _isActive &&
        _order['status_persetujuan_biaya'] != 'disetujui') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showFormEstimasiModal();
        }
      });
    }
  }

  Future<void> _refreshDetailFromSupabase() async {
    final orderId = _order['id_pesanan'];
    if (orderId == null) return;
    try {
      final client = Supabase.instance.client;
      final orderRes = await client
          .from('pesanan')
          .select(
            'id_pesanan, status, status_persetujuan_biaya, biaya_kunjungan, catatan',
          )
          .eq('id_pesanan', orderId)
          .maybeSingle();

      final invoiceRes = await client
          .from('invoice')
          .select(
            'jumlah_biaya, biaya_kunjungan, biaya_jasa, biaya_sparepart, status_bayar',
          )
          .eq('pesanan_id', orderId)
          .maybeSingle();

      if (mounted && orderRes != null) {
        setState(() {
          _order['status'] = orderRes['status'] ?? _order['status'];
          _order['status_persetujuan_biaya'] =
              orderRes['status_persetujuan_biaya'] ??
              _order['status_persetujuan_biaya'];
          _order['biaya_kunjungan'] =
              orderRes['biaya_kunjungan'] ??
              invoiceRes?['biaya_kunjungan'] ??
              _order['biaya_kunjungan'];
          _order['biaya_jasa'] =
              invoiceRes?['biaya_jasa'] ?? _order['biaya_jasa'];
          _order['biaya_sparepart'] =
              invoiceRes?['biaya_sparepart'] ?? _order['biaya_sparepart'];
          if (invoiceRes?['jumlah_biaya'] != null) {
            _order['price'] = invoiceRes!['jumlah_biaya'];
          }
          if (orderRes['catatan'] != null) {
            _order['catatan'] = orderRes['catatan'];
          }
        });
      }
    } catch (_) {}
  }

  String _formatPrice(dynamic value) {
    if (value == null) return 'Rp 0';
    final rawValue = value is num ? value : num.tryParse(value.toString());
    if (rawValue == null) return value.toString();
    final text = rawValue.round().toString();
    final formatted = text.replaceAllMapped(
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
    return KetokColors.darkPrimary;
  }

  bool get _isActive =>
      !{'selesai', 'dibatalkan'}.contains((_order['status'] as String? ?? ''));

  num _getVisitCost() {
    final v = _order['biaya_kunjungan'];
    if (v is num) return v;
    if (v != null) {
      final parsed = num.tryParse(v.toString());
      if (parsed != null) return parsed;
    }
    final p = _order['price'];
    if (p is num) return p;
    return 50000;
  }

  num _getJasaCost() {
    final v = _order['biaya_jasa'];
    if (v is num) return v;
    if (v != null) return num.tryParse(v.toString()) ?? 0;
    return 0;
  }

  num _getSparepartCost() {
    final v = _order['biaya_sparepart'];
    if (v is num) return v;
    if (v != null) return num.tryParse(v.toString()) ?? 0;
    return 0;
  }

  void _showFormEstimasiModal() {
    final visitCost = _getVisitCost();
    final initialJasa = _getJasaCost();
    final initialSparepart = _getSparepartCost();

    final jasaController = TextEditingController(
      text: initialJasa > 0 ? initialJasa.round().toString() : '',
    );
    final sparepartController = TextEditingController(
      text: initialSparepart > 0 ? initialSparepart.round().toString() : '',
    );
    final rincianController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        num curJasa = initialJasa;
        num curSparepart = initialSparepart;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final totalBiaya = visitCost + curJasa + curSparepart;

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: KetokColors.surfaceLow,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.request_quote_rounded,
                            color: KetokColors.darkPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Form Estimasi Biaya',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: KetokColors.darkPrimary,
                                ),
                              ),
                              Text(
                                'Kirim rincian biaya setelah pemeriksaan di lokasi',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.directions_car_filled_outlined,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Biaya Kunjungan (Sudah Disepakati)',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            _formatPrice(visitCost),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: KetokColors.darkPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Biaya Jasa / Pengerjaan *',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KetokColors.darkPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: jasaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: KetokColors.darkPrimary,
                        ),
                        hintText: 'Contoh: 150000',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          curJasa = num.tryParse(val) ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Biaya Sparepart / Material (Opsional)',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KetokColors.darkPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: sparepartController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: KetokColors.darkPrimary,
                        ),
                        hintText: '0 jika tidak ada pergantian komponen',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          curSparepart = num.tryParse(val) ?? 0;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Rincian Kerusakan & Komponen',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: KetokColors.darkPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: rincianController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            'Contoh: Penggantian kapasitor 25uF & tambah freon AC',
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFCBD5E1),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: KetokColors.surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: KetokColors.borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Kunjungan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                _formatPrice(visitCost),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Jasa Perbaikan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                _formatPrice(curJasa),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sparepart/Bahan',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              Text(
                                _formatPrice(curSparepart),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16, color: Color(0xFFCBD5E1)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Estimasi Biaya',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: KetokColors.darkPrimary,
                                ),
                              ),
                              Text(
                                _formatPrice(totalBiaya),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: KetokColors.darkPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (curJasa <= 0) {
                                  ScaffoldMessenger.of(
                                    modalContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Biaya jasa harus diisi lebih dari Rp 0.',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pop(modalContext);
                                await _submitEstimasi(
                                  visitCost: visitCost,
                                  jasaCost: curJasa,
                                  sparepartCost: curSparepart,
                                  totalBiaya: totalBiaya,
                                  rincian: rincianController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KetokColors.darkPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text(
                          'Kirim Estimasi ke Pelanggan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _submitEstimasi({
    required num visitCost,
    required num jasaCost,
    required num sparepartCost,
    required num totalBiaya,
    required String rincian,
  }) async {
    setState(() => _loading = true);

    try {
      final client = Supabase.instance.client;
      final orderId = _order['id_pesanan'];
      final customerId = _order['pengguna_id'];

      String existingCatatan = _order['catatan'] as String? ?? '';
      if (rincian.isNotEmpty) {
        existingCatatan += '\nEstimasi Perbaikan: $rincian';
      }

      // 1. Update tabel pesanan
      await client.from('pesanan').update({
        'status_persetujuan_biaya': 'menunggu_persetujuan',
        'catatan': existingCatatan,
      }).eq('id_pesanan', orderId);

      // 2. Update tabel invoice
      await client.from('invoice').update({
        'biaya_kunjungan': visitCost,
        'biaya_jasa': jasaCost,
        'biaya_sparepart': sparepartCost,
        'jumlah_biaya': totalBiaya,
      }).eq('pesanan_id', orderId);

      // 3. Kirim notifikasi ke pelanggan
      if (customerId != null) {
        try {
          await client.from('notifikasi').insert({
            'user_id': customerId,
            'judul':
                'Mitra mengirim estimasi biaya perbaikan: ${_formatPrice(totalBiaya)}. Silakan periksa dan beri persetujuan.',
            'status_baca': 'belum',
          });
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _order['status_persetujuan_biaya'] = 'menunggu_persetujuan';
        _order['biaya_kunjungan'] = visitCost;
        _order['biaya_jasa'] = jasaCost;
        _order['biaya_sparepart'] = sparepartCost;
        _order['price'] = totalBiaya;
        if (rincian.isNotEmpty) {
          _order['catatan'] = existingCatatan;
        }
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF059669),
          content: Text('Estimasi biaya berhasil dikirim ke pelanggan!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('Gagal mengirim estimasi: $error'),
        ),
      );
    }
  }

  Widget _buildQuotationStatusCard() {
    final statusPersetujuan =
        _order['status_persetujuan_biaya'] as String? ?? 'menunggu_estimasi';
    final visitCost = _getVisitCost();
    final jasaCost = _getJasaCost();
    final sparepartCost = _getSparepartCost();
    final totalCost = visitCost + jasaCost + sparepartCost;

    if (statusPersetujuan == 'menunggu_persetujuan') {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: KetokColors.surfaceLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: KetokColors.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: KetokColors.darkPrimary,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Estimasi Terkirim - Menunggu Persetujuan',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: KetokColors.darkPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Menunggu konfirmasi pelanggan terhadap total estimasi biaya berikut:',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: KetokColors.borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Biaya Kunjungan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _formatPrice(visitCost),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jasa Perbaikan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _formatPrice(jasaCost),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sparepart/Komponen',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        _formatPrice(sparepartCost),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 14, color: Color(0xFFE2E8F0)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimasi',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: KetokColors.darkPrimary,
                        ),
                      ),
                      Text(
                        _formatPrice(totalCost),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: KetokColors.darkPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (statusPersetujuan == 'disetujui') {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFECFDF5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFA7F3D0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimasi Biaya Disetujui Pelanggan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pelanggan telah menyetujui total biaya ${_formatPrice(totalCost)}. Anda dapat menyelesaikan perbaikan unit.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (statusPersetujuan == 'ditolak') {
      return Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
        ),
        child: const Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.cancel_rounded, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estimasi Biaya Ditolak Pelanggan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: Color(0xFF991B1B),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pelanggan tidak menyetujui estimasi biaya sebelumnya. Anda dapat berdiskusi via Chat atau mengirim ulang estimasi baru.',
                    style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C)),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Default: menunggu_estimasi
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: KetokColors.surfaceLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: KetokColors.borderColor),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: KetokColors.darkPrimary,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tahap Pemeriksaan Unit',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: KetokColors.darkPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Cek kondisi di lokasi pelanggan, lalu gunakan tombol "Kirim Estimasi" di bawah untuk mengajukan rincian biaya pengerjaan.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
    final status = _order['status'] as String? ?? '';
    final title = _order['category_name'] as String? ?? 'Pesanan';
    final customer = _order['customer_name'] as String? ?? 'Pelanggan';
    final location = _order['lokasi'] as String? ?? 'Lokasi belum tersedia';
    final date = _formatDate(_order['jadwal']);
    final price = _formatPrice(_order['price']);
    final note = _order['catatan'] as String? ?? '';
    final statusPersetujuan =
        _order['status_persetujuan_biaya'] as String? ?? 'menunggu_estimasi';
    final isApproved = statusPersetujuan == 'disetujui';

    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: KetokColors.darkPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0D000000),
                      blurRadius: 10,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.receipt_long_rounded,
                            color: KetokColors.darkPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Pesanan #${_order['id_pesanan'] ?? '-'}',
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
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(status).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          color: _statusColor(status),
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _buildQuotationStatusCard(),
              _infoSection(
                title: 'Informasi Pelanggan & Biaya',
                items: [
                  _infoRow(Icons.person_outline_rounded, 'Pemesan', customer),
                  _infoRow(Icons.location_on_outlined, 'Lokasi', location),
                  _infoRow(Icons.calendar_month_rounded, 'Jadwal', date),
                  _infoRow(
                    Icons.payments_outlined,
                    isApproved ? 'Total Biaya' : 'Biaya Kunjungan',
                    price,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _infoSection(
                title: 'Catatan & Rincian',
                items: [
                  if (note.isNotEmpty)
                    _infoRow(Icons.notes_rounded, 'Catatan', note)
                  else
                    _infoRow(
                      Icons.notes_rounded,
                      'Catatan',
                      'Tidak ada catatan tambahan',
                    ),
                ],
              ),
              const SizedBox(height: 22),
              if (widget.onComplete != null && _isActive)
                Column(
                  children: [
                    if (!isApproved) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading ? null : _showFormEstimasiModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KetokColors.darkPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.request_quote_outlined),
                          label: Text(
                            statusPersetujuan == 'menunggu_persetujuan'
                                ? 'Ubah Estimasi Biaya'
                                : (statusPersetujuan == 'ditolak'
                                    ? 'Kirim Ulang Estimasi Biaya'
                                    : 'Kirim Estimasi & Minta Persetujuan'),
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loading
                              ? null
                              : () async {
                                  await widget.onComplete!();
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: KetokColors.darkPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline_rounded),
                          label: const Text(
                            'Selesaikan Pesanan',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: KetokColors.darkPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text(
                      'Tutup',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoSection({required String title, required List<Widget> items}) {
    return Container(
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: KetokColors.darkPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
