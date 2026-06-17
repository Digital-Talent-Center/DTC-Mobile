import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../models/post.dart';
import '../models/profile_detail.dart';
import '../services/achievement_service.dart';
import '../services/post_service.dart';
import '../services/profile_service.dart';
import '../services/session.dart';
import '../widgets/bottom_navbar.dart';
import 'activities_screen.dart';
import 'co_guide_screen.dart';
import 'co_library_screen.dart';
import 'my_achievements_screen.dart';
import 'submit_achievement_screen.dart';
import 'premium_post_screen.dart';
import 'timeline_screen.dart';
import 'profile-edit.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedNavIndex = 4;

  bool _loading = true;
  String? _error;
  ProfileDetail? _profile;
  List<Achievement> _approved = [];
  List<Post> _recentPosts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        ProfileService.instance.fetch(),
        AchievementService.instance.list(),
        PostService.instance.listByUser(Session.instance.user?.id ?? 0),
      ]);
      if (!mounted) return;
      final profile = results[0] as ProfileDetail;
      final achievements = results[1] as List<Achievement>;
      final posts = results[2] as List<Post>;
      setState(() {
        _profile = profile;
        _approved = achievements.where((a) => a.isApproved).take(3).toList();
        _recentPosts = posts;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat profil. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  String _roleLabel(String role) =>
      role.isEmpty ? 'Student' : role[0].toUpperCase() + role.substring(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF6F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFBF6F0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavbar(currentIndex: _selectedNavIndex),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: Color(0xFFEA8000)));
    }
    if (_error != null || _profile == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(_error ?? 'Profil tidak tersedia',
                style: const TextStyle(color: Colors.black54)),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    final p = _profile!;
    return RefreshIndicator(
      color: const Color(0xFFEA8000),
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileCard(p),
            const SizedBox(height: 24),
            _buildStatsRow(p),
            const SizedBox(height: 24),
            _buildAboutSection(p),
            const SizedBox(height: 24),
            _buildAchievementsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
            _buildRecentPosts(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(ProfileDetail p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 190,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      gradient: LinearGradient(
                        colors: [Color(0xFFF5B800), Color(0xFFEA8000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 16,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEA8000),
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4)),
                        ],
                        image: p.avatarUrl != null
                            ? DecorationImage(
                                image: NetworkImage(p.avatarUrl!),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: p.avatarUrl != null
                          ? null
                          : Center(
                              child: Text(
                                p.initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                ),
                              ),
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 6,
                    right: 12,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ProfileEditScreen(),
                          ),
                        );
                        _load(); // refresh setelah edit
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5B800),
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit Profile',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _roleLabel(p.role),
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFEA8000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (p.email.isNotEmpty) _infoRow(Icons.email_outlined, p.email),
                  if (p.nim != null) ...[
                    const SizedBox(height: 6),
                    _infoRow(Icons.badge_outlined, 'NIM: ${p.nim}'),
                  ],
                  if (p.faculty != null) ...[
                    const SizedBox(height: 6),
                    _infoRow(Icons.school_outlined, p.faculty!),
                  ],
                  if (p.major != null) ...[
                    const SizedBox(height: 6),
                    _infoRow(Icons.menu_book_outlined, p.major!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(fontSize: 14, color: Colors.black54)),
        ),
      ],
    );
  }

  Widget _buildStatsRow(ProfileDetail p) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
              child: _statCard('Total Posts', '${p.postsCount}', Icons.article_outlined)),
          const SizedBox(width: 12),
          Expanded(
              child: _statCard('Tasks Completed', '${p.completedTasksCount}',
                  Icons.task_alt_outlined)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEA8000)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Colors.black45)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEA8000),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87)),
                const Spacer(),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection(ProfileDetail p) {
    return _sectionCard(
      title: 'About',
      child: Text(
        (p.about == null || p.about!.isEmpty)
            ? 'Belum ada deskripsi. Tekan "Edit Profile" untuk menambahkan.'
            : p.about!,
        style: const TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return _sectionCard(
      title: 'Achievements',
      trailing: GestureDetector(
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MyAchievementsScreen())),
        child: const Text('View all',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFFEA8000))),
      ),
      child: _approved.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Belum ada prestasi yang disetujui.',
                  style: TextStyle(color: Colors.black45)),
            )
          : Column(
              children: _approved.asMap().entries.map((entry) {
                final i = entry.key;
                final a = entry.value;
                return Column(
                  children: [
                    if (i > 0)
                      const Divider(height: 1, color: Color(0xFFF0EDED)),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFF3E0),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.emoji_events,
                                color: Color(0xFFEA8000), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black87)),
                                const SizedBox(height: 2),
                                Text(
                                  [a.category, a.tingkat]
                                      .where((e) => e != null && e.isNotEmpty)
                                      .join(' • '),
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
    );
  }

  Widget _buildRecentPosts() {
    return _sectionCard(
      title: 'Recent Posts',
      child: _recentPosts.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada postingan.',
                style: TextStyle(color: Colors.black45),
              ),
            )
          : SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentPosts.length,
                itemBuilder: (_, i) => _postCard(_recentPosts[i]),
              ),
            ),
    );
  }

  Widget _postCard(Post post) {
    final hasImage = post.imageUrl != null && !post.isVideo;
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEDE3D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                post.imageUrl!,
                height: 70,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.tag != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        post.tag!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFEA8000),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                  Expanded(
                    child: Text(
                      post.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.timeAgo,
                    style: const TextStyle(fontSize: 10, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = <Map<String, dynamic>>[
      {'label': 'Submit Achievement', 'icon': Icons.military_tech_outlined, 'builder': (BuildContext _) => const SubmitAchievementScreen()},
      {'label': 'My Activities', 'icon': Icons.event_note_outlined, 'builder': (BuildContext _) => const ActivitiesScreen()},
      {'label': 'Co-Library', 'icon': Icons.collections_bookmark_outlined, 'builder': (BuildContext _) => const CoLibraryScreen()},
      {'label': 'Co-Guide', 'icon': Icons.explore_outlined, 'builder': (BuildContext _) => const CoGuideScreen()},
      {'label': 'Timeline', 'icon': Icons.show_chart, 'builder': (BuildContext _) => const TimelineScreen()},
      {'label': 'Premium Post', 'icon': Icons.star_border, 'builder': (BuildContext _) => const PremiumPostScreen()},
    ];

    return _sectionCard(
      title: 'Quick Actions',
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.6,
        children: actions.map((a) {
          return InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: a['builder'] as WidgetBuilder),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFBF6F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEDE3D5)),
              ),
              child: Row(
                children: [
                  Icon(a['icon'] as IconData,
                      color: const Color(0xFFEA8000), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a['label'] as String,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
