import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class KetokOrder {
  final int? id;
  final int? mitraId;
  final String title;
  final String mitraName;
  final String? mitraPhotoUrl;
  final String location;
  final String status;
  final String invoice;
  final String price;
  final IconData icon;
  final String approvalStatus;
  final num totalCost;
  final num biayaKunjungan;
  final num biayaJasa;
  final num biayaSparepart;
  final String? jadwal;
  final String? catatan;
  final String? rincianEstimasi;
  final int? rating;
  final String? ulasanKomentar;
  final int? idUlasan;

  const KetokOrder({
    this.id,
    this.mitraId,
    required this.title,
    required this.mitraName,
    this.mitraPhotoUrl,
    required this.location,
    required this.status,
    required this.invoice,
    required this.price,
    required this.icon,
    required this.approvalStatus,
    required this.totalCost,
    this.biayaKunjungan = 50000,
    this.biayaJasa = 0,
    this.biayaSparepart = 0,
    this.jadwal,
    this.catatan,
    this.rincianEstimasi,
    this.rating,
    this.ulasanKomentar,
    this.idUlasan,
  });

  bool get isActive => !{'selesai', 'dibatalkan'}.contains(status);
  bool get hasReviewed => rating != null;
  String get statusLabel =>
      {
        'menuju_lokasi': 'Mitra menuju lokasi',
        'diproses': 'Sedang diproses',
        'dikerjakan': 'Dalam pengerjaan',
        'selesai': 'Selesai',
        'dibatalkan': 'Dibatalkan',
      }[status] ??
      'Menunggu konfirmasi';

  factory KetokOrder.fromMap(
    Map<String, dynamic> row,
    Map<int, String> mitraNames, {
    Map<int, String?>? mitraPhotos,
    Map<String, dynamic>? invoice,
    Map<String, dynamic>? ulasan,
  }) {
    final rawMitraId = row['mitra_id'];
    final mitraId = rawMitraId is int ? rawMitraId : null;
    final note = row['catatan'] as String?;

    String visitPriceText = 'Rp 50.000';
    if (note != null && note.contains('Biaya Kunjungan:')) {
      final match = RegExp(
        r'Biaya Kunjungan:\s*(Rp\s*[\d\.]+)',
      ).firstMatch(note);
      if (match != null) {
        visitPriceText = match.group(1) ?? 'Rp 50.000';
      }
    }

    final title = note?.isNotEmpty == true
        ? note!.split('\n').first.replaceFirst('Jasa: ', '').trim()
        : 'Layanan Ketok';

    final approvalStatus =
        row['status_persetujuan_biaya'] as String? ?? 'menunggu_estimasi';

    final num visitCost =
        (invoice?['biaya_kunjungan'] ?? row['biaya_kunjungan'] ?? 50000)
            as num;
    final num jasaCost = (invoice?['biaya_jasa'] ?? 0) as num;
    final num sparepartCost = (invoice?['biaya_sparepart'] ?? 0) as num;
    final num total =
        (invoice?['jumlah_biaya'] ??
                (visitCost + jasaCost + sparepartCost))
            as num;

    String? rincian;
    if (note != null && note.contains('Estimasi Perbaikan:')) {
      final parts = note.split('Estimasi Perbaikan:');
      if (parts.length > 1) {
        rincian = parts[1].trim();
      }
    }

    String displayPrice = visitPriceText;
    if (approvalStatus == 'disetujui' || row['status'] == 'selesai') {
      final formattedTotal = total.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
      displayPrice = 'Rp $formattedTotal';
    }

    return KetokOrder(
      id: row['id_pesanan'] as int?,
      mitraId: mitraId,
      title: title.isNotEmpty ? title : 'Layanan Ketok',
      mitraName: mitraId != null
          ? mitraNames[mitraId] ?? 'Mitra Ketok'
          : 'Menunggu konfirmasi mitra',
      mitraPhotoUrl:
          (mitraId != null && mitraPhotos != null) ? mitraPhotos[mitraId] : null,
      location: row['lokasi'] as String? ?? 'Lokasi belum diatur',
      status: row['status'] as String? ?? 'mencari_mitra',
      invoice: '#KTK-${row['id_pesanan']}',
      price: displayPrice,
      icon: Icons.handyman_rounded,
      approvalStatus: approvalStatus,
      totalCost: total,
      biayaKunjungan: visitCost,
      biayaJasa: jasaCost,
      biayaSparepart: sparepartCost,
      jadwal: row['jadwal'] as String?,
      catatan: note,
      rincianEstimasi: rincian,
      rating: ulasan?['rating'] as int?,
      ulasanKomentar: ulasan?['komentar'] as String?,
      idUlasan: ulasan?['id_ulasan'] as int?,
    );
  }

  KetokOrder copyWith({
    int? id,
    int? mitraId,
    String? title,
    String? mitraName,
    String? mitraPhotoUrl,
    String? location,
    String? status,
    String? invoice,
    String? price,
    IconData? icon,
    String? approvalStatus,
    num? totalCost,
    num? biayaKunjungan,
    num? biayaJasa,
    num? biayaSparepart,
    String? jadwal,
    String? catatan,
    String? rincianEstimasi,
    int? rating,
    String? ulasanKomentar,
    int? idUlasan,
  }) {
    return KetokOrder(
      id: id ?? this.id,
      mitraId: mitraId ?? this.mitraId,
      title: title ?? this.title,
      mitraName: mitraName ?? this.mitraName,
      mitraPhotoUrl: mitraPhotoUrl ?? this.mitraPhotoUrl,
      location: location ?? this.location,
      status: status ?? this.status,
      invoice: invoice ?? this.invoice,
      price: price ?? this.price,
      icon: icon ?? this.icon,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      totalCost: totalCost ?? this.totalCost,
      biayaKunjungan: biayaKunjungan ?? this.biayaKunjungan,
      biayaJasa: biayaJasa ?? this.biayaJasa,
      biayaSparepart: biayaSparepart ?? this.biayaSparepart,
      jadwal: jadwal ?? this.jadwal,
      catatan: catatan ?? this.catatan,
      rincianEstimasi: rincianEstimasi ?? this.rincianEstimasi,
      rating: rating ?? this.rating,
      ulasanKomentar: ulasanKomentar ?? this.ulasanKomentar,
      idUlasan: idUlasan ?? this.idUlasan,
    );
  }
}

