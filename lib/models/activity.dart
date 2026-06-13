import 'package:intl/intl.dart';

/// Aktivitas (Event / Task). Mengikuti skema tabel `activities` di backend.
/// status backend: pending | in_progress | completed | cancelled | overdue
class Activity {
  final int id;
  final String type; // 'event' | 'task'
  final String title;
  final String description;
  final String status;
  final DateTime? activityDate;
  final DateTime? deadline;
  final String? startTime; // 'HH:mm'
  final String? endTime; // 'HH:mm'
  final String? location;

  const Activity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.status,
    this.activityDate,
    this.deadline,
    this.startTime,
    this.endTime,
    this.location,
  });

  static DateTime? _date(dynamic v) {
    if (v == null || '$v'.isEmpty) return null;
    return DateTime.tryParse('$v');
  }

  factory Activity.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) => (v == null || '$v'.isEmpty) ? null : '$v';
    return Activity(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      type: '${j['type'] ?? 'event'}',
      title: '${j['title'] ?? ''}',
      description: '${j['description'] ?? ''}',
      status: '${j['status'] ?? 'pending'}',
      activityDate: _date(j['activityDate'] ?? j['activity_date']),
      deadline: _date(j['deadline']),
      startTime: s(j['startTime'] ?? j['start_time']),
      endTime: s(j['endTime'] ?? j['end_time']),
      location: s(j['location']),
    );
  }

  bool get isTask => type == 'task';
  bool get isEvent => type == 'event';

  /// Overdue dihitung di klien (seperti web): kalau belum selesai/dibatalkan
  /// dan tanggalnya sudah lewat.
  bool get isOverdue {
    final st = status.toLowerCase();
    if (st == 'completed' || st == 'cancelled') return false;
    final ref = isTask ? deadline : activityDate;
    if (ref == null) return false;
    return ref.isBefore(DateTime.now());
  }

  /// Status yang ditampilkan (mengganti jadi 'overdue' bila lewat tenggat).
  String get displayStatus => isOverdue ? 'overdue' : status.toLowerCase();

  String get dateLabel {
    if (activityDate == null) return '-';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(activityDate!);
  }

  String get deadlineLabel {
    if (deadline == null) return '-';
    return DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(deadline!);
  }

  String get timeLabel {
    if (startTime == null) return '';
    if (endTime == null) return startTime!;
    return '$startTime - $endTime';
  }
}
