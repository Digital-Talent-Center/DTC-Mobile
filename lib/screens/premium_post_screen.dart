import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class _DurationPlan {
  final String label;
  final int price;
  final bool popular;

  const _DurationPlan({
    required this.label,
    required this.price,
    this.popular = false,
  });
}

class PremiumPostScreen extends StatefulWidget {
  const PremiumPostScreen({Key? key}) : super(key: key);

  @override
  State<PremiumPostScreen> createState() => _PremiumPostScreenState();
}

class _PremiumPostScreenState extends State<PremiumPostScreen> {
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();

  // Upload
  String? _fileName;
  int? _fileSize;
  static const int _maxFileBytes = 10 * 1024 * 1024; // 10MB

  // Durasi layanan
  final List<_DurationPlan> _plans = const [
    _DurationPlan(label: '7 Hari', price: 49000),
    _DurationPlan(label: '1 Bulan', price: 149000, popular: true),
    _DurationPlan(label: '3 Bulan', price: 399000),
  ];
  int _selectedPlan = 1;

  // Metode pembayaran
  final List<Map<String, dynamic>> _methods = const [
    {'label': 'Virtual Account', 'icon': Icons.account_balance_outlined},
    {'label': 'E-Wallet (OVO/Gopay)', 'icon': Icons.account_balance_wallet_outlined},
    {'label': 'Kartu Kredit', 'icon': Icons.credit_card_outlined},
  ];
  int _selectedMethod = 1;

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  int get _basePrice => _plans[_selectedPlan].price;
  int get _tax => (_basePrice * 0.11).round();
  int get _total => _basePrice + _tax;

  String _rupiah(int value) {
    final s = value.toString();
    final buffer = StringBuffer('Rp ');
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['jpg', 'jpeg', 'png'],
        withData: false,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.size > _maxFileBytes) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ukuran file melebihi 10MB')),
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

  void _pay() {
    if (_judulCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul kegiatan wajib diisi')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Memproses pembayaran ${_rupiah(_total)} via ${_methods[_selectedMethod]['label']}...'),
      ),
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
          'Premium Post',
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
          _infoKegiatanCard(),
          const SizedBox(height: 20),
          _durasiCard(),
          const SizedBox(height: 20),
          _ringkasanCard(),
        ],
      ),
    );
  }

  // ---------- Card: Informasi Kegiatan ----------
  Widget _infoKegiatanCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.assignment_outlined, 'Informasi Kegiatan'),
          const SizedBox(height: 16),
          _label('JUDUL KEGIATAN'),
          _textField(_judulCtrl, 'Contoh: Webinar Strategi Belajar Efektif',
              maxLines: 2),
          const SizedBox(height: 16),
          _label('DESKRIPSI'),
          _textField(_deskripsiCtrl, 'Jelaskan detail kegiatan', maxLines: 4),
          const SizedBox(height: 16),
          _label('LAMPIRAN PENDUKUNG'),
          _uploadBox(),
        ],
      ),
    );
  }

  Widget _uploadBox() {
    final hasFile = _fileName != null;
    return GestureDetector(
      onTap: _pickFile,
      child: _DashedBox(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: hasFile
              ? Column(
                  children: [
                    const Icon(Icons.image_outlined,
                        size: 34, color: Color(0xFFEA8000)),
                    const SizedBox(height: 10),
                    Text(
                      _fileName!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (_fileSize != null) ...[
                      const SizedBox(height: 2),
                      Text(_formatSize(_fileSize!),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black45)),
                    ],
                    TextButton.icon(
                      onPressed: () => setState(() {
                        _fileName = null;
                        _fileSize = null;
                      }),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus'),
                      style:
                          TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    ),
                  ],
                )
              : Column(
                  children: const [
                    Icon(Icons.cloud_upload_outlined,
                        size: 34, color: Color(0xFFEA8000)),
                    SizedBox(height: 10),
                    Text(
                      'Klik untuk unggah atau seret file',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'PNG atau JPG (Maks. 10MB)',
                      style: TextStyle(fontSize: 13, color: Colors.black45),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------- Card: Durasi Layanan ----------
  Widget _durasiCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeader(Icons.verified_outlined, 'Pilih Durasi Layanan'),
          const SizedBox(height: 16),
          ...List.generate(_plans.length, (i) {
            final plan = _plans[i];
            final selected = _selectedPlan == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedPlan = i),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBEBD5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFF5B800)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  plan.label.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                    color: Color(0xFF6B5B45),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _rupiah(plan.price),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _radio(selected),
                        ],
                      ),
                    ),
                    if (plan.popular)
                      Positioned(
                        top: -10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B5B12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'PALING POPULER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Card: Ringkasan Pembayaran ----------
  Widget _ringkasanCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: Color(0xFFF5B800), width: 4),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Pembayaran',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
          ),
          const SizedBox(height: 16),
          _summaryRow(
              'Layanan Premium (${_plans[_selectedPlan].label})', _rupiah(_basePrice)),
          const SizedBox(height: 10),
          _summaryRow('Pajak (PPN 11%)', _rupiah(_tax)),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Bayar',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black87),
              ),
              Text(
                _rupiah(_total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFFC79100),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _label('METODE PEMBAYARAN'),
          const SizedBox(height: 4),
          ...List.generate(_methods.length, (i) {
            final m = _methods[i];
            final selected = _selectedMethod == i;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GestureDetector(
                onTap: () => setState(() => _selectedMethod = i),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBEBD5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFF5B800)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(m['icon'] as IconData,
                          size: 22, color: Colors.black54),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          m['label'] as String,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      _radio(selected),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF5B800),
                foregroundColor: Colors.black87,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Bayar Sekarang',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'DENGAN MENGEKLIK TOMBOL DI ATAS, ANDA MENYETUJUI KETENTUAN DAN KEBIJAKAN PRIVASI KAMI.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.black38,
              letterSpacing: 0.3,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Reusable ----------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeader(IconData icon, String title) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFFBE6BC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF6B5B12)),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
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

  Widget _textField(TextEditingController ctrl, String hint,
      {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.black87),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFFBEBD5),
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

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _radio(bool selected) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? const Color(0xFFC79100) : Colors.black26,
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFC79100),
                ),
              ),
            )
          : null,
    );
  }
}

/// Kotak dengan border putus-putus untuk area unggah.
class _DashedBox extends StatelessWidget {
  final Widget child;

  const _DashedBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: const Color(0xFFFDF8F1),
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
