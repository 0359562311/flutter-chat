import 'package:chat/app/data/models/user.dart';
import 'package:chat/core/const/api_path.dart';
import 'package:chat/core/const/hive_box.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive/hive.dart';

class UserRemoteSource {
  Future<User> me() async {
    final res = await GetIt.I<Dio>().get(APIPath.me);
    return User.fromMap(res.data);
  }
}

class UserLocalSource {
  Future<void> cache(User user) async {
    final box = await Hive.openBox(HiveBox.user);
    box.put("data",user);
  }
}