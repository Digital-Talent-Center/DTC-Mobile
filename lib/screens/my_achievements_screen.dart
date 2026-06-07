import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';
import 'submit_achievement_screen.dart';

enum AchievementStatus { pending, rejected }

class Achievement {
  String title;
  String description;
  String category;
  String date;
  AchievementStatus status;

  Achievement({
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.status,
  });
}

class MyAchievementsScreen extends StatefulWidget {
  const MyAchievementsScreen({Key? key}) : super(key: key);

  @override
  State<MyAchievementsScreen> createState() => _MyAchievementsScreenState();
}

class _MyAchievementsScreenState extends State<MyAchievementsScreen> {
  final int _selectedNavIndex = 0;
  int _selectedTab = 0; // 0 = Need Approval, 1 = Rejected

  final List<Achievement> _achievements = [
    Achievement(
      title: 'Juara makan kerupuk',
      description: 'dddd',
      category: 'Kompetisi Ilmiah',
      date: '-',
      status: AchievementStatus.pending,
    ),
  ];

  List<Achievement> get _filtered {
    final status =
        _selectedTab == 0 ? AchievementStatus.pending : AchievementStatus.rejected;
    return _achievements.where((a) => a.status == status).toList();
  }

  Future<void> _openSubmitScreen() async {
    final result = await Navigator.push<Achievement>(
      context,
      MaterialPageRoute(builder: (_) => const SubmitAchievementScreen()),
    );
    if (result != null) {
      setState(() => _achievements.add(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;

    return Scaffold(
      backgroundColor: const Color(0xFFFBF1E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEA8000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Achievements',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        children: [
          // Submit Achievement button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openSubmitScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B800),
                foregroundColor: Colors.black87,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.add, size: 24),
              label: const Text(
                'Submit Achievement',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Center(
            child: Text(
              'Achievement Collection',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Tabs
          Row(
            children: [
              _tab('Need Approval', 0),
              const SizedBox(width: 16),
              _tab('Rejected', 1),
            ],
          ),
          const SizedBox(height: 20),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Belum ada achievement',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            ...items.map((a) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _AchievementCard(achievement: a),
                )),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedNavIndex,
      ),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5B800) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.black87 : Colors.transparent,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: selected ? Colors.black87 : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDE3D5)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + category badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5CB7E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.description_outlined,
                    color: Color(0xFF6B4E1E), size: 26),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1E3CC),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  achievement.category,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6B4E1E),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            achievement.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            achievement.description,
            style: const TextStyle(fontSize: 15, color: Colors.black54),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 16, color: Colors.black45),
              const SizedBox(width: 8),
              Text(
                achievement.date,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFEDE3D5)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _statusBadge(achievement.status),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(AchievementStatus status) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status) {
      case AchievementStatus.pending:
        bg = const Color(0xFFFBE6A8);
        fg = const Color(0xFF7A5C12);
        label = 'Pending';
        break;
      case AchievementStatus.rejected:
        bg = const Color(0xFFF3C0C0);
        fg = const Color(0xFF7A1F1F);
        label = 'Rejected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: fg,
        ),
      ),
    );
  }
}
