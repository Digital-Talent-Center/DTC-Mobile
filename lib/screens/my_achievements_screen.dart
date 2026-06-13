import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../services/achievement_service.dart';
import '../services/api_client.dart';
import '../widgets/bottom_navbar.dart';
import 'submit_achievement_screen.dart';

class MyAchievementsScreen extends StatefulWidget {
  const MyAchievementsScreen({Key? key}) : super(key: key);

  @override
  State<MyAchievementsScreen> createState() => _MyAchievementsScreenState();
}

class _MyAchievementsScreenState extends State<MyAchievementsScreen> {
  final int _selectedNavIndex = 0;

  /// 0 = Collection (approved), 1 = Need Approval (pending), 2 = Rejected
  int _selectedTab = 0;

  bool _loading = true;
  String? _error;
  List<Achievement> _all = [];

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
      final data = await AchievementService.instance.list();
      if (!mounted) return;
      setState(() {
        _all = data;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.firstError;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Gagal memuat prestasi. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  List<Achievement> get _filtered {
    switch (_selectedTab) {
      case 0:
        return _all.where((a) => a.isApproved).toList();
      case 1:
        return _all.where((a) => a.isPending).toList();
      case 2:
        return _all.where((a) => a.isRejected).toList();
      default:
        return _all;
    }
  }

  Future<void> _openSubmitScreen() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const SubmitAchievementScreen()),
    );
    if (created == true) {
      // Prestasi baru selalu berstatus pending → arahkan ke tab Need Approval.
      setState(() => _selectedTab = 1);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: RefreshIndicator(
        color: const Color(0xFFEA8000),
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
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
            const SizedBox(height: 24),
            // Tabs (3): Collection / Need Approval / Rejected
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _tab('Achievement Collection', 0),
                  const SizedBox(width: 12),
                  _tab('Need Approval', 1),
                  const SizedBox(width: 12),
                  _tab('Rejected', 2),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildBody(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedNavIndex,
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFEA8000)),
        ),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.cloud_off, size: 48, color: Colors.black26),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              TextButton(onPressed: _load, child: const Text('Coba lagi')),
            ],
          ),
        ),
      );
    }
    final items = _filtered;
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
          child: Text(
            'Belum ada prestasi pada kategori ini.',
            style: TextStyle(color: Colors.black45),
          ),
        ),
      );
    }
    return Column(
      children: items
          .map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _AchievementCard(achievement: a),
              ))
          .toList(),
    );
  }

  Widget _tab(String label, int index) {
    final selected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF5B800) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? Colors.black87 : Colors.black26,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
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
                achievement.dateRangeLabel,
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          if (achievement.linkSertifikat != null &&
              achievement.linkSertifikat!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.link, size: 16, color: Color(0xFFEA8000)),
                SizedBox(width: 8),
                Text(
                  'Lihat Sertifikat',
                  style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFEA8000),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
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

  Widget _statusBadge(String status) {
    late Color bg;
    late Color fg;
    late String label;

    switch (status.toLowerCase()) {
      case 'approved':
        bg = const Color(0xFFC8E6C9);
        fg = const Color(0xFF1B5E20);
        label = 'Approved';
        break;
      case 'rejected':
        bg = const Color(0xFFF3C0C0);
        fg = const Color(0xFF7A1F1F);
        label = 'Rejected';
        break;
      default:
        bg = const Color(0xFFFBE6A8);
        fg = const Color(0xFF7A5C12);
        label = 'Pending';
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
