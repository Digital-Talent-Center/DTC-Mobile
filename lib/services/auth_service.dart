import '../models/user.dart';
import 'api_client.dart';
import 'fcm_service.dart';
import 'session.dart';

/// Layanan autentikasi: login, register, logout, ambil profil user aktif.
/// Token Sanctum disimpan via [Session].
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _api = ApiClient.instance;

  Future<AppUser> login({required String email, required String password}) async {
    final res = await _api.post('/auth/login', body: {
      'email': email,
      'password': password,
    });
    return await _persistFromAuthResponse(res);
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? nim,
    String? faculty,
    String? studyProgram,
  }) async {
    final res = await _api.post('/auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'nim': nim,
      'faculty': faculty,
      'study_program': studyProgram,
    });
    return await _persistFromAuthResponse(res);
  }

  /// Ambil ulang data user aktif (mis. setelah update profil).
  Future<AppUser?> me() async {
    final res = await _api.get('/auth/me');
    final userJson = _extractUser(res);
    if (userJson == null) return null;
    final user = AppUser.fromJson(userJson);
    await Session.instance.updateUser(user);
    return user;
  }

  Future<void> logout() async {
    try {
      await FcmService.instance.deleteTokenFromBackend();
      await _api.post('/auth/logout');
    } catch (_) {
      // Walau gagal di server, sesi lokal tetap dibersihkan.
    } finally {
      await Session.instance.clear();
    }
  }

  Future<AppUser> _persistFromAuthResponse(dynamic res) async {
    final token = (res is Map) ? '${res['token'] ?? ''}' : '';
    final userJson = _extractUser(res);
    if (token.isEmpty || userJson == null) {
      throw ApiException(500, 'Respons login tidak valid dari server.');
    }
    final user = AppUser.fromJson(userJson);
    // Bersihkan sesi lama lalu simpan sesi baru sampai tuntas, agar tidak
    // ada data/token akun sebelumnya yang tersisa.
    await Session.instance.clear();
    await Session.instance.save(token: token, user: user);
    return user;
  }

  Map<String, dynamic>? _extractUser(dynamic res) {
    if (res is! Map) return null;
    final u = res['user'] ?? res['data'];
    if (u is Map<String, dynamic>) return u;
    if (u is Map) return Map<String, dynamic>.from(u);
    return null;
  }
}
