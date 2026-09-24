import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../widgets/ketok_colors.dart';
import '../l10n/app_localizations.dart';

class ManajemenPekerjaanScreen extends StatefulWidget {
  final String? initialSection;

  const ManajemenPekerjaanScreen({super.key, this.initialSection});

  @override
  State<ManajemenPekerjaanScreen> createState() =>
      _ManajemenPekerjaanScreenState();
}

class _ManajemenPekerjaanScreenState extends State<ManajemenPekerjaanScreen> {
  final _client = Supabase.instance.client;
  bool _loading = true;
  String? _error;
  int? _mitraId;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _services = [];
  List<Map<String, dynamic>> _schedules = [];
  List<Map<String, dynamic>> _certificates = [];

  final List<TextEditingController> _scheduleStarts = List.generate(7, (_) => TextEditingController());
  final List<TextEditingController> _scheduleEnds = List.generate(7, (_) => TextEditingController());

  static const _daysId = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];
  static const _daysEn = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void dispose() {
    for (var c in _scheduleStarts) {
      c.dispose();
    }
    for (var c in _scheduleEnds) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<int> _loadMitraId() async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Sesi login tidak ditemukan.');
    final profile = await _client
        .from('users')
        .select('id_user')
        .eq('auth_uid', user.id)
        .maybeSingle();
    final id = profile?['id_user'];
    if (id is! int) throw Exception('Profil Mitra belum ditemukan.');
    return id;
  }

  Future<void> _loadData() async {
    try {
      final id = await _loadMitraId();
      final results = await Future.wait([
        _client
            .from('kategori_layanan')
            .select('id_katagori, nama_katagori')
            .order('nama_katagori'),
        _client
            .from('mitra_layanan')
            .select(
              'id_layanan_mitra, katagori_id, nama_jasa, deskripsi, tarif_mulai, tarif_selesai, biaya_kunjungan, satuan_tarif, foto_url, aktif',
            )
            .eq('mitra_id', id)
            .order('id_layanan_mitra'),
        _client
            .from('mitra_jadwal_kerja')
            .select('id_jadwal_mitra, hari, aktif, jam_mulai, jam_selesai')
            .eq('mitra_id', id)
            .order('hari'),

        _client
            .from('mitra_sertifikasi')
            .select(
              'id_sertifikasi_mitra, nama_sertifikasi, nomor_sertifikasi, penerbit, berlaku_sampai, dokumen_url, status_verifikasi',
            )
            .eq('mitra_id', id)
            .order('nama_sertifikasi'),
      ]);
      if (!mounted) return;
      setState(() {
        _mitraId = id;
        _categories = _maps(results[0]);
        _services = _maps(results[1]);
        _schedules = _maps(results[2]);
        for (int i = 0; i < 7; i++) {
          final found = _schedules.where((s) => s['hari'] == i + 1);
          final s = found.isNotEmpty ? found.first : null;
          if (s != null && s['aktif'] == true) {
            _scheduleStarts[i].text = (s['jam_mulai'] as String).substring(0, 5);
            _scheduleEnds[i].text = (s['jam_selesai'] as String).substring(0, 5);
          } else {
            _scheduleStarts[i].text = '';
            _scheduleEnds[i].text = '';
          }
        }
        _certificates = _maps(results[3]);
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  List<Map<String, dynamic>> _maps(dynamic value) =>
      (value as List).map((row) => Map<String, dynamic>.from(row)).toList();

  Future<void> _saveService({Map<String, dynamic>? item}) async {
    String formatInitialNum(dynamic val, {String defaultVal = ''}) {
      if (val == null) return defaultVal;
      final n = val is num ? val : num.tryParse(val.toString());
      if (n == null) return defaultVal;
      return n.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
    }

    final categoryId = ValueNotifier<int?>(item?['katagori_id'] as int?);
    final namaJasa = TextEditingController(text: item?['nama_jasa'] ?? '');
    final deskripsi = TextEditingController(text: item?['deskripsi'] ?? '');
    final start = TextEditingController(text: formatInitialNum(item?['tarif_mulai']));
    final end = TextEditingController(text: formatInitialNum(item?['tarif_selesai']));
    final visit = TextEditingController(
      text: formatInitialNum(item?['biaya_kunjungan'], defaultVal: '50.000'),
    );
    final unit = TextEditingController(
      text: item?['satuan_tarif'] ?? 'per layanan',
    );
    final isUploading = ValueNotifier<bool>(false);
    final fotoUrl = ValueNotifier<String?>(item?['foto_url'] as String?);
    final isIndo = context.l10n.isIndonesian;

    await _formDialog(
      title: item == null 
          ? (isIndo ? 'Tambah Layanan' : 'Add Service') 
          : (isIndo ? 'Ubah Layanan' : 'Edit Service'),
      fields: [
        ValueListenableBuilder<int?>(
          valueListenable: categoryId,
          builder: (context, value, child) => DropdownButtonFormField<int>(
            initialValue: value,
            isExpanded: true,
            decoration: InputDecoration(labelText: isIndo ? 'Layanan' : 'Service Category'),
            items: _categories
                .map(
                  (row) => DropdownMenuItem<int>(
                    value: row['id_katagori'] as int,
                    child: Text(row['nama_katagori'] as String),
                  ),
                )
                .toList(),
            onChanged: (next) => categoryId.value = next,
          ),
        ),
        TextField(
          controller: namaJasa,
          decoration: InputDecoration(labelText: isIndo ? 'Nama Jasa Spesifik' : 'Specific Service Name'),
        ),
        TextField(
          controller: deskripsi,
          maxLines: 3,
          decoration: InputDecoration(labelText: isIndo ? 'Deskripsi Singkat' : 'Brief Description'),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF7DD3FC)),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isIndo
                      ? 'Cukup masukkan kisaran harga. Harga akhir ditentukan setelah Anda tiba di lokasi dan memeriksa kendaraan. Jika batal, Anda tetap mendapat Biaya Kunjungan Rp 50.000.'
                      : 'Simply provide an estimated price range. Final price is determined after inspecting vehicle on site. If cancelled, you still receive a Visit Fee of IDR 50,000.',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF075985), height: 1.35),
                ),
              ),
            ],
          ),
        ),
        TextField(
          controller: start,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            labelText: isIndo ? 'Kisaran Harga Bawah' : 'Min Price Range',
            prefixText: 'Rp ',
          ),
        ),
        TextField(
          controller: end,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            labelText: isIndo ? 'Kisaran Harga Atas (Opsional)' : 'Max Price Range (Optional)',
            prefixText: 'Rp ',
          ),
        ),
        TextField(
          controller: visit,
          keyboardType: TextInputType.number,
          inputFormatters: [ThousandsSeparatorInputFormatter()],
          decoration: InputDecoration(
            labelText: isIndo ? 'Biaya Kunjungan' : 'Visit Fee',
            prefixText: 'Rp ',
          ),
        ),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
          valueListenable: isUploading,
          builder: (context, uploading, child) => ValueListenableBuilder<String?>(
            valueListenable: fotoUrl,
            builder: (context, url, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isIndo ? 'Foto Layanan (Opsional)' : 'Service Photo (Optional)', style: const TextStyle(fontSize: 12, color: KetokColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                if (url != null && url.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KetokColors.borderColor),
                      image: DecorationImage(
                        image: NetworkImage(url),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                if (url != null && url.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: uploading ? null : () async {
                            final picker = ImagePicker();
                            final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 800);
                            if (picked == null) return;
                            
                            isUploading.value = true;
                            try {
                              final file = File(picked.path);
                              final bytes = await file.readAsBytes();
                              final ext = picked.path.split('.').last.toLowerCase();
                              final fileName = 'layanan_${DateTime.now().millisecondsSinceEpoch}.$ext';
                              
                              await _client.storage.from('layanan_fotos').uploadBinary(
                                fileName,
                                bytes,
                                fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
                              );
                              
                              final uploadedUrl = _client.storage.from('layanan_fotos').getPublicUrl(fileName);
                              fotoUrl.value = uploadedUrl;
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isIndo ? 'Gagal unggah foto: $e' : 'Failed to upload photo: $e')));
                              }
                            } finally {
                              isUploading.value = false;
                            }
                          },
                          icon: uploading 
                              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                              : const Icon(Icons.edit_outlined, size: 16),
                          label: Text(uploading ? (isIndo ? 'Mengunggah...' : 'Uploading...') : (isIndo ? 'Ganti Foto' : 'Change Photo')),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: uploading ? null : () => fotoUrl.value = null,
                        style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                        icon: const Icon(Icons.delete_outline_rounded, size: 16),
                        label: Text(isIndo ? 'Hapus' : 'Delete'),
                      ),
                    ],
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: uploading ? null : () async {
                        final picker = ImagePicker();
                        final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 75, maxWidth: 800);
                        if (picked == null) return;
                        
                        isUploading.value = true;
                        try {
                          final file = File(picked.path);
                          final bytes = await file.readAsBytes();
                          final ext = picked.path.split('.').last.toLowerCase();
                          final fileName = 'layanan_${DateTime.now().millisecondsSinceEpoch}.$ext';
                          
                          await _client.storage.from('layanan_fotos').uploadBinary(
                            fileName,
                            bytes,
                            fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
                          );
                          
                          final uploadedUrl = _client.storage.from('layanan_fotos').getPublicUrl(fileName);
                          fotoUrl.value = uploadedUrl;
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isIndo ? 'Gagal unggah foto: $e' : 'Failed to upload photo: $e')));
                          }
                        } finally {
                          isUploading.value = false;
                        }
                      },
                      icon: uploading 
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                          : const Icon(Icons.add_photo_alternate_outlined),
                      label: Text(uploading ? (isIndo ? 'Mengunggah...' : 'Uploading...') : (isIndo ? 'Unggah Foto' : 'Upload Photo')),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
      onSave: () async {
        if (_mitraId == null ||
            categoryId.value == null ||
            namaJasa.text.trim().isEmpty ||
            start.text.trim().isEmpty) {
          return;
        }
        final data = {
          'mitra_id': _mitraId,
          'katagori_id': categoryId.value,
          'nama_jasa': namaJasa.text.trim(),
          'deskripsi': deskripsi.text.trim(),
          'tarif_mulai': _parsePrice(start.text),
          'foto_url': fotoUrl.value,
          'tarif_selesai': end.text.trim().isEmpty
              ? null
              : _parsePrice(end.text),
          'biaya_kunjungan': visit.text.trim().isEmpty 
              ? 50000 
              : _parsePrice(visit.text),
          'satuan_tarif': unit.text.trim().isEmpty
              ? 'per layanan'
              : unit.text.trim(),
        };
        if (item == null) {
          await _client.from('mitra_layanan').insert(data);
        } else {
          await _client
              .from('mitra_layanan')
              .update(data)
              .eq('id_layanan_mitra', item['id_layanan_mitra']);
        }
        await _loadData();
      },
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      categoryId.dispose();
      namaJasa.dispose();
      deskripsi.dispose();
      start.dispose();
      end.dispose();
      visit.dispose();
      unit.dispose();
      isUploading.dispose();
      fotoUrl.dispose();
    });
  }

  Future<void> _saveAllSchedules() async {
    if (_mitraId == null) return;
    setState(() => _loading = true);
    try {
      for (int i = 0; i < 7; i++) {
        final startRaw = _scheduleStarts[i].text.trim();
        final endRaw = _scheduleEnds[i].text.trim();
        final aktif = startRaw.isNotEmpty && endRaw.isNotEmpty;
        
        final found = _schedules.where((s) => s['hari'] == i + 1);
        final existing = found.isNotEmpty ? found.first : null;
        
        String start = startRaw;
        String end = endRaw;
        
        if (aktif) {
          final sParts = startRaw.split(':');
          final eParts = endRaw.split(':');
          start = '${(sParts.isNotEmpty ? sParts[0] : "08").padLeft(2, '0')}:${(sParts.length > 1 ? sParts[1] : "00").padLeft(2, '0')}:00';
          end = '${(eParts.isNotEmpty ? eParts[0] : "17").padLeft(2, '0')}:${(eParts.length > 1 ? eParts[1] : "00").padLeft(2, '0')}:00';
        }
        
        final data = {
          'mitra_id': _mitraId,
          'hari': i + 1,
          'aktif': aktif,
          if (aktif) 'jam_mulai': start,
          if (aktif) 'jam_selesai': end,
        };
        
        if (existing == null) {
          if (aktif) {
            await _client.from('mitra_jadwal_kerja').insert(data);
          }
        } else {
          await _client.from('mitra_jadwal_kerja').update(data).eq('id_jadwal_mitra', existing['id_jadwal_mitra']);
        }
      }
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isIndo ? 'Jadwal kerja berhasil disimpan.' : 'Work schedule saved successfully.'),
        ));
      }
      await _loadData();
    } catch (error) {
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isIndo ? 'Terjadi kesalahan: $error' : 'An error occurred: $error'),
        ));
      }
    }
  }

  Future<void> _saveCertificate({Map<String, dynamic>? item}) async {
    final isIndo = context.l10n.isIndonesian;
    final name = TextEditingController(text: item?['nama_sertifikasi'] ?? '');
    final number = TextEditingController(
      text: item?['nomor_sertifikasi'] ?? '',
    );
    final issuer = TextEditingController(text: item?['penerbit'] ?? '');
    final expiry = TextEditingController(text: item?['berlaku_sampai'] ?? '');
    final documentUrl = ValueNotifier<String?>(item?['dokumen_url'] as String?);
    final isUploading = ValueNotifier<bool>(false);
    await _formDialog(
      title: item == null 
          ? (isIndo ? 'Tambah Sertifikasi' : 'Add Certification') 
          : (isIndo ? 'Ubah Sertifikasi' : 'Edit Certification'),
      fields: [
        TextField(
          controller: name,
          decoration: InputDecoration(labelText: isIndo ? 'Nama sertifikasi' : 'Certification name'),
        ),
        TextField(
          controller: number,
          decoration: InputDecoration(labelText: isIndo ? 'Nomor sertifikasi' : 'Certificate number'),
        ),
        TextField(
          controller: issuer,
          decoration: InputDecoration(labelText: isIndo ? 'Penerbit' : 'Issuer'),
        ),
        TextField(
          controller: expiry,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              initialDate: DateTime.tryParse(expiry.text) ?? DateTime.now(),
            );
            if (picked != null) {
              expiry.text =
                  '${picked.year.toString().padLeft(4, '0')}-'
                  '${picked.month.toString().padLeft(2, '0')}-'
                  '${picked.day.toString().padLeft(2, '0')}';
            }
          },
          decoration: InputDecoration(
            labelText: isIndo ? 'Berlaku sampai (Opsional)' : 'Valid until (Optional)',
            suffixIcon: const Icon(Icons.calendar_today_outlined),
          ),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: isUploading,
          builder: (context, uploading, child) => ValueListenableBuilder<String?>(
            valueListenable: documentUrl,
            builder: (context, docUrl, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isIndo ? 'Dokumen Sertifikat' : 'Certificate Document', style: const TextStyle(fontSize: 12, color: KetokColors.onSurfaceVariant)),
                const SizedBox(height: 8),
                if (docUrl != null && docUrl.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: KetokColors.borderColor),
                      image: DecorationImage(
                        image: NetworkImage(docUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: uploading ? null : () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
                      if (picked == null) return;
                      
                      isUploading.value = true;
                      try {
                        final file = File(picked.path);
                        final bytes = await file.readAsBytes();
                        final ext = picked.path.split('.').last;
                        final fileName = '${DateTime.now().millisecondsSinceEpoch}.$ext';
                        
                        await _client.storage.from('mitra_documents').uploadBinary(
                          fileName,
                          bytes,
                          fileOptions: FileOptions(contentType: 'image/$ext'),
                        );
                        
                        final url = _client.storage.from('mitra_documents').getPublicUrl(fileName);
                        documentUrl.value = url;
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isIndo ? 'Gagal unggah: $e' : 'Failed to upload: $e')));
                        }
                      } finally {
                        isUploading.value = false;
                      }
                    },
                    icon: uploading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file_rounded),
                    label: Text(uploading 
                        ? (isIndo ? 'Mengunggah...' : 'Uploading...') 
                        : (docUrl != null ? (isIndo ? 'Ganti Dokumen' : 'Change Document') : (isIndo ? 'Unggah Dokumen' : 'Upload Document'))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
      onSave: () async {
        if (_mitraId == null || name.text.trim().isEmpty) return;
        final data = {
          'mitra_id': _mitraId,
          'nama_sertifikasi': name.text.trim(),
          'nomor_sertifikasi': number.text.trim(),
          'penerbit': issuer.text.trim(),
          'berlaku_sampai': expiry.text.trim().isEmpty
              ? null
              : expiry.text.trim(),
          'dokumen_url': documentUrl.value,
        };
        if (item == null) {
          await _client.from('mitra_sertifikasi').insert(data);
        } else {
          await _client
              .from('mitra_sertifikasi')
              .update(data)
              .eq('id_sertifikasi_mitra', item['id_sertifikasi_mitra']);
        }
        await _loadData();
      },
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      name.dispose();
      number.dispose();
      issuer.dispose();
      expiry.dispose();
      documentUrl.dispose();
      isUploading.dispose();
    });
  }

  Future<void> _formDialog({
    required String title,
    required List<Widget> fields,
    required Future<void> Function() onSave,
  }) async {
    final isIndo = context.l10n.isIndonesian;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: MediaQuery.of(dialogContext).size.width * 0.85,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields
                  .map(
                    (field) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: field,
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: KetokColors.onSurfaceVariant,
            ),
            child: Text(isIndo ? 'Batal' : 'Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await onSave();
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              } catch (error) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(content: Text(isIndo ? 'Gagal menyimpan: $error' : 'Failed to save: $error')),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF171717),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(isIndo ? 'Simpan' : 'Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _delete(String table, String column, dynamic id) async {
    try {
      await _client.from(table).delete().eq(column, id);
      await _loadData();
    } catch (error) {
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(isIndo ? 'Gagal menghapus: $error' : 'Failed to delete: $error')));
      }
    }
  }

  String _categoryName(dynamic id) =>
      _categories.firstWhere(
            (row) => row['id_katagori'] == id,
            orElse: () => {'nama_katagori': 'Layanan'},
          )['nama_katagori']
          as String;

  bool _showSection(String section) =>
      widget.initialSection == null || widget.initialSection == section;

  double _parsePrice(String value) =>
      double.parse(value.replaceAll('.', '').replaceAll(',', '.'));

  String _formatPrice(dynamic value) {
    if (value == null) return '-';
    final amount = (value as num).round().toString();
    return 'Rp ${amount.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => '.')}';
  }

  Widget _buildScheduleSection(bool isIndo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB),
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KetokColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.event_available_outlined, color: KetokColors.darkPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isIndo ? 'Jadwal & Jam Kerja' : 'Schedule & Working Hours',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isIndo
                        ? 'Kosongkan jam jika Anda tutup pada hari tersebut. Format waktu 24 jam.'
                        : 'Leave hours empty if closed on that day. 24-hour time format.',
                    style: const TextStyle(fontSize: 12, color: KetokColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  for (int i = 0; i < 7; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80,
                            child: Text(
                              isIndo ? _daysId[i] : _daysEn[i],
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _scheduleStarts[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: [TimeAutoFormatInputFormatter()],
                              decoration: InputDecoration(
                                labelText: isIndo ? 'Mulai' : 'Start',
                                hintText: '08:00',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text('-', style: TextStyle(fontWeight: FontWeight.w700)),
                          ),
                          Expanded(
                            child: TextField(
                              controller: _scheduleEnds[i],
                              keyboardType: TextInputType.number,
                              inputFormatters: [TimeAutoFormatInputFormatter()],
                              decoration: InputDecoration(
                                labelText: isIndo ? 'Selesai' : 'End',
                                hintText: '17:00',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _saveAllSchedules,
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(isIndo ? 'Simpan Jadwal' : 'Save Schedule'),
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

  Widget _section(
    String title,
    IconData icon,
    List<Map<String, dynamic>> items,
    VoidCallback onAdd,
    Widget Function(Map<String, dynamic>) tile, {
    required bool isIndo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
              decoration: const BoxDecoration(
                color: Color(0xFFF8F9FB),
                border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: KetokColors.darkPrimary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: KetokColors.darkPrimary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onAdd,
                    style: IconButton.styleFrom(
                      backgroundColor: KetokColors.darkPrimary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    tooltip: isIndo ? 'Tambah' : 'Add',
                  ),
                ],
              ),
            ),
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 40, color: KetokColors.onSurfaceVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text(
                      isIndo ? 'Belum ada data' : 'No data yet',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: KetokColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isIndo ? 'Ketuk tombol + untuk menambahkan' : 'Tap + button to add',
                      style: TextStyle(
                        fontSize: 12,
                        color: KetokColors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: items.map(tile).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(title: Text(isIndo ? 'Manajemen Pekerjaan' : 'Work Management')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  if (_showSection('services'))
                    _section(
                      isIndo ? 'Layanan & Tarif' : 'Services & Rates',
                      Icons.build_circle_outlined,
                      _services,
                      () => _saveService(),
                      isIndo: isIndo,
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.payments_rounded, color: KetokColors.darkPrimary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_jasa']?.toString().isNotEmpty == true 
                                        ? '${item['nama_jasa']}' 
                                        : _categoryName(item['katagori_id']),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${isIndo ? "Kisaran" : "Range"}: ${_formatPrice(item['tarif_mulai'])} ${item['tarif_selesai'] != null ? '- ${_formatPrice(item['tarif_selesai'])}' : ''}\n${isIndo ? "Kunjungan" : "Visit"}: ${_formatPrice(item['biaya_kunjungan'] ?? 50000)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: KetokColors.darkPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _saveService(item: item),
                                  icon: const Icon(Icons.edit_rounded, size: 18, color: KetokColors.onSurfaceVariant),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _delete(
                                    'mitra_layanan',
                                    'id_layanan_mitra',
                                    item['id_layanan_mitra'],
                                  ),
                                  icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (_showSection('schedule'))
                    _buildScheduleSection(isIndo),
                  if (_showSection('certificate'))
                    _section(
                      isIndo ? 'Sertifikasi & Dokumen' : 'Certifications & Documents',
                      Icons.verified_user_outlined,
                      _certificates,
                      () => _saveCertificate(),
                      isIndo: isIndo,
                      (item) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x05000000),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FB),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.verified_rounded, color: KetokColors.darkPrimary, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['nama_sertifikasi'] as String,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item['penerbit']?.toString().isNotEmpty == true
                                        ? '${item['penerbit']} • ${item['status_verifikasi']}'
                                        : item['status_verifikasi'] as String,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: KetokColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _saveCertificate(item: item),
                                  icon: const Icon(Icons.edit_rounded, size: 18, color: KetokColors.onSurfaceVariant),
                                ),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () => _delete(
                                    'mitra_sertifikasi',
                                    'id_sertifikasi_mitra',
                                    item['id_sertifikasi_mitra'],
                                  ),
                                  icon: const Icon(Icons.delete_rounded, size: 18, color: Colors.redAccent),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class TimeAutoFormatInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    String text = digits;
    if (text.length > 4) {
      text = text.substring(0, 4);
    }
    if (text.length >= 3) {
      text = '${text.substring(0, 2)}:${text.substring(2)}';
    }
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return newValue.copyWith(text: '');
    final formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
