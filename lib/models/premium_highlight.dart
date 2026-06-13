import 'package:intl/intl.dart';
import '../config/api_config.dart';

/// Premium Post yang sudah dibayar (status 'paid') — untuk seksi
/// "Premium Highlights" di dashboard.
class PremiumHighlight {
  final int id;
  final String postTitle;
  final String postDescription;
  final String? imageUrl;
  final String userName;
  final DateTime? date;

  const PremiumHighlight({
    required this.id,
    required this.postTitle,
    required this.postDescription,
    this.imageUrl,
    required this.userName,
    this.date,
  });

  factory PremiumHighlight.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    final rawImage = j['imageUrl'] ?? j['image_url'];
    final rawDate = j['paidAt'] ?? j['paid_at'] ?? j['createdAt'] ?? j['created_at'];
    return PremiumHighlight(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      postTitle: '${j['postTitle'] ?? j['post_title'] ?? ''}',
      postDescription: '${j['postDescription'] ?? j['post_description'] ?? ''}',
      imageUrl: (rawImage == null || '$rawImage'.isEmpty)
          ? null
          : ApiConfig.fileUrl('$rawImage'),
      userName: user is Map ? '${user['name'] ?? 'Anonymous'}' : 'Anonymous',
      date: rawDate == null ? null : DateTime.tryParse('$rawDate'),
    );
  }

  /// Label waktu relatif sederhana (mis. "2 jam lalu").
  String get timeAgo {
    if (date == null) return '';
    final diff = DateTime.now().difference(date!);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy', 'id_ID').format(date!);
  }
}
