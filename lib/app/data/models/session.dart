import 'dart:convert';

import 'package:hive/hive.dart';

part 'session.g.dart';

@HiveType(typeId: 1)
class Session extends HiveObject {
  @HiveField(0)
  final String access;
  @HiveField(1)
  final String refresh;

  Session({
    required this.access,
    required this.refresh,
  });

  Session copyWith({
    String? access,
    String? refresh,
  }) {
    return Session(
      access: access ?? this.access,
      refresh: refresh ?? this.refresh,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'access': access,
      'refresh': refresh,
    };
  }

  factory Session.fromMap(Map<String, dynamic> map) {
    return Session(
      access: map['access'],
      refresh: map['refresh'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Session.fromJson(String source) => Session.fromMap(json.decode(source));

  @override
  String toString() => 'Session(access: $access, refresh: $refresh)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Session &&
      other.access == access &&
      other.refresh == refresh;
  }

  @override
  int get hashCode => access.hashCode ^ refresh.hashCode;
}
