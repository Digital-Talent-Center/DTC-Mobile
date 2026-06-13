import 'api_client.dart';

class CreatedTransaction {
  final String snapToken;
  final String orderId;
  final int amount;
  const CreatedTransaction(
      {required this.snapToken, required this.orderId, required this.amount});
}

/// Alur pembayaran Premium Post (Midtrans Snap).
/// Karena Flutter tidak punya Snap JS SDK, halaman Snap dibuka via browser
/// (redirect URL dari snap_token), lalu status diverifikasi ke server.
class MidtransService {
  MidtransService._();
  static final MidtransService instance = MidtransService._();

  final _api = ApiClient.instance;

  /// Unggah lampiran (gambar). Mengembalikan path untuk disimpan di transaksi.
  Future<String?> uploadAttachment(String filePath) async {
    final res = await _api.multipart(
      '/midtrans/upload-attachment',
      method: 'POST',
      fileField: 'file',
      filePath: filePath,
    );
    return (res is Map) ? res['path'] as String? : null;
  }

  /// Buat transaksi → snap_token + order_id. duration ∈ 7-hari|1-bulan|3-bulan.
  Future<CreatedTransaction> createTransaction({
    required String duration,
    required String postTitle,
    String? postDescription,
    String? attachmentPath,
  }) async {
    final res = await _api.post('/midtrans/create-transaction', body: {
      'duration': duration,
      'post_title': postTitle,
      'post_description': postDescription,
      'attachment_path': attachmentPath,
    });
    final m = (res is Map) ? res : <String, dynamic>{};
    return CreatedTransaction(
      snapToken: '${m['snap_token'] ?? ''}',
      orderId: '${m['order_id'] ?? ''}',
      amount: (m['amount'] is int)
          ? m['amount'] as int
          : int.tryParse('${m['amount'] ?? 0}') ?? 0,
    );
  }

  /// Verifikasi & tandai lunas (dipanggil setelah user kembali dari Snap).
  /// Mengembalikan status terbaru ('paid' | 'pending' | ...).
  Future<String> checkAndMarkPaid(String orderId) async {
    final res = await _api.post('/midtrans/check-and-mark-paid',
        body: {'order_id': orderId});
    return (res is Map) ? '${res['status'] ?? 'pending'}' : 'pending';
  }
}
