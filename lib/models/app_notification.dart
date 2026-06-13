import 'package:intl/intl.dart';

/// Notifikasi sistem. Mengikuti tabel `notifications` di backend.
class AppNotification {
  final int id;
  final String category; // ACHIEVEMENT | ACTIVITY | SYSTEM | ...
  final String title;
  final String message;
  final bool isRead;
  final DateTime? createdAt;

  const AppNotification({
    required this.id,
    required this.category,
    required this.title,
    required this.message,
    required this.isRead,
    this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) {
    return AppNotification(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      category: '${j['category'] ?? 'SYSTEM'}'.toUpperCase(),
      title: '${j['title'] ?? ''}',
      message: '${j['message'] ?? ''}',
      isRead: j['isRead'] == true || j['is_read'] == true,
      createdAt: DateTime.tryParse('${j['createdAt'] ?? j['created_at'] ?? ''}'),
    );
  }

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        category: category,
        title: title,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  String get timeAgo {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt!);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(createdAt!);
  }
}
