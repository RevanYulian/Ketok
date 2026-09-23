import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';
import 'verifikasi_ktp_screen.dart';

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
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception('Sesi login tidak ditemukan.');
      final user = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      if (user == null) throw Exception('Data mitra tidak ditemukan.');

      final userId = user['id_user'] as int;
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
          final parsed = _parseNotification(rawText);

          notifications.add(
            _AppNotification(
              id: row['id_notif'] as int?,
              icon: parsed.icon,
              color: parsed.color,
              title: parsed.title,
              message: rawText,
              time: row['dibuat_pada'] != null ? _formatDate(row['dibuat_pada']) : null,
              unread: isUnread,
              actionType: parsed.actionType,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error loading notifikasi table: $e');
      }

      globalHasUnreadNotification.value = hasUnread;

      // 2. Cek status profil mitra & verifikasi KTP
      final profile = await client
          .from('mitra_profil')
          .select('nama_usaha, katagori_id, sub_kategori, status_verifikasi, catatan_verifikasi')
          .eq('user_id', userId)
          .maybeSingle();

      final profileComplete =
          (profile?['nama_usaha'] as String?)?.trim().isNotEmpty == true &&
          profile?['katagori_id'] != null &&
          (profile?['sub_kategori'] as String?)?.trim().isNotEmpty == true;

      final verifStatus = profile?['status_verifikasi'] as String?;
      final verifNote = (profile?['catatan_verifikasi'] as String?)?.trim();

      if (!profileComplete) {
        notifications.add(
          const _AppNotification(
            icon: Icons.assignment_ind_outlined,
            color: Color(0xFFC2410C),
            title: 'Profil Belum Lengkap',
            message: 'Lengkapi profil agar akun Anda dapat menerima pekerjaan.',
          ),
        );
      } else if (verifStatus == 'ditolak') {
        notifications.add(
          _AppNotification(
            icon: Icons.cancel_rounded,
            color: const Color(0xFFDC2626),
            title: 'Verifikasi KTP Ditolak',
            message: verifNote != null && verifNote.isNotEmpty
                ? 'Catatan admin: $verifNote. Silakan unggah ulang foto KTP yang valid.'
                : 'Dokumen KTP Anda ditolak oleh admin. Silakan periksa dan unggah ulang.',
            actionType: 'verifikasi_ktp',
          ),
        );
      } else if (verifStatus == 'menunggu') {
        notifications.add(
          const _AppNotification(
            icon: Icons.hourglass_top_rounded,
            color: Color(0xFFB45309),
            title: 'Menunggu Persetujuan Admin',
            message: 'Dokumen KTP & profil Anda sedang dalam antrean verifikasi oleh tim admin.',
            actionType: 'verifikasi_ktp',
          ),
        );
      }

      // 3. Cek pesanan berjalan
      final orders = await client
          .from('pesanan')
          .select('id_pesanan, status, jadwal')
          .eq('mitra_id', userId)
          .order('jadwal', ascending: false)
          .limit(10);

      for (final order in orders) {
        final status = order['status'] as String?;
        if (status == 'menuju_lokasi' || status == 'diproses') {
          notifications.add(
            _AppNotification(
              icon: Icons.assignment_outlined,
              color: KetokColors.darkPrimary,
              title: 'Pesanan Sedang Berjalan',
              message: 'Pesanan #${order['id_pesanan']} perlu segera ditindaklanjuti.',
            ),
          );
        }
      }

      if (notifications.isEmpty) {
        notifications.add(
          const _AppNotification(
            icon: Icons.check_circle_outline_rounded,
            color: Color(0xFF15803D),
            title: 'Semua Sudah Diperiksa',
            message: 'Belum ada notifikasi baru untuk Anda.',
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

  _NotificationStyle _parseNotification(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('verifikasi') && (lower.contains('tolak') || lower.contains('ditolak'))) {
      return const _NotificationStyle(
        icon: Icons.cancel_rounded,
        color: Color(0xFFDC2626),
        title: 'Verifikasi KTP Ditolak',
        actionType: 'verifikasi_ktp',
      );
    }
    if (lower.contains('verifikasi') && (lower.contains('setuju') || lower.contains('disetujui') || lower.contains('terverifikasi'))) {
      return const _NotificationStyle(
        icon: Icons.verified_rounded,
        color: Color(0xFF16A34A),
        title: 'Verifikasi KTP Disetujui',
      );
    }
    if (lower.contains('kemitraan') && (lower.contains('tolak') || lower.contains('ditolak'))) {
      return const _NotificationStyle(
        icon: Icons.error_rounded,
        color: Color(0xFFDC2626),
        title: 'Pengajuan Kemitraan Ditolak',
      );
    }
    if (lower.contains('kemitraan') && (lower.contains('setuju') || lower.contains('disetujui'))) {
      return const _NotificationStyle(
        icon: Icons.check_circle_rounded,
        color: Color(0xFF16A34A),
        title: 'Pengajuan Kemitraan Disetujui',
      );
    }
    if (lower.contains('suspend')) {
      return const _NotificationStyle(
        icon: Icons.block_rounded,
        color: Color(0xFFEA580C),
        title: 'Akun Disuspend',
      );
    }
    if (lower.contains('blokir') || lower.contains('diblokir')) {
      return const _NotificationStyle(
        icon: Icons.gavel_rounded,
        color: Color(0xFFDC2626),
        title: 'Akun Diblokir',
      );
    }
    if (lower.contains('diaktifkan') || (lower.contains('status akun') && lower.contains('aktif'))) {
      return const _NotificationStyle(
        icon: Icons.check_circle_rounded,
        color: Color(0xFF16A34A),
        title: 'Akun Diaktifkan',
      );
    }
    if (lower.contains('pesanan')) {
      return const _NotificationStyle(
        icon: Icons.handyman_rounded,
        color: KetokColors.darkPrimary,
        title: 'Info Pesanan',
      );
    }
    return const _NotificationStyle(
      icon: Icons.campaign_rounded,
      color: Color(0xFF0284C7),
      title: 'Pengumuman Admin',
    );
  }

  String _formatDate(dynamic dateVal) {
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
    if (diff.inSeconds < 60) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hr lalu';
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

    if (notification.actionType == 'verifikasi_ktp' && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const VerifikasiKtpScreen()),
      );
      if (mounted) {
        _loadNotifications();
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser != null) {
        final user = await client
            .from('users')
            .select('id_user')
            .eq('auth_uid', authUser.id)
            .maybeSingle();

        if (user != null) {
          await client
              .from('notifikasi')
              .update({'status_baca': 'sudah'})
              .eq('user_id', user['id_user'])
              .eq('status_baca', 'belum');
        }
      }

      globalHasUnreadNotification.value = false;
      await _loadNotifications();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua notifikasi ditandai sudah dibaca.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui notifikasi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        title: const Text('Notifikasi'),
        backgroundColor: KetokColors.bgColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'Tandai semua sudah dibaca',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!))
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              child: ListView.separated(
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
                                ? notification.color.withOpacity(0.5)
                                : KetokColors.borderColor,
                          ),
                          boxShadow: notification.unread
                              ? [
                                  BoxShadow(
                                    color: notification.color.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                              : null,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              backgroundColor: notification.color.withOpacity(0.12),
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
                                      if (notification.time != null && notification.time!.isNotEmpty) ...[
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
                                          : KetokColors.onSurfaceVariant,
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                  if (isActionable) ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          notification.actionType == 'verifikasi_ktp'
                                              ? 'Buka Formulir KTP →'
                                              : 'Lihat Detail →',
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
