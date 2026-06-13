import 'package:intl/intl.dart';

/// Prestasi mahasiswa. Mengikuti skema tabel `achievements` di backend.
/// Status backend: 'pending' | 'approved' | 'rejected'.
class Achievement {
  final int id;
  final String title;
  final String description;
  final String category;
  final String? jenis;
  final String? tingkat;
  final String? keikutsertaan;
  final String? tahunAjaran;
  final DateTime? tanggalMulai;
  final DateTime? tanggalSelesai;
  final String? linkSertifikat;
  final String status;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.jenis,
    this.tingkat,
    this.keikutsertaan,
    this.tahunAjaran,
    this.tanggalMulai,
    this.tanggalSelesai,
    this.linkSertifikat,
    this.status = 'pending',
  });

  static DateTime? _date(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse('$v');
  }

  factory Achievement.fromJson(Map<String, dynamic> j) {
    String? s(dynamic v) => v == null ? null : '$v';
    return Achievement(
      id: (j['id'] is int) ? j['id'] as int : int.tryParse('${j['id']}') ?? 0,
      title: '${j['title'] ?? ''}',
      description: '${j['description'] ?? ''}',
      category: '${j['category'] ?? 'Lainnya'}',
      jenis: s(j['jenis']),
      tingkat: s(j['tingkat']),
      keikutsertaan: s(j['keikutsertaan']),
      tahunAjaran: s(j['tahunAjaran'] ?? j['tahun_ajaran']),
      tanggalMulai: _date(j['tanggalMulai'] ?? j['tanggal_mulai']),
      tanggalSelesai: _date(j['tanggalSelesai'] ?? j['tanggal_selesai']),
      linkSertifikat: s(j['linkSertifikat'] ?? j['link_sertifikat']),
      status: '${j['status'] ?? 'pending'}',
    );
  }

  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

  /// Rentang tanggal untuk ditampilkan, mis. "1 Mei 2024 - 3 Mei 2024".
  String get dateRangeLabel {
    final f = DateFormat('d MMM yyyy', 'id_ID');
    if (tanggalMulai == null) return '-';
    final start = f.format(tanggalMulai!);
    if (tanggalSelesai == null) return start;
    return '$start - ${f.format(tanggalSelesai!)}';
  }
}
