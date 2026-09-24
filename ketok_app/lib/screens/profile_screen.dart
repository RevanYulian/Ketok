import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/app_config_service.dart';
import '../services/locale_service.dart';
import '../widgets/ketok_colors.dart';
import '../widgets/profile_avatar.dart';
import 'app.dart';
import 'profile/edit_profil_screen.dart';
import 'profile/alamat_tersimpan_screen.dart';
import 'profile/metode_pembayaran_screen.dart';
import 'profile/voucher_promo_screen.dart';
import 'profile/ubah_sandi_screen.dart';
import 'profile/bantuan_screen.dart';
import 'profile/syarat_ketentuan_screen.dart';
import 'profile/kebijakan_privasi_screen.dart';

class KetokProfileScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String phoneNumber;
  final String? photoUrl;
  final VoidCallback onLogout;
  final VoidCallback? onProfileUpdated;

  const KetokProfileScreen({
    super.key,
    required this.userName,
    required this.userEmail,
    this.phoneNumber = '',
    this.photoUrl,
    required this.onLogout,
    this.onProfileUpdated,
  });

  @override
  State<KetokProfileScreen> createState() => _KetokProfileScreenState();
}

class _KetokProfileScreenState extends State<KetokProfileScreen> {
  bool _notificationsEnabled = true;
  int _completedOrdersCount = 0;
  int _reviewsCount = 0;
  int _activeVoucherCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  @override
  void didUpdateWidget(covariant KetokProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userName != widget.userName ||
        oldWidget.userEmail != widget.userEmail) {
      _fetchStats();
    }
  }

  Future<void> _fetchStats() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final userRow = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', user.id)
          .maybeSingle();

      if (userRow != null) {
        final userId = userRow['id_user'] as int;
        final ordersRes = await client
            .from('pesanan')
            .select('id_pesanan')
            .eq('pengguna_id', userId)
            .eq('status', 'selesai');

        final reviewsRes = await client
            .from('ulasan')
            .select('id_ulasan, pesanan!inner(pengguna_id)')
            .eq('pesanan.pengguna_id', userId);

        final vouchersRes = await client
            .from('pengguna_voucher')
            .select('id_pengguna_voucher')
            .eq('user_id', userId)
            .eq('status', 'aktif');

        if (mounted) {
          setState(() {
            _completedOrdersCount = ordersRes.length;
            _reviewsCount = reviewsRes.length;
            _activeVoucherCount = vouchersRes.length;
          });
        }
      }
    } catch (_) {}
  }

  void _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfilScreen(
          initialName: widget.userName,
          initialEmail: widget.userEmail,
          initialPhone: widget.phoneNumber,
          initialPhotoUrl: widget.photoUrl,
          onProfileUpdated: widget.onProfileUpdated,
        ),
      ),
    );

    if (updated == true) {
      widget.onProfileUpdated?.call();
      _fetchStats();
    }
  }



  void _showLanguageModal() {
    final l10n = context.l10n;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.selectLanguageTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageTile('Bahasa Indonesia (ID)', const Locale('id')),
            const Divider(height: 1),
            _buildLanguageTile('English (US)', const Locale('en')),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String label, Locale targetLocale) {
    final isSelected =
        LocaleService.instance.currentLocale.languageCode == targetLocale.languageCode;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981))
          : null,
      onTap: () async {
        await LocaleService.instance.setLocale(targetLocale);
        if (!mounted) return;
        setState(() {});
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              targetLocale.languageCode == 'id'
                  ? 'Bahasa aplikasi diubah ke Bahasa Indonesia.'
                  : 'App language changed to English.',
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  void _showPartnerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KetokColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ketok Mitra Teknisi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Aplikasi khusus mitra penyedia jasa',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Keuntungan Bergabung Menjadi Mitra Ketok:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            _buildBenefitRow(Icons.schedule_rounded, 'Bebas atur jadwal dan wilayah kerja sesuai keinginan Anda.'),
            _buildBenefitRow(Icons.people_outline_rounded, 'Terhubung langsung dengan ribuan pelanggan di Malang Raya.'),
            _buildBenefitRow(Icons.payments_outlined, 'Penghasilan transparan dan dibayarkan langsung tanpa potongan rumit.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(
                    const ClipboardData(
                      text: 'https://play.google.com/store/apps/details?id=id.ketok.mitra',
                    ),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tautan download Ketok Mitra berhasil disalin!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                },
                icon: const Icon(Icons.download_rounded),
                label: const Text('Unduh Aplikasi Ketok Mitra'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
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

  Widget _buildBenefitRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF0284C7)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13, color: Color(0xFF334155), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text(
          l10n.logoutConfirmDesc,
          style: const TextStyle(color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            child: Text(l10n.logoutButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: KetokResponsiveContent(
          child: Column(
          children: [
            const KetokScreenHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAccountCard(context),
                    const SizedBox(height: 20),
                    _buildStats(),
                    const SizedBox(height: 24),
                    _buildSectionLabel(l10n.sectionActivity),
                    _buildSettingsGroup(context, [
                      _SettingItem(
                        Icons.location_on_outlined,
                        l10n.savedAddresses,
                        l10n.savedAddressesSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AlamatTersimpanScreen(),
                          ),
                        ),
                      ),
                      _SettingItem(
                        Icons.account_balance_wallet_outlined,
                        l10n.ketokPayBalance,
                        l10n.ketokPaySubtitle,
                        badge: 'Rp 0',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MetodePembayaranScreen(),
                          ),
                        ),
                      ),
                      _SettingItem(
                        Icons.confirmation_num_outlined,
                        l10n.myVouchers,
                        l10n.myVouchersSubtitle,
                        badge: _activeVoucherCount > 0
                            ? '$_activeVoucherCount Voucher'
                            : 'Promo',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const VoucherPromoScreen(),
                            ),
                          );
                          _fetchStats();
                        },
                      ),
                    ]),
                    const SizedBox(height: 22),
                    _buildSectionLabel(l10n.sectionSecurity),
                    _buildSettingsGroup(context, [
                      _SettingItem(
                        Icons.notifications_none_rounded,
                        l10n.notificationsSetting,
                        l10n.notificationsSubtitle,
                        toggle: true,
                        toggleValue: _notificationsEnabled,
                        onToggleChanged: (val) {
                          setState(() => _notificationsEnabled = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                val
                                    ? (l10n.isIndonesian
                                        ? 'Notifikasi pesanan & chat diaktifkan.'
                                        : 'Order & chat notifications enabled.')
                                    : (l10n.isIndonesian
                                        ? 'Notifikasi dinonaktifkan.'
                                        : 'Notifications disabled.'),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      ),
                      _SettingItem(
                        Icons.lock_outline_rounded,
                        l10n.accountSecurity,
                        l10n.accountSecuritySubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UbahSandiScreen(),
                          ),
                        ),
                      ),
                      _SettingItem(
                        Icons.translate_rounded,
                        l10n.appLanguage,
                        l10n.currentLanguageName,
                        onTap: _showLanguageModal,
                      ),
                    ]),
                    const SizedBox(height: 20),
                    _buildPartnerBanner(),
                    const SizedBox(height: 22),
                    _buildSectionLabel(l10n.sectionHelp),
                    _buildSettingsGroup(context, [
                      _SettingItem(
                        Icons.help_outline_rounded,
                        l10n.helpCenter,
                        l10n.helpCenterSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BantuanScreen(),
                          ),
                        ),
                      ),
                      _SettingItem(
                        Icons.gavel_rounded,
                        l10n.termsConditions,
                        l10n.termsConditionsSubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SyaratKetentuanScreen(),
                          ),
                        ),
                      ),
                      _SettingItem(
                        Icons.shield_outlined,
                        l10n.privacyPolicy,
                        l10n.privacyPolicySubtitle,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KebijakanPrivasiScreen(),
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _confirmLogout,
                        icon: const Icon(Icons.logout_rounded),
                        label: Text(l10n.logoutButton),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD8D6),
                          foregroundColor: const Color(0xFF9B1C1C),
                          minimumSize: const Size.fromHeight(46),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ValueListenableBuilder<AppConfig?>(
                      valueListenable: AppConfigService.instance.configNotifier,
                      builder: (context, config, _) {
                        final version = config?.versiAplikasi ?? '1.0.0';
                        final tagline = config?.tagline ??
                            'Platform Jasa Teknisi On-Demand Terpercaya';
                        return Center(
                          child: Text(
                            'Versi $version\n$tagline',
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
    ),
  );
}

  Widget _buildAccountCard(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x06000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          children: [
            ProfileAvatar(
              name: widget.userName,
              photoUrl: widget.photoUrl,
              radius: 38,
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
                        widget.userName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      _ActiveBadge(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.phoneNumber.isNotEmpty
                        ? widget.phoneNumber
                        : 'Nomor telepon belum diatur',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    widget.userEmail.isNotEmpty
                        ? widget.userEmail
                        : 'Email belum diatur',
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
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _openEditProfile,
            icon: const Icon(Icons.edit_note_rounded, size: 18),
            label: Text(context.l10n.editProfileTitle),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0F172A),
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

  Widget _buildStats() {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.verified_outlined,
            value: '$_completedOrdersCount',
            label: l10n.completedOrdersCountLabel,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.isIndonesian
                        ? 'Anda telah menyelesaikan $_completedOrdersCount pesanan layanan di Ketok.'
                        : 'You have completed $_completedOrdersCount service orders on Ketok.',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_outlined,
            value: '0',
            label: 'KetokPay (Rp)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MetodePembayaranScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            icon: Icons.star_rounded,
            value: '$_reviewsCount',
            label: l10n.reviewsCountLabel,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    l10n.isIndonesian
                        ? 'Anda telah memberikan $_reviewsCount ulasan kepuasan layanan.'
                        : 'You have written $_reviewsCount service reviews.',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 10),
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Color(0xFF64748B),
      ),
    ),
  );

  Widget _buildSettingsGroup(
    BuildContext context,
    List<_SettingItem> items,
  ) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: const [
        BoxShadow(
          color: Color(0x04000000),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: items.asMap().entries.map((entry) {
        final item = entry.value;
        return Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: KetokColors.surfaceLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(item.icon, size: 19, color: const Color(0xFF1E293B)),
              ),
              title: Text(
                item.title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: item.subtitle.isEmpty
                  ? null
                  : Text(
                      item.subtitle,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
              trailing: item.toggle
                  ? Switch(
                      value: item.toggleValue,
                      onChanged: item.onToggleChanged,
                      activeThumbColor: const Color(0xFF0F172A),
                    )
                  : item.badge != null
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.badge!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    )
                  : const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF94A3B8),
                    ),
              onTap: item.onTap,
            ),
            if (entry.key < items.length - 1)
              const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
          ],
        );
      }).toList(),
    ),
  );

  Widget _buildPartnerBanner() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF0F172A),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PELUANG TEKNISI',
          style: TextStyle(
            color: Color(0xFF38BDF8),
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Punya Keahlian Jasa?',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daftar sebagai mitra teknisi di Ketok Mitra dan mulai terima orderan langsung dari warga terdekat.',
          style: TextStyle(color: Color(0xFF94A3B8), height: 1.35, fontSize: 12.5),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _showPartnerModal,
          icon: const Icon(Icons.download_outlined, size: 18),
          label: const Text('Unduh Ketok Mitra'),
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF0F172A),
            minimumSize: const Size.fromHeight(42),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    ),
  );
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: const Color(0xFFECFDF5),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Text(
      'Pengguna Aktif',
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        color: Color(0xFF059669),
      ),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 104,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x04000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: KetokColors.surfaceLow,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 17, color: const Color(0xFF0F172A)),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
    ),
  );
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;
  final bool toggle;
  final bool toggleValue;
  final ValueChanged<bool>? onToggleChanged;
  final VoidCallback? onTap;

  const _SettingItem(
    this.icon,
    this.title,
    this.subtitle, {
    this.badge,
    this.toggle = false,
    this.toggleValue = false,
    this.onToggleChanged,
    this.onTap,
  });
}
