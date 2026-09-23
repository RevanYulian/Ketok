import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppConfig {
  final String namaAplikasi;
  final String? tagline;
  final String? logoUrl;
  final String? bannerPromoUrl;
  final String? kontakCs;
  final String? emailBantuan;
  final String versiAplikasi;
  final bool statusMaintenance;
  final String? pesanMaintenance;

  const AppConfig({
    required this.namaAplikasi,
    this.tagline,
    this.logoUrl,
    this.bannerPromoUrl,
    this.kontakCs,
    this.emailBantuan,
    this.versiAplikasi = '1.0.0',
    this.statusMaintenance = false,
    this.pesanMaintenance,
  });

  factory AppConfig.fromMap(Map<String, dynamic> map) {
    final rawMaintenance = map['status_maintenance'];
    final isMaintenance = rawMaintenance == true ||
        rawMaintenance == 1 ||
        rawMaintenance == '1' ||
        rawMaintenance == 'true';

    return AppConfig(
      namaAplikasi: map['nama_aplikasi'] as String? ?? 'Ketok',
      tagline: map['tagline'] as String?,
      logoUrl: map['logo_url'] as String?,
      bannerPromoUrl: map['banner_promo_url'] as String?,
      kontakCs: map['kontak_cs'] as String?,
      emailBantuan: map['email_bantuan'] as String?,
      versiAplikasi: map['versi_aplikasi'] as String? ?? '1.0.0',
      statusMaintenance: isMaintenance,
      pesanMaintenance: map['pesan_maintenance'] as String?,
    );
  }
}

class AppConfigService {
  static final AppConfigService instance = AppConfigService._();
  AppConfigService._();

  final ValueNotifier<AppConfig?> configNotifier = ValueNotifier<AppConfig?>(null);
  RealtimeChannel? _subscription;

  Future<void> loadConfig() async {
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('pengaturan_aplikasi')
          .select()
          .eq('tipe_app', 'ketok_app')
          .maybeSingle()
          .timeout(const Duration(seconds: 4));

      if (response != null) {
        configNotifier.value = AppConfig.fromMap(response);
      }
    } catch (e) {
      debugPrint('Error loading app config: $e');
    }
  }

  void subscribeConfig() {
    try {
      if (_subscription != null) return;
      final client = Supabase.instance.client;
      _subscription = client
          .channel('public:pengaturan_aplikasi:ketok_app')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'pengaturan_aplikasi',
            callback: (payload) {
              debugPrint('Realtime config change detected for ketok_app');
              final newRecord = payload.newRecord;
              if (newRecord.isNotEmpty && newRecord['tipe_app'] == 'ketok_app') {
                configNotifier.value = AppConfig.fromMap(newRecord);
              } else {
                loadConfig();
              }
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('Error subscribing to app config: $e');
    }
  }
}
