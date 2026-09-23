import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'maintenance_screen.dart';
import '../services/app_config_service.dart';
import '../widgets/ketok_colors.dart';

final GlobalKey<NavigatorState> ketokNavigatorKey = GlobalKey<NavigatorState>();

class KetokApp extends StatelessWidget {
  const KetokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: ketokNavigatorKey,
      title: 'Ketok',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF1A202C),
          onPrimary: Colors.white,
          secondary: Color(0xFF4A5568),
          onSecondary: Colors.white,
          surface: Color(0xFFF5F6F8),
          onSurface: Color(0xFF2D3748),
          outline: Color(0xFFC6C6CC),
          error: Color(0xFFC53030),
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F9FB),
        fontFamily: 'Manrope',
        dividerTheme: const DividerThemeData(color: Color(0xFFE2E5E9)),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: const Color(0xFF4A5568)),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Color(0xFFA0AEC0)),
        ),
      ),
      home: const _AppRootGate(),
    );
  }
}

class _AppRootGate extends StatefulWidget {
  const _AppRootGate();

  @override
  State<_AppRootGate> createState() => _AppRootGateState();
}

class _AppRootGateState extends State<_AppRootGate> {
  @override
  void initState() {
    super.initState();
    AppConfigService.instance.configNotifier.addListener(_onConfigChanged);
  }

  @override
  void dispose() {
    AppConfigService.instance.configNotifier.removeListener(_onConfigChanged);
    super.dispose();
  }

  void _onConfigChanged() {
    final config = AppConfigService.instance.configNotifier.value;
    if (config != null && config.statusMaintenance) {
      ketokNavigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        if (config != null && config.statusMaintenance) {
          return MaintenanceScreen(config: config);
        }

        final client = Supabase.instance.client;
        return StreamBuilder<AuthState>(
          stream: client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            if (client.auth.currentSession != null) {
              return const KetokMainScreen();
            }
            return const _LoginScreen();
          },
        );
      },
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  static const _backgroundColor = Color(0xFFF5F4F7);
  static const _darkColor = Color(0xFF1B1D2B);
  static const _fieldBorderColor = Color(0xFFE3E1E8);

