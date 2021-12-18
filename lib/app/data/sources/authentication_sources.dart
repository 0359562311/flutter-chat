import 'package:chat/app/data/models/session.dart';
import 'package:chat/core/const/api_path.dart';
import 'package:chat/core/const/hive_box.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class AuthenticationRemoteSource {
  Future<Session> logIn(String  username, String password) async {
    final res = await GetIt.I<Dio>().post(APIPath.logIn, data: {
      "username": username,
      "password": password
    });
    return Session.fromMap(res.data);
  }
}


class AuthenticationLocalSource {
  Future<void> cacheSession(Session session) async {
    final box = await Hive.openBox(HiveBox.session);
    return box.put("data", session);
  }
}