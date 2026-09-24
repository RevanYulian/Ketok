import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'beranda_screen.dart';
import 'maintenance_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/app_config_service.dart';
import '../services/locale_service.dart';

final GlobalKey<NavigatorState> ketokMitraNavigatorKey = GlobalKey<NavigatorState>();

class KetokMitraApp extends StatelessWidget {
  const KetokMitraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: LocaleService.instance.localeNotifier,
      builder: (context, currentLocale, _) {
        return MaterialApp(
          navigatorKey: ketokMitraNavigatorKey,
          title: 'Ketok Mitra',
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
            colorSchemeSeed: const Color(0xFF030813),
            scaffoldBackgroundColor: const Color(0xFFF8F9FB),
            useMaterial3: true,
          ),
          home: const _MitraRootGate(),
        );
      },
    );
  }
}

class _MitraRootGate extends StatefulWidget {
  const _MitraRootGate();

  @override
  State<_MitraRootGate> createState() => _MitraRootGateState();
}

class _MitraRootGateState extends State<_MitraRootGate> {
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
      ketokMitraNavigatorKey.currentState?.popUntil((route) => route.isFirst);
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

        return StreamBuilder<AuthState>(
          stream: Supabase.instance.client.auth.onAuthStateChange,
          builder: (context, snapshot) {
            final session = Supabase.instance.client.auth.currentSession;
            return session != null ? const BerandaScreen() : const LoginScreen();
          },
        );
      },
    );
  }
}

class _HomePage extends StatefulWidget {
  const _HomePage();

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  String _status = 'Belum ada percobaan koneksi.';

  Future<void> _testConnection() async {
    setState(() => _status = 'Menghubungkan ke Supabase...');
    try {
      final response =
          await Supabase.instance.client.from('kategori_layanan').select();
      setState(() => _status = 'Berhasil: $response');
    } catch (e) {
      setState(() => _status = 'Gagal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ketok Mitra')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Ketok Mitra App',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testConnection,
                child: const Text('Test Koneksi Supabase'),
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
