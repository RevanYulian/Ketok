import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'beranda_screen.dart';
import '../services/app_config_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _supabase = Supabase.instance.client;

  bool _isLogin = true;
  bool _obscurePassword = true;
  bool _loading = false;

  final _identifierController =
      TextEditingController(); // login: username/email
  final _namaController = TextEditingController(); // register
  final _emailController = TextEditingController(); // register
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static const _bgColor = Color(0xFFF5F4F7);
  static const _darkColor = Color(0xFF1B1D2B);
  static const _fieldBorderColor = Color(0xFFE3E1E8);

  @override
  void dispose() {
    _identifierController.dispose();
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    if (isError) debugPrint('LoginScreen error: $message');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade600,
        duration: Duration(seconds: isError ? 6 : 3),
      ),
    );
  }

  /// Cari email berdasarkan input yang bisa berupa email atau nama.
  Future<String?> _resolveEmail(String identifier) async {
    if (identifier.contains('@')) return identifier;
    try {
      final result = await _supabase
          .from('users')
          .select('email')
          .eq('nama', identifier)
          .maybeSingle();
      return result?['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleLogin() async {
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showMessage('Username/email dan kata sandi wajib diisi.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final email = await _resolveEmail(identifier);
      if (email == null) {
        _showMessage('Akun tidak ditemukan.', isError: true);
        return;
      }

      await _supabase.auth.signInWithPassword(email: email, password: password);
      
      _showMessage('Login berhasil!');

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BerandaScreen()),
      );
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage('Gagal login: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage('Semua kolom wajib diisi.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showMessage('Konfirmasi kata sandi tidak cocok.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showMessage('Kata sandi minimal 6 karakter.', isError: true);
      return;
    }

    setState(() => _loading = true);
    try {
      final authResponse = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      final authUid = authResponse.user?.id;
      if (authUid == null) {
        _showMessage(
          'Pendaftaran diproses. Cek email untuk verifikasi (jika diaktifkan).',
        );
        return;
      }

      // Link Supabase Auth dengan profil Mitra pada skema aplikasi.
      try {
        await _supabase.from('users').insert({
          'nama': nama,
          'email': email,
          'role': 'mitra',
          'status_mitra': 'pending',
          'auth_uid': authUid,
        });
      } on PostgrestException catch (e) {
        // Error spesifik dari database -- paling sering karena kolom
        // 'auth_uid' belum dibuat, atau RLS memblokir insert.
        _showMessage(
          'Akun auth berhasil dibuat, TAPI gagal simpan ke tabel users: '
          '${e.message} (code: ${e.code})',
          isError: true,
        );
        return;
      }

      _showMessage('Registrasi berhasil! Silakan login.');
      setState(() => _isLogin = true);
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') || e.message.toLowerCase().contains('already in use')) {
        _showMessage('Email sudah terdaftar di Ketok App. Silakan gunakan tab Login untuk masuk, lalu Anda bisa mendaftar sebagai Mitra di dalam aplikasi.', isError: true);
        return;
      }
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage('Gagal mendaftar: $e', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa Kata Sandi'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan email kamu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      _showMessage('Link reset kata sandi sudah dikirim ke $email.');
    } catch (e) {
      _showMessage('Gagal mengirim link reset: $e', isError: true);
    }
  }

  Future<void> _handleOAuth(OAuthProvider provider) async {
    try {
      await _supabase.auth.signInWithOAuth(provider);
    } catch (e) {
      _showMessage('Gagal login dengan ${provider.name}: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              _buildLogo(),
              const SizedBox(height: 16),
              _buildAppTitle(),
              const SizedBox(height: 32),
              _buildTabSelector(),
              const SizedBox(height: 24),
              _isLogin ? _buildLoginForm() : _buildRegisterForm(),
              const SizedBox(height: 24),
              _buildDivider(),
              const SizedBox(height: 20),
              _buildOAuthButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        final logoUrl = config?.logoUrl;
        final isNetwork = logoUrl != null && (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

        return Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: isNetwork
                ? Image.network(
                    logoUrl,
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/logo_mitra.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/logo_mitra.png',
                    width: 76,
                    height: 76,
                    fit: BoxFit.cover,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildAppTitle() {
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        final appName = config?.namaAplikasi ?? 'Ketok Mitra';
        final tagline = config?.tagline ?? 'Portal Khusus Mitra';

        return Column(
          children: [
            Text(
              appName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _darkColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tagline,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.black45),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7E5EC),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _tabButton('Login', true)),
          Expanded(child: _tabButton('Daftar Mitra', false)),
        ],
      ),
    );
  }

  Widget _tabButton(String label, bool isLoginTab) {
    final selected = _isLogin == isLoginTab;
    return GestureDetector(
      onTap: () => setState(() => _isLogin = isLoginTab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? _darkColor : Colors.black45,
          ),
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black38),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkColor),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Email atau Nama Mitra'),
        TextField(
          controller: _identifierController,
          decoration: _fieldDecoration('Masukkan email atau nama mitra'),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Kata Sandi'),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration('Masukkan kata sandi').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _handleForgotPassword,
            child: const Text(
              'Lupa kata sandi?',
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSubmitButton('Masuk', _handleLogin),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('Nama Lengkap'),
        TextField(
          controller: _namaController,
          decoration: _fieldDecoration('Masukkan nama lengkap'),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Email'),
        TextField(
          controller: _emailController,
          decoration: _fieldDecoration('Masukkan email'),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Kata Sandi'),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration('Masukkan kata sandi').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black45,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel('Konfirmasi Kata Sandi'),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration('Ulangi kata sandi'),
        ),
        const SizedBox(height: 20),
        _buildSubmitButton('Daftar', _handleRegister),
      ],
    );
  }

  Widget _buildSubmitButton(String label, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: _loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(color: _fieldBorderColor)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('ATAU', style: TextStyle(color: Colors.black38)),
        ),
        Expanded(child: Divider(color: _fieldBorderColor)),
      ],
    );
  }

  Widget _buildOAuthButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _oauthCircleButton(
          assetPath: 'assets/images/google_logo.png',
          onTap: () => _handleOAuth(OAuthProvider.google),
        ),
        const SizedBox(width: 16),
        _oauthCircleButton(
          assetPath: 'assets/images/apple_logo.png',
          onTap: () => _handleOAuth(OAuthProvider.apple),
        ),
      ],
    );
  }

  Widget _oauthCircleButton({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Image.asset(assetPath, fit: BoxFit.contain),
      ),
    );
  }
}
