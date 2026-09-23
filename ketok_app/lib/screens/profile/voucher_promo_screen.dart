import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VoucherPromoScreen extends StatefulWidget {
  const VoucherPromoScreen({super.key});

  @override
  State<VoucherPromoScreen> createState() => _VoucherPromoScreenState();
}

class _VoucherPromoScreenState extends State<VoucherPromoScreen> {
  final _claimController = TextEditingController();
  bool _isLoading = true;
  bool _isClaiming = false;
  String _filter = 'aktif'; // 'semua', 'aktif', 'terpakai'
  List<Map<String, dynamic>> _userVouchers = [];

  @override
  void initState() {
    super.initState();
    _loadVouchers();
  }

  @override
  void dispose() {
    _claimController.dispose();
    super.dispose();
  }

  Future<void> _loadVouchers() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) {
        setState(() => _isLoading = false);
        return;
      }

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
            .order('diklaim_pada', ascending: false);

        if (mounted) {
          setState(() {
            _userVouchers = List<Map<String, dynamic>>.from(res);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _claimNewVoucher() async {
    final code = _claimController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan kode voucher terlebih dahulu.')),
      );
      return;
    }

    setState(() => _isClaiming = true);
    try {
      final client = Supabase.instance.client;
      final authUser = client.auth.currentUser;
      if (authUser == null) throw Exception('Sesi login tidak valid.');

      final userRow = await client
          .from('users')
          .select('id_user')
          .eq('auth_uid', authUser.id)
          .maybeSingle();
      if (userRow == null) throw Exception('Pengguna tidak ditemukan.');
      final userId = userRow['id_user'] as int;

      // Check if voucher exists in master table
      final voucherRow = await client
          .from('voucher')
          .select('*')
          .eq('kode_voucher', code)
          .eq('aktif', true)
          .maybeSingle();

      if (voucherRow == null) {
        throw Exception('Kode voucher tidak ditemukan atau sudah tidak aktif.');
      }

      final voucherId = voucherRow['id_voucher'] as int;

      // Check if user already owns this voucher
      final alreadyOwned = await client
          .from('pengguna_voucher')
          .select('id_pengguna_voucher, status')
          .eq('user_id', userId)
          .eq('voucher_id', voucherId)
          .maybeSingle();

      if (alreadyOwned != null) {
        if (alreadyOwned['status'] == 'aktif') {
          throw Exception('Anda sudah memiliki voucher ini di akun Anda.');
        } else {
          throw Exception('Voucher ini sudah pernah Anda gunakan sebelumnya.');
        }
      }

      // Insert into pengguna_voucher
      await client.from('pengguna_voucher').insert({
        'user_id': userId,
        'voucher_id': voucherId,
        'status': 'aktif',
      });

      _claimController.clear();
      await _loadVouchers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat! Voucher $code berhasil diklaim ke akun Anda.'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
  }

  List<Map<String, dynamic>> get _filteredVouchers {
    if (_filter == 'aktif') {
      return _userVouchers.where((v) => v['status'] == 'aktif').toList();
    }
    if (_filter == 'terpakai') {
      return _userVouchers.where((v) => v['status'] != 'aktif').toList();
    }
    return _userVouchers;
  }

  String _formatCurrency(num value) {
    return value.round().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final vouchers = _filteredVouchers;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali',
        ),
        title: const Text(
          'Voucher & Promo Saya',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadVouchers,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat ulang',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadVouchers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Claim new voucher card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x04000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Punya Kode Promo Tambahan?',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Klaim kode promo untuk menambahkan voucher ke koleksi akun Anda.',
                      style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _claimController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'Contoh: KETOKHEMAT',
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        FilledButton(
                          onPressed: _isClaiming ? null : _claimNewVoucher,
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF0F172A),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                          ),
                          child: _isClaiming
                              ? const SizedBox.square(
                                  dimension: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Klaim',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Filter Tabs
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'VOUCHER YANG DIMILIKI',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '${_userVouchers.where((v) => v['status'] == 'aktif').length} Tersedia',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  _buildFilterTab('Voucher Aktif', 'aktif'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Semua', 'semua'),
                  const SizedBox(width: 8),
                  _buildFilterTab('Sudah Terpakai', 'terpakai'),
                ],
              ),
              const SizedBox(height: 14),

              // Vouchers list
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (vouchers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        size: 48,
                        color: Color(0xFFCBD5E1),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _filter == 'aktif'
                            ? 'Belum ada voucher aktif'
                            : _filter == 'terpakai'
                            ? 'Belum ada voucher yang terpakai'
                            : 'Belum ada voucher di akun Anda',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Voucher yang Anda miliki otomatis dapat dipilih saat memesan jasa teknisi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: vouchers.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final pv = vouchers[index];
                    final v = pv['voucher'] as Map<String, dynamic>? ?? {};
                    final isAktif = pv['status'] == 'aktif';

                    final kode = v['kode_voucher'] as String? ?? 'PROMO';
                    final judul = v['judul'] as String? ?? 'Diskon Spesial';
                    final deskripsi = v['deskripsi'] as String? ?? '';
                    final tipeDiskon = v['tipe_diskon'] as String? ?? 'nominal';
                    final nilaiDiskon = (v['nilai_diskon'] as num?)?.toDouble() ?? 0;
                    final minTrx = (v['minimal_transaksi'] as num?)?.toDouble() ?? 0;

                    String diskonLabel = '';
                    if (tipeDiskon == 'persen') {
                      diskonLabel = 'Diskon ${nilaiDiskon.toInt()}%';
                    } else {
                      diskonLabel = 'Potongan Rp ${_formatCurrency(nilaiDiskon)}';
                    }

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isAktif
                              ? const Color(0xFFE2E8F0)
                              : const Color(0xFFF1F5F9),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x04000000),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isAktif
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isAktif
                                            ? Icons.check_circle_rounded
                                            : Icons.history_rounded,
                                        size: 13,
                                        color: isAktif
                                            ? const Color(0xFF059669)
                                            : const Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        isAktif ? 'SUDAH DIMILIKI' : 'SUDAH TERPAKAI',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          color: isAktif
                                              ? const Color(0xFF059669)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Text(
                                    kode,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              judul,
                              style: TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: isAktif
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF94A3B8),
                              ),
                            ),
                            if (deskripsi.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                deskripsi,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  color: Color(0xFF64748B),
                                  height: 1.35,
                                ),
                              ),
                            ],
                            const SizedBox(height: 12),
                            const Divider(color: Color(0xFFF1F5F9), height: 1),
                            const SizedBox(height: 10),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      diskonLabel,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: isAktif
                                            ? const Color(0xFF0284C7)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                    if (minTrx > 0)
                                      Text(
                                        'Min. Transaksi: Rp ${_formatCurrency(minTrx)}',
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                  ],
                                ),
                                if (!isAktif)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'Terpakai',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () => setState(() => _filter = value),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }
}
