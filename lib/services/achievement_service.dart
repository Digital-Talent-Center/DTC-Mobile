import '../models/achievement.dart';
import 'api_client.dart';

/// Akses data prestasi (achievements) ke REST API DTC Platform.
class AchievementService {
  AchievementService._();
  static final AchievementService instance = AchievementService._();

  final _api = ApiClient.instance;

  /// Ambil semua prestasi milik user aktif (difilter per-tab di layar).
  Future<List<Achievement>> list() async {
    final res = await _api.get('/achievements');
    final list = _extractList(res);
    return list.map((e) => Achievement.fromJson(e)).toList();
  }

  /// Kirim prestasi baru (multipart, dengan opsi file bukti).
  /// Field memakai snake_case sesuai validasi AchievementController@store.
  Future<Achievement> create({
    required String nim,
    required String namaLengkap,
    required String tahunAjaran,
    required String tanggalMulai, // format yyyy-MM-dd
    required String tanggalSelesai, // format yyyy-MM-dd
    required String title,
    required String description,
    required String category,
    required String jenis,
    required String tingkat,
    required String keikutsertaan,
    String? linkSertifikat,
    String? buktiPath,
  }) async {
    final fields = <String, String>{
      'nim': nim,
      'nama_lengkap': namaLengkap,
      'tahun_ajaran': tahunAjaran,
      'tanggal_mulai': tanggalMulai,
      'tanggal_selesai': tanggalSelesai,
      'title': title,
      'description': description,
      'category': category,
      'jenis': jenis,
      'tingkat': tingkat,
      'keikutsertaan': keikutsertaan,
    };
    if (linkSertifikat != null && linkSertifikat.trim().isNotEmpty) {
      fields['link_sertifikat'] = linkSertifikat.trim();
    }

    final res = await _api.multipart(
      '/achievements',
      method: 'POST',
      fields: fields,
      fileField: (buktiPath != null && buktiPath.isNotEmpty) ? 'bukti' : null,
      filePath: buktiPath,
    );

    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : <String, dynamic>{};
    return Achievement.fromJson(data);
  }

  Future<void> delete(int id) async {
    await _api.delete('/achievements/$id');
  }

  List<Map<String, dynamic>> _extractList(dynamic res) {
    dynamic data = (res is Map) ? res['data'] : res;
    // Bisa berupa List langsung, atau objek paginator { data: [...] }.
    if (data is Map && data['data'] is List) data = data['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    return const [];
  }
}
