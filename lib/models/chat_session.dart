import 'dart:convert';
import 'chat_message.dart';

class ChatSession {
  final String id;
  String name;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    required this.name,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        name: json['name'] as String,
        messages: (json['messages'] as List)
            .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  static List<ChatSession> listFromJsonString(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<ChatSession> sessions) =>
      jsonEncode(sessions.map((s) => s.toJson()).toList());
}
