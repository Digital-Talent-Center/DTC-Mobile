import '../models/app_notification.dart';
import 'api_client.dart';

/// Akses notifikasi sistem.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _api = ApiClient.instance;

  Future<List<AppNotification>> list() async {
    final res = await _api.get('/notifications');
    return _extractList(res).map((e) => AppNotification.fromJson(e)).toList();
  }

  Future<void> markAsRead(int id) async {
    await _api.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.put('/notifications/mark-all-read');
  }

  Future<void> delete(int id) async {
    await _api.delete('/notifications/$id');
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
