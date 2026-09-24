import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
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

          DateTime? dt;
          final createdVal = row['dibuat_pada'];
          if (createdVal is DateTime) {
            dt = createdVal.toLocal();
          } else if (createdVal is String) {
            dt = DateTime.tryParse(createdVal)?.toLocal();
          }

          notifications.add(
            _AppNotification(
              id: row['id_notif'] as int?,
              icon: parsed.icon,
              color: parsed.color,
              getTitle: parsed.getTitle,
              getMessage: parsed.getMessage,
              createdAt: dt,
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
          _AppNotification(
            icon: Icons.assignment_ind_outlined,
            color: const Color(0xFFC2410C),
            getTitle: (isIndo) => isIndo ? 'Profil Belum Lengkap' : 'Profile Incomplete',
            getMessage: (isIndo) => isIndo
                ? 'Lengkapi profil agar akun Anda dapat menerima pekerjaan.'
                : 'Complete your profile so your account can receive jobs.',
          ),
        );
      } else if (verifStatus == 'ditolak') {
        notifications.add(
          _AppNotification(
            icon: Icons.cancel_rounded,
            color: const Color(0xFFDC2626),
            getTitle: (isIndo) => isIndo ? 'Verifikasi KTP Ditolak' : 'ID Card Verification Rejected',
            getMessage: (isIndo) => verifNote != null && verifNote.isNotEmpty
                ? (isIndo
                    ? 'Catatan admin: $verifNote. Silakan unggah ulang foto KTP yang valid.'
                    : 'Admin note: $verifNote. Please re-upload a valid ID card.')
                : (isIndo
                    ? 'Dokumen KTP Anda ditolak oleh admin. Silakan periksa dan unggah ulang.'
                    : 'Your ID card was rejected by admin. Please review and re-upload.'),
            actionType: 'verifikasi_ktp',
          ),
        );
      } else if (verifStatus == 'menunggu') {
        notifications.add(
          _AppNotification(
            icon: Icons.hourglass_top_rounded,
            color: const Color(0xFFB45309),
            getTitle: (isIndo) => isIndo ? 'Menunggu Persetujuan Admin' : 'Awaiting Admin Approval',
            getMessage: (isIndo) => isIndo
                ? 'Dokumen KTP & profil Anda sedang dalam antrean verifikasi oleh tim admin.'
                : 'Your ID card & profile are currently queued for verification by the admin team.',
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
          final orderId = order['id_pesanan'];
          notifications.add(
            _AppNotification(
              icon: Icons.assignment_outlined,
              color: KetokColors.darkPrimary,
              getTitle: (isIndo) => isIndo ? 'Pesanan Sedang Berjalan' : 'Order In Progress',
              getMessage: (isIndo) => isIndo
                  ? 'Pesanan #$orderId perlu segera ditindaklanjuti.'
                  : 'Order #$orderId requires your immediate action.',
            ),
          );
        }
      }

      if (notifications.isEmpty) {
        notifications.add(
          _AppNotification(
            icon: Icons.check_circle_outline_rounded,
            color: const Color(0xFF15803D),
            getTitle: (isIndo) => isIndo ? 'Semua Sudah Diperiksa' : 'All Caught Up',
            getMessage: (isIndo) => isIndo
                ? 'Belum ada notifikasi baru untuk Anda.'
                : 'There are no new notifications for you right now.',
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

  _NotificationParsed _parseNotification(String raw) {
    final lower = raw.toLowerCase();

    if (lower.contains('verifikasi') && (lower.contains('tolak') || lower.contains('ditolak'))) {
      return _NotificationParsed(
        icon: Icons.cancel_rounded,
        color: const Color(0xFFDC2626),
        getTitle: (isIndo) => isIndo ? 'Verifikasi KTP Ditolak' : 'ID Card Verification Rejected',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your ID card verification was rejected. Please review and re-upload.',
        actionType: 'verifikasi_ktp',
      );
    }
    if (lower.contains('verifikasi') &&
        (lower.contains('setuju') || lower.contains('disetujui') || lower.contains('terverifikasi'))) {
      return _NotificationParsed(
        icon: Icons.verified_rounded,
        color: const Color(0xFF16A34A),
        getTitle: (isIndo) => isIndo ? 'Verifikasi KTP Disetujui' : 'ID Card Verification Approved',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your ID card has been verified. You can now accept incoming customer orders.',
      );
    }
    if (lower.contains('kemitraan') && (lower.contains('tolak') || lower.contains('ditolak'))) {
      return _NotificationParsed(
        icon: Icons.error_rounded,
        color: const Color(0xFFDC2626),
        getTitle: (isIndo) => isIndo ? 'Pengajuan Kemitraan Ditolak' : 'Partnership Application Declined',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your partner registration request has been rejected by administrator.',
      );
    }
    if (lower.contains('kemitraan') && (lower.contains('setuju') || lower.contains('disetujui'))) {
      return _NotificationParsed(
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF16A34A),
        getTitle: (isIndo) => isIndo ? 'Pengajuan Kemitraan Disetujui' : 'Partnership Application Approved',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Congratulations! Your partner registration has been approved.',
      );
    }
    if (lower.contains('suspend')) {
      return _NotificationParsed(
        icon: Icons.block_rounded,
        color: const Color(0xFFEA580C),
        getTitle: (isIndo) => isIndo ? 'Akun Disuspend' : 'Account Suspended',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your account has been temporarily suspended. Please contact support.',
      );
    }
    if (lower.contains('blokir') || lower.contains('diblokir')) {
      return _NotificationParsed(
        icon: Icons.gavel_rounded,
        color: const Color(0xFFDC2626),
        getTitle: (isIndo) => isIndo ? 'Akun Diblokir' : 'Account Blocked',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your partner account has been blocked by administration.',
      );
    }
    if (lower.contains('diaktifkan') || (lower.contains('status akun') && lower.contains('aktif'))) {
      return _NotificationParsed(
        icon: Icons.check_circle_rounded,
        color: const Color(0xFF16A34A),
        getTitle: (isIndo) => isIndo ? 'Akun Diaktifkan' : 'Account Activated',
        getMessage: (isIndo) => isIndo
            ? raw
            : 'Your partner account is active and ready to take jobs.',
      );
    }
    if (lower.contains('pesanan')) {
      return _NotificationParsed(
        icon: Icons.handyman_rounded,
        color: KetokColors.darkPrimary,
        getTitle: (isIndo) => isIndo ? 'Info Pesanan' : 'Order Information',
        getMessage: (isIndo) => raw,
      );
    }
    return _NotificationParsed(
      icon: Icons.campaign_rounded,
      color: const Color(0xFF0284C7),
      getTitle: (isIndo) => isIndo ? 'Pengumuman Admin' : 'Admin Announcement',
      getMessage: (isIndo) => raw,
    );
  }

  String _formatRelativeTime(DateTime? dt, bool isIndo) {
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
    final l10n = context.l10n;
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
          SnackBar(
            content: Text(
              l10n.isIndonesian
                  ? 'Semua notifikasi ditandai sudah dibaca.'
                  : 'All notifications marked as read.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.isIndonesian
                  ? 'Gagal memperbarui notifikasi: $e'
                  : 'Failed to update notifications: $e',
            ),
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
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        title: Text(isIndo ? 'Notifikasi' : 'Notifications'),
        backgroundColor: KetokColors.bgColor,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: _markAllAsRead,
            icon: const Icon(Icons.done_all_rounded),
            tooltip: isIndo ? 'Tandai semua sudah dibaca' : 'Mark all as read',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off_rounded, size: 48, color: KetokColors.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(_errorMessage!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadNotifications,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, index) {
                      final notification = _notifications[index];
                      final isActionable = notification.actionType != null;
                      final title = notification.getTitle(isIndo);
                      final message = notification.getMessage(isIndo);
                      final timeStr = _formatRelativeTime(notification.createdAt, isIndo);

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
                                    : KetokColors.borderColor,
                              ),
                              boxShadow: notification.unread
                                  ? [
                                      BoxShadow(
                                        color: notification.color.withValues(alpha: 0.08),
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
                                              title,
                                              style: TextStyle(
                                                fontWeight: notification.unread
                                                    ? FontWeight.w800
                                                    : FontWeight.w600,
                                                color: const Color(0xFF030813),
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                          if (timeStr.isNotEmpty) ...[
                                            Text(
                                              timeStr,
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
                                        message,
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
                                                  ? (isIndo ? 'Buka Formulir KTP →' : 'Open ID Form →')
                                                  : (isIndo ? 'Lihat Detail →' : 'View Details →'),
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

class _NotificationParsed {
  final IconData icon;
  final Color color;
  final String Function(bool isIndo) getTitle;
  final String Function(bool isIndo) getMessage;
  final String? actionType;

  const _NotificationParsed({
    required this.icon,
    required this.color,
    required this.getTitle,
    required this.getMessage,
    this.actionType,
  });
}

class _AppNotification {
  final int? id;
  final IconData icon;
  final Color color;
  final String Function(bool isIndo) getTitle;
  final String Function(bool isIndo) getMessage;
  final DateTime? createdAt;
  final bool unread;
  final String? actionType;

  const _AppNotification({
    this.id,
    required this.icon,
    required this.color,
    required this.getTitle,
    required this.getMessage,
    this.createdAt,
    this.unread = false,
    this.actionType,
  });

  _AppNotification copyWith({
    int? id,
    IconData? icon,
    Color? color,
    String Function(bool isIndo)? getTitle,
    String Function(bool isIndo)? getMessage,
    DateTime? createdAt,
    bool? unread,
    String? actionType,
  }) {
    return _AppNotification(
      id: id ?? this.id,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      getTitle: getTitle ?? this.getTitle,
      getMessage: getMessage ?? this.getMessage,
      createdAt: createdAt ?? this.createdAt,
      unread: unread ?? this.unread,
      actionType: actionType ?? this.actionType,
    );
  }
}
