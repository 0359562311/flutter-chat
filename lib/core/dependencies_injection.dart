import 'package:chat/app/data/models/session.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/data/repositories/authentication_repository.dart';
import 'package:chat/app/data/repositories/conversation_repository.dart';
import 'package:chat/app/data/repositories/user_repository.dart';
import 'package:chat/app/data/sources/authentication_sources.dart';
import 'package:chat/app/data/sources/conversation_sources.dart';
import 'package:chat/app/data/sources/user_source.dart';
import 'package:chat/app/presentation/home/bloc/home_bloc.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_bloc.dart';
import 'package:chat/app/presentation/login/bloc/login_bloc.dart';
import 'package:chat/core/const/hive_box.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:rxdart/subjects.dart';

import 'interceptor.dart';
import 'package:dio/dio.dart';

import 'network_info.dart';

Future<void> initDependenciesInjection() async {
  GetIt getIt = GetIt.instance;
  GetIt.instance.allowReassignment = true;
  getIt.registerLazySingleton(() => GlobalKey<NavigatorState>());
  getIt.registerLazySingleton<PublishSubject<String>>(() => PublishSubject());

  final networkInfo = NetworkInfo();
  await networkInfo.init();
  getIt.registerSingleton(networkInfo);

  getIt.registerLazySingleton(() => Hive);

  final sessionBox = await Hive.openBox(HiveBox.session);
  Session? session = sessionBox.get("data");
  if(session != null) getIt.registerSingleton<Session>(session);

  final userBox = await Hive.openBox(HiveBox.user);
  User? user = userBox.get("data");
  if(user != null) getIt.registerSingleton<User>(user);

  var options = BaseOptions(
      baseUrl: 'http://192.168.0.101:8000',
      connectTimeout: 60000,
      receiveTimeout: 60000,
      responseType: ResponseType.json);

  getIt.registerSingleton(Dio(options)
    ..interceptors.addAll([
      AuthenticationInterceptor(),
      LogInterceptor(
          requestBody: true,
          requestHeader: false,
          responseBody: true,
          request: false,
          responseHeader: false,
          error: true),
    ]));

  // repositories
  getIt.registerLazySingleton<AuthenticationRepository>(
      () => AuthenticationRepository(getIt(), getIt()));
  getIt.registerLazySingleton<ConversationRepository>(
      () => ConversationRepository(getIt(), getIt()));
  getIt.registerLazySingleton<UserRepository>(
      () => UserRepository(getIt(), getIt()));

  // sources
  getIt.registerLazySingleton(() => AuthenticationRemoteSource());
  getIt.registerLazySingleton(() => AuthenticationLocalSource());
  getIt.registerLazySingleton(() => ConversationLocalSources());
  getIt.registerLazySingleton(() => ConversationRemoteSources());
  getIt.registerLazySingleton(() => UserRemoteSource());
  getIt.registerLazySingleton(() => UserLocalSource());

  /// bloc
  getIt.registerFactory(() => LoginBloc(getIt()));
  getIt.registerFactory(() => ListConversationsBloc(getIt()));
  getIt.registerFactory(() => HomeBloc(getIt()));
}