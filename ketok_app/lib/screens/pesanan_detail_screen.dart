import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/ketok_order_repository.dart';
import '../widgets/ketok_colors.dart';
import 'chat_screen.dart';
import 'estimasi_detail_screen.dart';
import 'quick_menu/cari_jasa_screen.dart';

class PesananDetailScreen extends StatefulWidget {
  final KetokOrder order;
  final VoidCallback? onRefresh;

  const PesananDetailScreen({
    super.key,
    required this.order,
    this.onRefresh,
  });

  @override
  State<PesananDetailScreen> createState() => _PesananDetailScreenState();
}

class _PesananDetailScreenState extends State<PesananDetailScreen> {
  late KetokOrder _order;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _refreshOrder();
  }

  Future<void> _refreshOrder() async {
    final orderId = _order.id;
    if (orderId == null) return;

    try {
      final client = Supabase.instance.client;
      final orderRow = await client
          .from('pesanan')
          .select()
          .eq('id_pesanan', orderId)
          .maybeSingle();

      if (orderRow == null) return;

      final invRow = await client
          .from('invoice')
          .select()
          .eq('pesanan_id', orderId)
          .maybeSingle();

      final ulasRow = await client
          .from('ulasan')
          .select('id_ulasan, pesanan_id, rating, komentar')
          .eq('pesanan_id', orderId)
          .maybeSingle();

      Map<int, String> mitraNames = {};
      Map<int, String?> mitraPhotos = {};
      final mId = orderRow['mitra_id'];
      if (mId is int) {
        final mRow = await client
            .from('users')
            .select('id_user,nama,foto_profil')
            .eq('id_user', mId)
            .maybeSingle();
        if (mRow != null) {
          mitraNames[mId] = mRow['nama'] as String? ?? 'Mitra Ketok';
          mitraPhotos[mId] = mRow['foto_profil'] as String?;
        }
      }

      final updated = KetokOrder.fromMap(
        orderRow,
        mitraNames,
        mitraPhotos: mitraPhotos,
        invoice: invRow,
        ulasan: ulasRow,
      );

      if (mounted) {
        setState(() {
          _order = updated;
        });
      }
    } catch (_) {}
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
    if (raw == null || raw.isEmpty) return '-';
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
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute ${isIndo ? 'WIB' : 'UTC+7'}';
  }

  Color get _statusColor {
    switch (_order.status) {
      case 'selesai':
        return KetokColors.success;
      case 'dibatalkan':
        return const Color(0xFFDC2626);
      case 'menuju_lokasi':
        return const Color(0xFF2563EB);
      case 'diproses':
      case 'dikerjakan':
        return const Color(0xFFD97706);
      default:
        return KetokColors.primary;
    }
  }

  IconData get _statusIcon {
    switch (_order.status) {
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'dibatalkan':
        return Icons.cancel_rounded;
      case 'menuju_lokasi':
        return Icons.near_me_rounded;
      case 'diproses':
      case 'dikerjakan':
        return Icons.handyman_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }

  void _openChat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          initialMitraName: _order.mitraName,
          initialMitraPhotoUrl: _order.mitraPhotoUrl,
          initialServiceName: _order.title,
        ),
      ),
    );
  }

  Future<void> _openEstimasiDetail() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EstimasiDetailScreen(
          order: _order,
          onRefresh: () {
            _refreshOrder();
            widget.onRefresh?.call();
          },
        ),
      ),
    );
    _refreshOrder();
  }

  void _showReviewModal({bool isEditing = false}) {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;
    int selectedRating = _order.rating ?? 5;
    final commentController = TextEditingController(
      text: _order.ulasanKomentar ?? '',
    );
    bool isSubmitting = false;

    final ratingLabels = isIndo
        ? [
            '',
            'Sangat Kurang Memuaskan',
            'Kurang Baik',
            'Cukup Baik',
            'Bagus & Rapi',
            'Sangat Puas & Rekomended!',
          ]
        : [
            '',
            'Very Unsatisfactory',
            'Poor',
            'Fair',
            'Good & Neat',
            'Highly Satisfied & Recommended!',
          ];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Color(0xFFD97706),
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditing
                              ? (isIndo ? 'Ubah Ulasan Layanan' : 'Edit Service Review')
                              : (isIndo ? 'Beri Rating & Ulasan' : 'Leave Rating & Review'),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _order.mitraName,
                          style: const TextStyle(
                            fontSize: 13,
                            color: KetokColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  isIndo ? 'Bagaimana kualitas layanan mitra ini?' : 'How was the service quality of this partner?',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF334155),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      onPressed: () {
                        setModalState(() {
                          selectedRating = starIndex;
                        });
                      },
                      iconSize: 42,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      icon: Icon(
                        starIndex <= selectedRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: starIndex <= selectedRating
                            ? Colors.amber
                            : const Color(0xFFCBD5E1),
                      ),
                    );
                  }),
                ),
              ),
              Center(
                child: Text(
                  ratingLabels[selectedRating],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFD97706),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                isIndo ? 'Ulasan Anda (Opsional)' : 'Your Review (Optional)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: isIndo
                      ? 'Tuliskan pengalaman Anda mengenai ketepatan waktu, kerapian, dan kualitas kerja mitra...'
                      : 'Share your experience regarding punctuality, neatness, and quality of work...',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: const Color(0xFFF8F9FB),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: KetokColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (selectedRating < 1) return;
                          setModalState(() => isSubmitting = true);

                          try {
                            final client = Supabase.instance.client;
                            final orderId = _order.id;
                            if (orderId == null) {
                              throw Exception(isIndo ? 'ID pesanan tidak valid.' : 'Invalid order ID.');
                            }

                            final comment = commentController.text.trim();

                            if (_order.hasReviewed && _order.idUlasan != null) {
                              await client.from('ulasan').update({
                                'rating': selectedRating,
                                'komentar': comment,
                              }).eq('id_ulasan', _order.idUlasan!);
                            } else {
                              await client.from('ulasan').insert({
                                'pesanan_id': orderId,
                                'rating': selectedRating,
                                'komentar': comment,
                              });
                            }

                            if (!modalContext.mounted) return;
                            Navigator.pop(modalContext);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: const Color(0xFF15803D),
                                  content: Text(
                                    isIndo
                                        ? 'Terima kasih! Ulasan Anda berhasil disimpan.'
                                        : 'Thank you! Your review has been saved.',
                                  ),
                                ),
                              );
                              _refreshOrder();
                              widget.onRefresh?.call();
                            }
                          } catch (e) {
                            setModalState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text(
                                    isIndo ? 'Gagal mengirim ulasan: $e' : 'Failed to submit review: $e',
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: KetokColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isEditing
                              ? (isIndo ? 'Perbarui Ulasan' : 'Update Review')
                              : (isIndo ? 'Kirim Ulasan' : 'Submit Review'),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTrackingTimelineModal() {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;
    final status = _order.status;
    final approval = _order.approvalStatus;

    int currentStep = 1;
    if (status == 'selesai') {
      currentStep = 5;
    } else if (status == 'dikerjakan') {
      currentStep = 4;
    } else if (approval == 'menunggu_persetujuan' || approval == 'disetujui') {
      currentStep = 3;
    } else if (status == 'menuju_lokasi' || status == 'diproses') {
      currentStep = 2;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.timeline_rounded, color: Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isIndo ? 'Status Pengerjaan' : 'Work Progress Status',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${isIndo ? 'Nomor Pesanan' : 'Order Number'}: ${_order.invoice}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KetokColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildTimelineStep(
              stepNumber: 1,
              title: isIndo ? 'Pesanan Dikonfirmasi' : 'Order Confirmed',
              description: isIndo
                  ? 'Pesanan telah dibuat dan masuk ke sistem mitra.'
                  : 'Order has been created and received by the partner.',
              isCompleted: currentStep > 1,
              isActive: currentStep == 1,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 2,
              title: isIndo ? 'Mitra Menuju Lokasi' : 'Partner En Route',
              description: currentStep >= 2
                  ? (isIndo
                      ? 'Mitra teknisi sedang bersiap atau dalam perjalanan ke alamat Anda.'
                      : 'The technician is preparing or on the way to your address.')
                  : (isIndo
                      ? 'Mitra akan segera berangkat ke lokasi pengerjaan.'
                      : 'Partner will depart to the work location shortly.'),
              isCompleted: currentStep > 2,
              isActive: currentStep == 2,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 3,
              title: isIndo ? 'Pemeriksaan & Estimasi Biaya' : 'Inspection & Cost Estimate',
              description: approval == 'menunggu_persetujuan'
                  ? (isIndo
                      ? 'Teknisi telah mengajukan rincian estimasi biaya untuk disetujui.'
                      : 'The technician has submitted a cost estimate for approval.')
                  : (isIndo
                      ? 'Pemeriksaan kendala di tempat & kalkulasi biaya suku cadang/jasa.'
                      : 'On-site issue inspection & calculation of parts/labor costs.'),
              isCompleted: currentStep > 3,
              isActive: currentStep == 3,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 4,
              title: isIndo ? 'Pengerjaan Servis' : 'Service Work',
              description: isIndo
                  ? 'Teknisi melakukan perbaikan dan pengujian perangkat.'
                  : 'The technician is carrying out repairs and equipment testing.',
              isCompleted: currentStep > 4,
              isActive: currentStep == 4,
              isLast: false,
            ),
            _buildTimelineStep(
              stepNumber: 5,
              title: isIndo ? 'Pesanan Selesai' : 'Order Completed',
              description: isIndo
                  ? 'Pengerjaan tuntas dan pelanggan dapat memberikan penilaian.'
                  : 'Work completed and customer can leave a review.',
              isCompleted: currentStep == 5,
              isActive: false,
              isLast: true,
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(modalContext),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF171717),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isIndo ? 'Tutup' : 'Close', style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required int stepNumber,
    required String title,
    required String description,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final color = isCompleted
        ? const Color(0xFF16A34A)
        : isActive
            ? const Color(0xFF2563EB)
            : const Color(0xFF94A3B8);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? const Color(0xFF16A34A)
                    : isActive
                        ? const Color(0xFF2563EB)
                        : Colors.white,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : Text(
                        '$stepNumber',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isActive ? Colors.white : const Color(0xFF94A3B8),
                        ),
                      ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isCompleted ? const Color(0xFF16A34A) : const Color(0xFFE2E8F0),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isCompleted || isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActionButton() {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;

    if (_order.status == 'selesai') {
      return FilledButton.icon(
        onPressed: () => _showReviewModal(
          isEditing: _order.hasReviewed,
        ),
        icon: Icon(
          _order.hasReviewed ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: 20,
        ),
        label: Text(
          _order.hasReviewed
              ? '${isIndo ? "Ulasan" : "Review"} (★ ${_order.rating})'
              : (isIndo ? 'Beri Rating & Ulasan' : 'Leave Rating & Review'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF171717),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (_order.status == 'dibatalkan') {
      return FilledButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CariJasaScreen()),
          );
        },
        icon: const Icon(Icons.search_rounded, size: 20),
        label: Text(
          isIndo ? 'Pesan Jasa Baru' : 'Book New Service',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF171717),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (_order.approvalStatus == 'menunggu_persetujuan') {
      return FilledButton.icon(
        onPressed: _openEstimasiDetail,
        icon: const Icon(Icons.request_quote_rounded, size: 20),
        label: Text(
          isIndo ? 'Tinjau Estimasi Biaya' : 'Review Cost Estimate',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFFD97706),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (_order.approvalStatus == 'disetujui') {
      return FilledButton.icon(
        onPressed: _openEstimasiDetail,
        icon: const Icon(Icons.assignment_turned_in_rounded, size: 20),
        label: Text(
          isIndo ? 'Estimasi Disetujui' : 'Estimate Approved',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF15803D),
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    // Default untuk status aktif (diproses, menuju_lokasi, dikerjakan, dll)
    return FilledButton.icon(
      onPressed: _showTrackingTimelineModal,
      icon: const Icon(Icons.timeline_rounded, size: 20),
      label: Text(
        isIndo ? 'Status Pengerjaan' : 'Work Progress',
        style: const TextStyle(
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF171717),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;

    return Scaffold(
      backgroundColor: KetokColors.background,
      appBar: AppBar(
        title: Text(isIndo ? 'Detail Pesanan' : 'Order Details'),
        backgroundColor: KetokColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: isIndo ? 'Kembali' : 'Back',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              setState(() => _loading = true);
              await _refreshOrder();
              setState(() => _loading = false);
            },
            icon: const Icon(Icons.refresh_rounded),
            tooltip: isIndo ? 'Segarkan' : 'Refresh',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      // 1. Status Banner
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: _statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(_statusIcon, color: _statusColor, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _order.localizedStatusLabel(isIndo),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: _statusColor,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _order.invoice,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: KetokColors.textMuted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Info Mitra Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIndo ? 'Mitra Penyedia Jasa' : 'Service Provider Partner',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: KetokColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Divider(height: 18),
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: KetokColors.surfaceLow,
                                  backgroundImage: _order.mitraPhotoUrl != null &&
                                          _order.mitraPhotoUrl!.isNotEmpty
                                      ? NetworkImage(_order.mitraPhotoUrl!)
                                      : null,
                                  child: _order.mitraPhotoUrl == null ||
                                          _order.mitraPhotoUrl!.isEmpty
                                      ? const Icon(Icons.person_rounded,
                                          size: 26, color: Color(0xFF64748B))
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _order.mitraName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF030813),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          const Icon(Icons.verified_rounded,
                                              size: 14, color: Color(0xFF16A34A)),
                                          const SizedBox(width: 4),
                                          Text(
                                            isIndo ? 'Mitra Terverifikasi Ketok' : 'Ketok Verified Partner',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF16A34A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_user_rounded,
                                          size: 14, color: Color(0xFF0F172A)),
                                      const SizedBox(width: 4),
                                      Text(
                                        isIndo ? 'Mitra Resmi' : 'Official Partner',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Layanan & Lokasi Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isIndo ? 'Informasi Pengerjaan' : 'Service Information',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: KetokColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Divider(height: 18),
                            _buildInfoRow(
                              Icons.handyman_outlined,
                              isIndo ? 'Jenis Layanan' : 'Service Type',
                              _order.title,
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.calendar_today_outlined,
                              isIndo ? 'Waktu Jadwal' : 'Scheduled Time',
                              _formatDate(_order.jadwal, isIndo: isIndo),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              isIndo ? 'Lokasi Pengerjaan' : 'Service Location',
                              _order.location,
                            ),
                            if (_order.catatan != null &&
                                _order.catatan!.trim().isNotEmpty) ...[
                              const SizedBox(height: 12),
                              _buildInfoRow(
                                Icons.notes_rounded,
                                isIndo ? 'Catatan Tambahan' : 'Additional Notes',
                                _order.catatan!,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Rincian Biaya
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  isIndo ? 'Rincian Pembayaran' : 'Payment Breakdown',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: KetokColors.textMuted,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _order.approvalStatus == 'disetujui'
                                        ? const Color(0xFFDCFCE7)
                                        : _order.approvalStatus == 'menunggu_persetujuan'
                                            ? const Color(0xFFFEF3C7)
                                            : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _order.approvalStatus == 'disetujui'
                                        ? (isIndo ? 'Biaya Disetujui' : 'Cost Approved')
                                        : _order.approvalStatus == 'menunggu_persetujuan'
                                            ? (isIndo ? 'Menunggu Persetujuan' : 'Pending Approval')
                                            : (isIndo ? 'Biaya Kunjungan Awal' : 'Initial Call-out Fee'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _order.approvalStatus == 'disetujui'
                                          ? const Color(0xFF15803D)
                                          : _order.approvalStatus == 'menunggu_persetujuan'
                                              ? const Color(0xFFB45309)
                                              : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            _buildPriceLine(isIndo ? 'Biaya Kunjungan & Cek' : 'Call-out & Inspection Fee', _formatPrice(_order.biayaKunjungan)),
                            if (_order.biayaJasa > 0) ...[
                              const SizedBox(height: 8),
                              _buildPriceLine(isIndo ? 'Biaya Pengerjaan / Jasa' : 'Service / Labor Fee', _formatPrice(_order.biayaJasa)),
                            ],
                            if (_order.biayaSparepart > 0) ...[
                              const SizedBox(height: 8),
                              _buildPriceLine(isIndo ? 'Biaya Suku Cadang' : 'Spare Parts Cost', _formatPrice(_order.biayaSparepart)),
                            ],
                            const Divider(height: 20),
                            Row(
                              children: [
                                Text(
                                  isIndo ? 'Total Biaya' : 'Total Cost',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF030813),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _order.price,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFF030813),
                                  ),
                                ),
                              ],
                            ),
                            if (_order.approvalStatus == 'menunggu_persetujuan') ...[
                              const SizedBox(height: 14),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton.icon(
                                  onPressed: _openEstimasiDetail,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFD97706),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  icon: const Icon(Icons.request_quote_rounded, size: 18),
                                  label: Text(
                                    isIndo ? 'Tinjau Rincian Estimasi Biaya' : 'Review Cost Estimate Details',
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Bagian Rating & Ulasan (Khusus Selesai)
                      if (_order.status == 'selesai') ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _order.hasReviewed
                                  ? const Color(0xFFFDE68A)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.rate_review_rounded,
                                    size: 18,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isIndo ? 'Ulasan & Penilaian Anda' : 'Your Rating & Review',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const Spacer(),
                                  if (_order.hasReviewed)
                                    TextButton(
                                      onPressed: () => _showReviewModal(isEditing: true),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: Text(
                                        isIndo ? 'Ubah' : 'Edit',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Divider(height: 18),
                              if (_order.hasReviewed) ...[
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (i) {
                                        return Icon(
                                          i < (_order.rating ?? 0)
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          size: 22,
                                          color: Colors.amber,
                                        );
                                      }),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_order.rating}/5',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF030813),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_order.ulasanKomentar != null &&
                                    _order.ulasanKomentar!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    '"${_order.ulasanKomentar!}"',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: Color(0xFF334155),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ] else ...[
                                Text(
                                  isIndo
                                      ? 'Pesanan telah selesai! Berikan rating dan ulasan Anda untuk membantu mitra meningkatkan kualitas pelayanannya.'
                                      : 'Order completed! Leave your rating and review to help the partner improve service quality.',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: KetokColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showReviewModal(isEditing: false),
                                    icon: const Icon(Icons.star_outline_rounded, color: Colors.amber),
                                    label: Text(
                                      isIndo ? 'Beri Rating & Ulasan Sekarang' : 'Leave Rating & Review Now',
                                      style: const TextStyle(
                                        color: Color(0xFF030813),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // 6. Bottom Sticky Action Bar (1/4 Chat + 3/4 Action Button)
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: const Border(
                      top: BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Tombol 1/4 (flex: 1) untuk Chat Mitra
                      Expanded(
                        flex: 1,
                        child: OutlinedButton.icon(
                          onPressed: _openChat,
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: Text(l10n.navChat),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF171717),
                            side: const BorderSide(color: Color(0xFF171717)),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Tombol 3/4 (flex: 3) untuk Aksi Utama Kontekstual
                      Expanded(
                        flex: 3,
                        child: _buildMainActionButton(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: KetokColors.textMuted),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceLine(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}
