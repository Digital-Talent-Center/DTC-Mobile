/// Konfigurasi koneksi ke backend DTC Platform (Laravel + Sanctum).
///
/// Base URL dapat dioverride saat build tanpa mengubah kode:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10
///
/// Panduan per environment:
/// ┌──────────────────────────────┬───────────────────────────────────────────────────┐
/// │ Environment                  │ Perintah                                          │
/// ├──────────────────────────────┼───────────────────────────────────────────────────┤
/// │ Emulator Android (Docker)    │ flutter run  (default: http://10.0.2.2)           │
/// │ HP fisik (WiFi sama laptop)  │ flutter run --dart-define=API_BASE_URL=http://192.168.1.4 │
/// │ Railway Production           │ flutter run --dart-define=API_BASE_URL=https://dtc-platform-production.up.railway.app │
/// └──────────────────────────────┴───────────────────────────────────────────────────┘
///
/// Catatan: Docker nginx berjalan di port 80 (HTTP default), tidak perlu
/// menuliskan port secara eksplisit.
class ApiConfig {
  ApiConfig._();

  /// Host server Laravel (tanpa trailing slash).
  /// - Emulator Android: 10.0.2.2 adalah alias ke localhost laptop (port 80)
  /// - HP fisik         : IP LAN laptop, mis. http://192.168.1.4
  /// - Production       : URL Railway, mis. https://dtc-platform-production.up.railway.app
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2',
  );

  /// Prefix semua endpoint REST.
  static const String apiPrefix = '/api';

  /// URL penuh ke endpoint API, mis. apiUrl('/activities').
  static String apiUrl(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$apiPrefix$p';
  }

  /// Host Midtrans Snap (sandbox secara default). Override via:
  ///   flutter run --dart-define=MIDTRANS_SNAP_HOST=https://app.midtrans.com
  static const String midtransSnapHost = String.fromEnvironment(
    'MIDTRANS_SNAP_HOST',
    defaultValue: 'https://app.sandbox.midtrans.com',
  );

  /// URL halaman pembayaran Snap untuk sebuah snap token (dibuka di browser).
  static String snapRedirectUrl(String token) =>
      '$midtransSnapHost/snap/v4/redirection/$token';

  /// Lengkapi path file/storage relatif (mis. "/storage/..") jadi URL absolut.
  /// Jika sudah absolut (http...) dikembalikan apa adanya.
  static String fileUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) return path;
    final p = path.startsWith('/') ? path : '/$path';
    return '$baseUrl$p';
  }
}
