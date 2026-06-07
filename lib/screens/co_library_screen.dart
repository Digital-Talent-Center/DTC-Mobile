import 'package:flutter/material.dart';
import '../widgets/bottom_navbar.dart';

class LibraryDocument {
  final String title;
  final String description;
  final IconData icon;
  final List<String> tags;
  final String competition;
  final String type;
  final String year;
  final String content; // isi dokumen untuk preview

  const LibraryDocument({
    required this.title,
    required this.description,
    required this.icon,
    required this.tags,
    required this.competition,
    required this.type,
    required this.year,
    required this.content,
  });
}

class CoLibraryScreen extends StatefulWidget {
  const CoLibraryScreen({Key? key}) : super(key: key);

  @override
  State<CoLibraryScreen> createState() => _CoLibraryScreenState();
}

class _CoLibraryScreenState extends State<CoLibraryScreen> {
  final int _selectedNavIndex = 0;
  final TextEditingController _searchCtrl = TextEditingController();

  String _search = '';
  String? _competition;
  String? _type;
  String? _year;

  final List<LibraryDocument> _documents = const [
    LibraryDocument(
      title: 'Template PKM-RE 2024.docx',
      description:
          'Official template for Program Kreativitas Mahasiswa Riset Eksakta for the 2024...',
      icon: Icons.description_outlined,
      tags: ['PKM', 'TEMPLATE', '2024'],
      competition: 'PKM',
      type: 'Template',
      year: '2024',
      content:
          'TEMPLATE PROPOSAL PKM-RE 2024\n\n'
          'BAB 1. PENDAHULUAN\n'
          '1.1 Latar Belakang\n'
          'Jelaskan latar belakang permasalahan yang mendasari penelitian. '
          'Uraikan urgensi dan kontribusi riset terhadap bidang keilmuan.\n\n'
          '1.2 Rumusan Masalah\n'
          'Tuliskan rumusan masalah secara ringkas dan terukur.\n\n'
          '1.3 Tujuan\n'
          'Sebutkan tujuan penelitian yang ingin dicapai.\n\n'
          'BAB 2. TINJAUAN PUSTAKA\n'
          'Uraikan teori dan penelitian terdahulu yang relevan.\n\n'
          'BAB 3. METODE PENELITIAN\n'
          'Jelaskan tahapan, variabel, dan teknik analisis data.\n\n'
          'BAB 4. BIAYA DAN JADWAL KEGIATAN\n'
          'Lampirkan rincian anggaran dan timeline pelaksanaan.',
    ),
    LibraryDocument(
      title: 'Panduan Umum PKM 2024',
      description:
          'Comprehensive guidebook covering all PKM schemes and general eligibility...',
      icon: Icons.menu_book_outlined,
      tags: ['GENERAL', 'GUIDE'],
      competition: 'PKM',
      type: 'Guide',
      year: '2024',
      content:
          'PANDUAN UMUM PKM 2024\n\n'
          'A. Pengertian PKM\n'
          'Program Kreativitas Mahasiswa (PKM) adalah wadah pengembangan '
          'kreativitas dan penalaran mahasiswa Indonesia.\n\n'
          'B. Bidang PKM\n'
          '1. PKM-RE (Riset Eksakta)\n'
          '2. PKM-RSH (Riset Sosial Humaniora)\n'
          '3. PKM-K (Kewirausahaan)\n'
          '4. PKM-PM (Pengabdian Masyarakat)\n'
          '5. PKM-PI (Penerapan Iptek)\n'
          '6. PKM-KC (Karsa Cipta)\n\n'
          'C. Persyaratan Umum\n'
          '- Mahasiswa aktif jenjang D3/D4/S1.\n'
          '- Anggota kelompok 3-5 orang.\n'
          '- Memiliki dosen pendamping.\n\n'
          'D. Tahapan Seleksi\n'
          'Pengusulan, penilaian, pendanaan, pelaksanaan, dan PIMNAS.',
    ),
    LibraryDocument(
      title: 'Contoh Proposal PKM-K Lolos',
      description:
          'A verified winning proposal from the Entrepreneurship category (2023).',
      icon: Icons.article_outlined,
      tags: ['PKM-K', 'WINNING'],
      competition: 'PKM',
      type: 'Proposal',
      year: '2023',
      content:
          'CONTOH PROPOSAL PKM-K (LOLOS PENDANAAN 2023)\n\n'
          'Judul: "SnackSehat - Camilan Sehat Berbasis Pangan Lokal"\n\n'
          'BAB 1. PENDAHULUAN\n'
          'Tren gaya hidup sehat meningkatkan permintaan camilan rendah gula. '
          'SnackSehat hadir memanfaatkan bahan pangan lokal bernilai gizi tinggi.\n\n'
          'BAB 2. GAMBARAN UMUM RENCANA USAHA\n'
          'Analisis pasar, keunggulan produk, dan strategi pemasaran digital.\n\n'
          'BAB 3. METODE PELAKSANAAN\n'
          'Produksi, quality control, distribusi, dan evaluasi penjualan.\n\n'
          'BAB 4. BIAYA DAN JADWAL\n'
          'Total anggaran Rp 9.800.000 dengan periode pelaksanaan 4 bulan.',
    ),
  ];

  List<String> get _competitionOptions =>
      _documents.map((d) => d.competition).toSet().toList();
  List<String> get _typeOptions =>
      _documents.map((d) => d.type).toSet().toList();
  List<String> get _yearOptions =>
      _documents.map((d) => d.year).toSet().toList();

  List<LibraryDocument> get _filtered {
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

  void _openDocument(LibraryDocument doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => _DocumentViewerScreen(doc: doc)),
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
          'Co-Library',
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
                    onTap: () => _openDocument(doc),
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
  final LibraryDocument doc;
  final VoidCallback onTap;

  const _DocumentCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
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
                    child: Icon(doc.icon,
                        color: const Color(0xFFEA8000), size: 26),
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
              // Indikator view-only (bukan tombol download)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5B800),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.visibility_outlined,
                        size: 20, color: Colors.black87),
                    SizedBox(width: 8),
                    Text(
                      'View Only',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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

/// Layar preview dokumen — hanya untuk dibaca, tidak bisa diunduh.
class _DocumentViewerScreen extends StatelessWidget {
  final LibraryDocument doc;

  const _DocumentViewerScreen({required this.doc});

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
        title: Text(
          doc.title,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: const [
          // Badge view-only, tanpa aksi download
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Row(
                children: [
                  Icon(Icons.lock_outline, size: 16, color: Colors.black45),
                  SizedBox(width: 4),
                  Text(
                    'View Only',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner pemberitahuan view-only
          Container(
            width: double.infinity,
            color: const Color(0xFFFFF3E0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: Color(0xFFEA8000)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dokumen ini hanya dapat dilihat dan tidak dapat diunduh.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF8A6A3E)),
                  ),
                ),
              ],
            ),
          ),
          // Halaman dokumen
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: SelectableText(
                  doc.content,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
