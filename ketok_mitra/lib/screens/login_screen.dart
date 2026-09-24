import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'beranda_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/app_config_service.dart';
import '../services/locale_service.dart';

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
    final l10n = context.l10n;
    final identifier = _identifierController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      _showMessage(
        l10n.isIndonesian
            ? 'Username/email dan kata sandi wajib diisi.'
            : 'Username/email and password are required.',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final email = await _resolveEmail(identifier);
      if (email == null) {
        _showMessage(
          l10n.isIndonesian ? 'Akun tidak ditemukan.' : 'Account not found.',
          isError: true,
        );
        return;
      }

      await _supabase.auth.signInWithPassword(email: email, password: password);
      
      _showMessage(
        l10n.isIndonesian ? 'Login berhasil!' : 'Login successful!',
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BerandaScreen()),
      );
    } on AuthException catch (e) {
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage(
        l10n.isIndonesian ? 'Gagal login: $e' : 'Login failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleRegister() async {
    final l10n = context.l10n;
    final nama = _namaController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (nama.isEmpty || email.isEmpty || password.isEmpty) {
      _showMessage(
        l10n.isIndonesian ? 'Semua kolom wajib diisi.' : 'All fields are required.',
        isError: true,
      );
      return;
    }
    if (password != confirmPassword) {
      _showMessage(
        l10n.isIndonesian ? 'Konfirmasi kata sandi tidak cocok.' : 'Password confirmation does not match.',
        isError: true,
      );
      return;
    }
    if (password.length < 6) {
      _showMessage(
        l10n.isIndonesian ? 'Kata sandi minimal 6 karakter.' : 'Password must be at least 6 characters.',
        isError: true,
      );
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
          l10n.isIndonesian
              ? 'Pendaftaran diproses. Cek email untuk verifikasi (jika diaktifkan).'
              : 'Registration processed. Check email for verification (if enabled).',
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
          l10n.isIndonesian
              ? 'Akun auth berhasil dibuat, TAPI gagal simpan ke tabel users: ${e.message} (code: ${e.code})'
              : 'Auth account created, BUT failed to save user profile: ${e.message} (code: ${e.code})',
          isError: true,
        );
        return;
      }

      _showMessage(
        l10n.isIndonesian
            ? 'Registrasi berhasil! Silakan login.'
            : 'Registration successful! Please login.',
      );
      setState(() => _isLogin = true);
    } on AuthException catch (e) {
      if (e.message.toLowerCase().contains('already registered') || e.message.toLowerCase().contains('already in use')) {
        _showMessage(
          l10n.isIndonesian
              ? 'Email sudah terdaftar di Ketok App. Silakan gunakan tab Login untuk masuk, lalu Anda bisa mendaftar sebagai Mitra di dalam aplikasi.'
              : 'Email is already registered on Ketok App. Please use Login tab to enter.',
          isError: true,
        );
        return;
      }
      _showMessage(e.message, isError: true);
    } catch (e) {
      _showMessage(
        l10n.isIndonesian ? 'Gagal mendaftar: $e' : 'Registration failed: $e',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _handleForgotPassword() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final email = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.forgotPassword),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: l10n.isIndonesian ? 'Masukkan email kamu' : 'Enter your email',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.send),
          ),
        ],
      ),
    );

    if (email == null || email.isEmpty) return;

    try {
      await _supabase.auth.resetPasswordForEmail(email);
      _showMessage(
        l10n.isIndonesian
            ? 'Link reset kata sandi sudah dikirim ke $email.'
            : 'Password reset link sent to $email.',
      );
    } catch (e) {
      _showMessage(
        l10n.isIndonesian
            ? 'Gagal mengirim link reset: $e'
            : 'Failed to send reset link: $e',
        isError: true,
      );
    }
  }

  Future<void> _handleOAuth(OAuthProvider provider) async {
    final l10n = context.l10n;
    try {
      await _supabase.auth.signInWithOAuth(provider);
    } catch (e) {
      _showMessage(
        l10n.isIndonesian
            ? 'Gagal login dengan ${provider.name}: $e'
            : 'Failed to login with ${provider.name}: $e',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: _buildLanguageToggle(),
              ),
              const SizedBox(height: 12),
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

  Widget _buildLanguageToggle() {
    final l10n = context.l10n;
    final isIndo = l10n.isIndonesian;
    return InkWell(
      onTap: () {
        final newLocale = isIndo ? const Locale('en') : const Locale('id');
        LocaleService.instance.setLocale(newLocale);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _fieldBorderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language_rounded, size: 16, color: _darkColor),
            const SizedBox(width: 5),
            Text(
              isIndo ? '🇮🇩 ID' : '🇬🇧 EN',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: _darkColor,
              ),
            ),
          ],
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
    final l10n = context.l10n;
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        final appName = config?.namaAplikasi ?? 'Ketok Mitra';
        final tagline = l10n.isIndonesian
            ? (config?.tagline ?? 'Portal Khusus Mitra')
            : 'Technician Partner Portal';

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
    final l10n = context.l10n;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE7E5EC),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _tabButton(l10n.login, true)),
          Expanded(
            child: _tabButton(
              l10n.isIndonesian ? 'Daftar Mitra' : 'Register Partner',
              false,
            ),
          ),
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
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(
          l10n.isIndonesian ? 'Email atau Nama Mitra' : 'Email or Partner Name',
        ),
        TextField(
          controller: _identifierController,
          decoration: _fieldDecoration(
            l10n.isIndonesian
                ? 'Masukkan email atau nama mitra'
                : 'Enter email or partner name',
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.password),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan kata sandi' : 'Enter password',
          ).copyWith(
            suffixIcon: IconButton(
              tooltip: _obscurePassword
                  ? (l10n.isIndonesian
                      ? 'Tampilkan kata sandi'
                      : 'Show password')
                  : (l10n.isIndonesian
                      ? 'Sembunyikan kata sandi'
                      : 'Hide password'),
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
            child: Text(
              l10n.isIndonesian ? 'Lupa kata sandi?' : 'Forgot password?',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSubmitButton(l10n.login, _handleLogin),
      ],
    );
  }

  Widget _buildRegisterForm() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(l10n.isIndonesian ? 'Nama Lengkap' : 'Full Name'),
        TextField(
          controller: _namaController,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan nama lengkap' : 'Enter full name',
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.email),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan email' : 'Enter email',
          ),
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.password),
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan kata sandi' : 'Enter password',
          ).copyWith(
            suffixIcon: IconButton(
              tooltip: _obscurePassword
                  ? (l10n.isIndonesian
                      ? 'Tampilkan kata sandi'
                      : 'Show password')
                  : (l10n.isIndonesian
                      ? 'Sembunyikan kata sandi'
                      : 'Hide password'),
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
        _fieldLabel(
          l10n.isIndonesian ? 'Konfirmasi Kata Sandi' : 'Confirm Password',
        ),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Ulangi kata sandi' : 'Repeat password',
          ),
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(l10n.register, _handleRegister),
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
    final l10n = context.l10n;
    return Row(
      children: [
        const Expanded(child: Divider(color: _fieldBorderColor)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(l10n.or, style: const TextStyle(color: Colors.black38)),
        ),
        const Expanded(child: Divider(color: _fieldBorderColor)),
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
