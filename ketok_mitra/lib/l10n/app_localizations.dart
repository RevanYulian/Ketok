import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('id'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('id'),
    Locale('en'),
  ];

  bool get isIndonesian => locale.languageCode == 'id';

  // Common UI
  String get ok => isIndonesian ? 'OK' : 'OK';
  String get cancel => isIndonesian ? 'Batal' : 'Cancel';
  String get save => isIndonesian ? 'Simpan' : 'Save';
  String get back => isIndonesian ? 'Kembali' : 'Back';
  String get next => isIndonesian ? 'Lanjut' : 'Next';
  String get close => isIndonesian ? 'Tutup' : 'Close';
  String get delete => isIndonesian ? 'Hapus' : 'Delete';
  String get continueText => isIndonesian ? 'Lanjutkan' : 'Continue';
  String get refresh => isIndonesian ? 'Muat Ulang' : 'Refresh';
  String get retry => isIndonesian ? 'Coba Lagi' : 'Retry';
  String get search => isIndonesian ? 'Cari' : 'Search';
  String get send => isIndonesian ? 'Kirim' : 'Send';
  String get apply => isIndonesian ? 'Terapkan' : 'Apply';
  String get viewAll => isIndonesian ? 'Lihat Semua' : 'View All';
  String get copy => isIndonesian ? 'Salin' : 'Copy';
  String get success => isIndonesian ? 'Berhasil' : 'Success';
  String get error => isIndonesian ? 'Terjadi Kesalahan' : 'An error occurred';
  String get loading => isIndonesian ? 'Memuat...' : 'Loading...';

  // Bottom Navigation
  String get navHome => isIndonesian ? 'Beranda' : 'Home';
  String get navOrders => isIndonesian ? 'Pesanan' : 'Orders';
  String get navChat => isIndonesian ? 'Chat' : 'Chat';
  String get navProfile => isIndonesian ? 'Profil' : 'Profile';

  // Authentication & Login
  String get login => isIndonesian ? 'Masuk' : 'Login';
  String get register => isIndonesian ? 'Daftar' : 'Register';
  String get email => isIndonesian ? 'Email' : 'Email';
  String get password => isIndonesian ? 'Kata Sandi' : 'Password';
  String get or => isIndonesian ? 'ATAU' : 'OR';
  String get loginTitle => isIndonesian ? 'Masuk Mitra Ketok' : 'Log In Ketok Partner';
  String get loginSubtitle => isIndonesian
      ? 'Aplikasi teknisi profesional untuk menerima pesanan servis'
      : 'Professional technician app for receiving service orders';
  String get emailLabel => isIndonesian ? 'Email Mitra' : 'Partner Email';
  String get emailHint => isIndonesian ? 'mitra@ketok.id' : 'partner@ketok.id';
  String get passwordLabel => isIndonesian ? 'Kata Sandi' : 'Password';
  String get passwordHint => isIndonesian ? 'Masukkan kata sandi' : 'Enter password';
  String get forgotPassword => isIndonesian ? 'Lupa Sandi?' : 'Forgot Password?';
  String get loginButton => isIndonesian ? 'Masuk Sekarang' : 'Log In Now';
  String get registerMitraPrompt => isIndonesian ? 'Ingin bergabung jadi teknisi mitra?' : 'Want to join as a partner technician?';
  String get registerMitraLink => isIndonesian ? 'Daftar Mitra Ketok' : 'Register as Ketok Partner';
  String get emailRequired => isIndonesian ? 'Email tidak boleh kosong' : 'Email is required';
  String get passwordRequired => isIndonesian ? 'Kata sandi tidak boleh kosong' : 'Password is required';

  // Beranda Mitra / Home
  String get greetingPartner => isIndonesian ? 'Halo, Mitra Ketok' : 'Hello, Ketok Partner';
  String get onlineStatusActive => isIndonesian ? 'Aktif Menerima Pesanan' : 'Active Accepting Orders';
  String get onlineStatusOffline => isIndonesian ? 'Sedang Istirahat / Offline' : 'Resting / Offline';
  String get activeOrdersCard => isIndonesian ? 'Pesanan Aktif' : 'Active Orders';
  String get todayEarningsCard => isIndonesian ? 'Pendapatan Hari Ini' : "Today's Earnings";
  String get totalCompletedCard => isIndonesian ? 'Pekerjaan Selesai' : 'Completed Jobs';
  String get ratingCard => isIndonesian ? 'Rating Mitra' : 'Partner Rating';
  String get availableOrdersTitle => isIndonesian ? 'Peluang Pesanan Baru' : 'New Order Opportunities';
  String get quickMenuTitle => isIndonesian ? 'Menu Cepat Mitra' : 'Partner Quick Menu';
  String get quickMenuSop => isIndonesian ? 'Panduan SOP' : 'SOP Guide';
  String get quickMenuAvailable => isIndonesian ? 'Pesanan Siap' : 'Available Jobs';
  String get quickMenuMarketing => isIndonesian ? 'Tagihan Komisi' : 'Commission Bills';
  String get quickMenuTips => isIndonesian ? 'Tips Teknisi' : 'Technician Tips';
  String get quickMenuReviews => isIndonesian ? 'Ulasan Pelanggan' : 'Customer Reviews';
  String get quickMenuHelp => isIndonesian ? 'Pusat Bantuan' : 'Help Center';

  // Pesanan Mitra
  String get ordersTitle => isIndonesian ? 'Kelola Pesanan' : 'Manage Orders';
  String get tabAll => isIndonesian ? 'Semua' : 'All';
  String get tabIncoming => isIndonesian ? 'Masuk' : 'Incoming';
  String get tabInProgress => isIndonesian ? 'Dikerjakan' : 'In Progress';
  String get tabCompleted => isIndonesian ? 'Selesai' : 'Completed';
  String get tabCancelled => isIndonesian ? 'Dibatalkan' : 'Cancelled';
  String get emptyOrdersMitra => isIndonesian ? 'Tidak Ada Pesanan' : 'No Orders Available';
  String get emptyOrdersMitraDesc => isIndonesian
      ? 'Belum ada pesanan aktif. Pastikan status Anda online agar pelanggan dapat memesan jasa Anda.'
      : 'No active orders yet. Make sure your status is Online to receive bookings.';
  String get acceptOrder => isIndonesian ? 'Terima Pesanan' : 'Accept Order';
  String get rejectOrder => isIndonesian ? 'Tolak Pesanan' : 'Decline Order';
  String get startWork => isIndonesian ? 'Mulai Pengerjaan' : 'Start Working';
  String get finishWork => isIndonesian ? 'Selesaikan Pekerjaan' : 'Finish Job';
  String get customerLabel => isIndonesian ? 'Pelanggan' : 'Customer';
  String get locationLabel => isIndonesian ? 'Lokasi Pelanggan' : 'Customer Location';
  String get problemDetailLabel => isIndonesian ? 'Keluhan Kerusakan' : 'Issue Description';
  String get orderFeeLabel => isIndonesian ? 'Tarif Pengerjaan' : 'Service Fee';
  String get visitFeeLabel => isIndonesian ? 'Biaya Kunjungan' : 'Visit Fee';
  String get contactCustomer => isIndonesian ? 'Hubungi Pelanggan' : 'Contact Customer';
  String get openMapLocation => isIndonesian ? 'Buka Google Maps' : 'Open in Maps';

  // Chat Mitra
  String get chatTitle => isIndonesian ? 'Obrolan Pelanggan' : 'Customer Chats';
  String get emptyChatMitra => isIndonesian ? 'Belum Ada Percakapan' : 'No Conversations Yet';
  String get emptyChatMitraDesc => isIndonesian
      ? 'Pesan dari pelanggan yang memesan jasa Anda akan tampil di sini.'
      : 'Customer inquiries regarding bookings will appear here.';
  String get typeMessageHint => isIndonesian ? 'Tulis pesan balasan...' : 'Type a reply...';

  // Profile Mitra
  String get profileTitle => isIndonesian ? 'Profil Mitra' : 'Partner Profile';
  String get sectionMitraService => isIndonesian ? 'DATA & LAYANAN MITRA' : 'PARTNER DATA & SERVICES';
  String get sectionSecurity => isIndonesian ? 'PREFERENSI & KEAMANAN' : 'PREFERENCES & SECURITY';
  String get sectionHelp => isIndonesian ? 'BANTUAN & INFO KETOK' : 'HELP & ABOUT KETOK';
  String get ktpVerificationTitle => isIndonesian ? 'Verifikasi Identitas (KTP)' : 'Identity Verification (ID)';
  String get ktpVerified => isIndonesian ? 'Terverifikasi' : 'Verified';
  String get ktpPending => isIndonesian ? 'Sedang Ditinjau' : 'Under Review';
  String get ktpUnverified => isIndonesian ? 'Belum Verifikasi' : 'Unverified';
  String get ktpRejected => isIndonesian ? 'Ditolak (Upload Ulang)' : 'Rejected (Re-upload)';
  String get servicesAndRates => isIndonesian ? 'Layanan & Tarif' : 'Services & Rates';
  String get servicesAndRatesSubtitle => isIndonesian ? 'Atur spesialisasi jasa dan kisaran biaya' : 'Set service specialization and price range';
  String get workSchedule => isIndonesian ? 'Jadwal & Jam Kerja' : 'Schedule & Working Hours';
  String get workScheduleSubtitle => isIndonesian ? 'Atur hari dan jam ketersediaan kerja' : 'Configure available working days and hours';
  String get extraCertificates => isIndonesian ? 'Sertifikasi Tambahan' : 'Additional Certifications';
  String get extraCertificatesSubtitle => isIndonesian ? 'Kelola dokumen dan sertifikat keahlian' : 'Manage skill certificates and credentials';
  String get notificationCenter => isIndonesian ? 'Pusat Notifikasi' : 'Notification Center';
  String get notificationCenterSubtitle => isIndonesian ? 'Pemberitahuan pembaruan status & pesanan' : 'Status and order update alerts';
  String get accountSecurity => isIndonesian ? 'Keamanan Akun' : 'Account Security';
  String get accountSecuritySubtitle => isIndonesian ? 'Ubah kata sandi dan proteksi akun' : 'Change password & account protection';
  String get appLanguage => isIndonesian ? 'Bahasa Aplikasi' : 'App Language';
  String get currentLanguageName => isIndonesian ? 'Bahasa Indonesia (ID)' : 'English (US)';
  String get selectLanguageTitle => isIndonesian ? 'Pilih Bahasa Aplikasi' : 'Select App Language';
  String get helpCenter => isIndonesian ? 'Pusat Bantuan & FAQ' : 'Help Center & FAQ';
  String get termsConditions => isIndonesian ? 'Syarat & Ketentuan Kemitraan' : 'Partnership Terms & Conditions';
  String get privacyPolicy => isIndonesian ? 'Kebijakan Privasi' : 'Privacy Policy';
  String get logoutButton => isIndonesian ? 'Keluar dari Akun' : 'Log Out';
  String get logoutConfirmTitle => isIndonesian ? 'Keluar Akun Mitra' : 'Log Out of Partner Account';
  String get logoutConfirmDesc => isIndonesian
      ? 'Apakah Anda yakin ingin keluar? Anda tidak akan menerima notifikasi pesanan saat keluar.'
      : 'Are you sure you want to log out? You will not receive order alerts while logged out.';

  String get editProfile => isIndonesian ? 'Edit Profil' : 'Edit Profile';
  String get phoneNotSet => isIndonesian ? 'Nomor telepon belum diatur' : 'Phone number not set';
  String get emailNotSet => isIndonesian ? 'Email belum diatur' : 'Email not set';
  String get ratingLabel => isIndonesian ? 'Rating' : 'Rating';
  String get ordersCompletedLabel => isIndonesian ? 'Pesanan Selesai' : 'Completed Orders';
  String get statusLabel => isIndonesian ? 'Status' : 'Status';
  String get onlineNow => isIndonesian ? 'Sedang online' : 'Currently online';
  String get offlineNow => isIndonesian ? 'Sedang offline' : 'Currently offline';
  String get onlineDescription => isIndonesian
      ? 'Pelanggan dapat menemukan Anda sekarang.'
      : 'Customers can find and book your services now.';
  String get offlineDescription => isIndonesian
      ? 'Anda tidak akan menerima pesanan baru.'
      : 'You will not receive new incoming orders.';
  String get ktpRequiredToOnline => isIndonesian
      ? 'Lengkapi verifikasi KTP dan tunggu persetujuan admin untuk dapat online.'
      : 'Complete ID verification and await admin approval to go online.';
  String get orderNotifications => isIndonesian ? 'Notifikasi Pesanan' : 'Order Notifications';
  String get orderNotificationsSubtitle => isIndonesian ? 'Pemberitahuan suara pesanan baru' : 'Sound alerts for new incoming orders';
  String get comingSoon => isIndonesian ? 'Fitur ini sedang disiapkan.' : 'This feature is coming soon.';
  String get lockedFeatureTitle => isIndonesian ? 'Fitur Terkunci' : 'Feature Locked';
  String get lockedWorkManagementDesc => isIndonesian
      ? 'Manajemen pekerjaan belum dapat digunakan karena akun Anda masih dalam status Pengajuan / Menunggu Verifikasi KTP dari Admin Ketok.\n\nSetelah dokumen KTP Anda disetujui, Anda dapat langsung mengatur layanan dan tarif pekerjaan Anda.'
      : 'Work management cannot be accessed while your account is pending ID verification from Admin.\n\nOnce approved, you will be able to configure services and pricing.';
  String get checkKtpStatus => isIndonesian ? 'Cek Status KTP' : 'Check ID Status';
  String get partnerVerified => isIndonesian ? 'Mitra Terverifikasi' : 'Verified Partner';
  String get waitingApproval => isIndonesian ? 'Menunggu Persetujuan' : 'Awaiting Approval';
  String get notUploaded => isIndonesian ? 'Belum Upload' : 'Not Uploaded';
  String get rejectedBadge => isIndonesian ? 'Ditolak' : 'Rejected';
  String get lockedWaitingKtp => isIndonesian ? 'Terkunci (Menunggu Verifikasi KTP)' : 'Locked (Awaiting ID Verification)';
  String get ktpStatusItemSubtitle => isIndonesian ? 'Status pengajuan identitas usaha & KTP' : 'Business identity & ID status';

  // Wallet & Dompet
  String get walletTitle => isIndonesian ? 'Dompet & Pendapatan' : 'Wallet & Earnings';
  String get withdrawFunds => isIndonesian ? 'Tarik Dana' : 'Withdraw Funds';
  String get withdrawMinInfo => isIndonesian ? 'Minimal penarikan Rp 50.000' : 'Minimum withdrawal IDR 50,000';
  String get transactionHistory => isIndonesian ? 'Riwayat Transaksi' : 'Transaction History';

  // Sub-screens
  String get maintenanceTitle => isIndonesian ? 'Sistem Sedang Maintenance' : 'System Under Maintenance';
  String get maintenanceSubtitle => isIndonesian ? 'Kami sedang melakukan pemeliharaan server demi kenyamanan mitra.' : 'We are performing scheduled maintenance to serve partners better.';
  String get uploadKtpTitle => isIndonesian ? 'Unggah Foto KTP' : 'Upload ID Card Photo';
  String get uploadKtpDesc => isIndonesian ? 'Pastikan foto KTP terlihat jelas dan tidak buram' : 'Ensure ID photo is clear and not blurry';
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['id', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
