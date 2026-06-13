import 'package:intl/intl.dart';
import '../config/api_config.dart';

String _avatar(dynamic user) {
  if (user is! Map) return '';
  final pe = user['profileExtension'] ?? user['profile_extension'];
  final url = (pe is Map) ? (pe['avatarUrl'] ?? pe['avatar_url']) : null;
  return (url == null || '$url'.isEmpty) ? '' : ApiConfig.fileUrl('$url');
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+'));
  if (parts.isEmpty || parts.first.isEmpty) return '?';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}

String _timeAgo(DateTime? d) {
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}j';
  if (diff.inDays < 7) return '${diff.inDays}h';
  return DateFormat('d MMM yyyy', 'id_ID').format(d);
}

class Comment {
  final int id;
  final String userName;
  final String userAvatarUrl;
  final String content;
  final DateTime? createdAt;

  const Comment({
    required this.id,
    required this.userName,
    required this.userAvatarUrl,
    required this.content,
    this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) {
    final user = j['user'];
    return Comment(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      userName: user is Map ? '${user['name'] ?? 'Anonymous'}' : 'Anonymous',
      userAvatarUrl: _avatar(user),
      content: '${j['content'] ?? ''}',
      createdAt: DateTime.tryParse('${j['createdAt'] ?? j['created_at'] ?? ''}'),
    );
  }

  String get initials => _initials(userName);
  String get timeAgo => _timeAgo(createdAt);
}

/// Post timeline. Field interaktif (like/komentar) dibuat mutable untuk
/// memudahkan pembaruan optimistik di layar.
class Post {
  final int id;
  final int userId;
  final String userName;
  final String userAvatarUrl;
  final String content;
  final String? tag;
  final String? imageUrl;
  final DateTime? createdAt;

  int likesCount;
  int commentsCount;
  bool likedByMe;
  List<Comment> comments;
  bool showComments;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userAvatarUrl,
    required this.content,
    this.tag,
    this.imageUrl,
    this.createdAt,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.likedByMe = false,
    this.comments = const [],
    this.showComments = false,
  });

  static int _int(dynamic v) =>
      (v is int) ? v : int.tryParse('${v ?? 0}') ?? 0;

  factory Post.fromJson(Map<String, dynamic> j, int currentUserId) {
    final user = j['user'];
    final likes = j['likes'];
    bool liked = false;
    if (likes is List) {
      liked = likes.any((l) =>
          l is Map && _int(l['userId'] ?? l['user_id']) == currentUserId);
    }
    final commentsJson = j['comments'];
    final comments = (commentsJson is List)
        ? commentsJson
            .whereType<Map>()
            .map((c) => Comment.fromJson(Map<String, dynamic>.from(c)))
            .toList()
        : <Comment>[];

    final rawImage = j['imageUrl'] ?? j['image_url'];

    return Post(
      id: _int(j['id']),
      userId: _int(j['userId'] ?? j['user_id']),
      userName: user is Map ? '${user['name'] ?? 'Anonymous'}' : 'Anonymous',
      userAvatarUrl: _avatar(user),
      content: '${j['content'] ?? ''}',
      tag: (j['tag'] == null || '${j['tag']}'.isEmpty) ? null : '${j['tag']}',
      imageUrl: (rawImage == null || '$rawImage'.isEmpty)
          ? null
          : ApiConfig.fileUrl('$rawImage'),
      createdAt: DateTime.tryParse('${j['createdAt'] ?? j['created_at'] ?? ''}'),
      likesCount: _int(j['likesCount'] ?? j['likes_count']),
      commentsCount: _int(j['commentsCount'] ?? j['comments_count']),
      likedByMe: liked,
      comments: comments,
    );
  }

  String get initials => _initials(userName);
  String get timeAgo => _timeAgo(createdAt);

  /// Apakah media post berupa video (berdasarkan ekstensi URL).
  bool get isVideo {
    final u = (imageUrl ?? '').toLowerCase();
    return u.endsWith('.mp4') ||
        u.endsWith('.webm') ||
        u.endsWith('.ogg') ||
        u.endsWith('.mov');
  }
}
