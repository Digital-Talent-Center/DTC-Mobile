import 'dart:convert';

class ChatMessage {
  final String id;
  final String content;
  final bool isFromUser;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isFromUser,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'isFromUser': isFromUser,
        'timestamp': timestamp.toIso8601String(),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        content: json['content'] as String,
        isFromUser: json['isFromUser'] as bool,
        timestamp: DateTime.parse(json['timestamp'] as String),
      );

  static List<ChatMessage> listFromJsonString(String jsonStr) {
    final list = jsonDecode(jsonStr) as List;
    return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
  }

  static String listToJsonString(List<ChatMessage> messages) =>
      jsonEncode(messages.map((m) => m.toJson()).toList());
}
