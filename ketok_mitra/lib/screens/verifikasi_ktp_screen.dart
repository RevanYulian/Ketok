import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/ketok_colors.dart';
import '../l10n/app_localizations.dart';
import 'ktp_camera_stub.dart'
    if (dart.library.html) 'ktp_camera_web.dart';

class VerifikasiKtpScreen extends StatefulWidget {
  const VerifikasiKtpScreen({super.key});

  @override
  State<VerifikasiKtpScreen> createState() => _VerifikasiKtpScreenState();
}

class _VerifikasiKtpScreenState extends State<VerifikasiKtpScreen> {
  final _businessNameController = TextEditingController();
  final _nikController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _errorMessage;

  int? _userId;
  String? _currentNik;
  String? _fotoKtpUrl;
  String _statusVerifikasi = 'belum_upload'; // belum_upload, menunggu, terverifikasi, ditolak
  String? _catatanVerifikasi;

  String? _selectedProvince;
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedVillage;
  List<Map<String, dynamic>> _regions = [];

  XFile? _selectedPhoto;
  Uint8List? _selectedPhotoBytes;

  List<String> _regionsByType(String type, String? parentName) {
    return _regions
        .where(
          (region) =>
              region['tipe'] == type && region['parent_nama'] == parentName,
        )
        .map((region) => region['nama'] as String)
        .toList();
  }

  List<String> get _provinces => _regionsByType('provinsi', null);
  List<String> get _cities => _regionsByType('kota', _selectedProvince);
  List<String> get _districts => _regionsByType('kecamatan', _selectedCity);
  List<String> get _villages => _regionsByType('kelurahan', _selectedDistrict);

  @override
  void initState() {
    super.initState();
    _loadKtpData();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _nikController.dispose();
    super.dispose();
  }

  Future<void> _loadKtpData() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception('Sesi login tidak ditemukan.');

      final user = await client
          .from('users')
          .select('id_user, status_mitra')
          .eq('auth_uid', authUser.id)
          .maybeSingle();

      if (user == null) throw Exception('Data akun tidak ditemukan.');
      final userId = user['id_user'] as int;

      final profile = await client
          .from('mitra_profil')
          .select(
            'nik, foto_ktp, status_verifikasi, catatan_verifikasi, nama_usaha, provinsi, kota, kecamatan, kelurahan',
          )
          .eq('user_id', userId)
          .maybeSingle();

      final regions = await client
          .from('wilayah_malang')
          .select('nama, tipe, parent_nama')
          .order('nama');

