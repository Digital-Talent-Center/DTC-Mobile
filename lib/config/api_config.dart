/// Konfigurasi koneksi ke backend DTC Platform (Laravel + Sanctum).
///
/// Base URL dapat dioverride saat build tanpa mengubah kode:
///   flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
///
/// Default `http://10.0.2.2:8000` adalah alamat loopback host laptop
/// dari sudut pandang Android Emulator (localhost-nya laptop).
/// - HP fisik   : pakai IP LAN laptop, mis. http://192.168.x.x:8000
/// - Chrome/web : http://localhost:8000
class ApiConfig {
  ApiConfig._();

  /// Host server Laravel (tanpa trailing slash).
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
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
