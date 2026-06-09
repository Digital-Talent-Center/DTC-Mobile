import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'activities_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final int _selectedNavIndex = 3;
  bool _showAllAchievements = false;

  // ── Dummy user data ──
  final String _firstName = 'Arrijal Julfa';
  final String _lastName = 'Arrasyid';
  final String _status = 'Human Capital';
  final String _email = 'arrijal.julfa@dtc.web';
  final String _nim = '202488192';
  final String _faculty = 'Faculty of Social Sciences';
  final String _about =
      'Passionate Human Capital professional with a focus on organizational development and talent acquisition. Dedicated to building inclusive workspaces where innovation thrives and individuals reach their full potential.';

  // ── Dummy achievements ──
  final List<Map<String, dynamic>> _achievements = [
    {
      'icon': Icons.emoji_events,
      'iconBg': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFEA8000),
      'title': '1st Place HC Competition',
      'subtitle': 'Regional Talent Strategy 2023',
    },
    {
      'icon': Icons.shield_outlined,
      'iconBg': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFEA8000),
      'title': 'Best Delegate Award',
      'subtitle': 'Youth Leadership Summit 2024',
    },
    {
      'icon': Icons.workspace_premium,
      'iconBg': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFEA8000),
      'title': "Dean's List Honoree",
      'subtitle': 'Top 5% Academic Excellence',
    },
    {
      'icon': Icons.star,
      'iconBg': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFEA8000),
      'title': 'Outstanding Volunteer',
      'subtitle': 'Community Service Award 2024',
    },
    {
      'icon': Icons.code,
      'iconBg': const Color(0xFFFFF3E0),
      'iconColor': const Color(0xFFEA8000),
      'title': 'Hackathon Winner',
      'subtitle': 'National Code Fest 2025',
    },
  ];

  // ── Dummy recent activities ──
  final List<Map<String, String>> _recentActivities = [
    {
      'title': 'Just finished a remarkable workshop on "Digital...',
      'author': 'Arrijal Julfa Arrasyid',
      'time': 'Posted • 5h ago',
    },
    {
      'title': 'Excited to announce my nomination for the upcoming...',
      'author': 'Arrijal Julfa Arrasyid',
      'time': 'Posted • 1d ago',
    },
    {
      'title': 'Sharing insights from the leadership seminar...',
      'author': 'Arrijal Julfa Arrasyid',
      'time': 'Posted • 3d ago',
    },
  ];

  String get _initials {
    final fi = _firstName.isNotEmpty ? _firstName[0] : '';
    final li = _lastName.isNotEmpty ? _lastName[0] : '';
    return '$fi$li'.toUpperCase();
  }

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Profile card (cover + avatar + user info) ───
            _buildProfileCard(),
            const SizedBox(height: 24),

            // ─── About section ───
            _buildAboutSection(),
            const SizedBox(height: 24),

            // ─── Achievements section ───
            _buildAchievementsSection(),
            const SizedBox(height: 24),

            // ─── Recent Activity section ───
            _buildRecentActivitySection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedNavIndex,
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // PROFILE CARD (COVER + AVATAR + USER INFO)
  // ════════════════════════════════════════════════════
  Widget _buildProfileCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Cover image ──
            SizedBox(
              height: 190,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Cover photo
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      image: const DecorationImage(
                        image: AssetImage('Assets/images/logo-dtc.png'),
                        fit: BoxFit.cover,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF5B800), Color(0xFFEA8000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        color: Colors.black.withOpacity(0.25),
                      ),
                    ),
                  ),

                  // Avatar circle – overlapping the cover
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
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          _initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Edit Profile button
                  Positioned(
                    bottom: 6,
                    right: 12,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Navigate to edit profile
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
                      label: const Text(
                        'Edit Profile',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── User info ──
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_firstName $_lastName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFFEA8000),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(Icons.email_outlined, _email),
                  const SizedBox(height: 6),
                  _infoRow(Icons.badge_outlined, 'NIM: $_nim'),
                  const SizedBox(height: 6),
                  _infoRow(Icons.school_outlined, _faculty),
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
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════
  // ABOUT SECTION
  // ════════════════════════════════════════════════════
  Widget _buildAboutSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
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
                const Text(
                  'About',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _about,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // ACHIEVEMENTS SECTION
  // ════════════════════════════════════════════════════
  Widget _buildAchievementsSection() {
    final displayedAchievements = _showAllAchievements
        ? _achievements
        : _achievements.take(3).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Color(0xFFEA8000),
                  ),
                ),
                const Spacer(),
                if (_achievements.length > 3)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showAllAchievements = !_showAllAchievements;
                      });
                    },
                    child: Text(
                      _showAllAchievements ? 'Show Less' : 'Show More',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFEA8000),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Achievement list
            ...displayedAchievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              return Column(
                children: [
                  if (index > 0)
                    const Divider(height: 1, color: Color(0xFFF0EDED)),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: achievement['iconBg'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement['icon'] as IconData,
                            color: achievement['iconColor'] as Color,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                achievement['title'] as String,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                achievement['subtitle'] as String,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════
  // RECENT ACTIVITY SECTION
  // ════════════════════════════════════════════════════
  Widget _buildRecentActivitySection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
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
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ActivitiesScreen()),
                    );
                  },
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFEA8000),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Activity cards (horizontal scroll)
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _recentActivities.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final activity = _recentActivities[index];
                  return _buildActivityCard(activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(Map<String, String> activity) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF6F0),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFEDE3D5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFEA8000),
                ),
                child: Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['author'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      activity['time'] ?? '',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Colors.black38,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Title / description
          Text(
            activity['title'] ?? '',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),

          // Dummy image placeholder
          Expanded(
            flex: 0,
            child: Container(
              height: 70,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFFE8D9C5),
                image: const DecorationImage(
                  image: AssetImage('Assets/images/logo-dtc.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
