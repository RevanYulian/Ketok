import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'jasa_detail_screen.dart';
import 'quick_menu_shared.dart';

class CariJasaScreen extends StatefulWidget {
  const CariJasaScreen({super.key});

  @override
  State<CariJasaScreen> createState() => _CariJasaScreenState();
}

class _CariJasaScreenState extends State<CariJasaScreen> {
  final _searchController = TextEditingController();
  late Future<List<_SearchService>> _servicesFuture;
  String _query = '';
  String _sort = 'Semua';

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadServices();
    _searchController.addListener(_handleSearchChanged);
  }

  @override
  void dispose() {
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    setState(() => _query = _searchController.text.trim().toLowerCase());
  }

  Future<List<_SearchService>> _loadServices() async {
    final client = Supabase.instance.client;
    final rows = await client
        .from('mitra_layanan')
        .select('mitra_id, katagori_id, nama_jasa, deskripsi, tarif_mulai, satuan_tarif, biaya_kunjungan, foto_url')
        .eq('aktif', true)
        .order('diperbarui_pada', ascending: false);
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
      final catName = category?['nama_katagori'] as String? ?? 'Layanan Ketok';
      final rawNamaJasa = (row['nama_jasa'] as String?)?.trim();
      final name = (rawNamaJasa != null && rawNamaJasa.isNotEmpty) ? rawNamaJasa : catName;
      final rawDesc = (row['deskripsi'] as String?)?.trim();
      final desc = (rawDesc != null && rawDesc.isNotEmpty)
          ? rawDesc
          : (category?['deskripsi'] as String? ?? 'Layanan profesional dari mitra Ketok.');
      final company = companies[row['mitra_id']];
      return _SearchService(
        name: name,
        company: company?.isNotEmpty == true
            ? company!
            : userNames[row['mitra_id']] ?? 'Mitra Ketok',
        description: desc,
        price: row['tarif_mulai'],
        visitPrice: row['biaya_kunjungan'] ?? 50000,
        unit: row['satuan_tarif'] as String? ?? 'per layanan',
        categoryId: row['katagori_id'] as int,
        categoryName: category?['kelompok'] as String? ?? catName,
        icon: _iconFor(catName),
        photoUrl: row['foto_url'] as String?,
        mitraId: row['mitra_id'] as int,
      );
    }).toList();
  }

  List<_SearchService> _filtered(List<_SearchService> services) {
    var list = services;
    if (_query.isNotEmpty) {
      list = list
          .where(
            (service) =>
                service.name.toLowerCase().contains(_query) ||
                service.company.toLowerCase().contains(_query) ||
                service.description.toLowerCase().contains(_query) ||
                service.categoryName.toLowerCase().contains(_query),
          )
          .toList();
    }
    if (_sort == 'Harga Termurah') {
      list = List.of(list)..sort((a, b) {
        final pa = (a.price is num) ? (a.price as num) : (num.tryParse(a.price.toString()) ?? 0);
        final pb = (b.price is num) ? (b.price as num) : (num.tryParse(b.price.toString()) ?? 0);
        return pa.compareTo(pb);
      });
    }
    return list;
  }

  IconData _iconFor(String name) {
    final value = name.toLowerCase();
    if (value.contains('ac')) return Icons.ac_unit_rounded;
    if (value.contains('listrik')) return Icons.electrical_services_rounded;
    if (value.contains('mesin cuci')) {
      return Icons.local_laundry_service_rounded;
    }
    if (value.contains('clean')) return Icons.cleaning_services_rounded;
    return Icons.handyman_rounded;
  }

  void _openDetail(_SearchService service) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => JasaDetailScreen(
          service: service.toMap(),
          categoryName: service.categoryName,
          icon: service.icon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: const Color(0xFF1B1D2B),
          tooltip: 'Kembali',
        ),
        titleSpacing: 0,
        title: Container(
          height: 42,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'Cari jasa, tukang, atau layanan...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Color(0xFF64748B),
                size: 20,
              ),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: _searchController.clear,
                      icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFF94A3B8)),
                    ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => setState(() => _servicesFuture = _loadServices()),
            icon: const Icon(Icons.refresh_rounded, size: 22),
            color: const Color(0xFF64748B),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: SafeArea(
        child: FutureBuilder<List<_SearchService>>(
          future: _servicesFuture,
          builder: (context, snapshot) {
            final services = _filtered(snapshot.data ?? []);
            final suggestions = _query.isEmpty
                ? <_SearchService>[]
                : services.take(4).toList();

            return Column(
              children: [
                _buildFilters(),
                if (suggestions.isNotEmpty && _query.length < 3)
                  _SuggestionPanel(
                    suggestions: suggestions,
                    onSelected: (service) {
                      _searchController.text = service.name;
                      _openDetail(service);
                    },
                  ),
                Expanded(
                  child: snapshot.connectionState == ConnectionState.waiting
                      ? const Center(child: CircularProgressIndicator())
                      : snapshot.hasError
                      ? const QuickMenuEmptyState(
                          icon: Icons.cloud_off_outlined,
                          title: 'Pencarian belum tersedia',
                          subtitle: 'Pastikan data layanan mitra sudah tersedia.',
                        )
                      : services.isEmpty
                      ? const QuickMenuEmptyState(
                          icon: Icons.search_off_rounded,
                          title: 'Jasa tidak ditemukan',
                          subtitle: 'Coba gunakan kata kunci lain.',
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          itemCount: services.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 12),
                          itemBuilder: (context, index) => _ResultCard(
                            service: services[index],
                            onTap: () => _openDetail(services[index]),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilters() {
    final filters = [
      ('Semua', Icons.grid_view_rounded),
      ('Terdekat', Icons.near_me_outlined),
      ('Rating 4.5+', Icons.star_rounded),
      ('Harga Termurah', Icons.sell_outlined),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final item = filters[index];
            final isSelected = _sort == item.$1;
            return InkWell(
              onTap: () => setState(() => _sort = item.$1),
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? KetokColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? KetokColors.primary : const Color(0xFFE2E8F0),
                    width: 1.1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: KetokColors.primary.withValues(alpha: 0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.$2,
                      size: 14,
                      color: isSelected
                          ? (item.$1 == 'Rating 4.5+' ? const Color(0xFFFBBF24) : Colors.white)
                          : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.$1,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SuggestionPanel extends StatelessWidget {
  final List<_SearchService> suggestions;
  final ValueChanged<_SearchService> onSelected;

  const _SuggestionPanel({required this.suggestions, required this.onSelected});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFE2E8F0)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      children: suggestions
          .map(
            (service) => ListTile(
              dense: true,
              leading: Icon(service.icon, size: 18, color: KetokColors.primary),
              title: Text(
                service.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              subtitle: Text(
                service.company,
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              trailing: const Icon(Icons.north_west_rounded, size: 14, color: Color(0xFF94A3B8)),
              onTap: () => onSelected(service),
            ),
          )
          .toList(),
    ),
  );
}

class _ResultCard extends StatelessWidget {
  final _SearchService service;
  final VoidCallback onTap;

  const _ResultCard({
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
                    // Compact, tasteful thumbnail (84 x 84)
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

                // Footer row with Price and Action Buttons
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

class _SearchService {
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

  const _SearchService({
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

  Map<String, dynamic> toMap() => {
    'nama_jasa': name,
    'deskripsi': description,
    'harga_mulai': price,
    'biaya_kunjungan': visitPrice,
    'katagori_id': categoryId,
    'mitra_id': mitraId,
    'foto_url': photoUrl,
  };
}
