import '../models/profile_detail.dart';
import 'api_client.dart';

/// Akses & update profil mahasiswa (ProfileExtension).
class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  final _api = ApiClient.instance;

  Future<ProfileDetail> fetch() async {
    final res = await _api.get('/profile');
    return ProfileDetail.fromJson(_data(res));
  }

  /// Update profil. Field opsional; hanya yang dikirim yang diperbarui.
  Future<ProfileDetail> update({
    String? nim,
    String? faculty,
    String? major,
    String? phone,
    String? about,
  }) async {
    final body = <String, dynamic>{
      'nim': nim,
      'faculty': faculty,
      'major': major,
      'phone': phone,
      'about': about,
    }..removeWhere((_, v) => v == null);

    final res = await _api.put('/profile', body: body);
    return ProfileDetail.fromJson(_data(res));
  }

  Map<String, dynamic> _data(dynamic res) {
    final d = (res is Map) ? res['data'] : res;
    if (d is Map<String, dynamic>) return d;
    if (d is Map) return Map<String, dynamic>.from(d);
    return <String, dynamic>{};
  }
}
