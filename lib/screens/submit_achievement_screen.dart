import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'my_achievements_screen.dart';

class SubmitAchievementScreen extends StatefulWidget {
  const SubmitAchievementScreen({Key? key}) : super(key: key);

  @override
  State<SubmitAchievementScreen> createState() =>
      _SubmitAchievementScreenState();
}

class _SubmitAchievementScreenState extends State<SubmitAchievementScreen> {
  // Controllers
  final _nimCtrl = TextEditingController();
  final _namaCtrl = TextEditingController();
  final _jenisCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  final _linkCtrl = TextEditingController();

  // Dropdown values
  String _tahunAjaran = '2023/2024';
  String _kategori = 'Kompetisi Ilmiah';
  String _tingkat = 'Internasional';
  String _keikutsertaan = 'Individu';

  // Dates
  DateTime? _tanggalMulai;
  DateTime? _tanggalSelesai;

  // Upload + agreement
  String? _fileName;
  int? _fileSize; // dalam byte
  bool _agree = false;

  static const int _maxFileBytes = 2 * 1024 * 1024; // 2MB

  final List<String> _tahunOptions = const [
    '2023/2024',
    '2024/2025',
    '2025/2026',
  ];
  final List<String> _kategoriOptions = const [
    'Kompetisi Ilmiah',
    'Kompetisi Non-Ilmiah',
    'Sertifikasi',
    'Organisasi',
  ];
  final List<String> _tingkatOptions = const [
    'Internasional',
    'Nasional',
    'Regional',
    'Universitas',
  ];
  final List<String> _keikutsertaanOptions = const [
    'Individu',
    'Tim',
  ];