      if (!mounted) return;
      setState(() {
        _userId = userId;
        _currentNik = profile?['nik'] as String?;
        _fotoKtpUrl = profile?['foto_ktp'] as String?;
        _catatanVerifikasi = profile?['catatan_verifikasi'] as String?;

        _businessNameController.text = profile?['nama_usaha'] as String? ?? '';
        _selectedProvince = profile?['provinsi'] as String?;
        _selectedCity = profile?['kota'] as String?;
        _selectedDistrict = profile?['kecamatan'] as String?;
        _selectedVillage = profile?['kelurahan'] as String?;

        _regions = regions
            .map((row) => Map<String, dynamic>.from(row))
            .toList();

        if (!_provinces.contains(_selectedProvince)) _selectedProvince = null;
        if (!_cities.contains(_selectedCity)) _selectedCity = null;
        if (!_districts.contains(_selectedDistrict)) _selectedDistrict = null;
        if (!_villages.contains(_selectedVillage)) _selectedVillage = null;

        if (_fotoKtpUrl != null && _fotoKtpUrl!.isNotEmpty) {
          _statusVerifikasi = profile?['status_verifikasi'] as String? ?? 'menunggu';
          _fetchKtpBytesFromStorage(_fotoKtpUrl!);
        } else {
          _statusVerifikasi = 'belum_upload';
        }

        if (_currentNik != null) {
          _nikController.text = _currentNik!;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _fetchKtpBytesFromStorage(String url) async {
    try {
      final client = Supabase.instance.client;
      if (url.contains('/mitra_documents/')) {
        final path = url.split('/mitra_documents/').last.split('?').first;
        final bytes = await client.storage.from('mitra_documents').download(path);
        if (mounted) {
          setState(() {
            _selectedPhotoBytes = bytes;
          });
        }
      }
    } catch (_) {
      // Biarkan fallback ke Image.network jika download langsung belum selesai
    }
  }

  void _onProvinceChanged(String? value) {
    setState(() {
      _selectedProvince = value;
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedVillage = null;
    });
  }

  void _onCityChanged(String? value) {
    setState(() {
      _selectedCity = value;
      _selectedDistrict = null;
      _selectedVillage = null;
    });
  }

  void _onDistrictChanged(String? value) {
    setState(() {
      _selectedDistrict = value;
      _selectedVillage = null;
    });
  }

  List<Directory> _getWindowsCameraRollDirs() {
    final userProfile = Platform.environment['USERPROFILE'] ?? '';
    final candidates = [
      '$userProfile\\OneDrive\\Pictures\\Camera Roll',
      '$userProfile\\Pictures\\Camera Roll',
      '$userProfile\\OneDrive\\Gambar\\Camera Roll',
      '$userProfile\\Gambar\\Camera Roll',
    ];
    return candidates
        .map((p) => Directory(p))
        .where((d) => d.existsSync())
        .toList();
  }

  File? _findNewestCameraRollImage({Set<String>? excludePaths}) {
    final dirs = _getWindowsCameraRollDirs();
    File? newestFile;
    DateTime? newestTime;

    for (final dir in dirs) {
      try {
        final entities = dir.listSync();
        for (final entity in entities) {
          if (entity is File) {
            final ext = entity.path.split('.').last.toLowerCase();
            if (['jpg', 'jpeg', 'png'].contains(ext)) {
              if (excludePaths != null && excludePaths.contains(entity.path)) {
                continue;
              }
              final mod = entity.lastModifiedSync();
              if (newestTime == null || mod.isAfter(newestTime)) {
                newestTime = mod;
                newestFile = entity;
              }
            }
          }
        }
      } catch (_) {}
    }
    return newestFile;
  }

  Future<void> _pickFromWindowsCamera() async {
    final beforeFiles = <String>{};
    for (final dir in _getWindowsCameraRollDirs()) {
      try {
        for (final file in dir.listSync()) {
          if (file is File) beforeFiles.add(file.path);
        }
      } catch (_) {}
    }

    try {
      await Process.run('cmd', ['/c', 'start', 'microsoft.windows.camera:']);
    } catch (_) {}

    if (!mounted) return;

    Timer? autoDetectTimer;

    final selectedFile = await showDialog<File?>(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        autoDetectTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
          final newPhoto = _findNewestCameraRollImage(excludePaths: beforeFiles);
          if (newPhoto != null && dialogCtx.mounted) {
            timer.cancel();
            Navigator.pop(dialogCtx, newPhoto);
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.camera_alt_rounded, color: KetokColors.darkPrimary),
              SizedBox(width: 8),
              Text('Kamera Windows Terbuka', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aplikasi Kamera Windows sedang aktif.\n\n1. Ambil foto KTP Anda dengan jelas.\n2. Foto akan otomatis terdeteksi begitu tersimpan di Camera Roll.\n3. Atau klik tombol di bawah jika foto sudah selesai diambil.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                autoDetectTimer?.cancel();
                Navigator.pop(dialogCtx, null);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                autoDetectTimer?.cancel();
                final latest = _findNewestCameraRollImage(excludePaths: beforeFiles) ??
                    _findNewestCameraRollImage();
                Navigator.pop(dialogCtx, latest);
              },
              style: FilledButton.styleFrom(backgroundColor: KetokColors.darkPrimary),
              child: const Text('Gunakan Foto Terakhir'),
            ),
          ],
        );
      },
    );

