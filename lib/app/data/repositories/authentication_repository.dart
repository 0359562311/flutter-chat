import 'package:chat/core/network_info.dart';
import 'package:get_it/get_it.dart';
import 'package:multiple_result/multiple_result.dart';

import 'package:chat/app/data/sources/authentication_sources.dart';
import 'package:chat/core/failure.dart';
import 'package:dio/dio.dart';

class AuthenticationRepository {

  final AuthenticationRemoteSource _remoteSource;
  final AuthenticationLocalSource _localSource;

  const AuthenticationRepository(
    this._remoteSource,
    this._localSource,
  );

  Future<Result<Failure, void>> logIn(String username, String password) async {
    if(GetIt.instance<NetworkInfo>().isConnecting) {
      try {
        final session = await _remoteSource.logIn(username, password);
        GetIt.I.registerSingleton(session);
        await _localSource.cacheSession(session);
        return const Success(null);
      } on DioError catch (e) {
        return Error(Failure(e.response?.data['detail']?? "Can not executed your request"));
      }
    } else {
      return Error(Failure("No internet connection."));
    }
  }
}
