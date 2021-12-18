import 'dart:convert';

import 'package:chat/app/data/models/message.dart';
import 'package:chat/core/extensions/string_to_datetime.dart';

class Conversation {
  int id;
  UserInConversation user1;
  UserInConversation user2;
  String? alias1;
  String? alias2;
  DateTime lastSeen1;
  DateTime lastSeen2;
  Message lastMessage;
  Conversation({
    required this.id,
    required this.user1,
    required this.user2,
    this.alias1,
    this.alias2,
    required this.lastSeen1,
    required this.lastSeen2,
    required this.lastMessage,
  });


  Conversation copyWith({
    int? id,
    UserInConversation? user1,
    UserInConversation? user2,
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
      user1: UserInConversation.fromMap(map['user1']),
      user2: UserInConversation.fromMap(map['user2']),
      alias1: map['alias1'],
      alias2: map['alias2'],
      lastSeen1:( map['last_seen1'] as String).toDateTime(),
      lastSeen2: (map['last_seen2'] as String).toDateTime(),
      lastMessage: Message.fromMap(map['last_message']),
    );
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

class UserInConversation {
  String? avatar;
  String username;
  bool isOnline;
  DateTime lastOnline;
  int id;
  UserInConversation({
    this.avatar,
    required this.username,
    required this.isOnline,
    required this.lastOnline,
    required this.id,
  });

  UserInConversation copyWith({
    String? avatar,
    String? username,
    bool? isOnline,
    DateTime? lastOnline,
    int? id,
  }) {
    return UserInConversation(
      avatar: avatar ?? this.avatar,
      username: username ?? this.username,
      isOnline: isOnline ?? this.isOnline,
      lastOnline: lastOnline ?? this.lastOnline,
      id: id ?? this.id,
    );
  }

  factory UserInConversation.fromMap(Map<String, dynamic> map) {
    return UserInConversation(
      avatar: map['avatar'],
      username: map['username'] ?? '',
      isOnline: map['is_online'] ?? false,
      lastOnline: (map['last_online'] as String).toDateTime(),
      id: map['id']?.toInt() ?? 0,
    );
  }

  factory UserInConversation.fromJson(String source) => UserInConversation.fromMap(json.decode(source));

  @override
  String toString() {
    return 'UserInConversation(avatar: $avatar, username: $username, isOnline: $isOnline, lastOnline: $lastOnline, id: $id)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is UserInConversation &&
      other.id == id;
  }

  @override
  int get hashCode {
    return avatar.hashCode ^
      username.hashCode ^
      isOnline.hashCode ^
      lastOnline.hashCode ^
      id.hashCode;
  }
}
