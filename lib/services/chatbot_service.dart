import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatbotService {
  static final ChatbotService instance = ChatbotService._();
  ChatbotService._();

  static const _sessionsKey = 'chatbot_sessions';

  static const _dummyResponses = [
    'Terima kasih atas pertanyaan Anda! Saya DTC AI, siap membantu terkait kompetisi dan pengembangan startup.',
    'Pertanyaan yang menarik! Dalam konteks startup, ada beberapa hal penting yang perlu diperhatikan. Apakah Anda ingin saya jelaskan lebih lanjut?',
    'Berdasarkan pengalaman tim DTC, strategi yang efektif untuk kompetisi startup adalah fokus pada validasi masalah terlebih dahulu sebelum membangun solusi.',
    'Saya siap membantu Anda mempersiapkan pitch deck, business model, atau strategi go-to-market. Apa yang ingin Anda ketahui?',
    'Fitur AI sedang dalam pengembangan penuh. Segera hadir dengan kemampuan analisis startup yang lebih canggih!',
  ];

  int _dummyIndex = 0;

  Future<List<ChatSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_sessionsKey);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      return ChatSession.listFromJsonString(jsonStr);
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<ChatSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionsKey, ChatSession.listToJsonString(sessions));
  }

  Future<String> sendMessage(String message) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final response = _dummyResponses[_dummyIndex % _dummyResponses.length];
    _dummyIndex++;
    return response;
  }
}
