import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/app.dart';
import 'services/app_config_service.dart';
import 'services/locale_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load dynamic branding & app config
  await AppConfigService.instance.loadConfig();
  AppConfigService.instance.subscribeConfig();

  // Load persisted language
  await LocaleService.instance.init();

  runApp(const KetokMitraApp());
}

final supabase = Supabase.instance.client;
