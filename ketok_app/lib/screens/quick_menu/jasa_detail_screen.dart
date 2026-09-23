import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../widgets/ketok_colors.dart';
import '../chat_screen.dart';
import 'jasa_booking_screen.dart';
import 'quick_menu_shared.dart';

const _detailBackground = Color(0xFFF8F9FB);

class JasaDetailScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final String categoryName;
  final IconData icon;

  const JasaDetailScreen({
    super.key,
    required this.service,
    required this.categoryName,
    required this.icon,
  });

  @override
  State<JasaDetailScreen> createState() => _JasaDetailScreenState();
}

class _JasaDetailScreenState extends State<JasaDetailScreen> {
  late Future<List<Map<String, dynamic>>> _reviewsFuture;
  late Future<Map<String, dynamic>> _mitraDataFuture;

  @override
  void initState() {
    super.initState();
    _reviewsFuture = _loadReviews();
    _mitraDataFuture = _loadMitraData();
  }

  Future<Map<String, dynamic>> _loadMitraData() async {
    final supabase = Supabase.instance.client;
    final mitraId = widget.service['mitra_id'];
    
    final results = await Future.wait([
      supabase.from('users').select('nama, foto_profil').eq('id_user', mitraId).maybeSingle(),
      supabase.from('mitra_jadwal_kerja').select('*').eq('mitra_id', mitraId).eq('aktif', true).order('hari'),
      supabase.from('mitra_sertifikasi').select('*').eq('mitra_id', mitraId).order('nama_sertifikasi'),
    ]);
    
    return {
      'profile': results[0] ?? {},
      'schedule': results[1] as List,
      'certificates': results[2] as List,
    };
  }

  Future<List<Map<String, dynamic>>> _loadReviews() async {
    final supabase = Supabase.instance.client;
    final res = await supabase.from('ulasan').select('''
      rating, komentar, pesanan!inner(mitra_id, katagori_id, pengguna_id, users!pesanan_pengguna_id_fkey(nama))
    ''').eq('pesanan.mitra_id', widget.service['mitra_id']).eq('pesanan.katagori_id', widget.service['katagori_id']);
    return List<Map<String, dynamic>>.from(res);
  }

