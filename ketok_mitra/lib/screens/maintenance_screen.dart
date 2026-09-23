import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/app_config_service.dart';
import '../widgets/ketok_colors.dart';

class MaintenanceScreen extends StatefulWidget {
  final AppConfig? config;

  const MaintenanceScreen({super.key, this.config});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  bool _isChecking = false;

  static const _backgroundColor = Color(0xFFF5F4F7);
  static const _darkColor = Color(0xFF1B1D2B);
  static const _fieldBorderColor = Color(0xFFE3E1E8);

  Future<void> _handleRefresh() async {
    setState(() => _isChecking = true);
    await AppConfigService.instance.loadConfig();
    if (!mounted) return;
    setState(() => _isChecking = false);

    final currentConfig = AppConfigService.instance.configNotifier.value;
    if (currentConfig != null && !currentConfig.statusMaintenance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pemeliharaan sistem telah selesai. Selamat bertugas!'),
          backgroundColor: Color(0xFF16A34A),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem mitra masih dalam pemeliharaan. Silakan coba lagi nanti.'),
          backgroundColor: _darkColor,
        ),
      );
    }
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label berhasil disalin: $text'),
        backgroundColor: KetokColors.darkPrimary,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppConfig?>(
      valueListenable: AppConfigService.instance.configNotifier,
      builder: (context, currentConfig, _) {
        final config = currentConfig ?? widget.config;
        final appName = config?.namaAplikasi ?? 'Ketok Mitra';
        final tagline = config?.tagline ?? 'Aplikasi Khusus Tukang & Mitra Profesional Ketok';
        final message = (config?.pesanMaintenance != null &&
                config!.pesanMaintenance!.trim().isNotEmpty)
            ? config.pesanMaintenance!.trim()
            : 'Sistem Ketok Mitra sedang dalam pemeliharaan server berkala untuk peningkatan performa dan stabilitas layanan.';
        final kontakCs = config?.kontakCs;
        final emailBantuan = config?.emailBantuan;
        final version = config?.versiAplikasi ?? '1.0.0';

        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(config),
                      const SizedBox(height: 16),
                      Text(
                        appName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: _darkColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBEBF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.build_circle_outlined, size: 15, color: Color(0xFF4A5568)),
                            SizedBox(width: 6),
                            Text(
                              'PEMELIHARAAN SISTEM MITRA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF4A5568),
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Card Info Pemeliharaan
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _fieldBorderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, size: 18, color: _darkColor),
                                SizedBox(width: 8),
                                Text(
                                  'Status Layanan Mitra',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _darkColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              message,
                              style: const TextStyle(
                                fontSize: 13.5,
                                color: Color(0xFF4A5568),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Card Kontak Bantuan
                      if ((kontakCs != null && kontakCs.isNotEmpty) ||
                          (emailBantuan != null && emailBantuan.isNotEmpty))
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: _fieldBorderColor),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bantuan operasional mitra:',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: _darkColor,
                                ),
                              ),
                              const SizedBox(height: 12),
                              if (kontakCs != null && kontakCs.isNotEmpty)
                                _buildContactItem(
                                  icon: Icons.phone_outlined,
                                  title: 'Kontak CS Mitra',
                                  value: kontakCs,
                                  onTap: () => _copyToClipboard(kontakCs, 'Nomor CS Mitra'),
                                ),
                              if (kontakCs != null &&
                                  kontakCs.isNotEmpty &&
                                  emailBantuan != null &&
                                  emailBantuan.isNotEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Divider(color: Color(0xFFF0EFF4), height: 1),
                                ),
                              if (emailBantuan != null && emailBantuan.isNotEmpty)
                                _buildContactItem(
                                  icon: Icons.mail_outline_rounded,
                                  title: 'Email Dukungan Mitra',
                                  value: emailBantuan,
                                  onTap: () => _copyToClipboard(emailBantuan, 'Email Dukungan'),
                                ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),

                      // Tombol Coba Lagi
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isChecking ? null : _handleRefresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _darkColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isChecking
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh_rounded, size: 18),
                                    SizedBox(width: 8),
                                    Text(
                                      'Coba Lagi',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Footer
                      Text(
                        tagline,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, color: Colors.black45),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Versi $version',
                        style: const TextStyle(fontSize: 12, color: Colors.black26),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLogo(AppConfig? config) {
    final logoUrl = config?.logoUrl;
    final isNetwork = logoUrl != null &&
        (logoUrl.startsWith('http://') || logoUrl.startsWith('https://'));

    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
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
                errorBuilder: (_, _, _) => Image.asset(
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
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F4F7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 18, color: _darkColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                  ),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: _darkColor,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.copy_rounded, size: 16, color: Colors.black38),
          ],
        ),
      ),
    );
  }
}
