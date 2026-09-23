import 'package:flutter/material.dart';
import '../services/app_config_service.dart';
import '../screens/notifikasi_screen.dart';
import 'ketok_colors.dart';

/// Global state untuk notifikasi (sementara)
final ValueNotifier<bool> globalHasUnreadNotification = ValueNotifier(true);

/// Top app bar Ketok Mitra yang dipakai di semua halaman utama.
///
/// Menampilkan logo aplikasi, nama brand "Ketok", tombol notifikasi,
/// dan avatar profil mitra. Klik pada avatar akan memanggil [onAvatarTap].
class KetokAppBar extends StatelessWidget {
  /// Callback saat tombol lonceng notifikasi ditekan.
  final VoidCallback? onNotificationTap;

  const KetokAppBar({
    super.key,
    this.onNotificationTap,
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
              final isNetwork = logoUrl != null && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: KetokColors.darkPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: isNetwork
                        ? Image.network(
                            logoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/logo_mitra.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.business_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : Image.asset(
                            'assets/images/logo_mitra.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.business_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    config?.namaAplikasi ?? 'Ketok',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  if (!(config?.namaAplikasi ?? 'Ketok').toLowerCase().contains('mitra')) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: KetokColors.surfaceLow,
                        border: Border.all(color: KetokColors.borderColor),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'MITRA',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      );
                    },
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  size: 27,
                ),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: globalHasUnreadNotification,
                builder: (context, hasUnread, child) {
                  if (!hasUnread) return const SizedBox.shrink();
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