class KetokChat {
  final KetokOrder order;
  final int unread;
  const KetokChat({required this.order, required this.unread});

  String get initials => order.mitraName
      .split(' ')
      .where((word) => word.isNotEmpty)
      .take(2)
      .map((word) => word[0])
      .join()
      .toUpperCase();
}

class KetokOrderRepository {
  final SupabaseClient _client;
  KetokOrderRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  Future<List<KetokOrder>> getOrders() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];
    final userRows = await _client
        .from('users')
        .select('id_user')
        .eq('auth_uid', user.id)
        .limit(1);
    if (userRows.isEmpty) return [];
    final rows = await _client
        .from('pesanan')
        .select()
        .eq('pengguna_id', userRows.first['id_user'])
        .order('jadwal', ascending: false);
    if (rows.isEmpty) return [];

    final orderIds =
        rows.map((r) => r['id_pesanan']).whereType<int>().toList();
    final invoiceMap = <int, Map<String, dynamic>>{};
    if (orderIds.isNotEmpty) {
      try {
        final invoiceRows = await _client
            .from('invoice')
            .select(
              'pesanan_id, jumlah_biaya, biaya_kunjungan, biaya_jasa, biaya_sparepart, status_bayar',
            )
            .inFilter('pesanan_id', orderIds);
        for (final inv in invoiceRows) {
          invoiceMap[inv['pesanan_id'] as int] =
              Map<String, dynamic>.from(inv);
        }
      } catch (_) {}
    }

    final ulasanMap = <int, Map<String, dynamic>>{};
    if (orderIds.isNotEmpty) {
      try {
        final ulasanRows = await _client
            .from('ulasan')
            .select('id_ulasan, pesanan_id, rating, komentar')
            .inFilter('pesanan_id', orderIds);
        for (final u in ulasanRows) {
          ulasanMap[u['pesanan_id'] as int] = Map<String, dynamic>.from(u);
        }
      } catch (_) {}
    }

    final mitraIds = rows
        .map((row) => row['mitra_id'])
        .whereType<int>()
        .toSet()
        .toList();
    final mitraNames = <int, String>{};
    final mitraPhotos = <int, String?>{};
    if (mitraIds.isNotEmpty) {
      final mitraRows = await _client
          .from('users')
          .select('id_user,nama,foto_profil')
          .inFilter('id_user', mitraIds);
      for (final row in mitraRows) {
        final id = row['id_user'] as int;
        mitraNames[id] = row['nama'] as String? ?? 'Mitra Ketok';
        mitraPhotos[id] = row['foto_profil'] as String?;
      }
    }
    return rows.map((row) {
      final orderId = row['id_pesanan'] as int? ?? 0;
      final inv = invoiceMap[orderId];
      final ulas = ulasanMap[orderId];
      return KetokOrder.fromMap(
        row,
        mitraNames,
        mitraPhotos: mitraPhotos,
        invoice: inv,
        ulasan: ulas,
      );
    }).toList();
  }

  Future<List<KetokChat>> getChats() async => (await getOrders())
      .map((order) => KetokChat(order: order, unread: order.isActive ? 1 : 0))
      .toList();
}

final ketokDemoOrders = [
  const KetokOrder(
    title: 'Perbaikan AC - Cuci & Tambah Freon',
    mitraName: 'Bambang Santoso',
    location: 'Jl. Tebet Barat Dalam No. 12',
    status: 'menuju_lokasi',
    invoice: 'INV/2026/001',
    price: 'Rp 50.000',
    icon: Icons.ac_unit_rounded,
    approvalStatus: 'menunggu_estimasi',
    totalCost: 50000,
  ),
  const KetokOrder(
    title: 'Servis Mesin Cuci & Pengering',
    mitraName: 'Agus Kurnia',
    location: 'Apartemen Kalibata City',
    status: 'selesai',
    invoice: 'INV/2026/002',
    price: 'Rp 250.000',
    icon: Icons.local_laundry_service_rounded,
    approvalStatus: 'disetujui',
    totalCost: 250000,
  ),
  const KetokOrder(
    title: 'Instalasi Titik Listrik Baru',
    mitraName: 'Dedi Kurniawan',
    location: 'Jl. Cilandak Barat',
    status: 'selesai',
    invoice: 'INV/2026/003',
    price: 'Rp 185.000',
    icon: Icons.electrical_services_rounded,
    approvalStatus: 'disetujui',
    totalCost: 185000,
  ),
];

final ketokDemoChats = ketokDemoOrders
    .map((order) => KetokChat(order: order, unread: 1))
    .toList();
