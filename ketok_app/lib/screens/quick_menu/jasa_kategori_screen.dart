import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'jasa_detail_screen.dart';
import 'quick_menu_shared.dart';

class JasaKategoriScreen extends StatefulWidget {
  final String categoryName;
  final IconData icon;

  const JasaKategoriScreen({
    super.key,
    required this.categoryName,
    required this.icon,
  });

  @override
  State<JasaKategoriScreen> createState() => _JasaKategoriScreenState();
}

class _JasaKategoriScreenState extends State<JasaKategoriScreen> {
  late Future<List<Map<String, dynamic>>> _servicesFuture;

  @override
  void initState() {
    super.initState();
    _servicesFuture = _loadServices();
  }

  List<String> _getMatchingGroups(String categoryName) {
    switch (categoryName.toLowerCase().trim()) {
      case 'teknisi & perbaikan':
        return ['perbaikan & instalasi rumah', 'teknisi & perbaikan'];
      case 'kebersihan & laundry':
        return ['kebersihan', 'kebersihan & laundry'];
      case 'pertukangan & bangunan':
        return ['renovasi & konstruksi ringan', 'pertukangan & bangunan'];
      case 'elektronik & gadget':
        return ['elektronik & gadget'];
      case 'gaya hidup & perawatan':
        return ['gaya hidup & perawatan'];
      case 'logistik & lainnya':
        return ['outdoor & kendaraan', 'logistik & lainnya'];
      default:
        return [categoryName.toLowerCase().trim()];
    }
  }

  Future<List<Map<String, dynamic>>> _loadServices() async {
    final rows = await Supabase.instance.client
        .from('mitra_layanan')
        .select('''
          id_layanan_mitra,
          mitra_id,
          katagori_id,
          nama_jasa,
          deskripsi,
          tarif_mulai,
          tarif_selesai,
          biaya_kunjungan,
          satuan_tarif,
          foto_url,
          kategori_layanan!inner ( id_katagori, nama_katagori, kelompok ),
          users!inner ( id_user, nama, foto_profil )
        ''')
        .eq('aktif', true)
        .order('tarif_mulai');
        
    final targetCat = widget.categoryName.toLowerCase().trim();
    final matchingGroups = _getMatchingGroups(widget.categoryName);

    final filtered = rows.where((row) {
      final kat = row['kategori_layanan'] as Map<String, dynamic>? ?? {};
      final namaKat = (kat['nama_katagori'] as String? ?? '').toLowerCase().trim();
      final kelompok = (kat['kelompok'] as String? ?? '').toLowerCase().trim();

      return namaKat == targetCat ||
          kelompok == targetCat ||
          matchingGroups.contains(kelompok) ||
          matchingGroups.contains(namaKat);
    }).toList();

    return filtered.map((row) {
      final kat = row['kategori_layanan'] as Map<String, dynamic>? ?? {};
      final namaKat = kat['nama_katagori'] as String? ?? widget.categoryName;
      final rawNamaJasa = (row['nama_jasa'] as String?)?.trim();
      final title = (rawNamaJasa != null && rawNamaJasa.isNotEmpty)
          ? rawNamaJasa
          : namaKat;
      final rawDeskripsi = (row['deskripsi'] as String?)?.trim();
      final desc = (rawDeskripsi != null && rawDeskripsi.isNotEmpty)
          ? rawDeskripsi
          : 'Layanan profesional dari mitra.';

      return <String, dynamic>{
        'id_jasa': row['id_layanan_mitra'],
        'mitra_id': row['mitra_id'],
        'katagori_id': row['katagori_id'],
        'nama_jasa': title,
        'deskripsi': desc,
        'harga_mulai': row['tarif_mulai'],
        'harga_selesai': row['tarif_selesai'],
        'biaya_kunjungan': row['biaya_kunjungan'] ?? 50000,
        'satuan_tarif': row['satuan_tarif'] ?? 'per layanan',
        'foto_url': row['foto_url'],
        'mitra_nama': (row['users'] as Map?)?['nama'] ?? 'Mitra Ketok',
      };
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() => _servicesFuture = _loadServices());
    await _servicesFuture;
  }

  @override
  Widget build(BuildContext context) => QuickMenuScaffold(
    title: widget.categoryName,
    icon: widget.icon,
    onRefresh: _refresh,
    child: FutureBuilder<List<Map<String, dynamic>>>(
      future: _servicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return _ErrorState(
            message:
                'Jasa belum dapat dimuat. Pastikan migration seed sudah dijalankan.',
            onRetry: _refresh,
          );
        }
        final services = snapshot.data ?? [];
        if (services.isEmpty) {
          return const QuickMenuEmptyState(
            icon: Icons.handyman_outlined,
            title: 'Belum ada jasa',
            subtitle: 'Jasa pada kategori ini akan muncul setelah tersedia.',
          );
        }
        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: services.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _ServiceCard(
            service: services[index],
            categoryName: widget.categoryName,
            icon: widget.icon,
          ),
        );
      },
    ),
  );
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 46, color: Colors.grey),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    ),
  );
}

class _ServiceCard extends StatelessWidget {
  final Map<String, dynamic> service;
  final String categoryName;
  final IconData icon;

  const _ServiceCard({
    required this.service,
    required this.categoryName,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final photoUrl = service['foto_url'] as String?;
    final title = service['nama_jasa'] as String? ?? 'Jasa Ketok';
    final company = service['mitra_nama'] as String? ?? 'Mitra Ketok';
    final desc = service['deskripsi'] as String? ?? 'Layanan profesional dari mitra.';
    final price = service['harga_mulai'];
    final visitPrice = service['biaya_kunjungan'] ?? 50000;

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
          onTap: () => Navigator.push<void>(
            context,
            MaterialPageRoute(
              builder: (_) => JasaDetailScreen(
                service: service,
                categoryName: categoryName,
                icon: icon,
              ),
            ),
          ),
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
                        child: photoUrl != null
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: KetokColors.primary.withValues(alpha: 0.05),
                                  child: Icon(icon, size: 36, color: KetokColors.primary),
                                ),
                              )
                            : Container(
                                color: KetokColors.primary.withValues(alpha: 0.05),
                                child: Icon(icon, size: 36, color: KetokColors.primary),
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
                                  title,
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
                                  company,
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
                            desc,
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
                            formatServicePrice(price),
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
                            'Kunjungan: ${formatFixedPrice(visitPrice)}',
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