    autoDetectTimer?.cancel();

    if (selectedFile != null && mounted) {
      try {
        final bytes = await selectedFile.readAsBytes();
        setState(() {
          _selectedPhoto = XFile(selectedFile.path);
          _selectedPhotoBytes = bytes;
          _errorMessage = null;
        });
        if (mounted) {
          final isIndo = context.l10n.isIndonesian;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isIndo ? 'Foto KTP dari kamera berhasil diambil!' : 'ID Card photo captured from camera successfully!'),
              backgroundColor: const Color(0xFF16A34A),
            ),
          );
        }
      } catch (err) {
        final isIndo = mounted ? context.l10n.isIndonesian : true;
        setState(() => _errorMessage = isIndo ? 'Gagal memproses foto kamera: $err' : 'Failed to process camera photo: $err');
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (kIsWeb) {
        final webPhoto = await showWebCameraDialog(context);
        if (webPhoto != null && mounted) {
          final bytes = await webPhoto.readAsBytes();
          setState(() {
            _selectedPhoto = webPhoto;
            _selectedPhotoBytes = bytes;
            _errorMessage = null;
          });
          if (mounted) {
            final isIndo = context.l10n.isIndonesian;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isIndo ? 'Foto KTP dari kamera berhasil diambil!' : 'ID Card photo captured from camera successfully!'),
                backgroundColor: const Color(0xFF16A34A),
              ),
            );
          }
        }
        return;
      }

      if (Platform.isWindows) {
        await _pickFromWindowsCamera();
        return;
      }
    }

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (photo != null) {
        final bytes = await photo.readAsBytes();
        if (mounted) {
          setState(() {
            _selectedPhoto = photo;
            _selectedPhotoBytes = bytes;
            _errorMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        setState(() => _errorMessage = isIndo ? 'Gagal memilih gambar: $e' : 'Failed to pick image: $e');
      }
    }
  }

  Future<void> _uploadAndSubmit() async {
    final isIndo = context.l10n.isIndonesian;
    final businessName = _businessNameController.text.trim();
    final nik = _nikController.text.trim();

    if (businessName.isEmpty) {
      setState(() => _errorMessage = isIndo ? 'Nama usaha / nama bengkel wajib diisi.' : 'Business / workshop name is required.');
      return;
    }
    if (_selectedProvince == null ||
        _selectedCity == null ||
        _selectedDistrict == null ||
        _selectedVillage == null) {
      setState(() => _errorMessage = isIndo ? 'Lengkapi seluruh data wilayah operasional Anda.' : 'Please complete all operational area details.');
      return;
    }
    if (nik.isEmpty) {
      setState(() => _errorMessage = isIndo ? 'Nomor Induk Kependudukan (NIK) wajib diisi.' : 'ID Card Number (NIK) is required.');
      return;
    }
    if (nik.length != 16 || int.tryParse(nik) == null) {
      setState(() => _errorMessage = isIndo ? 'NIK harus berupa 16 digit angka.' : 'NIK must be a 16-digit number.');
      return;
    }
    if (_selectedPhoto == null && (_fotoKtpUrl == null || _fotoKtpUrl!.isEmpty)) {
      setState(() => _errorMessage = isIndo ? 'Silakan pilih foto fisik KTP Anda terlebih dahulu.' : 'Please select your physical ID card photo first.');
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception(isIndo ? 'Sesi login tidak ditemukan.' : 'Login session not found.');

      var ktpUrl = _fotoKtpUrl;

      // Upload berkas jika ada foto baru yang dipilih
      if (_selectedPhoto != null && _selectedPhotoBytes != null) {
        final ext = _selectedPhoto!.name.split('.').last.toLowerCase();
        final path = 'ktp/${authUser.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';

        await client.storage.from('mitra_documents').uploadBinary(
          path,
          _selectedPhotoBytes!,
          fileOptions: FileOptions(
            contentType: _selectedPhoto!.mimeType ?? 'image/jpeg',
            upsert: true,
          ),
        );
        ktpUrl = client.storage.from('mitra_documents').getPublicUrl(path);
      }

      final wilayahList = [
        if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) 'Kec. $_selectedDistrict',
        if (_selectedCity != null && _selectedCity!.isNotEmpty) _selectedCity,
      ];
      final wilayahOperasional = wilayahList.isNotEmpty
          ? wilayahList.join(', ')
          : (_selectedCity ?? 'Malang Raya');

      // 1. Update status_mitra menjadi 'pengajuan' di tabel users
      await client
          .from('users')
          .update({'status_mitra': 'pengajuan'})
          .eq('id_user', _userId!);

      // 2. Update data identitas usaha, KTP, dan status_verifikasi di mitra_profil
      final profilePayload = {
        'nama_usaha': businessName,
        'provinsi': _selectedProvince,
        'kota': _selectedCity,
        'kecamatan': _selectedDistrict,
        'kelurahan': _selectedVillage,
        'wilayah_operasional': wilayahOperasional,
        'nik': nik,
        'foto_ktp': ktpUrl,
        'status_verifikasi': 'menunggu',
        'catatan_verifikasi': null,
      };

      final existing = await client
          .from('mitra_profil')
          .select('id_profil')
          .eq('user_id', _userId!)
          .maybeSingle();

      if (existing == null) {
        await client.from('mitra_profil').insert({
          ...profilePayload,
          'user_id': _userId,
          'status_online': false,
        });
      } else {
        await client
            .from('mitra_profil')
            .update(profilePayload)
            .eq('id_profil', existing['id_profil']);
      }

      if (!mounted) return;
      setState(() {
        _saving = false;
        _fotoKtpUrl = ktpUrl;
        _statusVerifikasi = 'menunggu';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isIndo
              ? 'Dokumen identitas usaha & KTP berhasil dikirim untuk diverifikasi.'
              : 'Business identity & ID card documents sent successfully for verification.'),
          backgroundColor: const Color(0xFF16A34A),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    final isLocked = _statusVerifikasi == 'menunggu' || _statusVerifikasi == 'terverifikasi';

    return Scaffold(
      backgroundColor: KetokColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: KetokColors.darkPrimary),
          onPressed: () => Navigator.pop(context, true),
        ),
        title: Text(
          isIndo ? 'Verifikasi Identitas Usaha & KTP' : 'Business Identity & ID Verification',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: KetokColors.darkPrimary,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: KetokColors.borderColor),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: KetokColors.darkPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusBanner(isIndo),
                  const SizedBox(height: 16),

                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 12, color: Color(0xFFDC2626)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // BAGIAN 1: IDENTITAS USAHA & WILAYAH OPERASIONAL
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KetokColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.storefront_outlined, size: 18, color: KetokColors.darkPrimary),
                            const SizedBox(width: 8),
                            Text(
                              isIndo ? 'IDENTITAS USAHA & WILAYAH' : 'BUSINESS & REGION IDENTITY',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: KetokColors.darkPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text(
                          isIndo ? 'Nama Usaha / Bengkel Mitra' : 'Partner Business / Workshop Name',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isIndo
                              ? 'Nama toko, bengkel, atau brand usaha jasa Anda.'
                              : 'Name of your shop, workshop, or service business brand.',
                          style: const TextStyle(fontSize: 11, color: KetokColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _businessNameController,
                          enabled: !isLocked && !_saving,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: isIndo ? 'Cth: Budi Servis Elektronik' : 'e.g. Budi Electronic Service',
                            filled: true,
                            fillColor: isLocked ? const Color(0xFFF9FAFB) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.darkPrimary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          isIndo ? 'Wilayah Jangkauan Operasional' : 'Operational Service Coverage Area',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isIndo
                              ? 'Tentukan domisili wilayah tempat Anda siap menerima panggilan.'
                              : 'Set your primary location where you are available for service requests.',
                          style: const TextStyle(fontSize: 11, color: KetokColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 10),

                        // Dropdown Provinsi
                        _buildDropdownField(
                          label: isIndo ? 'Provinsi' : 'Province',
                          value: _selectedProvince,
                          items: _provinces,
                          enabled: !isLocked && !_saving,
                          onChanged: _onProvinceChanged,
                        ),
                        const SizedBox(height: 10),

                        // Dropdown Kota/Kabupaten
                        _buildDropdownField(
                          label: isIndo ? 'Kota / Kabupaten' : 'City / Regency',
                          value: _selectedCity,
                          items: _cities,
                          enabled: !isLocked && !_saving && _selectedProvince != null,
                          onChanged: _onCityChanged,
                        ),
                        const SizedBox(height: 10),

                        // Dropdown Kecamatan
                        _buildDropdownField(
                          label: isIndo ? 'Kecamatan' : 'District',
                          value: _selectedDistrict,
                          items: _districts,
                          enabled: !isLocked && !_saving && _selectedCity != null,
                          onChanged: _onDistrictChanged,
                        ),
                        const SizedBox(height: 10),

                        // Dropdown Kelurahan
                        _buildDropdownField(
                          label: isIndo ? 'Kelurahan / Desa' : 'Sub-district / Village',
                          value: _selectedVillage,
                          items: _villages,
                          enabled: !isLocked && !_saving && _selectedDistrict != null,
                          onChanged: (val) => setState(() => _selectedVillage = val),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // BAGIAN 2: IDENTITAS PRIBADI (KTP)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: KetokColors.borderColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.badge_outlined, size: 18, color: KetokColors.darkPrimary),
                            const SizedBox(width: 8),
                            Text(
                              isIndo ? 'IDENTITAS PRIBADI (KTP)' : 'PERSONAL IDENTITY (ID CARD)',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: KetokColors.darkPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        Text(
                          isIndo ? 'Nomor Induk Kependudukan (NIK)' : 'ID Number (NIK)',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isIndo
                              ? 'Pastikan NIK 16 digit sesuai dengan fisik KTP asli Anda.'
                              : 'Ensure 16-digit ID number matches your original physical ID card.',
                          style: const TextStyle(fontSize: 11, color: KetokColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _nikController,
                          enabled: !isLocked && !_saving,
                          keyboardType: TextInputType.number,
                          maxLength: 16,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 1.2),
                          decoration: InputDecoration(
                            counterText: '',
                            hintText: isIndo ? 'Cth: 357301xxxxxxxxxx' : 'e.g. 357301xxxxxxxxxx',
                            filled: true,
                            fillColor: isLocked ? const Color(0xFFF9FAFB) : Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.borderColor),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: KetokColors.darkPrimary, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Text(
                          isIndo ? 'Foto KTP Asli' : 'Original ID Card Photo',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isIndo
                              ? 'Foto KTP harus jelas, terbaca, tidak terpotong, dan tidak silau.'
                              : 'ID photo must be clear, readable, not cropped, and without glare.',
                          style: const TextStyle(fontSize: 11, color: KetokColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 14),

                        // Preview Gambar KTP
                        if (_selectedPhotoBytes != null || (_fotoKtpUrl != null && _fotoKtpUrl!.isNotEmpty)) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              height: 190,
                              decoration: BoxDecoration(
                                color: KetokColors.surfaceLow,
                                border: Border.all(color: KetokColors.borderColor),
                              ),
                              child: _selectedPhotoBytes != null
                                  ? Image.memory(_selectedPhotoBytes!, fit: BoxFit.contain)
                                  : Image.network(
                                      _fotoKtpUrl!,
                                      fit: BoxFit.contain,
                                      loadingBuilder: (_, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2, color: KetokColors.darkPrimary),
                                        );
                                      },
                                      errorBuilder: (_, _, _) => Center(
                                        child: Text(isIndo ? 'Gagal memuat foto KTP' : 'Failed to load ID card photo', style: const TextStyle(fontSize: 11)),
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Tombol Pilih Foto (Hanya aktif jika belum terkunci)
                        if (!isLocked) ...[
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _saving ? null : () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                                  label: Text(isIndo ? 'Ambil Foto Kamera' : 'Take Camera Photo', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: KetokColors.darkPrimary,
                                    side: const BorderSide(color: KetokColors.borderColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _saving ? null : () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_outlined, size: 16),
                                  label: Text(isIndo ? 'Pilih dari Galeri' : 'Choose from Gallery', style: const TextStyle(fontSize: 12)),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: KetokColors.darkPrimary,
                                    side: const BorderSide(color: KetokColors.borderColor),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tombol Kirim / Submit
                  if (!isLocked) ...[
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _uploadAndSubmit,
                        style: FilledButton.styleFrom(
                          backgroundColor: KetokColors.darkPrimary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : Text(
                                _statusVerifikasi == 'ditolak'
                                    ? (isIndo ? 'Kirim Ulang Dokumen Verifikasi' : 'Resubmit Verification Documents')
                                    : (isIndo ? 'Kirim Dokumen Verifikasi' : 'Submit Verification Documents'),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    final isIndo = context.l10n.isIndonesian;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: KetokColors.borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : null,
              hint: Text(isIndo ? 'Pilih $label' : 'Select $label', style: const TextStyle(fontSize: 12, color: KetokColors.onSurfaceVariant)),
              isExpanded: true,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: KetokColors.onSurfaceVariant),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBanner(bool isIndo) {
    switch (_statusVerifikasi) {
      case 'terverifikasi':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded, size: 24, color: Color(0xFF16A34A)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIndo ? 'Identitas Usaha & KTP Terverifikasi' : 'Business Identity & ID Verified',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF15803D)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIndo
                          ? 'Data usaha dan dokumen KTP Anda telah disetujui oleh admin Ketok. Seluruh fitur pekerjaan telah aktif.'
                          : 'Your business details and ID document have been approved by Ketok admin. All work features are now active.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'menunggu':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.hourglass_top_rounded, size: 24, color: Color(0xFFD97706)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIndo ? 'Menunggu Verifikasi Admin' : 'Awaiting Admin Verification',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB45309)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIndo
                          ? 'Dokumen usaha & KTP telah terkirim dan sedang ditinjau. Menu manajemen pekerjaan akan aktif begitu disetujui.'
                          : 'Business documents & ID have been submitted and are under review. Work management will be unlocked once approved.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      case 'ditolak':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFECACA)),
          ),
          child: Row(
            children: [
              const Icon(Icons.cancel_outlined, size: 24, color: Color(0xFFDC2626)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIndo ? 'Verifikasi Ditolak' : 'Verification Rejected',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFFB91C1C)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _catatanVerifikasi != null && _catatanVerifikasi!.isNotEmpty
                          ? (isIndo ? 'Alasan: $_catatanVerifikasi' : 'Reason: $_catatanVerifikasi')
                          : (isIndo
                              ? 'Dokumen Anda belum sesuai. Silakan periksa data usaha dan unggah ulang foto yang jelas.'
                              : 'Your documents were not accepted. Please review your business information and re-upload clear photos.'),
                      style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: KetokColors.surfaceLow,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: KetokColors.borderColor),
          ),
          child: Row(
            children: [
              const Icon(Icons.badge_outlined, size: 24, color: KetokColors.darkPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isIndo ? 'Belum Terverifikasi' : 'Not Verified',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: KetokColors.darkPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isIndo
                          ? 'Lengkapi nama usaha, wilayah operasional, dan foto KTP untuk mengajukan verifikasi akun mitra.'
                          : 'Complete business name, operational area, and ID card photo to submit partner account verification.',
                      style: const TextStyle(fontSize: 11, color: KetokColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
    }
  }
}
