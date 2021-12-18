import 'dart:convert';
import 'package:chat/core/extensions/string_to_datetime.dart';

class Message {
  int id;
  String? text;
  DateTime sendAt;
  bool deleted;
  int sendBy;
  int conversation;
  Message({
    required this.id,
    this.text,
    required this.sendAt,
    required this.deleted,
    required this.sendBy,
    required this.conversation,
  });

  Message copyWith({
    int? id,
    String? text,
    DateTime? sendAt,
    bool? deleted,
    int? sendBy,
    int? conversation,
  }) {
    return Message(
      id: id ?? this.id,
      text: text ?? this.text,
      sendAt: sendAt ?? this.sendAt,
      deleted: deleted ?? this.deleted,
      sendBy: sendBy ?? this.sendBy,
      conversation: conversation ?? this.conversation,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'send_at': sendAt.toUtc().toIso8601String(),
      'deleted': deleted,
      'send_by': sendBy,
      'conversation': conversation,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id']?.toInt() ?? 0,
      text: map['text'],
      sendAt: (map['send_at'] as String).toDateTime(),
      deleted: map['deleted'] ?? false,
      sendBy: map['send_by']?.toInt() ?? 0,
      conversation: map['conversation']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) => Message.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Message(id: $id, text: $text, sendAt: $sendAt, deleted: $deleted, sendBy: $sendBy, conversation: $conversation)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Message &&
      other.id == id &&
      other.text == text &&
      other.sendAt == sendAt &&
      other.deleted == deleted &&
      other.sendBy == sendBy &&
      other.conversation == conversation;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      text.hashCode ^
      sendAt.hashCode ^
      deleted.hashCode ^
      sendBy.hashCode ^
      conversation.hashCode;
  }
}
