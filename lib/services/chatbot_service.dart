import 'api_client.dart';
import '../models/chat_session.dart';

/// Service untuk menyimpan/memuat riwayat sesi chatbot dari server.
///
/// Pesan chat ditangani sepenuhnya oleh Botpress di dalam WebView.
/// Service ini mengelola sinkronisasi daftar sesi (nama percakapan + ID)
/// antara aplikasi mobile dan database backend DTC Platform.
class ChatbotService {
  static final ChatbotService instance = ChatbotService._();
  ChatbotService._();

  final _api = ApiClient.instance;

  /// Memuat semua sesi chat pengguna dari database server.
  Future<List<ChatSession>> loadSessions() async {
    try {
      final res = await _api.get('/chat-sessions');
      if (res is List) {
        return res
            .map((e) => ChatSession.fromApi(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Membuat atau memperbarui sesi chat di server.
  /// Mengembalikan objek ChatSession baru yang berisi `serverId` dari database.
  Future<ChatSession> upsertSession(String botpressConvoId, String title) async {
    final res = await _api.post('/chat-sessions', body: {
      'botpress_conversation_id': botpressConvoId,
      'title': title,
    });
    return ChatSession.fromApi(res as Map<String, dynamic>);
  }

  /// Menghapus sesi chat tertentu di server berdasarkan DB primary key (serverId).
  Future<void> deleteSession(int serverId) async {
    await _api.delete('/chat-sessions/$serverId');
  }

  /// Menghapus semua sesi chat pengguna di server.
  Future<void> deleteAllSessions() async {
    await _api.delete('/chat-sessions/all');
  }
}
