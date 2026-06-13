import '../config/api_config.dart';

/// Item repositori belajar — dipakai untuk Co-Library (documents) maupun
/// Co-Guide (guides) karena strukturnya mirip.
class LibraryItem {
  final int id;
  final String title;
  final String description;
  final String? category;
  final String? level;
  final int? year;
  final String? filePath; // relatif (mis. /storage/..) atau absolut
  final List<String> tags;
  final int viewsCount;
  final int downloadsCount;

  const LibraryItem({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    this.level,
    this.year,
    this.filePath,
    this.tags = const [],
    this.viewsCount = 0,
    this.downloadsCount = 0,
  });

  /// URL file absolut yang siap dibuka di browser.
  String get fileUrl => ApiConfig.fileUrl(filePath);
  bool get hasFile => filePath != null && filePath!.isNotEmpty;

  static List<String> _tags(dynamic v) {
    if (v is! List) return const [];
    return v.map((e) {
      if (e is String) return e;
      if (e is Map) return '${e['name'] ?? ''}';
      return '$e';
    }).where((s) => s.isNotEmpty).toList();
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse('${v ?? 0}') ?? 0;
  }

  factory LibraryItem.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) => (v == null || '$v'.isEmpty) ? null : '$v';
    return LibraryItem(
      id: _int(j['id']),
      title: '${j['title'] ?? ''}',
      description: '${j['description'] ?? ''}',
      category: s(j['category']),
      level: s(j['level']),
      year: j['year'] == null ? null : _int(j['year']),
      filePath: s(j['filePath'] ?? j['file_path']),
      tags: _tags(j['tags']),
      viewsCount: _int(j['viewsCount'] ?? j['views_count']),
      downloadsCount: _int(j['downloadsCount'] ?? j['downloads_count']),
    );
  }
}
