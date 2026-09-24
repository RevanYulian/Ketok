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
  String get loginTitle => isIndonesian ? 'Masuk ke Ketok' : 'Log In to Ketok';
  String get loginSubtitle => isIndonesian
      ? 'Solusi cepat perbaikan rumah & servis teknisi terpercaya'
      : 'Fast home repair solutions & trusted technician services';
  String get emailLabel => isIndonesian ? 'Email' : 'Email';
  String get emailHint => isIndonesian ? 'nama@email.com' : 'name@email.com';
  String get passwordLabel => isIndonesian ? 'Kata Sandi' : 'Password';
  String get passwordHint => isIndonesian ? 'Minimal 6 karakter' : 'At least 6 characters';
  String get forgotPassword => isIndonesian ? 'Lupa Sandi?' : 'Forgot Password?';
  String get loginButton => isIndonesian ? 'Masuk' : 'Log In';
  String get registerButton => isIndonesian ? 'Daftar' : 'Sign Up';
  String get dontHaveAccount => isIndonesian ? 'Belum punya akun?' : "Don't have an account?";
  String get alreadyHaveAccount => isIndonesian ? 'Sudah punya akun?' : 'Already have an account?';
  String get registerNow => isIndonesian ? 'Daftar Sekarang' : 'Register Now';
  String get loginNow => isIndonesian ? 'Masuk Sekarang' : 'Log In Now';
  String get orLoginWith => isIndonesian ? 'atau masuk dengan' : 'or continue with';
  String get googleLogin => isIndonesian ? 'Lanjutkan dengan Google' : 'Continue with Google';
  String get appleLogin => isIndonesian ? 'Lanjutkan dengan Apple' : 'Continue with Apple';
  String get emailRequired => isIndonesian ? 'Email tidak boleh kosong' : 'Email is required';
  String get passwordRequired => isIndonesian ? 'Kata sandi tidak boleh kosong' : 'Password is required';
  String get passwordMinLength => isIndonesian ? 'Kata sandi minimal 6 karakter' : 'Password must be at least 6 characters';
  String get fullNameLabel => isIndonesian ? 'Nama Lengkap' : 'Full Name';
  String get fullNameHint => isIndonesian ? 'Masukkan nama lengkap Anda' : 'Enter your full name';
  String get phoneLabel => isIndonesian ? 'Nomor Telepon' : 'Phone Number';
  String get phoneHint => isIndonesian ? 'Contoh: 08123456789' : 'e.g. 08123456789';

  // Beranda / Home
  String get greetingGoodMorning => isIndonesian ? 'Selamat Pagi' : 'Good Morning';
  String get greetingGoodAfternoon => isIndonesian ? 'Selamat Siang' : 'Good Afternoon';
  String get greetingGoodEvening => isIndonesian ? 'Selamat Sore' : 'Good Evening';
  String get greetingGoodNight => isIndonesian ? 'Selamat Malam' : 'Good Night';
  String get searchServiceHint => isIndonesian ? 'Cari layanan teknisi, AC, listrik...' : 'Search technician, AC, electrical services...';
  String get mainCategories => isIndonesian ? 'Kategori Layanan' : 'Service Categories';
  String get popularServices => isIndonesian ? 'Jasa Paling Populer' : 'Popular Services';
  String get specialPromo => isIndonesian ? 'Promo Spesial' : 'Special Offers';
  String get tipsAndInsights => isIndonesian ? 'Tips & Inspirasi Rumah' : 'Home Tips & Insights';
  String get verifiedMitraBadge => isIndonesian ? 'Mitra Terverifikasi' : 'Verified Partner';
  String get startingFrom => isIndonesian ? 'Mulai dari' : 'Starting from';
  String get orderNow => isIndonesian ? 'Pesan Sekarang' : 'Book Now';
  String get seeDetails => isIndonesian ? 'Lihat Detail' : 'View Details';
  String get emptyData => isIndonesian ? 'Belum ada data tersedia' : 'No data available yet';

  // Orders / Pesanan
  String get ordersTitle => isIndonesian ? 'Pesanan Saya' : 'My Orders';
  String get tabAll => isIndonesian ? 'Semua' : 'All';
  String get tabWaiting => isIndonesian ? 'Menunggu' : 'Pending';
  String get tabInProgress => isIndonesian ? 'Diproses' : 'In Progress';
  String get tabCompleted => isIndonesian ? 'Selesai' : 'Completed';
  String get tabCancelled => isIndonesian ? 'Dibatalkan' : 'Cancelled';
  String get emptyOrders => isIndonesian ? 'Belum Ada Pesanan' : 'No Orders Yet';
  String get emptyOrdersDesc => isIndonesian
      ? 'Anda belum memiliki riwayat pesanan layanan.'
      : 'You have no order history yet.';
  String get orderNumber => isIndonesian ? 'No. Pesanan' : 'Order No.';
  String get orderDate => isIndonesian ? 'Tanggal Pesanan' : 'Order Date';
  String get orderStatus => isIndonesian ? 'Status Pesanan' : 'Order Status';
  String get technician => isIndonesian ? 'Teknisi' : 'Technician';
  String get totalPayment => isIndonesian ? 'Total Pembayaran' : 'Total Payment';
  String get cancelOrder => isIndonesian ? 'Batalkan Pesanan' : 'Cancel Order';
  String get contactTechnician => isIndonesian ? 'Hubungi Teknisi' : 'Contact Technician';
  String get reorder => isIndonesian ? 'Pesan Lagi' : 'Reorder';
  String get giveReview => isIndonesian ? 'Beri Ulasan' : 'Write Review';
  String get orderDetailTitle => isIndonesian ? 'Detail Pesanan' : 'Order Detail';
  String get serviceAddress => isIndonesian ? 'Alamat Layanan' : 'Service Address';
  String get problemDescription => isIndonesian ? 'Deskripsi Keluhan' : 'Problem Description';
  String get paymentSummary => isIndonesian ? 'Rincian Pembayaran' : 'Payment Summary';
  String get basePrice => isIndonesian ? 'Biaya Jasa' : 'Service Fee';
  String get visitFee => isIndonesian ? 'Biaya Kunjungan' : 'Visit Fee';
  String get discount => isIndonesian ? 'Diskon Promo' : 'Promo Discount';

  // Chat
  String get chatTitle => isIndonesian ? 'Chat & Pesan' : 'Chat & Messages';
  String get emptyChat => isIndonesian ? 'Belum Ada Pesan' : 'No Messages Yet';
  String get emptyChatDesc => isIndonesian
      ? 'Obrolan Anda dengan teknisi mitra akan muncul di sini.'
      : 'Your conversations with technician partners will appear here.';
  String get typeMessageHint => isIndonesian ? 'Tulis pesan...' : 'Type a message...';
  String get activeNow => isIndonesian ? 'Online' : 'Online';

  // Profile / Settings
  String get profileTitle => isIndonesian ? 'Profil Saya' : 'My Profile';
  String get completedOrdersCountLabel => isIndonesian ? 'Pesanan Selesai' : 'Completed';
  String get reviewsCountLabel => isIndonesian ? 'Ulasan Diberikan' : 'Reviews';
  String get activeVouchersCountLabel => isIndonesian ? 'Voucher Aktif' : 'Vouchers';
  String get sectionActivity => isIndonesian ? 'AKTIVITAS & ALAMAT' : 'ACTIVITY & ADDRESS';
  String get sectionSecurity => isIndonesian ? 'PREFERENSI & KEAMANAN' : 'PREFERENCES & SECURITY';
  String get sectionHelp => isIndonesian ? 'BANTUAN & INFO KETOK' : 'HELP & ABOUT KETOK';
  String get savedAddresses => isIndonesian ? 'Alamat Tersimpan' : 'Saved Addresses';
  String get savedAddressesSubtitle => isIndonesian ? 'Kelola alamat rumah, kantor, atau lokasi kerja' : 'Manage home, office, or job locations';
  String get ketokPayBalance => isIndonesian ? 'Saldo KetokPay' : 'KetokPay Balance';
  String get ketokPaySubtitle => isIndonesian ? 'Pemasukan, pengeluaran & isi saldo' : 'Income, expenses & top-up';
  String get myVouchers => isIndonesian ? 'Voucher & Promo Saya' : 'My Vouchers & Promos';
  String get myVouchersSubtitle => isIndonesian ? 'Koleksi voucher promo yang Anda miliki' : 'Voucher collection you own';
  String get notificationsSetting => isIndonesian ? 'Notifikasi Pesanan & Chat' : 'Order & Chat Notifications';
  String get notificationsSubtitle => isIndonesian ? 'Pemberitahuan pembaruan pesanan waktu nyata' : 'Real-time order update alerts';
  String get accountSecurity => isIndonesian ? 'Keamanan Akun & Sandi' : 'Account Security & Password';
  String get accountSecuritySubtitle => isIndonesian ? 'Ubah kata sandi akun Anda' : 'Change your account password';
  String get appLanguage => isIndonesian ? 'Bahasa Aplikasi' : 'App Language';
  String get currentLanguageName => isIndonesian ? 'Bahasa Indonesia (ID)' : 'English (US)';
  String get selectLanguageTitle => isIndonesian ? 'Pilih Bahasa Aplikasi' : 'Select App Language';
  String get partnerBannerTitle => isIndonesian ? 'Tertarik Menjadi Mitra Ketok?' : 'Interested in Becoming a Ketok Partner?';
  String get partnerBannerSubtitle => isIndonesian ? 'Dapatkan penghasilan fleksibel dengan bergabung sebagai teknisi profesional Ketok.' : 'Earn flexible income by joining as a professional Ketok technician.';
  String get partnerBannerAction => isIndonesian ? 'Daftar Jadi Mitra' : 'Join as Partner';
  String get helpCenter => isIndonesian ? 'Pusat Bantuan & FAQ' : 'Help Center & FAQ';
  String get helpCenterSubtitle => isIndonesian ? 'Pertanyaan umum dan kontak Customer Service' : 'Frequently asked questions & Customer Service';
  String get termsConditions => isIndonesian ? 'Syarat & Ketentuan Layanan' : 'Terms & Conditions';
  String get termsConditionsSubtitle => isIndonesian ? 'Ketentuan penggunaan platform Ketok' : 'Terms of use for Ketok platform';
  String get privacyPolicy => isIndonesian ? 'Kebijakan Privasi' : 'Privacy Policy';
  String get privacyPolicySubtitle => isIndonesian ? 'Perlindungan data dan privasi pengguna' : 'User privacy and data protection';
  String get logoutButton => isIndonesian ? 'Keluar dari Akun' : 'Log Out';
  String get logoutConfirmTitle => isIndonesian ? 'Keluar dari Akun' : 'Log Out of Account';
  String get logoutConfirmDesc => isIndonesian ? 'Apakah Anda yakin ingin keluar dari akun Ketok Anda?' : 'Are you sure you want to log out of your Ketok account?';

  // Sub-pages
  String get editProfileTitle => isIndonesian ? 'Ubah Profil' : 'Edit Profile';
  String get changePasswordTitle => isIndonesian ? 'Ubah Kata Sandi' : 'Change Password';
  String get oldPassword => isIndonesian ? 'Kata Sandi Saat Ini' : 'Current Password';
  String get newPassword => isIndonesian ? 'Kata Sandi Baru' : 'New Password';
  String get confirmNewPassword => isIndonesian ? 'Konfirmasi Kata Sandi Baru' : 'Confirm New Password';
  String get passwordMismatch => isIndonesian ? 'Konfirmasi kata sandi tidak cocok' : 'Password confirmation does not match';
  String get notificationsPageTitle => isIndonesian ? 'Pusat Notifikasi' : 'Notification Center';
  String get markAllAsRead => isIndonesian ? 'Tandai Semua Dibaca' : 'Mark All as Read';
  String get addAddress => isIndonesian ? 'Tambah Alamat Baru' : 'Add New Address';
  String get addressNameLabel => isIndonesian ? 'Label Alamat (Rumah, Kantor)' : 'Address Label (Home, Office)';
  String get fullAddressLabel => isIndonesian ? 'Alamat Lengkap' : 'Full Address';
  String get setAsDefaultAddress => isIndonesian ? 'Jadikan Alamat Utama' : 'Set as Default Address';
  String get voucherCodeHint => isIndonesian ? 'Masukkan kode voucher' : 'Enter voucher code';
  String get useVoucher => isIndonesian ? 'Gunakan' : 'Apply';
  String get bookingConfirmed => isIndonesian ? 'Pesanan Berhasil Dibuat!' : 'Booking Successfully Created!';
  String get bookingConfirmedDesc => isIndonesian ? 'Mitra teknisi akan segera memproses pesanan Anda.' : 'The technician partner will process your booking shortly.';
  String get maintenanceTitle => isIndonesian ? 'Sistem Sedang Maintenance' : 'System Under Maintenance';
  String get maintenanceSubtitle => isIndonesian ? 'Kami sedang melakukan pemeliharaan server demi kenyamanan Anda.' : 'We are performing scheduled maintenance to serve you better.';
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
