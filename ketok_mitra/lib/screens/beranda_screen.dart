import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'pesanan_screen.dart';
import 'pesanan_detail_screen.dart';
import 'chat_screen.dart';
import 'profile_screen.dart';
import 'profile_setup_screen.dart';
import 'verifikasi_ktp_screen.dart';
import 'notifikasi_screen.dart';
import 'dompet_detail_screen.dart';
import 'quick_menu/panduan_sop_screen.dart';
import 'quick_menu/pesanan_tersedia_screen.dart';
import 'bantuan_screen.dart';
import 'quick_menu/tagihan_marketing_screen.dart';
import 'quick_menu/tips_mitra_screen.dart';
import 'quick_menu/ulasan_mitra_screen.dart';
import 'quick_menu/tip_detail_screen.dart';
import '../widgets/ketok_colors.dart';
import '../widgets/ketok_app_bar.dart';
import '../widgets/ketok_nav_bar.dart';
import '../l10n/app_localizations.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  int _currentTabIndex = 0;
  int _pesananRefreshVersion = 0;
  bool _isOnline = true;
  bool _profileDataComplete = false;
  bool _profileComplete = false;
  String _approvalStatus = 'menunggu';
  int? _mitraUserId;
  int? _mitraProfileId;
  bool _loadingAvailableOrders = true;
  List<Map<String, dynamic>> _availableOrders = [];
  bool _loadingHomeData = true;
  double _monthlyIncome = 0;
  int _completedOrderCount = 0;
  double _averageRating = 0;
  int _reviewCount = 0;
  int _unreadReviewCount = 0;
  int _latestReviewMaxId = 0;
  int _activeOrdersCount = 0;
  int _tagihanMarketingCount = 0;
  int _chatCount = 0;
  List<Map<String, dynamic>> _tips = [];
  List<Map<String, dynamic>> _reviews = [];
  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  String _userName = 'Mitra';
  String _userEmail = '';
  String _phoneNumber = '';
  String? _photoUrl;

  // Warna diambil dari KetokColors agar konsisten di semua halaman.
  static const _bgColor = KetokColors.bgColor;
  static const _darkPrimary = KetokColors.darkPrimary;
  static const _onSurface = KetokColors.onSurface;
  static const _onSurfaceVariant = KetokColors.onSurfaceVariant;
  static const _surfaceLow = KetokColors.surfaceLow;
  static const _surfaceCard = KetokColors.surfaceCard;
  static const _borderColor = KetokColors.borderColor;

  @override
  void initState() {
    super.initState();
    _initUserData();
  }

  Future<void> _initUserData() async {
    final client = _supabase;
    if (client == null) return;
    final user = client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userEmail = user.email ?? '';
      });

      // Ambil profil custom berdasarkan UID Supabase Auth.
      try {
        final profile = await client
            .from('users')
            .select('id_user, nama, nomor_telepon, alamat, foto_profil')
            .eq('auth_uid', user.id)
            .maybeSingle();
        if (profile == null) return;
        final userId = profile['id_user'] as int;
        final mitraProfile = await client
            .from('mitra_profil')
            .select(
              'id_profil, status_online, katagori_id, nama_usaha, sub_kategori, provinsi, kota, kecamatan, kelurahan, status_verifikasi',
            )
            .eq('user_id', userId)
            .maybeSingle();
        final profileComplete =
            (profile['nama'] as String?)?.trim().isNotEmpty == true &&
            (profile['nomor_telepon'] as String?)?.trim().isNotEmpty == true;
        final approved =
            (mitraProfile?['status_verifikasi'] as String?) == 'terverifikasi';
        final approvalStatus =
            (mitraProfile?['status_verifikasi'] as String?) ?? 'menunggu';
            
        if (mitraProfile == null) {
          try {
            await client.from('mitra_profil').insert({
              'user_id': userId,
              'status_online': false,
              'status_verifikasi': 'belum_upload',
              'wilayah_operasional': 'Malang Raya',
            });
          } catch (_) {}
        }
        
        if (mounted) {
          setState(() {
            _mitraUserId = userId;
            _mitraProfileId = mitraProfile?['id_profil'] as int?;
            _userName = profile['nama'] as String? ?? _userName;
            _phoneNumber = profile['nomor_telepon'] as String? ?? '';
            _photoUrl = profile['foto_profil'] as String?;
            _isOnline = mitraProfile?['status_online'] as bool? ?? false;
            _approvalStatus = approvalStatus;
            _profileDataComplete = profileComplete;
            _profileComplete = profileComplete && approved;
          });
          await _loadHomeData();
          await _loadAvailableOrders();

          // Cek status notifikasi belum dibaca dari tabel
          try {
            final unreadList = await client
                .from('notifikasi')
                .select('id_notif')
                .eq('user_id', userId)
                .eq('status_baca', 'belum')
                .limit(1);
            globalHasUnreadNotification.value = (unreadList as List).isNotEmpty;
          } catch (_) {}
        }
      } catch (_) {
        // Fallback jika belum tersinkron
        if (user.userMetadata?['nama'] != null) {
          setState(() {
            _userName = user.userMetadata!['nama'] as String;
          });
        }
      }
    }
  }

  Future<void> _loadHomeData() async {
    final client = _supabase;
    if (client == null || _mitraUserId == null) return;

    try {
      final monthStart = DateTime(DateTime.now().year, DateTime.now().month);
      final orders = await client
          .from('pesanan')
          .select('id_pesanan, pengguna_id, status, jadwal')
          .eq('mitra_id', _mitraUserId!);
      final completedOrders = orders.where((order) {
        final scheduledAt = DateTime.tryParse(
          order['jadwal']?.toString() ?? '',
        );
        return order['status'] == 'selesai' &&
            scheduledAt != null &&
            !scheduledAt.isBefore(monthStart);
      }).toList();
      final completedIds = completedOrders
          .map((order) => order['id_pesanan'])
          .toList();
      var income = 0.0;
      var tagihan = 0;
      for (final order in completedOrders) {
        final invoice = await client
            .from('invoice')
            .select('jumlah_biaya, status_bayar')
            .eq('pesanan_id', order['id_pesanan'])
            .maybeSingle();
        if (invoice != null) {
          if (invoice['status_bayar'] == 'lunas') {
            income += (invoice['jumlah_biaya'] as num?)?.toDouble() ?? 0;
          } else {
            tagihan++;
          }
        }
      }
      
      final activeOrders = orders.where((o) => ['diproses', 'menuju_lokasi', 'dikerjakan'].contains(o['status'])).length;

      final reviews = completedIds.isEmpty
          ? <dynamic>[]
          : await client
                .from('ulasan')
                .select('id_ulasan, pesanan_id, rating, komentar')
                .inFilter('pesanan_id', completedIds)
                .order('id_ulasan', ascending: false);
      final reviewRows = <Map<String, dynamic>>[];
      for (final review in reviews.take(3)) {
        final order = completedOrders.firstWhere(
          (item) => item['id_pesanan'] == review['pesanan_id'],
          orElse: () => <String, dynamic>{},
        );
        final customer = order.isEmpty
            ? null
            : await client
                  .from('users')
                  .select('nama')
                  .eq('id_user', order['pengguna_id'])
                  .maybeSingle();
        reviewRows.add({
          ...Map<String, dynamic>.from(review),
          'customer_name': customer?['nama'] ?? 'Pelanggan',
        });
      }

      final tipRows = await client
          .from('artikel')
          .select('id_artikel, judul, ringkasan, isi, dibuat_pada')
          .eq('aktif', true)
          .order('dibuat_pada', ascending: false)
          .limit(3);

      final ratings = reviews
          .map((review) => (review['rating'] as num?)?.toDouble())
          .whereType<double>()
          .toList();

      int unreadReviews = 0;
      int maxReviewId = 0;
      for (final r in reviews) {
        final id = (r['id_ulasan'] as num?)?.toInt() ?? 0;
        if (id > maxReviewId) maxReviewId = id;
      }

      if (reviews.isNotEmpty && _mitraUserId != null) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final lastSeenId = prefs.getInt('last_seen_review_id_$_mitraUserId');
          final hasSeen = prefs.getBool('has_seen_reviews_$_mitraUserId') ?? false;

          if (!hasSeen && lastSeenId == null) {
            unreadReviews = reviews.length;
          } else {
            final maxSeen = lastSeenId ?? 0;
            unreadReviews = reviews.where((r) {
              final id = (r['id_ulasan'] as num?)?.toInt() ?? 0;
              return id > maxSeen;
            }).length;
          }
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _monthlyIncome = income;
        _completedOrderCount = completedOrders.length;
        _reviewCount = reviews.length;
        _unreadReviewCount = unreadReviews;
        _latestReviewMaxId = maxReviewId;
        _averageRating = ratings.isEmpty
            ? 0
            : ratings.reduce((a, b) => a + b) / ratings.length;
        _tagihanMarketingCount = tagihan;
        _activeOrdersCount = activeOrders;
        _chatCount = activeOrders; // Asumsi: ada 1 chat room per active order
        _reviews = reviewRows;
        _tips = tipRows.map((row) => Map<String, dynamic>.from(row)).toList();
        _loadingHomeData = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingHomeData = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data beranda gagal dimuat: $error')),
      );
    }
  }

  Future<void> _markReviewsAsSeen() async {
    if (_mitraUserId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_latestReviewMaxId > 0) {
        final currentSaved = prefs.getInt('last_seen_review_id_$_mitraUserId') ?? 0;
        if (_latestReviewMaxId > currentSaved) {
          await prefs.setInt('last_seen_review_id_$_mitraUserId', _latestReviewMaxId);
        }
      }
      await prefs.setBool('has_seen_reviews_$_mitraUserId', true);
      if (mounted) {
        setState(() {
          _unreadReviewCount = 0;
        });
      }
    } catch (_) {}
  }

  Future<void> _syncUnreadReviews() async {
    if (_mitraUserId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeenId = prefs.getInt('last_seen_review_id_$_mitraUserId') ?? 0;
      final hasSeen = prefs.getBool('has_seen_reviews_$_mitraUserId') ?? false;

      if (!hasSeen) return;

      int unread = 0;
      if (_reviews.isNotEmpty) {
        unread = _reviews.where((r) {
          final id = (r['id_ulasan'] as num?)?.toInt() ?? 0;
          return id > lastSeenId;
        }).length;
      }
      if (mounted) {
        setState(() {
          _unreadReviewCount = unread;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadAvailableOrders() async {
    final client = _supabase;
    if (client == null || _mitraUserId == null) return;

    setState(() => _loadingAvailableOrders = true);
    try {
      final rows = await client
          .from('pesanan')
          .select(
            'id_pesanan, pengguna_id, katagori_id, status, lokasi, jadwal, catatan, biaya_kunjungan, status_persetujuan_biaya',
          )
          .eq('mitra_id', _mitraUserId!)
          .inFilter('status', ['diproses', 'menuju_lokasi', 'dikerjakan'])
          .order('jadwal', ascending: false)
          .limit(10);

      final orders = <Map<String, dynamic>>[];

      for (final order in rows) {
        final customer = await client
            .from('users')
            .select('nama')
            .eq('id_user', order['pengguna_id'])
            .maybeSingle();
        final category = await client
            .from('kategori_layanan')
            .select('nama_katagori')
            .eq('id_katagori', order['katagori_id'])
            .maybeSingle();
        final invoice = await client
            .from('invoice')
            .select('jumlah_biaya, biaya_kunjungan, biaya_jasa, biaya_sparepart')
            .eq('pesanan_id', order['id_pesanan'])
            .maybeSingle();

        orders.add({
          ...Map<String, dynamic>.from(order),
          'customer_name': customer?['nama'] ?? 'Pelanggan',
          'category_name': category?['nama_katagori'] ?? 'Layanan Ketok',
          'price': invoice?['jumlah_biaya'] ?? order['biaya_kunjungan'] ?? 50000,
        });
      }

      if (!mounted) return;
      setState(() {
        _availableOrders = orders;
        _loadingAvailableOrders = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _loadingAvailableOrders = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pesanan baru gagal dimuat: $error')),
      );
    }
  }

  Future<void> _openOrderDetail(
    Map<String, dynamic> order, {
    bool openEstimasi = false,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PesananDetailScreen(
          order: order,
          openEstimasiOnStart: openEstimasi,
          onComplete: () async => _loadAvailableOrders(),
        ),
      ),
    );
    _loadAvailableOrders();
  }

  Future<void> _declineOrder(Map<String, dynamic> order) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.isIndonesian ? 'Tolak Pesanan?' : 'Decline Order?'),
        content: Text(
          l10n.isIndonesian
              ? 'Apakah Anda yakin ingin menolak pesanan ini? Pesanan akan dibatalkan.'
              : 'Are you sure you want to decline this order? The order will be cancelled.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.isIndonesian ? 'Ya, Tolak' : 'Yes, Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final client = _supabase;
    if (client == null) return;

    try {
      await client
          .from('pesanan')
          .update({'status': 'dibatalkan'})
          .eq('id_pesanan', order['id_pesanan']);

      if (!mounted) return;
      setState(() {
        _availableOrders.removeWhere(
          (item) => item['id_pesanan'] == order['id_pesanan'],
        );
      });
      _showOrderMessage(
        l10n.isIndonesian
            ? 'Pesanan telah ditolak dan dibatalkan.'
            : 'Order has been declined and cancelled.',
      );
    } catch (error) {
      _showOrderMessage(
        l10n.isIndonesian ? 'Gagal menolak pesanan: $error' : 'Failed to decline order: $error',
        error: true,
      );
    }
  }

  void _showOrderMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade700 : null,
      ),
    );
  }

  Future<void> _toggleOnlineStatus() async {
    final nextStatus = !_isOnline;
    setState(() => _isOnline = nextStatus);
    final client = _supabase;
    if (client == null || _mitraUserId == null) return;

    try {
      if (_mitraProfileId == null) {
        final category = await client
            .from('kategori_layanan')
            .select('id_katagori')
            .limit(1)
            .maybeSingle();
        final categoryId = category?['id_katagori'];
        if (categoryId == null) {
          throw Exception('Belum ada kategori layanan untuk profil Mitra.');
        }
        final profile = await client
            .from('mitra_profil')
            .insert({
              'user_id': _mitraUserId,
              'katagori_id': categoryId,
              'status_online': nextStatus,
            })
            .select('id_profil')
            .single();
        _mitraProfileId = profile['id_profil'] as int;
      } else {
        await client
            .from('mitra_profil')
            .update({'status_online': nextStatus})
            .eq('id_profil', _mitraProfileId!);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _isOnline = !nextStatus);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status online gagal disimpan: $error')),
      );
    }
  }

  Future<void> _handleLogout() async {
    final l10n = context.l10n;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          l10n.logoutConfirmTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(l10n.logoutConfirmDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: const TextStyle(color: _onSurfaceVariant),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.logoutButton),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final client = _supabase;
      if (client != null) {
        await client.auth.signOut();
      }
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildHomeContent(),
            _buildPesananContent(),
            _buildChatContent(),
            _buildProfileContent(),
          ],
        ),
      ),
      bottomNavigationBar: KetokNavBar(
        currentIndex: _currentTabIndex,
        items: [
          KetokNavItem(
            selectedIcon: Icons.home_rounded,
            unselectedIcon: Icons.home_outlined,
            label: l10n.navHome,
          ),
          KetokNavItem(
            selectedIcon: Icons.assignment_rounded,
            unselectedIcon: Icons.assignment_outlined,
            label: l10n.navOrders,
            badge: _activeOrdersCount > 0 ? _activeOrdersCount.toString() : null,
          ),
          KetokNavItem(
            selectedIcon: Icons.chat_bubble_rounded,
            unselectedIcon: Icons.chat_bubble_outline_rounded,
            label: l10n.navChat,
            badge: _chatCount > 0 ? _chatCount.toString() : null,
          ),
          KetokNavItem(
            selectedIcon: Icons.person_rounded,
            unselectedIcon: Icons.person_outline_rounded,
            label: l10n.navProfile,
          ),
        ],
        onTap: (i) => setState(() {
          _currentTabIndex = i;
          if (i == 1) _pesananRefreshVersion++;
        }),
      ),
    );
  }

  // ==================== HOME TAB CONTENT ====================
  Widget _buildHomeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMitraHeader(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMitraGreeting(),
                if (!_profileDataComplete) _buildProfileCompletionBanner(),
                if (_profileDataComplete && !_profileComplete)
                  _buildApprovalBanner(),
                _buildPerformanceCard(),
                _buildQuickMenu(),
                _buildAvailableOrders(),
                _buildTipsArtikelSection(),
                _buildTestimoniSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openVerifikasiKtp() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VerifikasiKtpScreen()),
    );
    if (mounted) _initUserData();
  }

  Widget _buildApprovalBanner() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: _openVerifikasiKtp,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.timelapse_rounded,
                color: Color(0xFFC2410C),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isIndonesian ? 'Menunggu Verifikasi KTP' : 'Awaiting ID Verification',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isIndonesian
                          ? 'Pengajuan akun & berkas KTP sedang ditinjau admin. Ketuk untuk melihat status verifikasi.'
                          : 'Account and ID documents are under admin review. Tap to check verification status.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A3412),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2410C)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCompletionBanner() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        onTap: _openProfileSetup,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF7ED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFED7AA)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.assignment_ind_outlined,
                color: Color(0xFFC2410C),
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.isIndonesian ? 'Lengkapi profil Anda' : 'Complete your profile',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.isIndonesian
                          ? 'Isi data diri dan keahlian agar bisa menerima pekerjaan yang sesuai.'
                          : 'Fill in your details and skills to receive relevant job orders.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9A3412),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC2410C)),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openProfileSetup() async {
    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const ProfileSetupScreen()),
    );
    if (completed == true && mounted) {
      await _initUserData();
    }
  }

  Future<void> _openNotificationScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiScreen()),
    );
    if (mounted) {
      _initUserData();
    }
  }

  Widget _buildMitraHeader() {
    return KetokAppBar(
      onNotificationTap: _openNotificationScreen,
    );
  }

  Widget _buildMitraGreeting() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10n.greetingPartner,
                      style: const TextStyle(color: _onSurfaceVariant),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: _surfaceLow,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('✓', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _userName == 'Mitra' ? 'Budi Santoso' : _userName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: _toggleOnlineStatus,
            borderRadius: BorderRadius.circular(24),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Color(0x12000000), blurRadius: 6),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isOnline ? _darkPrimary : _onSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 7),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isOnline
                            ? (l10n.isIndonesian ? 'Online' : 'Online')
                            : (l10n.isIndonesian ? 'Istirahat' : 'Resting'),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        _isOnline
                            ? (l10n.isIndonesian ? 'Siap Order' : 'Ready')
                            : (l10n.isIndonesian ? 'Tidak menerima' : 'Offline'),
                        style: const TextStyle(
                          fontSize: 10,
                          color: _onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.expand_more_rounded, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final l10n = context.l10n;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A202C),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                color: Color(0xFFD8DCE5),
                size: 17,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.isIndonesian ? 'RINGKASAN BULAN INI' : 'THIS MONTH SUMMARY',
                  style: const TextStyle(
                    color: Color(0xFFD8DCE5),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DompetDetailScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(l10n.isIndonesian ? 'Detail Dompet' : 'Wallet Details'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  textStyle: const TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 21),
          Text(
            l10n.isIndonesian ? 'Total Pendapatan Bersih' : 'Total Net Income',
            style: const TextStyle(color: Color(0xFF9AA2B2), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            _formatCurrency(_monthlyIncome),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0x334A5364), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              _metric(
                Icons.task_alt_rounded,
                '$_completedOrderCount Order',
                l10n.isIndonesian ? 'Pesanan selesai' : 'Completed orders',
              ),
              const SizedBox(width: 22),
              _metric(
                Icons.star_rounded,
                _averageRating == 0 ? '-' : _averageRating.toStringAsFixed(1),
                '($_reviewCount ${l10n.isIndonesian ? 'Ulasan' : 'Reviews'})',
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DompetDetailScreen()),
                );
              },
              icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
              label: Text(l10n.isIndonesian ? 'Tarik Saldo Instan' : 'Instant Withdrawal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _darkPrimary,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(IconData icon, String value, String label) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFFAAB1BE), fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatCurrency(num value) {
    final number = value.round().toString();
    final formatted = number.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return 'Rp $formatted';
  }

  Widget _buildQuickMenu() {
    final l10n = context.l10n;
    final items = [
      (
        Icons.inventory_2_outlined,
        l10n.quickMenuAvailable,
        _availableOrders.isNotEmpty ? _availableOrders.length.toString() : '',
        const PesananTersediaScreen(),
      ),
      (
        Icons.rate_review_outlined,
        l10n.quickMenuReviews,
        _unreadReviewCount > 0 ? _unreadReviewCount.toString() : '',
        const UlasanMitraScreen(),
      ),
      (
        Icons.receipt_long_outlined,
        l10n.quickMenuMarketing,
        _tagihanMarketingCount > 0 ? _tagihanMarketingCount.toString() : '',
        const TagihanMarketingScreen(),
      ),
      (Icons.lightbulb_outline, l10n.quickMenuTips, '', const TipsMitraScreen()),
      (
        Icons.support_agent_outlined,
        l10n.quickMenuHelp,
        '',
        const BantuanScreen(),
      ),
      (
        Icons.verified_user_outlined,
        l10n.quickMenuSop,
        '',
        const PanduanSopScreen(),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 10,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (_, index) {
          final item = items[index];
          return InkWell(
            onTap: () async {
              if (index == 1) {
                setState(() {
                  _unreadReviewCount = 0;
                });
                _markReviewsAsSeen();
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item.$4),
              );
              if (!mounted) return;
              if (index == 1) {
                await _syncUnreadReviews();
              } else if (index == 0) {
                await _loadAvailableOrders();
              } else {
                _loadHomeData();
              }
            },
            borderRadius: BorderRadius.circular(9),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _surfaceLow,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 43,
                        height: 43,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.$1, size: 22),
                      ),
                      if (item.$3.isNotEmpty)
                        Positioned(
                          right: -5,
                          top: -5,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: _darkPrimary,
                            child: Text(
                              item.$3,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvailableOrders() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 26, 16, 0),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                l10n.isIndonesian ? 'Pesanan Tersedia' : 'Available Orders',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _surfaceLow,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _loadAvailableOrders,
                child: Text(
                  l10n.refresh,
                  style: const TextStyle(fontSize: 12, color: _onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_loadingAvailableOrders)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            )
          else if (_availableOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                l10n.isIndonesian
                    ? 'Belum ada pesanan baru untuk Anda.'
                    : 'No new orders available for you right now.',
                style: const TextStyle(color: _onSurfaceVariant),
              ),
            )
          else
            for (var index = 0; index < _availableOrders.length; index++) ...[
              if (index > 0) const SizedBox(height: 12),
              _orderCardFromData(_availableOrders[index]),
            ],
        ],
      ),
    );
  }

  Widget _orderCardFromData(Map<String, dynamic> order) {
    final l10n = context.l10n;
    final schedule = DateTime.tryParse(order['jadwal']?.toString() ?? '');
    final scheduleText = schedule == null
        ? (l10n.isIndonesian ? 'Jadwal belum ditentukan' : 'Schedule not set')
        : '${schedule.day}/${schedule.month}/${schedule.year}, ${schedule.hour.toString().padLeft(2, '0')}:${schedule.minute.toString().padLeft(2, '0')} WIB';
    final category = order['category_name'] as String? ?? (l10n.isIndonesian ? 'Layanan Ketok' : 'Ketok Service');
    final amount = order['price'];
    final price = amount == null
        ? (l10n.isIndonesian ? 'Harga akan dikonfirmasi' : 'Price to be confirmed')
        : 'Rp ${(amount as num).round()}';
    return _orderCard(
      order: order,
      title: category,
      schedule: scheduleText,
      address: order['lokasi'] as String? ?? (l10n.isIndonesian ? 'Lokasi belum tersedia' : 'Location not available'),
      price: price,
      status: l10n.isIndonesian ? 'Pesanan Baru' : 'New Order',
      icon: Icons.ac_unit_rounded,
      urgent: true,
    );
  }

  Widget _orderCard({
    required Map<String, dynamic> order,
    required String title,
    required String schedule,
    required String address,
    required String price,
    required String status,
    required IconData icon,
    required bool urgent,
  }) {
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Color(0x10000000), blurRadius: 6)],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _surfaceLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 29),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 4,
                          ),
                          color: _surfaceLow,
                          child: const Text(
                            'AIR CONDITIONER',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            color: urgent
                                ? const Color(0xFFD32F2F)
                                : _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 13,
                          color: _onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            schedule,
                            style: const TextStyle(
                              fontSize: 11,
                              color: _onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: _surfaceLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: _onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    address,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: _onSurfaceVariant,
                    ),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _declineOrder(order),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: _surfaceLow,
                    foregroundColor: _onSurface,
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(l10n.isIndonesian ? 'Tolak' : 'Decline'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _openOrderDetail(order, openEstimasi: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _darkPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.isIndonesian ? 'Detail & Estimasi' : 'Details & Estimate',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 6. TIPS & ARTIKEL SECTION
  Widget _buildTipsArtikelSection() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.isIndonesian ? 'Artikel & Tips' : 'Articles & Tips',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _onSurface,
            ),
          ),
          const SizedBox(height: 12),
          if (_loadingHomeData)
            const CircularProgressIndicator()
          else if (_tips.isEmpty)
            Text(l10n.isIndonesian ? 'Belum ada tips untuk ditampilkan.' : 'No tips to display yet.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _tips.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final tip = _tips[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipDetailScreen(tip: tip),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _borderColor.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _darkPrimary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.lightbulb_outline_rounded,
                            color: _darkPrimary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tip['judul'] as String,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: _onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tip['ringkasan'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: _onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: _onSurfaceVariant,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // 7. TESTIMONI PELANGGAN SECTION
  Widget _buildTestimoniSection() {
    final l10n = context.l10n;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.quickMenuReviews,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _onSurface,
                ),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    _unreadReviewCount = 0;
                  });
                  _markReviewsAsSeen();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UlasanMitraScreen()),
                  );
                  if (mounted) {
                    await _syncUnreadReviews();
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(50, 30),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.viewAll,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _darkPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_loadingHomeData)
          const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          )
        else if (_reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(l10n.isIndonesian ? 'Belum ada ulasan dari pelanggan.' : 'No reviews from customers yet.'),
          )
        else
          SizedBox(
            height: 130,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _reviews[index];
                return InkWell(
                  onTap: () async {
                    setState(() {
                      _unreadReviewCount = 0;
                    });
                    _markReviewsAsSeen();
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const UlasanMitraScreen()),
                    );
                    if (mounted) {
                      await _syncUnreadReviews();
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 280,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _surfaceCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _borderColor.withValues(alpha: 0.9),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFF59E0B),
                              size: 18,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${item['rating']}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _onSurface,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '"${item['komentar'] ?? (l10n.isIndonesian ? 'Pelanggan belum menulis komentar.' : 'Customer has not written a comment.')}"',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: _onSurface,
                            height: 1.3,
                          ),
                        ),
                        Text(
                          '${item['customer_name']} - ${l10n.customerLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: _onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ==================== PESANAN TAB CONTENT ====================
  Widget _buildPesananContent() {
    return PesananScreen(
      key: ValueKey(_pesananRefreshVersion),
      onNotificationTap: _openNotificationScreen,
    );
  }

  // ==================== CHAT TAB CONTENT ====================
  Widget _buildChatContent() {
    return ChatScreen(
      onNotificationTap: _openNotificationScreen,
    );
  }

  // ==================== PROFIL TAB CONTENT ====================
  Widget _buildProfileContent() {
    return ProfileScreen(
      userName: _userName,
      photoUrl: _photoUrl,
      userEmail: _userEmail,
      phoneNumber: _phoneNumber,
      approvalStatus: _approvalStatus,
      isOnline: _isOnline,
      onOnlineChanged: (value) {
        _toggleOnlineStatus();
      },
      onLogout: _handleLogout,
      onProfileUpdated: _initUserData,
      onNotificationTap: _openNotificationScreen,
    );
  }
}
