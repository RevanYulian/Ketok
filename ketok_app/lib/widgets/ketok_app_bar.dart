import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/app_config_service.dart';
import 'ketok_colors.dart';

/// Global state untuk notifikasi ketok_app
final ValueNotifier<bool> globalHasUnreadNotification = ValueNotifier(false);

/// Cek apakah pengguna saat ini memiliki notifikasi yang belum dibaca
Future<void> checkGlobalUnreadNotifications() async {
  try {
    final client = Supabase.instance.client;
    final authUser = client.auth.currentUser;
    if (authUser == null) {
      globalHasUnreadNotification.value = false;
      return;
    }
    final user = await client
        .from('users')
        .select('id_user')
        .eq('auth_uid', authUser.id)
        .maybeSingle();
    final userId = user?['id_user'];
    if (userId is! int) {
      globalHasUnreadNotification.value = false;
      return;
    }

    final unread = await client
        .from('notifikasi')
        .select('id_notif')
        .eq('user_id', userId)
        .eq('status_baca', 'belum')
        .limit(1);

    globalHasUnreadNotification.value = unread.isNotEmpty;
  } catch (_) {
    // ignore
  }
}

class KetokAppBar extends StatelessWidget {
  final VoidCallback? onNotificationTap;
  final bool? showNotificationDot;

  const KetokAppBar({
    super.key,
    this.onNotificationTap,
    this.showNotificationDot,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          ValueListenableBuilder<AppConfig?>(
            valueListenable: AppConfigService.instance.configNotifier,
            builder: (context, config, _) {
              final logoUrl = config?.logoUrl;
              final appName = config?.namaAplikasi ?? 'Ketok';
              final isNetwork = logoUrl != null && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

              return Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: KetokColors.primary,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: isNetwork
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Image.asset('assets/images/ketok.png'),
                          )
                        : Image.asset('assets/images/ketok.png'),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    appName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              );
            },
          ),
          const Spacer(),
          Stack(
            children: [
              IconButton(
                onPressed:
                    onNotificationTap ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Belum ada notifikasi baru.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                tooltip: 'Notifikasi',
                icon: const Icon(Icons.notifications_none_rounded, size: 27),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: globalHasUnreadNotification,
                builder: (context, hasUnread, _) {
                  final showDot = showNotificationDot ?? hasUnread;
                  if (!showDot) return const SizedBox.shrink();
                  return Positioned(
                    right: 10,
                    top: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE53E3E),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
