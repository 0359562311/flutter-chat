import 'package:chat/app/data/sources/user_source.dart';
import 'package:chat/core/failure.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:multiple_result/multiple_result.dart';

class UserRepository {
  final UserRemoteSource _remoteSource;
  final UserLocalSource _localSource;
  const UserRepository(
    this._remoteSource,
    this._localSource,
  );

  Future<Result<Failure,void>> me() async {
    try {
      final user = await _remoteSource.me();
      GetIt.I.registerSingleton(user);
      _localSource.cache(user);
      // ignore: prefer_const_constructors
      return Success(null);
    } on DioError catch (e) {
      return Error(Failure(e.response?.data['detail']));
    }
  }
}
