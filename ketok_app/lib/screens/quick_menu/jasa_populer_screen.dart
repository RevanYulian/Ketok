import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'jasa_detail_screen.dart';
import 'quick_menu_shared.dart';

class JasaPopulerScreen extends StatefulWidget {
  const JasaPopulerScreen({super.key});

  @override
  State<JasaPopulerScreen> createState() => _JasaPopulerScreenState();
}

class _PopularServiceItem {
  final int id;
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

  const _PopularServiceItem({
    required this.id,
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

class _JasaPopulerScreenState extends State<JasaPopulerScreen> {
  late Future<List<_PopularServiceItem>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadPopularServices();
  }

  Future<void> _refresh() async {
    setState(() {
      _servicesFuture = _loadPopularServices();
    });
    await _servicesFuture;
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

  Future<List<_PopularServiceItem>> _loadPopularServices() async {
    final client = Supabase.instance.client;
    final rows = await client
        .from('mitra_layanan')
        .select(
          'id_layanan_mitra, mitra_id, katagori_id, nama_jasa, deskripsi, tarif_mulai, satuan_tarif, biaya_kunjungan, foto_url',
        )
        .eq('aktif', true)
        .order('diperbarui_pada', ascending: false)
        .limit(15);

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

      return _PopularServiceItem(
        id: row['id_layanan_mitra'] as int,
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

  void _openService(BuildContext context, _PopularServiceItem service) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Jasa Populer',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<_PopularServiceItem>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Gagal memuat jasa populer: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: KetokColors.textMuted),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _refresh,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                ),
              );
            }

            final services = snapshot.data ?? [];
            if (services.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.star_outline_rounded,
                        size: 52,
                        color: Color(0xFFD1D5DB),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Belum Ada Jasa Populer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Layanan dari mitra akan ditampilkan di sini saat tersedia.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: KetokColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: services.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _PopularServiceCard(
                    service: service,
                    onTap: () => _openService(context, service),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PopularServiceCard extends StatelessWidget {
  final _PopularServiceItem service;
  final VoidCallback onTap;

  const _PopularServiceCard({
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
