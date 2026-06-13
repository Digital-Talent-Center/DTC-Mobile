import '../models/premium_highlight.dart';
import 'api_client.dart';

/// Akses data Premium Highlights (post premium yang sudah dibayar).
class PremiumService {
  PremiumService._();
  static final PremiumService instance = PremiumService._();

  final _api = ApiClient.instance;

  Future<List<PremiumHighlight>> highlights() async {
    final res = await _api.get('/premium-transactions/highlights');
    final data = (res is Map) ? res['data'] : res;
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => PremiumHighlight.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return const [];
  }
}
