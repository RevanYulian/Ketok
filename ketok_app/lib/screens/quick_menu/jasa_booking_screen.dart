import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ketok_colors.dart';
import '../profile/alamat_tersimpan_screen.dart';
import 'jasa_pembayaran_screen.dart';
import 'quick_menu_shared.dart';

class JasaBookingScreen extends StatefulWidget {
  final Map<String, dynamic> service;
  final String categoryName;
  final IconData icon;

  const JasaBookingScreen({
    super.key,
    required this.service,
    required this.categoryName,
    required this.icon,
  });

  @override
  State<JasaBookingScreen> createState() => _JasaBookingScreenState();
}

class _JasaBookingScreenState extends State<JasaBookingScreen> {
  final _labelController = TextEditingController(text: 'Rumah');
  final _receiverController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saveAddressToAccount = false;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

  Map<String, dynamic>? _selectedVoucher;
  List<Map<String, dynamic>> _userVouchers = [];
  bool _loadingVouchers = true;

  List<Map<String, dynamic>> _savedAddresses = [];
  bool _loadingAddresses = true;

  String get _serviceName =>
      widget.service['nama_jasa'] as String? ?? 'Jasa Ketok';
  String get _price => formatServicePrice(widget.service['harga_mulai']);
  String get _visitPrice => formatFixedPrice(widget.service['biaya_kunjungan'] ?? 50000);
  double get _visitPriceRaw =>
      (widget.service['biaya_kunjungan'] as num?)?.toDouble() ?? 50000.0;

