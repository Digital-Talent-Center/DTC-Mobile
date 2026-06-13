import '../config/api_config.dart';

/// Detail profil lengkap (gabungan ProfileExtension + User + statistik)
/// dari endpoint GET /api/profile.
class ProfileDetail {
  final String name;
  final String email;
  final String role;
  final String? nim;
  final String? faculty;
  final String? major;
  final String? phone;
  final String? avatarUrl;
  final String? about;
  final int postsCount;
  final int completedTasksCount;

  const ProfileDetail({
    required this.name,
    required this.email,
    this.role = 'student',
    this.nim,
    this.faculty,
    this.major,
    this.phone,
    this.avatarUrl,
    this.about,
    this.postsCount = 0,
    this.completedTasksCount = 0,
  });

  static int _int(dynamic v) =>
      (v is int) ? v : int.tryParse('${v ?? 0}') ?? 0;

  factory ProfileDetail.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) => (v == null || '$v'.isEmpty) ? null : '$v';
    final user = j['user'];
    final avatar = s(j['avatarUrl'] ?? j['avatar_url']);
    return ProfileDetail(
      name: user is Map ? '${user['name'] ?? ''}' : '',
      email: user is Map ? '${user['email'] ?? ''}' : '',
      role: '${j['role'] ?? 'student'}',
      nim: s(j['nim']),
      faculty: s(j['faculty']),
      major: s(j['major']),
      phone: s(j['phone']),
      avatarUrl: avatar == null ? null : ApiConfig.fileUrl(avatar),
      about: s(j['about']),
      postsCount: _int(j['postsCount'] ?? j['posts_count']),
      completedTasksCount:
          _int(j['completedTasksCount'] ?? j['completed_tasks_count']),
    );
  }

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
