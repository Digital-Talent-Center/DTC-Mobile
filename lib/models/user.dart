/// Profil mahasiswa (gabungan data User + ProfileExtension dari backend).
class Profile {
  final String? nim;
  final String? faculty;
  final String? major;
  final String? phone;
  final String? avatarUrl;
  final String? about;
  final String? role;

  const Profile({
    this.nim,
    this.faculty,
    this.major,
    this.phone,
    this.avatarUrl,
    this.about,
    this.role,
  });

  factory Profile.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) => v == null ? null : '$v';
    return Profile(
      nim: s(j['nim']),
      faculty: s(j['faculty']),
      major: s(j['major'] ?? j['studyProgram'] ?? j['study_program']),
      phone: s(j['phone']),
      avatarUrl: s(j['avatarUrl'] ?? j['avatar_url']),
      about: s(j['about']),
      role: s(j['role']),
    );
  }

  Map<String, dynamic> toJson() => {
        'nim': nim,
        'faculty': faculty,
        'major': major,
        'phone': phone,
        'avatarUrl': avatarUrl,
        'about': about,
        'role': role,
      };

  Profile copyWith({
    String? nim,
    String? faculty,
    String? major,
    String? phone,
    String? avatarUrl,
    String? about,
    String? role,
  }) {
    return Profile(
      nim: nim ?? this.nim,
      faculty: faculty ?? this.faculty,
      major: major ?? this.major,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      about: about ?? this.about,
      role: role ?? this.role,
    );
  }
}

/// User yang sedang login.
class AppUser {
  final int id;
  final String name;
  final String email;
  final String role;
  final Profile? profile;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'student',
    this.profile,
  });

  factory AppUser.fromJson(Map<String, dynamic> j) {
    final profileJson = j['profile'] ?? j['profileExtension'] ?? j['profile_extension'];
    return AppUser(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      name: '${j['name'] ?? ''}',
      email: '${j['email'] ?? ''}',
      role: '${j['role'] ?? (profileJson is Map ? profileJson['role'] : null) ?? 'student'}',
      profile: profileJson is Map<String, dynamic>
          ? Profile.fromJson(profileJson)
          : (profileJson is Map ? Profile.fromJson(Map<String, dynamic>.from(profileJson)) : null),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'profile': profile?.toJson(),
      };

  /// Inisial untuk avatar (mis. "Arrijal Julfa" -> "AJ").
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  AppUser copyWith({String? name, String? email, String? role, Profile? profile}) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profile: profile ?? this.profile,
    );
  }
}