  @override
  void dispose() {
    _nimCtrl.dispose();
    _namaCtrl.dispose();
    _jenisCtrl.dispose();
    _deskripsiCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2015),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _tanggalMulai = picked;
        } else {
          _tanggalSelesai = picked;
        }
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
        withData: false,
      );

      if (result == null || result.files.isEmpty) return; // dibatalkan

      final file = result.files.single;

      if (file.size > _maxFileBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file melebihi 2MB')),
        );
        return;
      }

      setState(() {
        _fileName = file.name;
        _fileSize = file.size;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memilih file: $e')),
      );
    }
  }

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  void _submit({required bool draft}) {
    if (!draft) {
      if (_namaCtrl.text.trim().isEmpty || _jenisCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nama dan Jenis kegiatan wajib diisi')),
        );
        return;
      }
      if (!_agree) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harap centang pernyataan terlebih dahulu')),
        );
        return;
      }
    }

    final title = _jenisCtrl.text.trim().isEmpty
        ? 'Achievement Baru'
        : _jenisCtrl.text.trim();
    final dateText = _tanggalMulai != null ? _formatDate(_tanggalMulai!) : '-';

    final achievement = Achievement(
      title: title,
      description: _deskripsiCtrl.text.trim(),
      category: _kategori,
      date: dateText,
      status: AchievementStatus.pending,
    );

    Navigator.pop(context, achievement);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(draft ? 'Draf disimpan' : 'Prestasi dikirim')),
    );
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
          'Submit Achievement',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
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
                _label('NIM'),
                _textField(_nimCtrl, 'contoh: 21004567',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _label('NAMA LENGKAP'),
                _textField(_namaCtrl, 'John Doe'),
                const SizedBox(height: 24),

                _sectionTitle('JADWAL KEGIATAN'),
                const SizedBox(height: 16),
                _label('TAHUN AJARAN'),
                _dropdown(
                  value: _tahunAjaran,
                  options: _tahunOptions,
                  onChanged: (v) => setState(() => _tahunAjaran = v!),
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('TANGGAL MULAI'),
                          _dateField(_tanggalMulai, isStart: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('TANGGAL SELESAI'),
                          _dateField(_tanggalSelesai, isStart: false),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                _sectionTitle('INFORMASI KEGIATAN'),
                const SizedBox(height: 16),
                _label('KATEGORI'),
                _dropdown(
                  value: _kategori,
                  options: _kategoriOptions,
                  onChanged: (v) => setState(() => _kategori = v!),
                ),
                const SizedBox(height: 16),
                _label('JENIS'),
                _textField(_jenisCtrl, 'contoh: Hackathon'),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('TINGKAT'),
                          _dropdown(
                            value: _tingkat,
                            options: _tingkatOptions,
                            onChanged: (v) => setState(() => _tingkat = v!),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('KEIKUTSERTAAN'),
                          _dropdown(
                            value: _keikutsertaan,
                            options: _keikutsertaanOptions,
                            onChanged: (v) =>
                                setState(() => _keikutsertaan = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _label('DESKRIPSI PRESTASI'),
                _textField(
                  _deskripsiCtrl,
                  'Jelaskan secara singkat peran Anda\ndan hasil dari\nprestasi tersebut...',
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                _label('LINK SERTIFIKAT (OPSIONAL)'),
                _textField(_linkCtrl, 'https://...',
                    keyboardType: TextInputType.url),
                const SizedBox(height: 16),
                _label('BUKTI PRESTASI'),
                _uploadBox(),
                const SizedBox(height: 24),

                _agreementBox(),
                const SizedBox(height: 20),

                // Kirim Prestasi
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _submit(draft: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5B800),
                      foregroundColor: Colors.black87,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Kirim Prestasi',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Simpan Draf
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _submit(draft: true),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black87,
                      side: const BorderSide(color: Color(0xFFE0D4C2)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Simpan Draf',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Reusable widgets ----------

  Widget _sectionTitle(String text) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
          color: Color(0xFF6B5B45),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
          color: Color(0xFF5A5246),
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF3E8D7),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFEA8000)),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E8D7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black54),
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          borderRadius: BorderRadius.circular(12),
          items: options
              .map((o) => DropdownMenuItem(value: o, child: Text(o)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _dateField(DateTime? date, {required bool isStart}) {
    return GestureDetector(
      onTap: () => _pickDate(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF3E8D7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              date != null ? _formatDate(date) : 'mm/dd/yyyy',
              style: TextStyle(
                fontSize: 14,
                color: date != null ? Colors.black87 : Colors.black38,
              ),
            ),
            const Icon(Icons.calendar_today_outlined,
                size: 16, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  Widget _uploadBox() {
    final hasFile = _fileName != null;

    return GestureDetector(
      onTap: _pickFile,
      child: DottedBorderBox(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          child: hasFile
              ? Column(
                  children: [
                    const Icon(Icons.insert_drive_file_outlined,
                        size: 36, color: Color(0xFFEA8000)),
                    const SizedBox(height: 10),
                    Text(
                      _fileName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    if (_fileSize != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        _formatSize(_fileSize!),
                        style: const TextStyle(
                            fontSize: 13, color: Colors.black45),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: _pickFile,
                          icon: const Icon(Icons.swap_horiz, size: 18),
                          label: const Text('Ganti'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFFEA8000),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => setState(() {
                            _fileName = null;
                            _fileSize = null;
                          }),
                          icon: const Icon(Icons.delete_outline, size: 18),
                          label: const Text('Hapus'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Column(
                  children: const [
                    Icon(Icons.cloud_upload_outlined,
                        size: 36, color: Color(0xFFEA8000)),
                    SizedBox(height: 10),
                    Text(
                      'Klik untuk unggah PDF atau Gambar',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Ukuran maks 2MB',
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _agreementBox() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F1EC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5DDCF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _agree,
              onChanged: (v) => setState(() => _agree = v ?? false),
              activeColor: const Color(0xFFEA8000),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Dengan ini saya menyatakan bahwa data yang diunggah adalah akurat. '
              'Saya siap menerima sanksi atas segala informasi palsu yang diberikan.',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kotak dengan border putus-putus untuk area unggah.
class DottedBorderBox extends StatelessWidget {
  final Widget child;

  const DottedBorderBox({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFFFBF7F0),
          child: child,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD8CBB6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rrect);
    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
