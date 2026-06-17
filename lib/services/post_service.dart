import '../models/post.dart';
import 'api_client.dart';
import 'session.dart';

/// Akses timeline: posts, like, komentar, dan laporan (report).
class PostService {
  PostService._();
  static final PostService instance = PostService._();

  final _api = ApiClient.instance;

  int get _uid => Session.instance.user?.id ?? 0;

  Future<List<Post>> list({int page = 1, int perPage = 10}) async {
    final res = await _api.get('/posts', query: {'page': page, 'per_page': perPage});
    return _extractList(res)
        .map((e) => Post.fromJson(e, _uid))
        .toList();
  }

  Future<List<Post>> listByUser(int userId, {int perPage = 5}) async {
    final res = await _api.get('/posts', query: {'user_id': userId, 'per_page': perPage});
    return _extractList(res).map((e) => Post.fromJson(e, _uid)).toList();
  }

  Future<Post> create({
    required String content,
    String? tag,
    String? imageUrl,
  }) async {
    final res = await _api.post('/posts', body: {
      'content': content,
      if (tag != null && tag.isNotEmpty) 'tag': tag,
      if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
    });
    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : <String, dynamic>{};
    return Post.fromJson(data, _uid);
  }

  /// Unggah media (foto/video) ke server, kembalikan path relatif (mis. /storage/..).
  Future<String?> uploadMedia(String filePath) async {
    final res = await _api.multipart(
      '/posts/upload-media',
      method: 'POST',
      fileField: 'file',
      filePath: filePath,
    );
    if (res is Map) {
      return (res['url'] ?? res['path']) as String?;
    }
    return null;
  }

  /// Toggle like. Mengembalikan (isLiked, likesCount) dari server.
  Future<({bool isLiked, int likesCount})> toggleLike(int postId) async {
    final res = await _api.post('/posts/$postId/like');
    final m = (res is Map) ? res : <String, dynamic>{};
    return (
      isLiked: m['isLiked'] == true,
      likesCount: (m['likesCount'] is int)
          ? m['likesCount'] as int
          : int.tryParse('${m['likesCount'] ?? 0}') ?? 0,
    );
  }

  Future<Comment> addComment(int postId, String content) async {
    final res =
        await _api.post('/posts/$postId/comments', body: {'content': content});
    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : <String, dynamic>{};
    return Comment.fromJson(data);
  }

  Future<void> deletePost(int postId) async {
    await _api.delete('/posts/$postId');
  }

  /// Laporkan post. reason ∈ inappropriate_content|spam|harassment|
  /// false_information|copyright_violation|other
  Future<void> report({
    required int postId,
    required String reason,
    String? description,
  }) async {
    await _api.post('/reports', body: {
      'post_id': postId,
      'reason': reason,
      if (description != null && description.isNotEmpty) 'description': description,
    });
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
