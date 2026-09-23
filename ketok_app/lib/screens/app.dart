import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_app_bar.dart';
import '../widgets/ketok_nav_bar.dart';
import 'beranda_screen.dart';
import 'chat_screen.dart';
import 'pesanan_screen.dart';
import 'profile_screen.dart';
import 'notifikasi_screen.dart';

class KetokMainScreen extends StatefulWidget {
  const KetokMainScreen({super.key});

  @override
  State<KetokMainScreen> createState() => _KetokMainScreenState();
}

class _KetokMainScreenState extends State<KetokMainScreen> {
  int _selectedIndex = 0;
  String _userName = 'K';
  String _userEmail = '';
  String _phoneNumber = '';
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    checkGlobalUnreadNotifications();
  }

  Future<void> _loadUserProfile() async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) return;

    try {
      final profile = await client
          .from('users')
          .select('nama, email, nomor_telepon, foto_profil')
          .eq('auth_uid', user.id)
          .maybeSingle();

      // Perbarui waktu terakhir aktif pengguna secara asinkron
      client
          .from('users')
          .update({'terakhir_aktif': DateTime.now().toUtc().toIso8601String()})
          .eq('auth_uid', user.id)
          .catchError((_) {});
      if (!mounted) return;
      setState(() {
        _userName =
            profile?['nama'] as String? ??
            user.userMetadata?['full_name'] as String? ??
            user.email?.split('@').first ??
            'K';
        _userEmail = profile?['email'] as String? ?? user.email ?? '';
        _phoneNumber = profile?['nomor_telepon'] as String? ?? '';
        _photoUrl = profile?['foto_profil'] as String?;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userName =
            user.userMetadata?['full_name'] as String? ??
            user.email?.split('@').first ??
            'K';
        _userEmail = user.email ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _selectedIndex,
      children: [
        const BerandaScreen(),
        const PesananScreen(),
        const ChatScreen(),
        KetokProfileScreen(
          userName: _userName,
          userEmail: _userEmail,
          phoneNumber: _phoneNumber,
          photoUrl: _photoUrl,
          onProfileUpdated: _loadUserProfile,
          onLogout: () => Supabase.instance.client.auth.signOut(),
        ),
      ],
    ),
    bottomNavigationBar: KetokNavBar(
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
    ),
  );
}

class KetokResponsiveContent extends StatelessWidget {
  final Widget child;

  const KetokResponsiveContent({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1100),
      child: child,
    ),
  );
}

class KetokScreenHeader extends StatelessWidget {
  const KetokScreenHeader({super.key});

  Future<void> _openNotifications(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
    await checkGlobalUnreadNotifications();
  }

  @override
  Widget build(BuildContext context) => KetokAppBar(
    onNotificationTap: () => _openNotifications(context),
  );
}
