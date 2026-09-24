import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../widgets/ketok_app_bar.dart';
import '../widgets/ketok_colors.dart';
import 'pesanan_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  bool _loading = true;
  String? _errorMessage;
  List<_AppNotification> _notifications = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    final isIndo = mounted ? context.l10n.isIndonesian : true;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception(isIndo ? 'Sesi login tidak ditemukan.' : 'Login session not found.');
      final profile = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      final userId = profile?['id_user'];
      if (userId is! int) throw Exception(isIndo ? 'Profil pengguna belum tersedia.' : 'User profile not available.');

      final notifications = <_AppNotification>[];

      // 1. Ambil notifikasi dari tabel 'notifikasi'
      bool hasUnread = false;
      try {
        List<dynamic> notifRows;
        try {
          notifRows = await client
              .from('notifikasi')
              .select('id_notif, judul, status_baca, dibuat_pada')
              .eq('user_id', userId)
              .order('id_notif', ascending: false)
              .limit(30);
        } catch (_) {
          notifRows = await client
              .from('notifikasi')
              .select('id_notif, judul, status_baca')
              .eq('user_id', userId)
              .order('id_notif', ascending: false)
              .limit(30);
        }

        for (final row in notifRows) {
          final isUnread = row['status_baca'] == 'belum';
          if (isUnread) hasUnread = true;

          final rawText = (row['judul'] as String? ?? '').trim();
          final parsed = _parseNotification(rawText, isIndo: isIndo);

          notifications.add(
            _AppNotification(
              id: row['id_notif'] as int?,
              icon: parsed.icon,
              color: parsed.color,
              title: parsed.title,
              message: rawText,
              time: row['dibuat_pada'] != null ? _formatDate(row['dibuat_pada'], isIndo: isIndo) : null,
              unread: isUnread,
              actionType: parsed.actionType,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error loading notifikasi table: $e');
      }

      globalHasUnreadNotification.value = hasUnread;

      // 2. Cek pesanan aktif pelanggan
      try {
        final orders = await client
            .from('pesanan')
            .select('id_pesanan, status, jadwal')
            .eq('pengguna_id', userId)
            .order('jadwal', ascending: false)
            .limit(10);

        for (final order in orders) {
          final status = order['status'] as String? ?? '';
          final id = order['id_pesanan'];
          final item = _notificationForOrder(id, status, order['jadwal'], isIndo: isIndo);
          if (item != null) notifications.add(item);
        }
      } catch (e) {
        debugPrint('Error loading active orders: $e');
      }

      if (notifications.isEmpty) {
        notifications.add(
          _AppNotification(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF15803D),
            title: isIndo ? 'Semua Sudah Diperiksa' : 'All Caught Up',
            message: isIndo ? 'Belum ada notifikasi baru untuk Anda.' : 'No new notifications for you yet.',
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _notifications = notifications;
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

  _NotificationStyle _parseNotification(String raw, {bool isIndo = true}) {
    final lower = raw.toLowerCase();

    if (lower.contains('promo') || lower.contains('voucher') || lower.contains('diskon')) {
      return _NotificationStyle(
        icon: Icons.local_offer_rounded,
        color: const Color(0xFF7C3AED),
        title: isIndo ? 'Promo Spesial' : 'Special Promo',
      );
    }
    if (lower.contains('bayar') || lower.contains('pembayaran') || lower.contains('invoice')) {
      return _NotificationStyle(
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF0D9488),
        title: isIndo ? 'Info Pembayaran' : 'Payment Info',
        actionType: 'pesanan',
      );
    }
    if (lower.contains('selesai') || lower.contains('berhasil')) {
      return _NotificationStyle(
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF16A34A),
        title: isIndo ? 'Pesanan Selesai' : 'Order Completed',
        actionType: 'pesanan',
      );
    }
    if (lower.contains('batal') || lower.contains('dibatalkan') || lower.contains('tolak')) {
      return _NotificationStyle(
        icon: Icons.cancel_rounded,
        color: const Color(0xFFDC2626),
        title: isIndo ? 'Info Pembatalan' : 'Cancellation Info',
        actionType: 'pesanan',
      );
    }
    if (lower.contains('menuju lokasi') || lower.contains('perjalanan')) {
      return _NotificationStyle(
        icon: Icons.near_me_rounded,
        color: const Color(0xFF2563EB),
        title: isIndo ? 'Mitra Menuju Lokasi' : 'Partner En Route',
        actionType: 'pesanan',
      );
    }
    if (lower.contains('pesanan') || lower.contains('teknisi') || lower.contains('mitra')) {
      return _NotificationStyle(
        icon: Icons.handyman_rounded,
        color: KetokColors.primary,
        title: isIndo ? 'Info Pesanan' : 'Order Info',
        actionType: 'pesanan',
      );
    }
    return _NotificationStyle(
      icon: Icons.campaign_rounded,
      color: const Color(0xFF0284C7),
      title: isIndo ? 'Pemberitahuan' : 'Notification',
    );
  }

  _AppNotification? _notificationForOrder(dynamic id, String status, dynamic dateVal, {bool isIndo = true}) {
    final timeStr = dateVal != null ? _formatDate(dateVal, isIndo: isIndo) : null;
    switch (status) {
      case 'mencari_mitra':
        return _AppNotification(
          icon: Icons.search_rounded,
          color: const Color(0xFFB45309),
          title: isIndo ? 'Sedang Mencari Mitra' : 'Finding Partner',
          message: isIndo
              ? 'Pesanan #$id sedang dicarikan mitra teknisi terbaik.'
              : 'Order #$id is looking for the best technician partner.',
          time: timeStr,
          unread: false,
          actionType: 'pesanan',
        );
      case 'menuju_lokasi':
        return _AppNotification(
          icon: Icons.near_me_rounded,
          color: const Color(0xFF2563EB),
          title: isIndo ? 'Mitra Menuju Lokasi' : 'Partner En Route',
          message: isIndo
              ? 'Mitra untuk pesanan #$id sedang dalam perjalanan.'
              : 'Partner for order #$id is on the way.',
          time: timeStr,
          unread: false,
          actionType: 'pesanan',
        );
      case 'diproses':
      case 'dikerjakan':
        return _AppNotification(
          icon: Icons.handyman_rounded,
          color: KetokColors.primary,
          title: isIndo ? 'Pesanan Sedang Dikerjakan' : 'Order in Progress',
          message: isIndo
              ? 'Mitra sedang mengerjakan pesanan #$id.'
              : 'Partner is working on order #$id.',
          time: timeStr,
          unread: false,
          actionType: 'pesanan',
        );
      case 'selesai':
        return _AppNotification(
          icon: Icons.star_rounded,
          color: const Color(0xFF16A34A),
          title: isIndo ? 'Pesanan Selesai' : 'Order Completed',
          message: isIndo
              ? 'Pesanan #$id telah selesai. Berikan ulasan Anda.'
              : 'Order #$id has been completed. Leave your review.',
          time: timeStr,
          unread: false,
          actionType: 'pesanan',
        );
      case 'dibatalkan':
        return _AppNotification(
          icon: Icons.cancel_rounded,
          color: const Color(0xFFDC2626),
          title: isIndo ? 'Pesanan Dibatalkan' : 'Order Cancelled',
          message: isIndo
              ? 'Pesanan #$id telah dibatalkan.'
              : 'Order #$id has been cancelled.',
          time: timeStr,
          unread: false,
          actionType: 'pesanan',
        );
      default:
        return null;
    }
  }

  String _formatDate(dynamic dateVal, {bool isIndo = true}) {
    if (dateVal == null) return '';
    DateTime? dt;
    if (dateVal is DateTime) {
      dt = dateVal.toLocal();
    } else if (dateVal is String) {
      dt = DateTime.tryParse(dateVal)?.toLocal();
    }
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return isIndo ? 'Baru saja' : 'Just now';
    if (diff.inMinutes < 60) return isIndo ? '${diff.inMinutes} mnt lalu' : '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return isIndo ? '${diff.inHours} jam lalu' : '${diff.inHours}h ago';
    if (diff.inDays < 7) return isIndo ? '${diff.inDays} hr lalu' : '${diff.inDays}d ago';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
  }

  Future<void> _handleNotificationTap(_AppNotification notification, int index) async {
    if (notification.id != null && notification.unread) {
      try {
        final client = Supabase.instance.client;
        await client
            .from('notifikasi')
            .update({'status_baca': 'sudah'})
            .eq('id_notif', notification.id!);

        setState(() {
          _notifications[index] = notification.copyWith(unread: false);
        });
        final hasRemaining = _notifications.any((n) => n.unread);
        globalHasUnreadNotification.value = hasRemaining;
      } catch (e) {
        debugPrint('Error marking notification as read: $e');
      }
    }

    if (notification.actionType == 'pesanan' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const PesananScreen()),
      );
      if (mounted) {
        _loadNotifications();
      }
    }
  }

  Future<void> _markAllAsRead() async {
    final isIndo = mounted ? context.l10n.isIndonesian : true;
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        final profile = await client
            .from('users')
            .select('id_user')
            .eq('auth_uid', authUser.id)
            .maybeSingle();

        final userId = profile?['id_user'];
        if (userId is int) {
          await client
              .from('notifikasi')
              .update({'status_baca': 'sudah'})
              .eq('user_id', userId)
              .eq('status_baca', 'belum');
        }
      }

      globalHasUnreadNotification.value = false;
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isIndo ? 'Semua notifikasi ditandai sudah dibaca.' : 'All notifications marked as read.'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isIndo ? 'Gagal memperbarui notifikasi: $e' : 'Failed to update notifications: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;

    return Scaffold(
      backgroundColor: KetokColors.background,
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
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
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
            tooltip: isIndo ? 'Tandai semua sudah dibaca' : 'Mark all as read',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off_outlined, size: 46, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: _loadNotifications,
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(isIndo ? 'Coba Lagi' : 'Try Again'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, index) {
                  final notification = _notifications[index];
                  final isActionable = notification.actionType != null;

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _handleNotificationTap(notification, index),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: notification.unread
                                ? notification.color.withValues(alpha: 0.5)
                                : KetokColors.border,
                          ),
                          boxShadow: notification.unread
                              ? [
                                  BoxShadow(
                                    color: notification.color.withValues(alpha: 0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: notification.color.withValues(alpha: 0.12),
                              child: Icon(
                                notification.icon,
                                color: notification.color,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          notification.title,
                                          style: TextStyle(
                                            fontWeight: notification.unread
                                                ? FontWeight.w800
                                                : FontWeight.w600,
                                            color: const Color(0xFF030813),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      if (notification.time != null &&
                                          notification.time!.isNotEmpty) ...[
                                        Text(
                                          notification.time!,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                      ],
                                      if (notification.unread)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: BoxDecoration(
                                            color: notification.color,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    notification.message,
                                    style: TextStyle(
                                      color: notification.unread
                                          ? const Color(0xFF1F2937)
                                          : KetokColors.textMuted,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (isActionable) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          isIndo ? 'Lihat Detail →' : 'View Details →',
                                          style: TextStyle(
                                            color: notification.color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final String title;
  final String? actionType;

  const _NotificationStyle({
    required this.icon,
    required this.color,
    required this.title,
    this.actionType,
  });
}

class _AppNotification {
  final int? id;
  final IconData icon;
  final Color color;
  final String title;
  final String message;
  final String? time;
  final bool unread;
  final String? actionType;

  const _AppNotification({
    this.id,
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
    this.time,
    this.unread = false,
    this.actionType,
  });

  _AppNotification copyWith({
    int? id,
    IconData? icon,
    Color? color,
    String? title,
    String? message,
    String? time,
    bool? unread,
    String? actionType,
  }) {
    return _AppNotification(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      unread: unread ?? this.unread,
      actionType: actionType ?? this.actionType,
    );
  }
}
