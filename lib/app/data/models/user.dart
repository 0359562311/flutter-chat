import 'dart:convert';
import 'package:chat/core/extensions/string_to_datetime.dart';

import 'package:hive/hive.dart';
part 'user.g.dart';

@HiveType(typeId: 2)
class User {
  @HiveField(0)
  int id;
  @HiveField(1)
  String username;
  @HiveField(2)
  DateTime lastOnline;
  @HiveField(3)
  String? avatar;
  @HiveField(4)
  String email;
  @HiveField(5)
  bool isPublic;
  @HiveField(6)
  bool isOnline;

  User({
    required this.id,
    required this.username,
    required this.lastOnline,
    this.avatar,
    required this.email,
    required this.isPublic,
    required this.isOnline,
  });

  User copyWith({
    int? id,
    String? username,
    DateTime? lastOnline,
    String? avatar,
    String? email,
    bool? isPublic,
    bool? isOnline,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      lastOnline: lastOnline ?? this.lastOnline,
      avatar: avatar ?? this.avatar,
      email: email ?? this.email,
      isPublic: isPublic ?? this.isPublic,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'last_online': lastOnline.toUtc().toIso8601String(),
      'avatar': avatar,
      'email': email,
      'is_public': isPublic,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id']?.toInt() ?? 0,
      username: map['username'] ?? '',
      lastOnline: (map['last_online'] as String).toDateTime(),
      avatar: map['avatar'],
      email: map['email'] ?? '',
      isPublic: map['is_public'] ?? false,
      isOnline: map['is_online'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() {
    return 'User(id: $id, username: $username, lastOnline: $lastOnline, avatar: $avatar, email: $email, isPublic: $isPublic)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is User &&
      (other.id == id || other.username == username);
  }

  @override
  int get hashCode {
    return id.hashCode ^
      username.hashCode ^
      lastOnline.hashCode ^
      avatar.hashCode ^
      email.hashCode ^
      isPublic.hashCode;
  }
}