  SupabaseClient get _client => Supabase.instance.client;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<String?> _resolveLoginEmail(String identifier) async {
    if (identifier.contains('@')) return identifier;
    try {
      final profile = await _client
          .from('users')
          .select('email')
          .eq('nama', identifier)
          .maybeSingle();
      return profile?['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureUserProfile({required String authUid}) async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final existing = await _client
        .from('users')
        .select('id_user')
        .eq('auth_uid', authUid)
        .maybeSingle();
    if (existing != null) {
      await _client
          .from('users')
          .update({'terakhir_aktif': DateTime.now().toUtc().toIso8601String()})
          .eq('auth_uid', authUid);
      return;
    }

    await _client.from('users').insert({
      'nama': name.isEmpty ? email.split('@').first : name,
      'email': email,
      'role': 'pengguna',
      'auth_uid': authUid,
      'terakhir_aktif': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        final authResponse = await _client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'full_name': _nameController.text.trim()},
        );
        final authUid = authResponse.user?.id;
        if (authUid == null) {
          throw const AuthException('Akun gagal dibuat. Silakan coba lagi.');
        }

        try {
          await _ensureUserProfile(authUid: authUid);
        } on PostgrestException catch (error) {
          if (mounted) {
            _showMessage(
              'Akun Auth berhasil dibuat, tetapi profil pengguna gagal disimpan: '
              '${error.message} (code: ${error.code})',
              isError: true,
            );
          }
          return;
        }

        if (mounted) {
          _showMessage('Akun berhasil dibuat. Silakan cek email Anda.');
          setState(() => _isRegistering = false);
        }
      } else {
        final email = await _resolveLoginEmail(_emailController.text.trim());
        if (email == null) {
          if (mounted) {
            _showMessage(
              'Akun dengan nama atau email tersebut tidak ditemukan.',
              isError: true,
            );
          }
          return;
        }
        await _client.auth.signInWithPassword(
          email: email,
          password: _passwordController.text,
        );
      }
    } on AuthException catch (error) {
      if (mounted) {
        final alreadyRegistered = error.message.toLowerCase().contains(
          'already registered',
        );
        if (_isRegistering && alreadyRegistered) {
          try {
            final response = await _client.auth.signInWithPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text,
            );
            final authUid = response.user?.id;
            if (authUid == null) {
              throw const AuthException('Sesi login tidak ditemukan.');
            }
            await _ensureUserProfile(authUid: authUid);
            if (!mounted) return;
            _showMessage(
              'Akun sudah ada. Profil pengguna berhasil disiapkan, silakan masuk.',
            );
            await _client.auth.signOut();
            setState(() => _isRegistering = false);
          } on PostgrestException catch (profileError) {
            _showMessage(
              'Akun Auth sudah ada, tetapi profil database gagal dibuat: '
              '${profileError.message} (code: ${profileError.code})',
              isError: true,
            );
          } on AuthException catch (loginError) {
            _showMessage(
              'Email sudah terdaftar. Masuk memakai password akun tersebut. '
              '${loginError.message}',
              isError: true,
            );
          }
        } else {
          _showMessage(error.message, isError: true);
        }
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Terjadi kesalahan. Silakan coba lagi.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWith(OAuthProvider provider) async {
    setState(() => _isLoading = true);
    try {
      await _client.auth.signInWithOAuth(provider);
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(error.message, isError: true);
      }
    } catch (_) {
      if (mounted) {
        _showMessage('Login sosial tidak tersedia saat ini.', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage('Masukkan email terlebih dahulu.', isError: true);
      return;
    }
    try {
      await _client.auth.resetPasswordForEmail(email);
      if (mounted) {
        _showMessage('Tautan reset kata sandi dikirim ke email Anda.');
      }
    } on AuthException catch (error) {
      if (mounted) {
        _showMessage(error.message, isError: true);
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? const Color(0xFFC53030)
              : KetokColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildLogo(),
                const SizedBox(height: 16),
                _buildAppTitle(),
                const SizedBox(height: 32),
                _buildModeTabs(),
                const SizedBox(height: 24),
                _isRegistering ? _buildRegisterForm() : _buildLoginForm(),
                const SizedBox(height: 24),
                _buildDivider(),
                const SizedBox(height: 20),
                _buildOAuthButtons(),
              ],
            ),
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
                      'assets/images/ketok.png',
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                    ),
                  )
                : Image.asset(
                    'assets/images/ketok.png',
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
        final appName = config?.namaAplikasi ?? 'Ketok';
        final tagline = config?.tagline ?? 'Layanan Profesional Untuk Anda';

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

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
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

  Widget _fieldLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
    ),
  );

  Widget _buildLoginForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel('Username atau Email'),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: _fieldDecoration('Masukkan username atau email'),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Masukkan username atau email'
            : null,
      ),
      const SizedBox(height: 18),
      _fieldLabel('Kata Sandi'),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: _fieldDecoration('Masukkan kata sandi').copyWith(
          suffixIcon: IconButton(
            tooltip: _obscurePassword
                ? 'Tampilkan kata sandi'
                : 'Sembunyikan kata sandi',
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
        validator: (value) => value == null || value.length < 6
            ? 'Kata sandi minimal 6 karakter'
            : null,
      ),
      Align(
        alignment: Alignment.centerRight,
        child: TextButton(
          onPressed: _isLoading ? null : _resetPassword,
          child: const Text(
            'Lupa kata sandi?',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ),
      const SizedBox(height: 8),
      _buildSubmitButton('Masuk'),
    ],
  );

  Widget _buildRegisterForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _fieldLabel('Nama Lengkap'),
      TextFormField(
        controller: _nameController,
        decoration: _fieldDecoration('Masukkan nama lengkap'),
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Nama lengkap wajib diisi'
            : null,
      ),
      const SizedBox(height: 18),
      _fieldLabel('Email'),
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: _fieldDecoration('Masukkan email'),
        validator: (value) => value == null || !value.contains('@')
            ? 'Masukkan email yang valid'
            : null,
      ),
      const SizedBox(height: 18),
      _fieldLabel('Kata Sandi'),
      TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        decoration: _fieldDecoration(
          'Masukkan kata sandi',
        ).copyWith(suffixIcon: _passwordVisibilityButton()),
        validator: (value) => value == null || value.length < 6
            ? 'Kata sandi minimal 6 karakter'
            : null,
      ),
      const SizedBox(height: 18),
      _fieldLabel('Konfirmasi Kata Sandi'),
      TextFormField(
        obscureText: _obscurePassword,
        decoration: _fieldDecoration('Ulangi kata sandi'),
        validator: (value) => value != _passwordController.text
            ? 'Konfirmasi kata sandi tidak cocok'
            : null,
      ),
      const SizedBox(height: 20),
      _buildSubmitButton('Daftar'),
    ],
  );

  Widget _passwordVisibilityButton() => IconButton(
    tooltip: _obscurePassword
        ? 'Tampilkan kata sandi'
        : 'Sembunyikan kata sandi',
    icon: Icon(
      _obscurePassword
          ? Icons.visibility_off_outlined
          : Icons.visibility_outlined,
      color: Colors.black45,
    ),
    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
  );

  Widget _buildSubmitButton(String label) => SizedBox(
    width: double.infinity,
    height: 52,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _submit,
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: _isLoading
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

  Widget _buildDivider() => const Row(
    children: [
      Expanded(child: Divider(color: _fieldBorderColor)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('ATAU', style: TextStyle(color: Colors.black38)),
      ),
      Expanded(child: Divider(color: _fieldBorderColor)),
    ],
  );

  Widget _buildOAuthButtons() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _SocialButton(
        asset: 'assets/images/google_logo.png',
        label: 'Google',
        onPressed: _isLoading ? null : () => _signInWith(OAuthProvider.google),
      ),
      const SizedBox(width: 16),
      _SocialButton(
        asset: 'assets/images/apple_logo.png',
        label: 'Apple',
        onPressed: _isLoading ? null : () => _signInWith(OAuthProvider.apple),
      ),
    ],
  );

  Widget _buildModeTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E5EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: 'Login',
            selected: !_isRegistering,
            onTap: () => setState(() => _isRegistering = false),
          ),
          _ModeTab(
            label: 'Register',
            selected: _isRegistering,
            onTap: () => setState(() => _isRegistering = true),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
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
              color: selected ? _LoginScreenState._darkColor : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String asset;
  final String label;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.asset,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
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
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          semanticLabel: 'Login dengan $label',
        ),
      ),
    );
  }
}