  @override
  void initState() {
    super.initState();
    _loadUserVouchers();
    _loadSavedAddresses();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _receiverController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadUserVouchers() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) return;
      final userRow = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      if (userRow != null) {
        final userId = userRow['id_user'] as int;
        final res = await client
            .from('pengguna_voucher')
            .select('id_pengguna_voucher, status, diklaim_pada, voucher!inner(*)')
            .eq('user_id', userId)
            .eq('status', 'aktif')
            .order('diklaim_pada', ascending: false);
        if (mounted) {
          setState(() {
            _userVouchers = List<Map<String, dynamic>>.from(res);
            _loadingVouchers = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingVouchers = false);
    }
  }

  Future<void> _loadSavedAddresses() async {
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) return;
      final userRow = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      if (userRow != null) {
        final userId = userRow['id_user'] as int;
        final res = await client
            .from('alamat_pengguna')
            .select('*')
            .eq('user_id', userId)
            .order('is_default', ascending: false)
            .order('id_alamat', ascending: true);
        if (mounted) {
          final list = List<Map<String, dynamic>>.from(res);
          setState(() {
            _savedAddresses = list;
            _loadingAddresses = false;
            // Pre-fill location if currently empty
            if (_addressController.text.trim().isEmpty) {
              if (list.isNotEmpty) {
                final defaultAddr = list.firstWhere(
                  (a) => a['is_default'] == true,
                  orElse: () => list.first,
                );
                _labelController.text =
                    defaultAddr['label'] as String? ?? 'Rumah';
                _receiverController.text =
                    defaultAddr['nama_penerima'] as String? ?? '';
                _phoneController.text =
                    defaultAddr['nomor_telepon'] as String? ?? '';
                _addressController.text =
                    defaultAddr['alamat_lengkap'] as String? ?? '';
                _notesController.text =
                    defaultAddr['catatan'] as String? ?? '';
              } else {
                _receiverController.text =
                    userRow['nama'] as String? ?? '';
                _phoneController.text =
                    userRow['nomor_telepon'] as String? ?? '';
              }
            }
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _loadingAddresses = false);
    }
  }

  double get _discountAmount {
    if (_selectedVoucher == null) return 0.0;
    final v = _selectedVoucher!['voucher'] as Map<String, dynamic>? ?? {};
    final tipe = v['tipe_diskon'] as String? ?? 'nominal';
    final nilai = (v['nilai_diskon'] as num?)?.toDouble() ?? 0.0;
    final maxDiskon = (v['maksimal_diskon'] as num?)?.toDouble();

    double disc = 0.0;
    if (tipe == 'persen') {
      disc = _visitPriceRaw * (nilai / 100.0);
      if (maxDiskon != null && disc > maxDiskon) {
        disc = maxDiskon;
      }
    } else {
      disc = nilai;
    }

    if (disc > _visitPriceRaw) {
      disc = _visitPriceRaw;
    }
    return disc;
  }

  double get _finalVisitPrice =>
      (_visitPriceRaw - _discountAmount).clamp(0.0, double.infinity);

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      initialDate: _selectedDate,
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  void _pickTime() {
    DateTime tempDateTime = DateTime(
      2026,
      1,
      1,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    context.l10n.cancel,
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  context.l10n.isIndonesian ? 'Pilih Jam Kunjungan' : 'Select Visit Time',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedTime = TimeOfDay(
                        hour: tempDateTime.hour,
                        minute: tempDateTime.minute,
                      );
                    });
                    Navigator.pop(ctx);
                  },
                  child: Text(
                    context.l10n.apply,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: tempDateTime,
                onDateTimeChanged: (newDateTime) {
                  tempDateTime = newDateTime;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.isIndonesian ? 'Pilih Alamat Tersimpan' : 'Select Saved Address',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                TextButton.icon(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AlamatTersimpanScreen(),
                      ),
                    );
                    _loadSavedAddresses();
                  },
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: Text(context.l10n.isIndonesian ? 'Kelola' : 'Manage'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingAddresses)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_savedAddresses.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.location_off_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.l10n.isIndonesian
                            ? 'Belum ada alamat tersimpan di akun Anda.'
                            : 'No saved addresses in your account.',
                        style: const TextStyle(color: KetokColors.textMuted),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AlamatTersimpanScreen(),
                            ),
                          );
                          _loadSavedAddresses();
                        },
                        icon: const Icon(Icons.add_location_alt_outlined, size: 16),
                        label: Text(context.l10n.isIndonesian ? 'Tambah Alamat Baru' : 'Add New Address'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _savedAddresses.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final addr = _savedAddresses[index];
                    final label = addr['label'] as String? ?? 'Alamat';
                    final full = addr['alamat_lengkap'] as String? ?? '';
                    final note = addr['catatan'] as String? ?? '';
                    final isDefault = addr['is_default'] as bool? ?? false;
                    final receiver = addr['nama_penerima'] as String? ?? '';
                    final phone = addr['nomor_telepon'] as String? ?? '';

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _labelController.text = label;
                          _receiverController.text = receiver;
                          _phoneController.text = phone;
                          _addressController.text = full;
                          _notesController.text = note;
                        });
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDefault
                                ? KetokColors.primary
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.location_on_outlined,
                                size: 20,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13.5,
                                        ),
                                      ),
                                      if (isDefault) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFECFDF5),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'UTAMA',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF059669),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (receiver.isNotEmpty || phone.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      '$receiver${receiver.isNotEmpty && phone.isNotEmpty ? ' • ' : ''}$phone',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 3),
                                  Text(
                                    full,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF334155),
                                    ),
                                  ),
                                  if (note.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      'Patokan: $note',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Color(0xFF94A3B8),
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
        ),
      ),
    );
  }

  void _showVoucherPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Gunakan Voucher Promo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                if (_selectedVoucher != null)
                  TextButton(
                    onPressed: () {
                      setState(() => _selectedVoucher = null);
                      Navigator.pop(ctx);
                      _showMessage('Voucher dilepas.');
                    },
                    child: const Text(
                      'Hapus',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            if (_loadingVouchers)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_userVouchers.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(Icons.confirmation_num_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Belum ada voucher aktif di akun Anda.',
                        style: TextStyle(color: KetokColors.textMuted),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _userVouchers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final pv = _userVouchers[index];
                    final v = pv['voucher'] as Map<String, dynamic>? ?? {};
                    final isSelected = _selectedVoucher?['id_pengguna_voucher'] ==
                        pv['id_pengguna_voucher'];

                    final kode = v['kode_voucher'] as String? ?? '';
                    final judul = v['judul'] as String? ?? '';
                    final deskripsi = v['deskripsi'] as String? ?? '';
                    final tipe = v['tipe_diskon'] as String? ?? 'nominal';
                    final nilai = (v['nilai_diskon'] as num?)?.toDouble() ?? 0;

                    return InkWell(
                      onTap: () {
                        setState(() => _selectedVoucher = pv);
                        Navigator.pop(ctx);
                        _showMessage('Voucher $kode berhasil diterapkan!');
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : const Color(0xFFE2E8F0),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.confirmation_num_outlined,
                                size: 22,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        kode,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                          color: Color(0xFF0284C7),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          tipe == 'persen'
                                              ? 'Diskon ${nilai.toInt()}%'
                                              : 'Potongan Rp ${nilai.toInt()}',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                  if (deskripsi.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      deskripsi,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? const Color(0xFF10B981)
                                  : const Color(0xFFCBD5E1),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _goToPaymentStep() async {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showMessage('Alamat lengkap pengerjaan wajib diisi.', isError: true);
      return;
    }

    final categoryId = widget.service['katagori_id'];
    if (categoryId is! int) {
      _showMessage(
        'Kategori jasa belum terhubung. Jalankan migration jasa terbaru.',
        isError: true,
      );
      return;
    }

    // Jika pengguna memilih simpan alamat ke akun
    if (_saveAddressToAccount) {
      try {
        final client = Supabase.instance.client;
        final authUser = client.auth.currentUser;
        if (authUser != null) {
          final userRow = await client
              .from('users')
              .select('id_user')
              .eq('auth_uid', authUser.id)
              .maybeSingle();
          if (userRow != null) {
            await client.from('alamat_pengguna').insert({
              'user_id': userRow['id_user'],
              'label': _labelController.text.trim().isEmpty
                  ? 'Alamat'
                  : _labelController.text.trim(),
              'nama_penerima': _receiverController.text.trim(),
              'nomor_telepon': _phoneController.text.trim(),
              'alamat_lengkap': address,
              'catatan': _notesController.text.trim(),
              'is_default': _savedAddresses.isEmpty,
            });
          }
        }
      } catch (_) {}
    }

    final schedule = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final fullFormattedLocation = [
      if (_labelController.text.trim().isNotEmpty)
        '[${_labelController.text.trim()}]',
      if (_receiverController.text.trim().isNotEmpty ||
          _phoneController.text.trim().isNotEmpty)
        'Kontak: ${[
          if (_receiverController.text.trim().isNotEmpty)
            _receiverController.text.trim(),
          if (_phoneController.text.trim().isNotEmpty)
            _phoneController.text.trim()
        ].join(" • ")}',
      address,
      if (_notesController.text.trim().isNotEmpty)
        'Patokan: ${_notesController.text.trim()}',
    ].join('\n');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => JasaPembayaranScreen(
          service: widget.service,
          categoryName: widget.categoryName,
          icon: widget.icon,
          location: fullFormattedLocation,
          schedule: schedule,
          note: _noteController.text.trim(),
          selectedVoucher: _selectedVoucher,
          visitPriceRaw: _visitPriceRaw,
          discountAmount: _discountAmount,
          finalVisitPrice: _finalVisitPrice,
        ),
      ),
    );
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF10B981),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FB),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: isIndo ? 'Kembali' : 'Back',
        ),
        title: Text(
          isIndo ? 'Pesan Jasa' : 'Book Service',
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                _buildServiceSummary(),
                const SizedBox(height: 20),
                _sectionTitle(
                  Icons.location_on_outlined,
                  isIndo ? 'Lokasi Pengerjaan' : 'Service Location',
                ),
                _buildLocationCard(isIndo),
                const SizedBox(height: 20),
                _sectionTitle(
                  Icons.calendar_today_outlined,
                  isIndo ? 'Jadwal Kedatangan Teknisi' : 'Technician Arrival Schedule',
                ),
                _buildScheduleCard(),
                const SizedBox(height: 20),
                _sectionTitle(
                  Icons.edit_note_rounded,
                  isIndo ? 'Catatan Tambahan (Opsional)' : 'Additional Notes (Optional)',
                ),
                _buildNoteCard(isIndo),
                const SizedBox(height: 20),
                _sectionTitle(
                  Icons.confirmation_num_outlined,
                  isIndo ? 'Voucher & Promo Diskon' : 'Voucher & Promo Discounts',
                ),
                _buildVoucherCard(isIndo),
                const SizedBox(height: 20),
                _sectionTitle(
                  Icons.payments_outlined,
                  isIndo ? 'Rincian Biaya Transparan' : 'Transparent Cost Breakdown',
                ),
                _buildCostCard(isIndo),
              ],
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: FilledButton.icon(
                onPressed: _goToPaymentStep,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(isIndo ? 'Lanjut ke Pembayaran' : 'Proceed to Payment'),
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
      ),
    );
  }

  Widget _buildServiceSummary() => QuickMenuCard(
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: KetokColors.surfaceLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(widget.icon, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.categoryName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: KetokColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                _serviceName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(_price, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _sectionTitle(IconData icon, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );

  Widget _buildLocationCard(bool isIndo) => QuickMenuCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isIndo ? 'Alamat Pengerjaan' : 'Service Address',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
            const SizedBox(width: 8),
            InkWell(
              onTap: _showAddressPicker,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBAE6FD)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.bookmark_outline_rounded,
                      size: 14,
                      color: Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isIndo ? 'Pilih Tersimpan' : 'Select Saved',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _labelController,
          decoration: InputDecoration(
            labelText: isIndo
                ? 'Label Alamat (Contoh: Rumah, Kantor, Kost)'
                : 'Address Label (e.g. Home, Office, Apt)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.label_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _receiverController,
                decoration: InputDecoration(
                  labelText: isIndo ? 'Nama Penerima / Kontak' : 'Recipient / Contact Name',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: isIndo ? 'No. WhatsApp / HP' : 'WhatsApp / Phone No.',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: InputDecoration(
            labelText: isIndo ? 'Alamat Lengkap' : 'Full Address',
            hintText: isIndo
                ? 'Nama jalan, nomor rumah, RT/RW, kelurahan, kecamatan'
                : 'Street name, unit number, district, city',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.home_outlined, size: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          decoration: InputDecoration(
            labelText: isIndo ? 'Patokan / Catatan Alamat (Opsional)' : 'Landmark / Address Notes (Optional)',
            hintText: isIndo ? 'Contoh: Pagar hitam, samping masjid' : 'e.g. Black gate, next to convenience store',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.info_outline_rounded, size: 20),
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          dense: true,
          title: Text(
            isIndo
                ? 'Simpan alamat ini ke daftar Alamat Tersimpan saya'
                : 'Save this address to my Saved Addresses',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          value: _saveAddressToAccount,
          onChanged: (val) => setState(() => _saveAddressToAccount = val),
        ),
      ],
    ),
  );

  Widget _buildScheduleCard() => QuickMenuCard(
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.event_outlined),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickTime,
            icon: const Icon(Icons.schedule_outlined),
            label: Text(_selectedTime.format(context)),
          ),
        ),
      ],
    ),
  );

  Widget _buildNoteCard(bool isIndo) => QuickMenuCard(
    child: TextField(
      controller: _noteController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: isIndo ? 'Catatan tambahan' : 'Additional notes',
        hintText: isIndo
            ? 'Tuliskan detail kendala atau rincian layanan'
            : 'Describe the issue or service requirements',
      ),
    ),
  );

  Widget _buildVoucherCard(bool isIndo) {
    final hasVoucher = _selectedVoucher != null;
    final v = _selectedVoucher?['voucher'] as Map<String, dynamic>?;

    return QuickMenuCard(
      child: InkWell(
        onTap: _showVoucherPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: hasVoucher
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasVoucher
                      ? Icons.check_circle_rounded
                      : Icons.confirmation_num_outlined,
                  size: 22,
                  color: hasVoucher
                      ? const Color(0xFF059669)
                      : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasVoucher
                          ? (v?['judul'] as String? ?? (isIndo ? 'Voucher Terpasang' : 'Voucher Applied'))
                          : (isIndo ? 'Gunakan Voucher Diskon' : 'Apply Discount Voucher'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: hasVoucher
                            ? const Color(0xFF059669)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasVoucher
                          ? (isIndo
                              ? 'Hemat ${formatFixedPrice(_discountAmount)} • Kode: ${v?['kode_voucher']}'
                              : 'Save ${formatFixedPrice(_discountAmount)} • Code: ${v?['kode_voucher']}')
                          : (_userVouchers.isNotEmpty
                              ? (isIndo
                                  ? '${_userVouchers.length} voucher aktif tersedia di akun Anda'
                                  : '${_userVouchers.length} active vouchers available')
                              : (isIndo
                                  ? 'Pilih voucher untuk hemat biaya kunjungan'
                                  : 'Select a voucher to save on visit fees')),
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                hasVoucher
                    ? (isIndo ? 'Ubah' : 'Change')
                    : (isIndo ? 'Pilih' : 'Select'),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostCard(bool isIndo) {
    final hasDiscount = _discountAmount > 0;
    return QuickMenuCard(
      child: Column(
        children: [
          _costRow(isIndo ? 'Kisaran Biaya Layanan' : 'Estimated Service Fee', _price),
          const SizedBox(height: 8),
          _costRow(isIndo ? 'Biaya Kunjungan / Pengecekan' : 'Visit / Inspection Fee', _visitPrice),
          if (hasDiscount) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_num_outlined,
                        size: 15,
                        color: Color(0xFF059669),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        isIndo
                            ? 'Diskon Promo (${_selectedVoucher!['voucher']['kode_voucher']})'
                            : 'Promo Discount (${_selectedVoucher!['voucher']['kode_voucher']})',
                        style: const TextStyle(
                          color: Color(0xFF059669),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '-${formatFixedPrice(_discountAmount)}',
                  style: const TextStyle(
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  isIndo ? 'Total Biaya Kunjungan' : 'Total Visit Fee',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount)
                    Text(
                      _visitPrice,
                      style: const TextStyle(
                        fontSize: 11.5,
                        decoration: TextDecoration.lineThrough,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  Text(
                    formatFixedPrice(_finalVisitPrice),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isIndo
                ? 'Biaya ini adalah ongkos kunjungan awal teknisi. Biaya perbaikan & suku cadang akan dikonfirmasi transparan setelah pengecekan di lokasi.'
                : 'This is the initial technician call-out fee. Repair and spare part costs will be confirmed transparently after inspection on site.',
            style: const TextStyle(fontSize: 11, color: KetokColors.textMuted),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  Widget _costRow(String label, String value) => Row(
    children: [
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: KetokColors.textMuted),
        ),
      ),
      Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
    ],
  );
}
