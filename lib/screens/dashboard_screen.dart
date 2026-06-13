import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import '../models/premium_highlight.dart';
import '../services/session.dart';
import '../services/auth_service.dart';
import '../services/premium_service.dart';
import 'login_screen.dart';
import 'activities_screen.dart';
import 'co_guide_screen.dart';
import 'co_library_screen.dart';
import 'my_achievements_screen.dart';
import 'submit_achievement_screen.dart';
import 'premium_post_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final int _selectedIndex = 0;

  bool _loadingHighlights = true;
  String? _highlightsError;
  List<PremiumHighlight> _highlights = [];

  final List<Map<String, dynamic>> _features = [
    {'icon': Icons.event_note_outlined, 'label': 'Activities', 'color': Color(0xFFEA8000)},
    {'icon': Icons.emoji_events_outlined, 'label': 'My Achievement', 'color': Color(0xFFF5B800)},
    {'icon': Icons.military_tech_outlined, 'label': 'Submit Achievement', 'color': Color(0xFF8B5CF6)},
    {'icon': Icons.collections_bookmark_outlined, 'label': 'Co-Library', 'color': Color(0xFFEA8000)},
    {'icon': Icons.explore_outlined, 'label': 'Co-Guide', 'color': Color(0xFFE91E63)},
    {'icon': Icons.star_border, 'label': 'Premium Post', 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    setState(() {
      _loadingHighlights = true;
      _highlightsError = null;
    });
    try {
      final data = await PremiumService.instance.highlights();
      if (!mounted) return;
      setState(() {
        _highlights = data;
        _loadingHighlights = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _highlightsError = 'Gagal memuat Premium Highlights.';
        _loadingHighlights = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _openFeature(String label) {
    final routes = <String, WidgetBuilder>{
      'Activities': (_) => const ActivitiesScreen(),
      'Co-Guide': (_) => const CoGuideScreen(),
      'Co-Library': (_) => const CoLibraryScreen(),
      'My Achievement': (_) => const MyAchievementsScreen(),
      'Submit Achievement': (_) => const SubmitAchievementScreen(),
      'Premium Post': (_) => const PremiumPostScreen(),
    };
    final builder = routes[label];
    if (builder != null) {
      Navigator.push(context, MaterialPageRoute(builder: builder))
          .then((_) => _loadHighlights());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFFEA8000),
          onRefresh: _loadHighlights,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                Text(
                  'Hi, ${Session.instance.user?.name ?? 'Mahasiswa'}!',
                  style: const TextStyle(
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
                      onTap: () => _openFeature(f['label'] as String),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'PREMIUM HIGHLIGHTS',
                  style: TextStyle(
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                _buildHighlights(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavbar(currentIndex: _selectedIndex),
    );
  }

  Widget _buildHighlights() {
    if (_loadingHighlights) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFEA8000))),
      );
    }
    if (_highlightsError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.cloud_off, color: Colors.black38),
            const SizedBox(width: 12),
            Expanded(child: Text(_highlightsError!)),
            TextButton(onPressed: _loadHighlights, child: const Text('Coba lagi')),
          ],
        ),
      );
    }
    if (_highlights.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          children: [
            const Icon(Icons.star_border, size: 40, color: Color(0xFFF5B800)),
            const SizedBox(height: 10),
            const Text(
              'Belum ada Premium Post yang tersedia.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _openFeature('Premium Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B800),
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Buat Premium Post',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    }
    return Column(
      children: _highlights
          .map((h) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _HighlightCard(highlight: h),
              ))
          .toList(),
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
                  color: color.withValues(alpha: 0.15),
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

class _HighlightCard extends StatelessWidget {
  final PremiumHighlight highlight;

  const _HighlightCard({required this.highlight});

  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Color(0xFFF5B800), size: 20),
            const SizedBox(width: 8),
            const Expanded(child: Text('Premium Post')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (highlight.imageUrl != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  highlight.imageUrl!,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text('${highlight.userName} • ${highlight.timeAgo}',
                style: const TextStyle(fontSize: 12, color: Colors.black45)),
            const SizedBox(height: 8),
            Text(highlight.postTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            if (highlight.postDescription.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(highlight.postDescription,
                  style: const TextStyle(color: Colors.black54)),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
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
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: highlight.imageUrl != null
                  ? Image.network(
                      highlight.imageUrl!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _placeholderIcon(),
                    )
                  : _placeholderIcon(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Color(0xFFF5B800)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          highlight.userName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                      Text(highlight.timeAgo,
                          style: const TextStyle(
                              fontSize: 11, color: Colors.black38)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    highlight.postTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Container(
      width: 56,
      height: 56,
      color: const Color(0xFFFFF3E0),
      child: const Icon(Icons.image_outlined, color: Color(0xFFEA8000)),
    );
  }
}
