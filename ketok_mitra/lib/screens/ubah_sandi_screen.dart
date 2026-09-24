import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../widgets/ketok_colors.dart';
import '../l10n/app_localizations.dart';

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isIndo ? 'Harap isi semua kolom.' : 'Please fill in all fields.'),
      ));
      return;
    }
    if (newPwd.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isIndo ? 'Kata sandi baru minimal 6 karakter.' : 'New password must be at least 6 characters.'),
      ));
      return;
    }
    if (newPwd != confPwd) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isIndo ? 'Konfirmasi kata sandi tidak cocok.' : 'Password confirmation does not match.'),
      ));
      return;
    }
    
    setState(() => _loading = true);
    try {
      final supabase = Supabase.instance.client;
      final email = supabase.auth.currentUser?.email;
      if (email == null) throw Exception(isIndo ? 'Sesi tidak valid. Silakan login kembali.' : 'Invalid session. Please log in again.');
      
      // Verifikasi sandi lama dengan mencoba login
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isIndo ? 'Kata sandi berhasil diperbarui.' : 'Password updated successfully.'),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isIndo ? 'Gagal: Pastikan kata sandi lama benar.' : 'Failed: Make sure old password is correct.'),
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
        title: Text(isIndo ? 'Keamanan Akun' : 'Account Security', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              isIndo ? 'Ubah Kata Sandi' : 'Change Password',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              isIndo
                  ? 'Untuk keamanan akun Anda, masukkan kata sandi saat ini sebelum membuat kata sandi baru.'
                  : 'For your account security, enter your current password before creating a new password.',
              style: const TextStyle(color: KetokColors.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 32),
            
            _buildTextField(
              controller: _oldPasswordController,
              label: isIndo ? 'Kata Sandi Saat Ini' : 'Current Password',
              obscure: _obscureOld,
              onToggle: () => setState(() => _obscureOld = !_obscureOld),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _newPasswordController,
              label: isIndo ? 'Kata Sandi Baru' : 'New Password',
              obscure: _obscureNew,
              onToggle: () => setState(() => _obscureNew = !_obscureNew),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _confirmController,
              label: isIndo ? 'Konfirmasi Kata Sandi Baru' : 'Confirm New Password',
              obscure: _obscureConfirm,
              onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _loading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: KetokColors.darkPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _loading 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(isIndo ? 'Simpan Kata Sandi' : 'Save Password', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: KetokColors.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KetokColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KetokColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: KetokColors.darkPrimary, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: KetokColors.onSurfaceVariant),
          onPressed: onToggle,
        ),
      ),
    );
  }
}
