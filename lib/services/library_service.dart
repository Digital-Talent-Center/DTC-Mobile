import '../models/library_item.dart';
import 'api_client.dart';

/// Akses Co-Library (documents) & Co-Guide (guides).
class LibraryService {
  LibraryService._();
  static final LibraryService instance = LibraryService._();

  final _api = ApiClient.instance;

  /// Co-Library — dokumen publik.
  Future<List<LibraryItem>> documents() async {
    final res = await _api.get('/documents');
    return _extractList(res).map((e) => LibraryItem.fromJson(e)).toList();
  }

  /// Co-Guide — panduan/tutorial publik.
  Future<List<LibraryItem>> guides() async {
    final res = await _api.get('/guides');
    return _extractList(res).map((e) => LibraryItem.fromJson(e)).toList();
  }

  /// Catat view dokumen (membuka file menambah hitungan view di server).
  Future<void> markDocumentViewed(int id) async {
    try {
      await _api.get('/documents/$id');
    } catch (_) {/* best-effort */}
  }

  /// Catat view guide.
  Future<void> markGuideViewed(int id) async {
    try {
      await _api.get('/guides/$id');
    } catch (_) {/* best-effort */}
  }

  /// Catat unduhan guide (menambah downloads_count di server).
  Future<void> markGuideDownloaded(int id) async {
    try {
      await _api.post('/guides/$id/download');
    } catch (_) {/* best-effort */}
  }

  List<Map<String, dynamic>> _extractList(dynamic res) {
    dynamic data = (res is Map) ? res['data'] : res;
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
