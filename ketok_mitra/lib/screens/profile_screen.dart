import 'package:flutter/material.dart';

import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';
import '../widgets/profile_avatar.dart';
import 'manajemen_pekerjaan_screen.dart';
import 'profile_setup_screen.dart';
import 'verifikasi_ktp_screen.dart';
import 'notifikasi_screen.dart';
import 'ubah_sandi_screen.dart';
import 'bantuan_screen.dart';
import 'syarat_ketentuan_screen.dart';
import 'kebijakan_privasi_screen.dart';
import '../services/app_config_service.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String approvalStatus;
  final String? photoUrl;
  final bool isOnline;
  final ValueChanged<bool> onOnlineChanged;
  final VoidCallback onLogout;
  final VoidCallback? onProfileUpdated;
  final VoidCallback? onNotificationTap;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.phoneNumber = '',
    required this.approvalStatus,
    this.photoUrl,
    required this.isOnline,
    required this.onOnlineChanged,
    required this.onLogout,
    this.onProfileUpdated,
    this.onNotificationTap,
  });

  String get _displayName => userName == 'Mitra' ? 'Budi Santoso' : userName;

  @override
  Widget build(BuildContext context) {
    final isApproved = approvalStatus == 'terverifikasi';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            KetokAppBar(
              onNotificationTap: onNotificationTap ??
                  () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotifikasiScreen(),
                        ),
                      ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountCard(context),
                    const SizedBox(height: 22),
                    _buildOnlineCard(context),
                    const SizedBox(height: 16),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildSectionLabel('MANAJEMEN PEKERJAAN'),
                    _buildSettingsGroup([
                      _SettingItem(
                        Icons.badge_outlined,
                        'Verifikasi Identitas Usaha & KTP',
                        'Status pengajuan identitas usaha & KTP',
                        () => _openVerifikasiKtp(context),
                        trailingBadge: _buildKtpBadge(),
                      ),
                      _SettingItem(
                        Icons.build_circle_outlined,
                        'Layanan & Tarif',
                        isApproved ? 'Atur layanan dan kisaran tarif' : 'Terkunci (Menunggu Verifikasi KTP)',
                        isApproved ? () => _openWorkManagement(context, 'services') : () => _showLockedWorkManagement(context),
                        isLocked: !isApproved,
                      ),
                      _SettingItem(
                        Icons.event_available_outlined,
                        'Jadwal & Jam Kerja',
                        isApproved ? 'Atur hari dan jam kerja Anda' : 'Terkunci (Menunggu Verifikasi KTP)',
                        isApproved ? () => _openWorkManagement(context, 'schedule') : () => _showLockedWorkManagement(context),
                        isLocked: !isApproved,
                      ),
                      _SettingItem(
                        Icons.verified_user_outlined,
                        'Sertifikasi Tambahan',
                        isApproved ? 'Kelola dokumen pendukung' : 'Terkunci (Menunggu Verifikasi KTP)',
                        isApproved ? () => _openWorkManagement(context, 'certificate') : () => _showLockedWorkManagement(context),
                        isLocked: !isApproved,
                      ),
                    ]),
            const SizedBox(height: 22),
            _buildSectionLabel('PREFERENSI & KEAMANAN'),
            _buildSettingsGroup([
              _SettingItem(
                Icons.notifications_outlined,
                'Pusat Notifikasi',
                'Lihat semua pemberitahuan dan status verifikasi',
                onNotificationTap ??
                    () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NotifikasiScreen(),
                          ),
                        ),
              ),
              _SettingItem(
                Icons.notifications_active_outlined,
                'Notifikasi Pesanan',
                'Pemberitahuan suara pesanan baru',
                () => _showComingSoon(context),
                toggle: true,
              ),
              _SettingItem(
                Icons.lock_outline_rounded,
                'Keamanan Akun',
                'Ubah kata sandi dan pengaturan akun',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UbahSandiScreen())),
              ),
            ]),
            const SizedBox(height: 22),

            _buildSectionLabel('BANTUAN & INFO KETOK'),
            _buildSettingsGroup([
              _SettingItem(
                Icons.help_outline_rounded,
                'Pusat Bantuan & FAQ',
                '',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BantuanScreen())),
              ),
              _SettingItem(
                Icons.gavel_rounded,
                'Syarat & Ketentuan Layanan',
                '',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SyaratKetentuanScreen())),
              ),
              _SettingItem(
                Icons.shield_outlined,
                'Kebijakan Privasi',
                '',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KebijakanPrivasiScreen())),
              ),
            ]),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Keluar dari Akun'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD8D6),
                  foregroundColor: const Color(0xFF9B1C1C),
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<AppConfig?>(
              valueListenable: AppConfigService.instance.configNotifier,
              builder: (context, config, _) {
                final version = config?.versiAplikasi ?? '1.0.0';
                final tagline = config?.tagline ?? 'Platform Jasa Teknisi On-Demand Terpercaya';
                return Center(
                  child: Text(
                    'Versi $version (Ketok Mitra)\n$tagline',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8B8F96),
                      height: 1.8,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [BoxShadow(color: Color(0x0C000000), blurRadius: 6)],
    ),
    child: Column(
      children: [
        Row(
          children: [
            ProfileAvatar(
              name: _displayName,
              photoUrl: photoUrl,
              radius: 36,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        _displayName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _MitraBadge(approved: approvalStatus == 'terverifikasi'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    phoneNumber.isNotEmpty
                        ? phoneNumber
                        : 'Nomor telepon belum diatur',
                    style: const TextStyle(
                      fontSize: 12,
                      color: KetokColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    userEmail.isNotEmpty ? userEmail : 'Email belum diatur',
                    style: const TextStyle(
                      fontSize: 12,
                      color: KetokColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _openProfileSetup(context),
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: const Text('Edit Profil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: KetokColors.darkPrimary,
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              minimumSize: const Size.fromHeight(40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildStats() => Row(
    children: [
      Expanded(
        child: _StatCard(
          icon: Icons.star_rounded,
          value: '4.9',
          label: 'Rating',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(
          icon: Icons.verified_outlined,
          value: '128',
          label: 'Pesanan Selesai',
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _StatCard(
          icon: Icons.bolt_rounded,
          value: isOnline ? 'Online' : 'Offline',
          label: 'Status',
        ),
      ),
    ],
  );

  Widget _buildSectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: .6,
      ),
    ),
  );

  Widget _buildSettingsGroup(List<_SettingItem> items) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 4,
              ),
              leading: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.isLocked ? const Color(0xFFF3F4F6) : KetokColors.surfaceLow,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  item.icon,
                  size: 18,
                  color: item.isLocked ? const Color(0xFF9CA3AF) : KetokColors.onSurface,
                ),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: item.isLocked ? const Color(0xFF9CA3AF) : KetokColors.onSurface,
                      ),
                    ),
                  ),
                  if (item.trailingBadge != null) item.trailingBadge!,
                ],
              ),
              subtitle: item.subtitle.isEmpty
                  ? null
                  : Text(
                      item.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: item.isLocked ? const Color(0xFF9CA3AF) : KetokColors.onSurfaceVariant,
                      ),
                    ),
              trailing: item.toggle
                  ? Switch(value: isOnline, onChanged: onOnlineChanged)
                  : item.isLocked
                      ? const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFF9CA3AF))
                      : const Icon(Icons.chevron_right_rounded),
              onTap: item.onTap,
            ),
            if (entry.key < items.length - 1)
              const Divider(height: 1, indent: 62),
          ],
        );
      }).toList(),
    ),
  );

  Widget _buildOnlineCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFF0FDF4) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOnline ? const Color(0xFFBBF7D0) : KetokColors.borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF16A34A)
                  : KetokColors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline ? 'Sedang online' : 'Sedang offline',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  isOnline
                      ? 'Pelanggan dapat menemukan Anda sekarang.'
                      : 'Anda tidak akan menerima pesanan baru.',
                  style: const TextStyle(
                    color: KetokColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            onChanged: (val) {
              if (val && approvalStatus != 'terverifikasi') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Lengkapi verifikasi KTP dan tunggu persetujuan admin untuk dapat online.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
                return;
              }
              onOnlineChanged(val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKtpBadge() {
    Color bg;
    Color text;
    String label;

    switch (approvalStatus) {
      case 'terverifikasi':
        bg = const Color(0xFFE8F5E9);
        text = const Color(0xFF2E7D32);
        label = 'Terverifikasi';
        break;
      case 'menunggu':
        bg = const Color(0xFFFFF7ED);
        text = const Color(0xFFC2410C);
        label = 'Menunggu';
        break;
      case 'ditolak':
        bg = const Color(0xFFFFEBEE);
        text = const Color(0xFFC62828);
        label = 'Ditolak';
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        text = const Color(0xFF4B5563);
        label = 'Belum Upload';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: text),
      ),
    );
  }

  void _showLockedWorkManagement(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 22),
            SizedBox(width: 8),
            Text('Fitur Terkunci', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: const Text(
          'Manajemen pekerjaan belum dapat digunakan karena akun Anda masih dalam status Pengajuan / Menunggu Verifikasi KTP dari Admin Ketok.\n\nSetelah dokumen KTP Anda disetujui, Anda dapat langsung mengatur layanan dan tarif pekerjaan Anda.',
          style: TextStyle(fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: KetokColors.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openVerifikasiKtp(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: KetokColors.darkPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cek Status KTP'),
          ),
        ],
      ),
    );
  }

  Future<void> _openVerifikasiKtp(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VerifikasiKtpScreen()),
    );
    if (updated == true) {
      onProfileUpdated?.call();
    }
  }

  Future<void> _openWorkManagement(BuildContext context, String section) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => ManajemenPekerjaanScreen(initialSection: section),
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur ini sedang disiapkan.')),
    );
  }

  Future<void> _openProfileSetup(BuildContext context) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
    if (updated == true) {
      onProfileUpdated?.call();
    }
  }
}

class _MitraBadge extends StatelessWidget {
  final bool approved;

  const _MitraBadge({required this.approved});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: approved ? const Color(0xFFE8F5E9) : const Color(0xFFFFF7ED),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Text(
      approved ? 'Mitra Terverifikasi' : 'Menunggu Persetujuan',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: approved ? const Color(0xFF2E7D32) : const Color(0xFFC2410C),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) => Container(
    height: 108,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: KetokColors.surfaceLow,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(icon, size: 17),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 10,
            color: KetokColors.onSurfaceVariant,
          ),
        ),
      ],
    ),
  );
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool toggle;
  final bool isLocked;
  final Widget? trailingBadge;

  const _SettingItem(
    this.icon,
    this.title,
    this.subtitle,
    this.onTap, {
    this.toggle = false,
    this.isLocked = false,
    this.trailingBadge,
  });
}
