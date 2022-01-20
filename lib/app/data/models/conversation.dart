import 'dart:convert';

import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/core/extensions/string_to_datetime.dart';
import 'package:get_it/get_it.dart';

class Conversation {
  int id;
  User user1;
  User user2;
  String? alias1;
  String? alias2;
  DateTime lastSeen1;
  DateTime lastSeen2;
  Message? lastMessage;
  Conversation({
    required this.id,
    required this.user1,
    required this.user2,
    this.alias1,
    this.alias2,
    required this.lastSeen1,
    required this.lastSeen2,
    this.lastMessage,
  });


  Conversation copyWith({
    int? id,
    User? user1,
    User? user2,
    String? alias1,
    String? alias2,
    DateTime? lastSeen1,
    DateTime? lastSeen2,
    Message? lastMessage,
  }) {
    return Conversation(
      id: id ?? this.id,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      alias1: alias1 ?? this.alias1,
      alias2: alias2 ?? this.alias2,
      lastSeen1: lastSeen1 ?? this.lastSeen1,
      lastSeen2: lastSeen2 ?? this.lastSeen2,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }

  factory Conversation.fromMap(Map<String, dynamic> map) {
    return Conversation(
      id: map['id']?.toInt() ?? 0,
      user1: User.fromMap(map['user1']),
      user2: User.fromMap(map['user2']),
      alias1: map['alias1'],
      alias2: map['alias2'],
      lastSeen1:( map['last_seen1'] as String).toDateTime(),
      lastSeen2: (map['last_seen2'] as String).toDateTime(),
      lastMessage: map['last_message'] != null ? Message.fromMap(map['last_message']) : null,
    );
  }

  User getOther() {
    final user = GetIt.I<User>();
    if(user1.id == user.id) {
      return user2;
    }
    return user1;
  }

  DateTime getMyLastSeen() {
    final user = GetIt.I<User>();
    if(user1.id == user.id) {
      return lastSeen1;
    }
    return lastSeen2;
  }

  DateTime getOtherLastSeen() {
    final user = GetIt.I<User>();
    if(user1.id != user.id) {
      return lastSeen1;
    }
    return lastSeen2;
  }

  factory Conversation.fromJson(String source) => Conversation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Conversation(id: $id, user1: $user1, user2: $user2, alias1: $alias1, alias2: $alias2, lastSeen1: $lastSeen1, lastSeen2: $lastSeen2, lastMessage: $lastMessage)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Conversation &&
      (other.id == id ||
      (other.user1 == user1 &&
      other.user2 == user2));
      
  }

  @override
  int get hashCode {
    return id.hashCode ^
      user1.hashCode ^
      user2.hashCode ^
      alias1.hashCode ^
      alias2.hashCode ^
      lastSeen1.hashCode ^
      lastSeen2.hashCode ^
      lastMessage.hashCode;
  }
}
