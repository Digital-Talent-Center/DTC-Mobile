import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/library_item.dart';
import '../services/library_service.dart';
import '../services/api_client.dart';
import '../widgets/bottom_navbar.dart';

class CoLibraryScreen extends StatefulWidget {
  const CoLibraryScreen({Key? key}) : super(key: key);

  @override
  State<CoLibraryScreen> createState() => _CoLibraryScreenState();
}

class _CoLibraryScreenState extends State<CoLibraryScreen> {
  final int _selectedNavIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  bool _loading = true;
  String? _error;
  List<LibraryItem> _documents = [];

  String _search = '';
  String _category = 'all';

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
      final data = await LibraryService.instance.documents();
      if (!mounted) return;
      setState(() {
        _documents = data;
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
        _error = 'Gagal memuat dokumen. Periksa koneksi server.';
        _loading = false;
      });
    }
  }

  List<String> get _categories {
    final set = <String>{};
    for (final d in _documents) {
      if (d.category != null && d.category!.isNotEmpty) set.add(d.category!);
    }
    return set.toList()..sort();
  }

  List<LibraryItem> get _filtered {
    return _documents.where((d) {
      final matchSearch = _search.isEmpty ||
          d.title.toLowerCase().contains(_search.toLowerCase()) ||
          d.description.toLowerCase().contains(_search.toLowerCase());
      final matchCat = _category == 'all' || d.category == _category;
      return matchSearch && matchCat;
    }).toList();
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openFile(LibraryItem doc) async {
    if (!doc.hasFile) {
      _snack('File belum tersedia untuk dokumen ini.');
      return;
    }
    LibraryService.instance.markDocumentViewed(doc.id); // best-effort
    try {
      final ok = await launchUrl(Uri.parse(doc.fileUrl),
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
          'Co-Library',
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
            if (_categories.isNotEmpty) _buildCategoryChips(),
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
    final docs = _filtered;
    if (docs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Center(
            child: Text('Dokumen tidak ditemukan',
                style: TextStyle(color: Colors.black45))),
      );
    }
    return Column(
      children: docs
          .map((doc) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _DocumentCard(doc: doc, onView: () => _openFile(doc)),
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
          hintText: 'Cari dokumen...',
          hintStyle: TextStyle(color: Colors.black38),
          prefixIcon: Icon(Icons.search, color: Colors.black45),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final cats = ['all', ..._categories];
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cats[i];
          final selected = _category == c;
          return GestureDetector(
            onTap: () => setState(() => _category = c),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFEA8000) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE6D8C6)),
              ),
              child: Text(
                c == 'all' ? 'All' : c,
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
}

class _DocumentCard extends StatelessWidget {
  final LibraryItem doc;
  final VoidCallback onView;

  const _DocumentCard({required this.doc, required this.onView});

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
                child: const Icon(Icons.description_outlined,
                    color: Color(0xFFEA8000), size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doc.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (doc.tags.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: doc.tags.map((t) => _tag(t)).toList(),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.remove_red_eye_outlined,
                  size: 15, color: Colors.black38),
              const SizedBox(width: 4),
              Text('${doc.viewsCount} views',
                  style: const TextStyle(fontSize: 12, color: Colors.black38)),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onView,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B800),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.visibility_outlined, size: 20),
              label: const Text('View File',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
        ],
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