  String get _name => widget.service['nama_jasa'] as String? ?? 'Jasa Ketok';
  String get _description =>
      widget.service['deskripsi'] as String? ??
      'Layanan profesional dari mitra Ketok.';
  String get _price => formatServicePrice(widget.service['harga_mulai']);
  String get _visitPrice => formatFixedPrice(widget.service['biaya_kunjungan'] ?? 50000);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _detailBackground,
    appBar: AppBar(
      backgroundColor: _detailBackground,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_rounded),
        tooltip: 'Kembali',
      ),
      title: const Text(
        'Detail Layanan',
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Bagikan layanan',
        ),
      ],
    ),
    body: SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(),
                const SizedBox(height: 16),
                Text(
                  _name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _description,
                  style: const TextStyle(
                    color: KetokColors.textMuted,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                _buildPriceCard(),
                const SizedBox(height: 24),
                FutureBuilder<Map<String, dynamic>>(
                  future: _mitraDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          'Gagal memuat profil mitra: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }
                    if (!snapshot.hasData) return const SizedBox();
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Profil Mitra'),
                        const SizedBox(height: 8),
                        _buildMitraProfile(snapshot.data!['profile'] as Map<String, dynamic>),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                ),

                _buildSectionTitle('Alur Pengerjaan'),
                const SizedBox(height: 8),
                _buildSteps(),
                const SizedBox(height: 24),

                FutureBuilder<Map<String, dynamic>>(
                  future: _mitraDataFuture,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.hasError) return const SizedBox();
                    final data = snapshot.data!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Jadwal & Jam Kerja'),
                        const SizedBox(height: 8),
                        _buildSchedule(data['schedule'] as List<dynamic>),
                        const SizedBox(height: 24),
                        
                        _buildSectionTitle('Sertifikasi & Dokumen'),
                        const SizedBox(height: 8),
                        _buildCertificates(data['certificates'] as List<dynamic>),
                        const SizedBox(height: 24),
                      ],
                    );
                  }
                ),
                _buildSectionTitle('Ulasan Pelanggan'),
                const SizedBox(height: 4),
                const Text(
                  'Rating layanan dari pengguna Ketok',
                  style: TextStyle(color: KetokColors.textMuted, fontSize: 12),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: _reviewsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final reviews = snapshot.data ?? [];
                    if (reviews.isEmpty) {
                      return const Text(
                        'Belum ada ulasan untuk jasa ini.',
                        style: TextStyle(color: KetokColors.textMuted, fontStyle: FontStyle.italic),
                      );
                    }
                    return Column(
                      children: reviews.map((r) {
                        final pesanan = r['pesanan'] as Map;
                        final user = pesanan['users'] as Map;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _ReviewCard(
                            name: user['nama'] ?? 'Pelanggan',
                            text: r['komentar'] ?? 'Tidak ada komentar',
                            rating: r['rating'] as int? ?? 5,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: _detailBackground,
                border: const Border(top: BorderSide(color: Color(0xFFE5E7EB))),
              ),
              child: Row(
                children: [
                Expanded(
                  flex: 1,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      String mitraName = 'Mitra Ketok';
                      String? photoUrl;
                      try {
                        final data = await _mitraDataFuture;
                        final profile = data['profile'] as Map<String, dynamic>?;
                        if (profile != null) {
                          if (profile['nama'] != null) {
                            mitraName = profile['nama'] as String;
                          }
                          if (profile['foto_profil'] != null) {
                            photoUrl = profile['foto_profil'] as String;
                          }
                        }
                      } catch (_) {}

                      if (!context.mounted) return;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            initialMitraName: mitraName,
                            initialMitraPhotoUrl: photoUrl,
                            initialServiceName: _name,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Chat'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF171717),
                      side: const BorderSide(color: Color(0xFF171717)),
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: () => _showBookingConfirmation(context),
                    icon: const Icon(Icons.handyman_outlined),
                    label: const Text('Panggil & Cek'),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF171717),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    ),
  );

  Widget _buildHero() => Container(
    height: 190,
    width: double.infinity,
    decoration: BoxDecoration(
      color: KetokColors.surfaceLow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: KetokColors.border),
      image: widget.service['foto_url'] != null
          ? DecorationImage(
              image: NetworkImage(widget.service['foto_url']),
              fit: BoxFit.cover,
            )
          : null,
    ),
    child: Stack(
      children: [
        if (widget.service['foto_url'] == null)
          Center(child: Icon(widget.icon, size: 82, color: KetokColors.primary)),
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: KetokColors.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              widget.categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        Positioned(
          left: 12,
          bottom: 12,
          child: _HeroBadge(
            icon: Icons.verified_rounded,
            label: 'Garansi layanan',
          ),
        ),
        Positioned(
          right: 12,
          bottom: 12,
          child: _HeroBadge(icon: Icons.star_rounded, label: '4.9 Rating'),
        ),
      ],
    ),
  );

  Widget _buildPriceCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: KetokColors.border),
    ),
    child: Column(
      children: [
        Row(
          children: [
            const Icon(Icons.payments_outlined, color: KetokColors.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Kisaran Harga',
                style: TextStyle(color: KetokColors.textMuted),
              ),
            ),
            Text(
              _price,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: KetokColors.border),
        ),
        Row(
          children: [
            const Icon(Icons.directions_car_filled_outlined, color: KetokColors.primary),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Biaya Kunjungan',
                style: TextStyle(color: KetokColors.textMuted),
              ),
            ),
            Text(
              _visitPrice,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildMitraProfile(Map<String, dynamic> profile) {
    return QuickMenuCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: profile['foto_profil'] != null ? NetworkImage(profile['foto_profil']) : null,
            child: profile['foto_profil'] == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile['nama'] ?? 'Mitra Ketok',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 2),
                const Text('Mitra Terverifikasi', style: TextStyle(color: KetokColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchedule(List<dynamic> schedules) {
    if (schedules.isEmpty) {
      return const Text('Jadwal belum diatur.', style: TextStyle(color: KetokColors.textMuted));
    }
    const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return QuickMenuCard(
      child: Column(
        children: schedules.map((s) {
          final dayName = days[(s['hari'] as int) - 1];
          final start = (s['jam_mulai'] as String).substring(0, 5);
          final end = (s['jam_selesai'] as String).substring(0, 5);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text('$start - $end', style: const TextStyle(color: KetokColors.textMuted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCertificates(List<dynamic> certificates) {
    if (certificates.isEmpty) {
      return const Text('Belum ada sertifikasi.', style: TextStyle(color: KetokColors.textMuted));
    }
    return Column(
      children: certificates.map((c) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: QuickMenuCard(
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: KetokColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c['nama_sertifikasi'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text(c['penerbit'] ?? '', style: const TextStyle(fontSize: 12, color: KetokColors.textMuted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
  );

  Widget _buildSteps() => QuickMenuCard(
    child: Column(
      children: const [
        _Step(number: '1', title: 'Pilih Paket & Jadwal'),
        _Step(number: '2', title: 'Teknisi Datang ke Lokasi'),
        _Step(number: '3', title: 'Pengecekan & Pengerjaan'),
        _Step(number: '4', title: 'Pembayaran & Garansi'),
      ],
    ),
  );

  void _showBookingConfirmation(BuildContext context) {
    Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (_) => JasaBookingScreen(
          service: widget.service,
          categoryName: widget.categoryName,
          icon: widget.icon,
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: KetokColors.primary),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  final String number;
  final String title;

  const _Step({required this.number, required this.title});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: KetokColors.primary,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String text;
  final int rating;

  const _ReviewCard({required this.name, required this.text, required this.rating});

  @override
  Widget build(BuildContext context) => QuickMenuCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 15,
              backgroundColor: KetokColors.surfaceLow,
              child: Text(name[0]),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            ...List.generate(rating, (_) => const Icon(Icons.star_rounded, size: 17, color: Colors.amber)),
          ],
        ),
        const SizedBox(height: 8),
        Text(text, style: const TextStyle(color: KetokColors.textMuted)),
      ],
    ),
  );
}
