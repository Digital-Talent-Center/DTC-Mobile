import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class GuideDocument {
  final String title;
  final String description;
  final IconData icon;
  final List<String> tags;
  final String competition;
  final String type;
  final String year;

  const GuideDocument({
    required this.title,
    required this.description,
    required this.icon,
    required this.tags,
    required this.competition,
    required this.type,
    required this.year,
  });
}

class CoGuideScreen extends StatefulWidget {
  const CoGuideScreen({Key? key}) : super(key: key);

  @override
  State<CoGuideScreen> createState() => _CoGuideScreenState();
}

class _CoGuideScreenState extends State<CoGuideScreen> {
  final int _selectedNavIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  String _search = '';
  String? _competition;
  String? _type;
  String? _year;

  final List<GuideDocument> _documents = const [
    GuideDocument(
      title: 'Template PKM-RE 2024.docx',
      description:
          'Official template for Program Kreativitas Mahasiswa Riset Eksakta for the 2024...',
      icon: Icons.description_outlined,
      tags: ['PKM', 'TEMPLATE', '2024'],
      competition: 'PKM',
      type: 'Template',
      year: '2024',
    ),
    GuideDocument(
      title: 'Panduan Umum PKM 2024',
      description:
          'Comprehensive guidebook covering all PKM schemes and general eligibility...',
      icon: Icons.menu_book_outlined,
      tags: ['GENERAL', 'GUIDE'],
      competition: 'PKM',
      type: 'Guide',
      year: '2024',
    ),
    GuideDocument(
      title: 'Contoh Proposal PKM-K Lolos',
      description:
          'A verified winning proposal from the Entrepreneurship category (2023).',
      icon: Icons.article_outlined,
      tags: ['PKM-K', 'WINNING'],
      competition: 'PKM',
      type: 'Proposal',
      year: '2023',
    ),
  ];

  List<String> get _competitionOptions =>
      _documents.map((d) => d.competition).toSet().toList();
  List<String> get _typeOptions =>
      _documents.map((d) => d.type).toSet().toList();
  List<String> get _yearOptions =>
      _documents.map((d) => d.year).toSet().toList();

  List<GuideDocument> get _filtered {
    return _documents.where((d) {
      final matchSearch = _search.isEmpty ||
          d.title.toLowerCase().contains(_search.toLowerCase()) ||
          d.description.toLowerCase().contains(_search.toLowerCase());
      final matchComp = _competition == null || d.competition == _competition;
      final matchType = _type == null || d.type == _type;
      final matchYear = _year == null || d.year == _year;
      return matchSearch && matchComp && matchType && matchYear;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _download(GuideDocument doc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Mengunduh "${doc.title}"...')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final docs = _filtered;

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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 16),
          // Competition + Type
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Competition',
                  value: _competition,
                  options: _competitionOptions,
                  onChanged: (v) => setState(() => _competition = v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Type',
                  value: _type,
                  options: _typeOptions,
                  onChanged: (v) => setState(() => _type = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Year
          _buildDropdown(
            label: 'Year',
            value: _year,
            options: _yearOptions,
            onChanged: (v) => setState(() => _year = v),
          ),
          const SizedBox(height: 20),
          if (docs.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40),
              child: Center(
                child: Text(
                  'Dokumen tidak ditemukan',
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            ...docs.map((doc) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _DocumentCard(
                    doc: doc,
                    onDownload: () => _download(doc),
                  ),
                )),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedNavIndex,
      ),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
              hint: const Text(''),
              borderRadius: BorderRadius.circular(12),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('All', style: TextStyle(color: Colors.black54)),
                ),
                ...options.map(
                  (o) => DropdownMenuItem<String?>(
                    value: o,
                    child: Text(o),
                  ),
                ),
              ],
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final GuideDocument doc;
  final VoidCallback onDownload;

  const _DocumentCard({required this.doc, required this.onDownload});

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
                child: Icon(doc.icon, color: const Color(0xFFEA8000), size: 26),
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
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: doc.tags.map((t) => _tag(t)).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B800),
                foregroundColor: Colors.black87,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.download, size: 20),
              label: const Text(
                'Download',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
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
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8A6A3E),
        ),
      ),
    );
  }
}
