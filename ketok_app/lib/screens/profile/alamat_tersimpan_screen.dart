import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';
import '../../widgets/ketok_colors.dart';

class AddressItem {
  final int id;
  final String label;
  final String receiverName;
  final String phoneNumber;
  final String fullAddress;
  final String notes;
  final bool isDefault;

  const AddressItem({
    required this.id,
    required this.label,
    required this.receiverName,
    required this.phoneNumber,
    required this.fullAddress,
    this.notes = '',
    this.isDefault = false,
  });

  factory AddressItem.fromMap(Map<String, dynamic> map) {
    return AddressItem(
      id: map['id_alamat'] as int,
      label: map['label'] as String? ?? 'Alamat',
      receiverName: map['nama_penerima'] as String? ?? '',
      phoneNumber: map['nomor_telepon'] as String? ?? '',
      fullAddress: map['alamat_lengkap'] as String? ?? '',
      notes: map['catatan'] as String? ?? '',
      isDefault: map['is_default'] as bool? ?? false,
    );
  }
}

class AlamatTersimpanScreen extends StatefulWidget {
  const AlamatTersimpanScreen({super.key});

  @override
  State<AlamatTersimpanScreen> createState() => _AlamatTersimpanScreenState();
}

class _AlamatTersimpanScreenState extends State<AlamatTersimpanScreen> {
  bool _isLoading = true;
  int? _userId;
  List<AddressItem> _addresses = [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
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
        _userId = userRow['id_user'] as int;
        final res = await client
            .from('alamat_pengguna')
            .select('*')
            .eq('user_id', _userId!)
            .order('is_default', ascending: false)
            .order('id_alamat', ascending: true);

        if (mounted) {
          setState(() {
            _addresses = (res as List)
                .map((m) => AddressItem.fromMap(m as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefaultAddress(int id) async {
    if (_userId == null) return;
    try {
      final client = Supabase.instance.client;
      // Set all to false
      await client
          .from('alamat_pengguna')
          .update({'is_default': false})
          .eq('user_id', _userId!);

      // Set target to true
      await client
          .from('alamat_pengguna')
          .update({'is_default': true})
          .eq('id_alamat', id);

      await _loadAddresses();

      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo
                  ? 'Alamat utama berhasil diubah.'
                  : 'Primary address changed successfully.',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo
                  ? 'Gagal mengubah alamat utama: $e'
                  : 'Failed to change primary address: $e',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(int id) async {
    try {
      final client = Supabase.instance.client;
      await client.from('alamat_pengguna').delete().eq('id_alamat', id);
      await _loadAddresses();

      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo ? 'Alamat berhasil dihapus.' : 'Address deleted successfully.',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final isIndo = context.l10n.isIndonesian;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo
                  ? 'Gagal menghapus alamat: $e'
                  : 'Failed to delete address: $e',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _showAddAddressModal([AddressItem? existing]) {
    final isIndo = context.l10n.isIndonesian;
    final labelCtrl = TextEditingController(text: existing?.label ?? '');
    final nameCtrl = TextEditingController(text: existing?.receiverName ?? '');
    final phoneCtrl = TextEditingController(text: existing?.phoneNumber ?? '');
    final addressCtrl = TextEditingController(text: existing?.fullAddress ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    bool isDef = existing?.isDefault ?? (_addresses.isEmpty);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
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
                Text(
                  existing == null
                      ? (isIndo ? 'Tambah Alamat Baru' : 'Add New Address')
                      : (isIndo ? 'Edit Alamat' : 'Edit Address'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: labelCtrl,
                  decoration: InputDecoration(
                    labelText: isIndo
                        ? 'Label Alamat (Contoh: Rumah, Kantor)'
                        : 'Address Label (e.g. Home, Office)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    labelText: isIndo ? 'Nama Penerima' : 'Recipient Name',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: isIndo ? 'Nomor WhatsApp / HP' : 'WhatsApp / Phone Number',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: isIndo ? 'Alamat Lengkap' : 'Full Address',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  decoration: InputDecoration(
                    labelText: isIndo ? 'Patokan / Catatan (Opsional)' : 'Landmark / Notes (Optional)',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(isIndo ? 'Jadikan sebagai Alamat Utama' : 'Set as Primary Address'),
                  value: isDef,
                  onChanged: (val) => setModalState(() => isDef = val),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: isSaving
                        ? null
                        : () async {
                            final addressText = addressCtrl.text.trim();
                            if (addressText.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isIndo
                                        ? 'Alamat tidak boleh kosong.'
                                        : 'Address cannot be empty.',
                                  ),
                                ),
                              );
                              return;
                            }

                            if (_userId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isIndo
                                        ? 'Sesi user tidak ditemukan.'
                                        : 'User session not found.',
                                  ),
                                ),
                              );
                              return;
                            }

                            setModalState(() => isSaving = true);
                            try {
                              final client = Supabase.instance.client;

                              // If setting as default, clear others
                              if (isDef) {
                                await client
                                    .from('alamat_pengguna')
                                    .update({'is_default': false})
                                    .eq('user_id', _userId!);
                              }

                              final payload = {
                                'user_id': _userId,
                                'label': labelCtrl.text.trim().isEmpty
                                    ? (isIndo ? 'Alamat' : 'Address')
                                    : labelCtrl.text.trim(),
                                'nama_penerima': nameCtrl.text.trim(),
                                'nomor_telepon': phoneCtrl.text.trim(),
                                'alamat_lengkap': addressText,
                                'catatan': notesCtrl.text.trim(),
                                'is_default': isDef,
                                'updated_at': DateTime.now().toIso8601String(),
                              };

                              if (existing != null) {
                                await client
                                    .from('alamat_pengguna')
                                    .update(payload)
                                    .eq('id_alamat', existing.id);
                              } else {
                                await client
                                    .from('alamat_pengguna')
                                    .insert(payload);
                              }

                              await _loadAddresses();

                              if (ctx.mounted) Navigator.pop(ctx);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      existing == null
                                          ? (isIndo
                                              ? 'Alamat berhasil ditambahkan ke database.'
                                              : 'Address added to database successfully.')
                                          : (isIndo
                                              ? 'Alamat berhasil diperbarui.'
                                              : 'Address updated successfully.'),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            } catch (e) {
                              setModalState(() => isSaving = false);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isIndo
                                          ? 'Gagal menyimpan alamat: $e'
                                          : 'Failed to save address: $e',
                                    ),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0F172A),
                    ),
                    child: isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(isIndo ? 'Simpan Alamat' : 'Save Address'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          isIndo ? 'Alamat Tersimpan' : 'Saved Addresses',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        ),
        child: FilledButton.icon(
          onPressed: () => _showAddAddressModal(),
          icon: const Icon(Icons.add_location_alt_outlined),
          label: Text(isIndo ? 'Tambah Alamat Baru' : 'Add New Address'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF0F172A),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAddresses,
              child: _addresses.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(32),
                      children: [
                        const SizedBox(height: 80),
                        const Icon(
                          Icons.location_off_outlined,
                          size: 64,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isIndo
                              ? 'Belum ada alamat tersimpan'
                              : 'No saved addresses yet',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isIndo
                              ? 'Tambahkan alamat rumah atau lokasi kerja untuk mempermudah pemesanan jasa teknisi.'
                              : 'Add your home or work address to make booking technician services easier.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Color(0xFF64748B)),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: _addresses.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final item = _addresses[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: item.isDefault
                                  ? KetokColors.primary
                                  : const Color(0xFFE2E8F0),
                              width: item.isDefault ? 1.5 : 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x06000000),
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
                                    Text(
                                      item.label,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (item.isDefault)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isIndo ? 'UTAMA' : 'PRIMARY',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    PopupMenuButton<String>(
                                      onSelected: (val) {
                                        if (val == 'default') {
                                          _setDefaultAddress(item.id);
                                        } else if (val == 'edit') {
                                          _showAddAddressModal(item);
                                        } else if (val == 'delete') {
                                          _deleteAddress(item.id);
                                        }
                                      },
                                      itemBuilder: (context) => [
                                        if (!item.isDefault)
                                          PopupMenuItem(
                                            value: 'default',
                                            child: Text(
                                              isIndo
                                                  ? 'Jadikan Alamat Utama'
                                                  : 'Set as Primary Address',
                                            ),
                                          ),
                                        PopupMenuItem(
                                          value: 'edit',
                                          child: Text(
                                            isIndo ? 'Edit Alamat' : 'Edit Address',
                                          ),
                                        ),
                                        PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            isIndo ? 'Hapus Alamat' : 'Delete Address',
                                            style: const TextStyle(color: Colors.red),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (item.receiverName.isNotEmpty ||
                                    item.phoneNumber.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    '${item.receiverName}${item.receiverName.isNotEmpty && item.phoneNumber.isNotEmpty ? ' • ' : ''}${item.phoneNumber}',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 4),
                                Text(
                                  item.fullAddress,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF334155),
                                    height: 1.35,
                                  ),
                                ),
                                if (item.notes.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.info_outline_rounded,
                                        size: 14,
                                        color: Color(0xFF94A3B8),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${isIndo ? 'Patokan' : 'Landmark'}: ${item.notes}',
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            color: Color(0xFF64748B),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
