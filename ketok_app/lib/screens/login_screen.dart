import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

import 'app.dart';
import 'maintenance_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/app_config_service.dart';
import '../services/locale_service.dart';
import '../widgets/ketok_colors.dart';

final GlobalKey<NavigatorState> ketokNavigatorKey = GlobalKey<NavigatorState>();

class KetokApp extends StatelessWidget {
  const KetokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.instance.localeNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          navigatorKey: ketokNavigatorKey,
          title: 'Ketok',
          debugShowCheckedModeBanner: false,
          locale: currentLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
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
      },
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
      final l10n = context.l10n;
      if (_isRegistering) {
        final authResponse = await _client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          data: {'full_name': _nameController.text.trim()},
        );
        final authUid = authResponse.user?.id;
        if (authUid == null) {
          throw AuthException(
            l10n.isIndonesian
                ? 'Akun gagal dibuat. Silakan coba lagi.'
                : 'Failed to create account. Please try again.',
          );
        }

        try {
          await _ensureUserProfile(authUid: authUid);
        } on PostgrestException catch (error) {
          if (mounted) {
            _showMessage(
              l10n.isIndonesian
                  ? 'Akun Auth berhasil dibuat, tetapi profil pengguna gagal disimpan: ${error.message} (code: ${error.code})'
                  : 'Auth account created, but user profile failed to save: ${error.message} (code: ${error.code})',
              isError: true,
            );
          }
          return;
        }

        if (mounted) {
          _showMessage(
            l10n.isIndonesian
                ? 'Akun berhasil dibuat. Silakan cek email Anda.'
                : 'Account created successfully. Please check your email.',
          );
          setState(() => _isRegistering = false);
        }
      } else {
        final email = await _resolveLoginEmail(_emailController.text.trim());
        if (email == null) {
          if (mounted) {
            _showMessage(
              l10n.isIndonesian
                  ? 'Akun dengan nama atau email tersebut tidak ditemukan.'
                  : 'Account with that name or email was not found.',
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
        final l10n = context.l10n;
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
              throw AuthException(
                l10n.isIndonesian ? 'Sesi login tidak ditemukan.' : 'Login session not found.',
              );
            }
            await _ensureUserProfile(authUid: authUid);
            if (!mounted) return;
            _showMessage(
              l10n.isIndonesian
                  ? 'Akun sudah ada. Profil pengguna berhasil disiapkan, silakan masuk.'
                  : 'Account already exists. User profile prepared, please log in.',
            );
            await _client.auth.signOut();
            setState(() => _isRegistering = false);
          } on PostgrestException catch (profileError) {
            _showMessage(
              l10n.isIndonesian
                  ? 'Akun Auth sudah ada, tetapi profil database gagal dibuat: ${profileError.message} (code: ${profileError.code})'
                  : 'Auth account already exists, but database profile creation failed: ${profileError.message} (code: ${profileError.code})',
              isError: true,
            );
          } on AuthException catch (loginError) {
            _showMessage(
              l10n.isIndonesian
                  ? 'Email sudah terdaftar. Masuk memakai password akun tersebut. ${loginError.message}'
                  : 'Email already registered. Log in with that account password. ${loginError.message}',
              isError: true,
            );
          }
        } else {
          _showMessage(error.message, isError: true);
        }
      }
    } catch (_) {
      if (mounted) {
        final l10n = context.l10n;
        _showMessage(
          l10n.isIndonesian
              ? 'Terjadi kesalahan. Silakan coba lagi.'
              : 'An error occurred. Please try again.',
          isError: true,
        );
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
        final l10n = context.l10n;
        _showMessage(
          l10n.isIndonesian
              ? 'Login sosial tidak tersedia saat ini.'
              : 'Social login is not available right now.',
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showMessage(
        l10n.isIndonesian
            ? 'Masukkan email terlebih dahulu.'
            : 'Please enter a valid email first.',
        isError: true,
      );
      return;
    }
    try {
      await _client.auth.resetPasswordForEmail(email);
      if (mounted) {
        _showMessage(
          l10n.isIndonesian
              ? 'Tautan reset kata sandi dikirim ke email Anda.'
              : 'Password reset link sent to your email.',
        );
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
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
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
    final l10n = context.l10n;
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, config, _) {
        final appName = config?.namaAplikasi ?? 'Ketok';
        final tagline = l10n.isIndonesian
            ? (config?.tagline ?? 'Layanan Profesional Untuk Anda')
            : 'Professional Services For You';

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

  Widget _buildLoginForm() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(
          l10n.isIndonesian ? 'Username atau Email' : 'Username or Email',
        ),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            l10n.isIndonesian
                ? 'Masukkan username atau email'
                : 'Enter username or email',
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? (l10n.isIndonesian
                  ? 'Masukkan username atau email'
                  : 'Enter username or email')
              : null,
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.password),
        TextFormField(
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
          validator: (value) => value == null || value.length < 6
              ? (l10n.isIndonesian
                  ? 'Kata sandi minimal 6 karakter'
                  : 'Password must be at least 6 characters')
              : null,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : _resetPassword,
            child: Text(
              l10n.isIndonesian ? 'Lupa kata sandi?' : 'Forgot password?',
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _buildSubmitButton(l10n.login),
      ],
    );
  }

  Widget _buildRegisterForm() {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(l10n.isIndonesian ? 'Nama Lengkap' : 'Full Name'),
        TextFormField(
          controller: _nameController,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan nama lengkap' : 'Enter full name',
          ),
          validator: (value) => value == null || value.trim().isEmpty
              ? (l10n.isIndonesian
                  ? 'Nama lengkap wajib diisi'
                  : 'Full name is required')
              : null,
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.email),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan email' : 'Enter email',
          ),
          validator: (value) => value == null || !value.contains('@')
              ? (l10n.isIndonesian
                  ? 'Masukkan email yang valid'
                  : 'Enter a valid email')
              : null,
        ),
        const SizedBox(height: 18),
        _fieldLabel(l10n.password),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Masukkan kata sandi' : 'Enter password',
          ).copyWith(suffixIcon: _passwordVisibilityButton()),
          validator: (value) => value == null || value.length < 6
              ? (l10n.isIndonesian
                  ? 'Kata sandi minimal 6 karakter'
                  : 'Password must be at least 6 characters')
              : null,
        ),
        const SizedBox(height: 18),
        _fieldLabel(
          l10n.isIndonesian ? 'Konfirmasi Kata Sandi' : 'Confirm Password',
        ),
        TextFormField(
          obscureText: _obscurePassword,
          decoration: _fieldDecoration(
            l10n.isIndonesian ? 'Ulangi kata sandi' : 'Repeat password',
          ),
          validator: (value) => value != _passwordController.text
              ? (l10n.isIndonesian
                  ? 'Konfirmasi kata sandi tidak cocok'
                  : 'Password confirmation does not match')
              : null,
        ),
        const SizedBox(height: 20),
        _buildSubmitButton(l10n.register),
      ],
    );
  }

  Widget _passwordVisibilityButton() => IconButton(
    tooltip: _obscurePassword
        ? (context.l10n.isIndonesian
            ? 'Tampilkan kata sandi'
            : 'Show password')
        : (context.l10n.isIndonesian
            ? 'Sembunyikan kata sandi'
            : 'Hide password'),
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
    final l10n = context.l10n;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE7E5EC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: l10n.login,
            selected: !_isRegistering,
            onTap: () => setState(() => _isRegistering = false),
          ),
          _ModeTab(
            label: l10n.register,
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
