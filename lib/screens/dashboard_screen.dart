import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'login_screen.dart';
import 'activities_screen.dart';
import 'co_guide_screen.dart';
import 'co_library_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  int _visiblePremiumPostCount = 3;
  int _visiblePremiumHighlightCount = 3;

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.calendar_today, 'label': 'Activities', 'color': Color(0xFFEA8000)},
    {'icon': Icons.assignment_outlined, 'label': 'My Tasks', 'color': Color(0xFF2D7BF4)},
    {'icon': Icons.military_tech_outlined, 'label': 'Submit Achievement', 'color': Color(0xFF8B5CF6)},
    {'icon': Icons.menu_book_outlined, 'label': 'Co-Library', 'color': Color(0xFFEA8000)},
    {'icon': Icons.explore_outlined, 'label': 'Co-Guide', 'color': Color(0xFFE91E63)},
    {'icon': Icons.star_border, 'label': 'Premium Post', 'color': Color(0xFF8B5CF6)},
  ];

  final List<Map<String, String>> _premiumPosts = [
    {
      'title': 'Course material updated',
      'description': 'Advanced Statistics - Chapter 4 was just updated with new practice quizzes.',
      'timeAgo': '2 HOURS AGO',
    },
    {
      'title': 'New premium article',
      'description': 'Exclusive case study on machine learning applications in finance.',
      'timeAgo': '5 HOURS AGO',
    },
    {
      'title': 'Webinar reminder',
      'description': 'Join our upcoming live session on data visualization tomorrow at 7PM.',
      'timeAgo': '1 DAY AGO',
    },
    {
      'title': 'New tutorial released',
      'description': 'Step-by-step guide on Flutter state management with Provider package.',
      'timeAgo': '2 DAYS AGO',
    },
    {
      'title': 'Mentor session available',
      'description': 'Book a 1-on-1 mentor session with our experienced industry experts.',
      'timeAgo': '3 DAYS AGO',
    },
  ];

  final List<Map<String, String>> _premiumHighlights = [
    {
      'title': 'Course material updated',
      'description': 'Advanced Statistics - Chapter 4 was just updated with new practice quizzes.',
      'timeAgo': '2 HOURS AGO',
    },
    {
      'title': 'Top student of the week',
      'description': 'Congratulations to Sarah for achieving the highest score this week.',
      'timeAgo': '6 HOURS AGO',
    },
    {
      'title': 'Featured project showcase',
      'description': 'Check out the trending student project on AI-based recommendation systems.',
      'timeAgo': '12 HOURS AGO',
    },
    {
      'title': 'New scholarship opportunity',
      'description': 'Applications are now open for the Prodigi Excellence Scholarship 2026.',
      'timeAgo': '1 DAY AGO',
    },
    {
      'title': 'Community event recap',
      'description': 'Highlights from the recent Prodigi Hackathon held last weekend.',
      'timeAgo': '2 DAYS AGO',
    },
  ];

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _showMorePosts() {
    setState(() {
      _visiblePremiumPostCount = (_visiblePremiumPostCount + 3).clamp(0, _premiumPosts.length);
    });
  }

  void _showMoreHighlights() {
    setState(() {
      _visiblePremiumHighlightCount = (_visiblePremiumHighlightCount + 3).clamp(0, _premiumHighlights.length);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visiblePosts = _premiumPosts.take(_visiblePremiumPostCount).toList();
    final hasMorePosts = _visiblePremiumPostCount < _premiumPosts.length;
    final visibleHighlights = _premiumHighlights.take(_visiblePremiumHighlightCount).toList();
    final hasMoreHighlights = _visiblePremiumHighlightCount < _premiumHighlights.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset('Assets/images/logo-horizontal.png', height: 40),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red),
                    onPressed: _logout,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Hi, Arrijal Julfa Arrasyid!',
                style: TextStyle(
                  color: Color(0xFFEA8000),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Fitur Aplikasi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.95,
                children: _features.map((f) {
                  return _FeatureCard(
                    icon: f['icon'] as IconData,
                    label: f['label'] as String,
                    color: f['color'] as Color,
                    onTap: () {
                      if (f['label'] == 'Activities') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ActivitiesScreen()),
                        );
                      } else if (f['label'] == 'Co-Guide') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CoGuideScreen()),
                        );
                      } else if (f['label'] == 'Co-Library') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CoLibraryScreen()),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'PREMIUM POST',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              ...visiblePosts.map((post) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostCard(
                  title: post['title']!,
                  description: post['description']!,
                  timeAgo: post['timeAgo']!,
                ),
              )),
              if (hasMorePosts)
                Center(
                  child: TextButton(
                    onPressed: _showMorePosts,
                    child: const Text(
                      'Show More',
                      style: TextStyle(
                        color: Color(0xFFEA8000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const Text(
                'PREMIUM HIGHLIGHT',
                style: TextStyle(
                  color: Colors.black45,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 12),
              ...visibleHighlights.map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PostCard(
                  title: h['title']!,
                  description: h['description']!,
                  timeAgo: h['timeAgo']!,
                ),
              )),
              if (hasMoreHighlights)
                Center(
                  child: TextButton(
                    onPressed: _showMoreHighlights,
                    child: const Text(
                      'Show More',
                      style: TextStyle(
                        color: Color(0xFFEA8000),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final String title;
  final String description;
  final String timeAgo;

  const _PostCard({
    required this.title,
    required this.description,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFEA8000).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFFEA8000), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 8),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: Colors.black38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
