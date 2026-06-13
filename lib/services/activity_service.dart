import '../models/activity.dart';
import 'api_client.dart';

/// Akses data aktivitas (events & tasks) ke REST API DTC Platform.
class ActivityService {
  ActivityService._();
  static final ActivityService instance = ActivityService._();

  final _api = ApiClient.instance;

  Future<List<Activity>> list() async {
    final res = await _api.get('/activities');
    return _extractList(res).map((e) => Activity.fromJson(e)).toList();
  }

  /// Buat aktivitas baru. Field memakai snake_case sesuai ActivityController@store.
  /// [activityDate]/[deadline] format yyyy-MM-dd, [startTime]/[endTime] format HH:mm.
  Future<Activity> create({
    required String type, // 'event' | 'task'
    required String title,
    String? description,
    required String activityDate,
    String? deadline,
    String? startTime,
    String? endTime,
    String? location,
  }) async {
    final body = <String, dynamic>{
      'type': type,
      'title': title,
      'description': description,
      'status': 'pending',
      'activity_date': activityDate,
      'deadline': deadline,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
    };
    final res = await _api.post('/activities', body: body);
    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : <String, dynamic>{};
    return Activity.fromJson(data);
  }

  /// Ubah status aktivitas (Start / Complete / Cancel).
  /// status valid: pending|in_progress|completed|cancelled|overdue
  Future<void> updateStatus(int id, String status) async {
    await _api.put('/activities/$id', body: {'status': status});
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
