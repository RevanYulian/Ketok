import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../l10n/app_localizations.dart';

class UbahSandiScreen extends StatefulWidget {
  const UbahSandiScreen({super.key});

  @override
  State<UbahSandiScreen> createState() => _UbahSandiScreenState();
}

class _UbahSandiScreenState extends State<UbahSandiScreen> {
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();
  
  bool _loading = false;
  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isIndo = context.l10n.isIndonesian;
    final oldPwd = _oldPasswordController.text;
    final newPwd = _newPasswordController.text;
    final confPwd = _confirmController.text;
    
    if (oldPwd.isEmpty || newPwd.isEmpty || confPwd.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isIndo
                ? 'Harap isi semua kolom kata sandi.'
                : 'Please fill in all password fields.',
          ),
        ),
      );
      return;
    }
    if (newPwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isIndo
                ? 'Kata sandi baru minimal 6 karakter.'
                : 'New password must be at least 6 characters.',
          ),
        ),
      );
      return;
    }
    if (newPwd != confPwd) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isIndo
                ? 'Konfirmasi kata sandi tidak cocok.'
                : 'Password confirmation does not match.',
          ),
        ),
      );
      return;
    }
    
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;
      if (email == null) {
        throw Exception(
          isIndo
              ? 'Sesi tidak valid. Silakan login kembali.'
              : 'Invalid session. Please login again.',
        );
      }
      
      // Verifikasi sandi lama dengan mencoba re-autentikasi
      await supabase.auth.signInWithPassword(
        email: email,
        password: oldPwd,
      );
      
      // Ubah ke sandi baru
      await supabase.auth.updateUser(
        UserAttributes(password: newPwd),
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo
                  ? 'Kata sandi berhasil diperbarui.'
                  : 'Password updated successfully.',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isIndo
                  ? 'Gagal: Pastikan kata sandi lama Anda benar.'
                  : 'Failed: Make sure your current password is correct.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIndo = context.l10n.isIndonesian;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isIndo ? 'Keamanan Akun' : 'Account Security',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              isIndo ? 'Ubah Kata Sandi' : 'Change Password',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              isIndo
                  ? 'Untuk keamanan akun Anda, masukkan kata sandi saat ini sebelum membuat kata sandi baru.'
                  : 'For your account security, enter your current password before creating a new password.',
              style: const TextStyle(color: Color(0xFF64748B), height: 1.4),
            ),
            const SizedBox(height: 28),
            
            TextField(
              controller: _oldPasswordController,
              obscureText: _obscureOld,
              decoration: InputDecoration(
                labelText: isIndo ? 'Kata Sandi Saat Ini' : 'Current Password',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureOld ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureOld = !_obscureOld),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _newPasswordController,
              obscureText: _obscureNew,
              decoration: InputDecoration(
                labelText: isIndo
                    ? 'Kata Sandi Baru (Min. 6 Karakter)'
                    : 'New Password (Min. 6 Characters)',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            TextField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              decoration: InputDecoration(
                labelText: isIndo
                    ? 'Konfirmasi Kata Sandi Baru'
                    : 'Confirm New Password',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading 
                  ? const SizedBox(
                      width: 20, 
                      height: 20, 
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      isIndo ? 'Simpan Kata Sandi' : 'Save Password',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
