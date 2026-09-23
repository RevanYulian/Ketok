import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';
import '../services/app_config_service.dart';
import 'app.dart';
import 'quick_menu/jasa_detail_screen.dart';
import 'quick_menu/jasa_kategori_screen.dart';
import 'quick_menu/quick_menu_shared.dart';
import 'quick_menu/cari_jasa_screen.dart';
import 'quick_menu/tips_artikel_screen.dart';
import 'quick_menu/tips_detail_screen.dart';
import 'quick_menu/jasa_populer_screen.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  final _searchController = TextEditingController();
  late Future<List<_PopularService>> _popularServicesFuture;
  late Future<List<Map<String, dynamic>>> _tipsFuture;
  final String _searchTerm = '';

  static const _categories = [
    ('Teknisi & Perbaikan', Icons.home_repair_service_outlined),
    ('Kebersihan & Laundry', Icons.cleaning_services_outlined),
    ('Pertukangan & Bangunan', Icons.construction_outlined),
    ('Elektronik & Gadget', Icons.devices_other_outlined),
    ('Gaya Hidup & Perawatan', Icons.spa_outlined),
    ('Logistik & Lainnya', Icons.local_shipping_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _popularServicesFuture = _loadPopularServices();
    _tipsFuture = _loadTips();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: KetokResponsiveContent(
        child: Column(
          children: [
            Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const KetokScreenHeader(),
            ),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: _GreetingSection()),
                  SliverToBoxAdapter(
                    child: _HomeSearchBar(
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(builder: (_) => const CariJasaScreen()),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: _InfoBannerSection(
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (_) => const CariJasaScreen()),
                        ),
                      ),
                    ),
                  ),
            const SliverToBoxAdapter(
              child: _SectionTitle(title: 'Layanan Kami'),
            ),
            SliverToBoxAdapter(child: _CategoryGrid(categories: _categories)),
            SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Jasa Populer',
                onSeeAll: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const JasaPopulerScreen()),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<_PopularService>>(
                future: _popularServicesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final query = _searchTerm.trim().toLowerCase();
                  final services = (snapshot.data ?? [])
                      .where(
                        (service) =>
                            query.isEmpty ||
                            service.name.toLowerCase().contains(query) ||
                            service.company.toLowerCase().contains(query),
                      )
                      .toList();
                  if (snapshot.hasError || services.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Text(
                        'Belum ada jasa dari mitra yang tersedia.',
                        style: TextStyle(color: KetokColors.textMuted),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: services
                          .map(
                            (service) => _ServiceTile(
                              service: service,
                              onTap: () => _openService(context, service),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: _SectionTitle(
                title: 'Tips & Artikel',
                onSeeAll: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(builder: (_) => const TipsArtikelScreen()),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _tipsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(28),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final tips = snapshot.data ?? [];
                  if (snapshot.hasError || tips.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                      child: Text(
                        'Belum ada tips & artikel.',
                        style: TextStyle(color: KetokColors.textMuted),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Column(
                      children: tips.map((tip) {
                        return InkWell(
                          onTap: () => Navigator.push<void>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TipsDetailScreen(tip: tip),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF3F4F6)),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x0A000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tip['judul'] as String? ?? 'Tips',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  tip['ringkasan'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: KetokColors.textMuted,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Row(
                                  children: [
                                    Text(
                                      'Baca selengkapnya',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: KetokColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 4),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: KetokColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),
);
}

  Future<List<_PopularService>> _loadPopularServices() async {
    final client = Supabase.instance.client;
    final rows = await client
        .from('mitra_layanan')
        .select(
          'id_layanan_mitra, mitra_id, katagori_id, nama_jasa, deskripsi, tarif_mulai, satuan_tarif, biaya_kunjungan, foto_url',
        )
        .eq('aktif', true)
        .order('diperbarui_pada', ascending: false)
        .limit(8);
    if (rows.isEmpty) return [];

    final mitraIds = rows.map((row) => row['mitra_id'] as int).toSet().toList();
    final categoryIds = rows
        .map((row) => row['katagori_id'] as int)
        .toSet()
        .toList();
    final users = await client
        .from('users')
        .select('id_user, nama')
        .inFilter('id_user', mitraIds);
    final profiles = await client
        .from('mitra_profil')
        .select('user_id, nama_usaha')
        .inFilter('user_id', mitraIds);
    final categories = await client
        .from('kategori_layanan')
        .select('id_katagori, nama_katagori, kelompok, deskripsi')
        .inFilter('id_katagori', categoryIds);
    final userNames = {
      for (final row in users)
        row['id_user'] as int: row['nama'] as String? ?? 'Mitra Ketok',
    };
    final companies = {
      for (final row in profiles)
        row['user_id'] as int: row['nama_usaha'] as String? ?? '',
    };
    final categoryRows = {
      for (final row in categories) row['id_katagori'] as int: row,
    };

    return rows.map((row) {
      final category = categoryRows[row['katagori_id']];
      final categoryName =
          category?['nama_katagori'] as String? ?? 'Layanan Ketok';
      final menuName = category?['kelompok'] as String? ?? categoryName;
      final rawNamaJasa = (row['nama_jasa'] as String?)?.trim();
      final displayName = (rawNamaJasa != null && rawNamaJasa.isNotEmpty)
          ? rawNamaJasa
          : menuName;
      final rawDesc = (row['deskripsi'] as String?)?.trim();
      final displayDesc = (rawDesc != null && rawDesc.isNotEmpty)
          ? rawDesc
          : (category?['deskripsi'] as String? ?? 'Layanan profesional dari mitra.');

      return _PopularService(
        name: displayName,
        company: companies[row['mitra_id']]?.isNotEmpty == true
            ? companies[row['mitra_id']]!
            : userNames[row['mitra_id']] ?? 'Mitra Ketok',
        description: displayDesc,
        price: row['tarif_mulai'],
        visitPrice: row['biaya_kunjungan'] ?? 50000,
        unit: row['satuan_tarif'] as String? ?? 'per layanan',
        mitraId: row['mitra_id'] as int,
        categoryId: row['katagori_id'] as int,
        categoryName: menuName,
        icon: _iconForCategory(categoryName),
        photoUrl: row['foto_url'] as String?,
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadTips() async {
    try {
      final rows = await Supabase.instance.client
          .from('tips_artikel')
          .select('id_tips, judul, ringkasan, dibuat_pada')
          .eq('aktif', true)
          .order('dibuat_pada', ascending: false)
          .limit(3);
      return rows;
    } catch (_) {
      return [];
    }
  }

  IconData _iconForCategory(String name) {
    final normalized = name.toLowerCase();
    if (normalized.contains('ac')) return Icons.ac_unit_rounded;
    if (normalized.contains('listrik')) {
      return Icons.electrical_services_rounded;
    }
    if (normalized.contains('mesin cuci')) {
      return Icons.local_laundry_service_rounded;
    }
    if (normalized.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.handyman_rounded;
  }

  void _openService(BuildContext context, _PopularService service) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => JasaDetailScreen(
          service: {
            'nama_jasa': service.name,
            'deskripsi': service.description,
            'harga_mulai': service.price,
            'biaya_kunjungan': service.visitPrice,
            'katagori_id': service.categoryId,
            'mitra_id': service.mitraId,
            'foto_url': service.photoUrl,
          },
          categoryName: service.categoryName,
          icon: service.icon,
        ),
      ),
    );
  }
}

class _PopularService {
  final String name;
  final String company;
  final String description;
  final dynamic price;
  final dynamic visitPrice;
  final String unit;
  final int categoryId;
  final String categoryName;
  final IconData icon;
  final String? photoUrl;
  final int mitraId;

  const _PopularService({
    required this.name,
    required this.company,
    required this.description,
    required this.price,
    required this.visitPrice,
    required this.unit,
    required this.categoryId,
    required this.categoryName,
    required this.icon,
    required this.mitraId,
    this.photoUrl,
  });
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo, Pengguna Ketok',
          style: TextStyle(color: KetokColors.textMuted),
        ),
        SizedBox(height: 2),
        Text(
          'Butuh bantuan hari ini?',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionTitle({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
    child: Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            child: const Text('Lihat Semua'),
          ),
      ],
    ),
  );
}

class _HomeSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const _HomeSearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: KetokColors.primary.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.search_rounded,
                      color: KetokColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Cari jasa, tukang, atau layanan...',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBannerSection extends StatefulWidget {
  final VoidCallback onTap;
  const _InfoBannerSection({required this.onTap});

  @override
  State<_InfoBannerSection> createState() => _InfoBannerSectionState();
}

class _InfoBannerSectionState extends State<_InfoBannerSection> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;
  int _bannerCount = 3;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startTimer();
  }

  void _startTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted || !_pageController.hasClients || _bannerCount <= 1) return;
      final nextPage = (_currentPage + 1) % _bannerCount;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        final bannerUrl = config?.bannerPromoUrl;
        final hasCustomBanner = bannerUrl != null &&
            (bannerUrl.startsWith('http://') || bannerUrl.startsWith('https://'));

        final banners = <Widget>[
          if (hasCustomBanner)
            _buildImageBanner(bannerUrl)
          else
            _buildGradientBanner(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              tag: 'PROMO SPESIAL',
              tagColor: const Color(0xFF38BDF8),
              title: 'Diskon 30% Layanan Pertama',
              subtitle: 'Khusus pengguna baru Ketok. Tukang & teknisi profesional bergaransi.',
              icon: Icons.handyman_rounded,
            ),
          _buildGradientBanner(
            gradient: const LinearGradient(
              colors: [Color(0xFF065F46), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            tag: 'LAYANAN CEPAT',
            tagColor: const Color(0xFF34D399),
            title: 'Teknisi Siap Datang Cepat',
            subtitle: 'Perbaikan darurat AC, pipa bocor & kelistrikan ditangani dalam hitungan jam.',
            icon: Icons.flash_on_rounded,
          ),
          _buildGradientBanner(
            gradient: const LinearGradient(
              colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            tag: 'GARANSI LAYANAN',
            tagColor: const Color(0xFFA5B4FC),
            title: 'Tarif Pasti & Garansi Servis',
            subtitle: 'Transparan tanpa biaya tersembunyi dengan jaminan servis hingga 30 hari.',
            icon: Icons.verified_user_rounded,
          ),
        ];

        _bannerCount = banners.length;

        return Column(
          children: [
            SizedBox(
              height: 160,
              child: PageView.builder(
                controller: _pageController,
                itemCount: banners.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                  _startTimer();
                },
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: banners[index],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(banners.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  height: 5,
                  width: isActive ? 20 : 6,
                  decoration: BoxDecoration(
                    color: isActive ? KetokColors.primary : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageBanner(String url) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: AspectRatio(
          aspectRatio: 16 / 7,
          child: Image.network(
            url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildGradientBanner(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              tag: 'PROMO SPESIAL',
              tagColor: const Color(0xFF38BDF8),
              title: 'Diskon 30% Layanan Pertama',
              subtitle: 'Khusus pengguna baru Ketok. Tukang & teknisi terpercaya.',
              icon: Icons.handyman_rounded,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGradientBanner({
    required LinearGradient gradient,
    required String tag,
    required Color tagColor,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.12,
                child: Icon(icon, size: 100, color: Colors.white),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          color: tagColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<(String, IconData)> categories;
  const _CategoryGrid({required this.categories});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    child: GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => JasaKategoriScreen(
                categoryName: category.$1,
                icon: category.$2,
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KetokColors.surfaceLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    category.$2,
                    size: 22,
                    color: const Color(0xFF030813),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  category.$1,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF191C1E),
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

class _ServiceTile extends StatelessWidget {
  final _PopularService service;
  final VoidCallback onTap;

  const _ServiceTile({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Compact thumbnail (84 x 84)
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: service.photoUrl != null
                            ? Image.network(
                                service.photoUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: KetokColors.primary.withValues(alpha: 0.05),
                                  child: Icon(service.icon, size: 36, color: KetokColors.primary),
                                ),
                              )
                            : Container(
                                color: KetokColors.primary.withValues(alpha: 0.05),
                                child: Icon(service.icon, size: 36, color: KetokColors.primary),
                              ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Service detail info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  service.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.star_rounded, size: 14, color: Color(0xFFD97706)),
                                    SizedBox(width: 3),
                                    Text(
                                      '4.9',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Row(
                            children: [
                              const Icon(
                                Icons.storefront_outlined,
                                size: 14,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  service.company,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            service.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF94A3B8),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 10),

                // Clean Footer row with Price and Visit badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Mulai dari',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            formatServicePrice(service.price),
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Kunjungan: ${formatFixedPrice(service.visitPrice)}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
