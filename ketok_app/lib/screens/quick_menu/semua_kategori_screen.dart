import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import 'jasa_kategori_screen.dart';

class SemuaKategoriScreen extends StatefulWidget {
  const SemuaKategoriScreen({super.key});

  @override
  State<SemuaKategoriScreen> createState() => _SemuaKategoriScreenState();
}

class _CategoryItem {
  final String name;
  final IconData icon;
  final int subCount;

  const _CategoryItem(this.name, this.icon, [this.subCount = 0]);
}

class _SemuaKategoriScreenState extends State<SemuaKategoriScreen> {
  late Future<List<_CategoryItem>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  Future<void> _refresh() async {
    setState(() {
      _categoriesFuture = _loadCategories();
    });
    await _categoriesFuture;
  }


  Future<List<_CategoryItem>> _loadCategories() async {
    final client = Supabase.instance.client;
    final Map<String, int> subCounts = {};

    // Hitung jumlah sub-layanan aktif per kelompok kategori utama
    try {
      final rows = await client
          .from('kategori_layanan')
          .select('kelompok');
      for (final r in rows) {
        final name = (r['kelompok'] as String?)?.trim();
        if (name != null && name.isNotEmpty) {
          subCounts[name] = (subCounts[name] ?? 0) + 1;
        }
      }
    } catch (_) {}

    // Tepat 6 kategori utama yang sama dengan halaman beranda
    const standardCategories = [
      ('Teknisi & Perbaikan', Icons.home_repair_service_outlined),
      ('Kebersihan & Laundry', Icons.cleaning_services_outlined),
      ('Pertukangan & Bangunan', Icons.construction_outlined),
      ('Elektronik & Gadget', Icons.devices_other_outlined),
      ('Gaya Hidup & Perawatan', Icons.spa_outlined),
      ('Logistik & Lainnya', Icons.local_shipping_outlined),
    ];

    return standardCategories
        .map(
          (cat) => _CategoryItem(
            cat.$1,
            cat.$2,
            subCounts[cat.$1] ?? 0,
          ),
        )
        .toList();
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
          'Semua Kategori',
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
        child: FutureBuilder<List<_CategoryItem>>(
          future: _categoriesFuture,
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
                        'Gagal memuat kategori: ${snapshot.error}',
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

            final categories = snapshot.data ?? [];
            if (categories.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.category_outlined,
                        size: 52,
                        color: Color(0xFFD1D5DB),
                      ),
                      SizedBox(height: 14),
                      Text(
                        'Belum Ada Kategori',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Kategori utama akan tampil di sini saat ditambahkan oleh admin.',
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
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFF3F4F6)),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.grid_view_rounded,
                            color: Color(0xFF2563EB),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Kategori Layanan Ketok',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${categories.length} kategori utama tersedia untuk kebutuhan Anda',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: KetokColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: categories.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.95,
                    ),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      return InkWell(
                        onTap: () => Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JasaKategoriScreen(
                              categoryName: item.name,
                              icon: item.icon,
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
                                  item.icon,
                                  size: 22,
                                  color: const Color(0xFF030813),
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                item.name,
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
                              if (item.subCount > 0) ...[
                                const SizedBox(height: 3),
                                Text(
                                  '${item.subCount} layanan',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    color: KetokColors.textMuted,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
