import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/library_item.dart';
import '../services/library_service.dart';
import '../services/api_client.dart';
import '../widgets/bottom_navbar.dart';

class CoGuideScreen extends StatefulWidget {
  const CoGuideScreen({Key? key}) : super(key: key);

  @override
  State<CoGuideScreen> createState() => _CoGuideScreenState();
}

class _CoGuideScreenState extends State<CoGuideScreen> {
  final int _selectedNavIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  List<LibraryItem> _guides = [];

  String _search = '';
  String _level = 'all';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await LibraryService.instance.guides();
      if (!mounted) return;
      setState(() {
        _guides = data;
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
        _error = 'Gagal memuat panduan. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  List<String> get _levels {
    final set = <String>{};
    for (final g in _guides) {
      if (g.level != null && g.level!.isNotEmpty) set.add(g.level!);
    }
    return set.toList()..sort();
  }

  List<LibraryItem> get _filtered {
    return _guides.where((g) {
      final matchSearch = _search.isEmpty ||
          g.title.toLowerCase().contains(_search.toLowerCase()) ||
          g.description.toLowerCase().contains(_search.toLowerCase());
      final matchLevel = _level == 'all' || g.level == _level;
      return matchSearch && matchLevel;
    }).toList();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _open(LibraryItem g, {required bool isDownload}) async {
    if (!g.hasFile) {
      _snack('File belum tersedia untuk panduan ini.');
      return;
    }
    if (isDownload) {
      LibraryService.instance.markGuideDownloaded(g.id);
    } else {
      LibraryService.instance.markGuideViewed(g.id);
    }
    try {
      final ok = await launchUrl(Uri.parse(g.fileUrl),
          mode: LaunchMode.externalApplication);
      if (!ok) _snack('Tidak dapat membuka file.');
    } catch (_) {
      _snack('Tidak dapat membuka file.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF1E8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFEA8000)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Co-Guide',
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
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),
            _buildLevelChips(),
            const SizedBox(height: 16),
            _buildBody(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(currentIndex: _selectedNavIndex),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator(color: Color(0xFFEA8000))),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Center(
          child: Column(children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.black26),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54)),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ]),
        ),
      );
    }
    final guides = _filtered;
    if (guides.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
            child: Text('Panduan tidak ditemukan',
                style: TextStyle(color: Colors.black45))),
      );
    }
    return Column(
      children: guides
          .map((g) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _GuideCard(
                  guide: g,
                  onView: () => _open(g, isDownload: false),
                  onDownload: () => _open(g, isDownload: true),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: TextField(
        controller: _searchCtrl,
        onChanged: (v) => setState(() => _search = v),
        decoration: const InputDecoration(
          hintText: 'Cari panduan...',
          hintStyle: TextStyle(color: Colors.black38),
          prefixIcon: Icon(Icons.search, color: Colors.black45),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildLevelChips() {
    final levels = ['all', ..._levels];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final lv = levels[i];
          final selected = _level == lv;
          return GestureDetector(
            onTap: () => setState(() => _level = lv),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEA8000) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6D8C6)),
              ),
              child: Text(
                lv == 'all' ? 'All Levels' : _capitalize(lv),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: selected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _GuideCard extends StatelessWidget {
  final LibraryItem guide;
  final VoidCallback onView;
  final VoidCallback onDownload;

  const _GuideCard({
    required this.guide,
    required this.onView,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book_outlined,
                    color: Color(0xFFEA8000), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      guide.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      guide.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              if (guide.level != null) _levelBadge(guide.level!),
            ],
          ),
          if (guide.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: guide.tags.map((t) => _tag(t)).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  size: 15, color: Colors.black38),
              const SizedBox(width: 4),
              Text('${guide.viewsCount} views',
                  style: const TextStyle(fontSize: 12, color: Colors.black38)),
              const SizedBox(width: 14),
              const Icon(Icons.download_outlined,
                  size: 15, color: Colors.black38),
              const SizedBox(width: 4),
              Text('${guide.downloadsCount} downloads',
                  style: const TextStyle(fontSize: 12, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onView,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEA8000),
                    side: const BorderSide(color: Color(0xFFEA8000)),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.visibility_outlined, size: 18),
                  label: const Text('View',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onDownload,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5B800),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.download, size: 18),
                  label: const Text('Download',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _levelBadge(String level) {
    Color bg;
    Color fg;
    switch (level.toLowerCase()) {
      case 'beginner':
        bg = const Color(0xFFE3F2FD);
        fg = const Color(0xFF1565C0);
        break;
      case 'intermediate':
        bg = const Color(0xFFFFF3CD);
        fg = const Color(0xFFB8860B);
        break;
      default:
        bg = const Color(0xFFFDE0E0);
        fg = const Color(0xFFB71C1C);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(
        level[0].toUpperCase() + level.substring(1),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  Widget _tag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF6EADD),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8A6A3E),
        ),
      ),
    );
  }
}
