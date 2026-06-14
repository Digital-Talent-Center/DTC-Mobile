import 'dart:convert';
import 'chat_message.dart';

class ChatSession {
  final String id; // botpress_conversation_id
  final int? serverId; // DB primary key
  String name;
  final List<ChatMessage> messages;
  final DateTime createdAt;

  ChatSession({
    required this.id,
    this.serverId,
    required this.name,
    required this.messages,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'serverId': serverId,
        'name': name,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
        id: json['id'] as String,
        serverId: json['serverId'] as int?,
        name: json['name'] as String,
        messages: json['messages'] != null
            ? (json['messages'] as List)
                .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );

  factory ChatSession.fromApi(Map<String, dynamic> json) => ChatSession(
        id: json['botpress_conversation_id'] as String,
        serverId: json['id'] as int?,
        name: (json['title'] as String?) ?? 'Percakapan Baru',
        messages: [],
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'] as String)
            : DateTime.now(),
      );

  static List<ChatSession> listFromJsonString(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => ChatSession.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<ChatSession> sessions) =>
      jsonEncode(sessions.map((s) => s.toJson()).toList());
}
