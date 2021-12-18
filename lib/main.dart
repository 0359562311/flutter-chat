import 'dart:async';
import 'dart:io';

import 'package:chat/app/data/models/session.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/home/ui/home.dart';
import 'package:chat/core/custom_widget/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/subjects.dart';

import 'app/presentation/login/ui/login.dart';
import 'core/const/app_routes.dart';
import 'core/dependencies_injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory? appDocDir = await getExternalStorageDirectory();
  String appDocPath = (appDocDir?.path ?? "")+"tankiem_chat";
  Hive..init(appDocPath)
  ..registerAdapter(SessionAdapter())
  ..registerAdapter(UserAdapter());
  await initDependenciesInjection();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.white));
    return NotificationListener<OverscrollIndicatorNotification>(
      onNotification: (overscroll) {
        overscroll.disallowIndicator();
        return true;
      },
      child: MaterialApp(
        title: 'Simple Chat App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          fontFamily: "Roboto",
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        debugShowCheckedModeBanner: false,
        navigatorKey: GetIt.instance<GlobalKey<NavigatorState>>(),
        routes: {
          AppRoute.init: (context) => const Bridge(),
          AppRoute.login: (context) => const Login(),
        },
        onGenerateRoute: (settings) {
          // if (settings.name == AppRoute.registerableClassDetails) {
          //   return MaterialPageRoute(
          //       builder: (context) => RegisterableClassDetailsScreen(
          //             id: settings.arguments as int,
          //           ));
          // }
        },
      ),
    );
  }
}

class Bridge extends StatefulWidget {
  const Bridge({ Key? key }) : super(key: key);

  @override
  _BridgeState createState() => _BridgeState();
}

class _BridgeState extends State<Bridge> {
  late final StreamSubscription _subscription;
  String? lastEvent;
  @override
  void initState() {
    super.initState();
    _subscription = GetIt.instance<PublishSubject<String>>().stream.listen((event) { 
      // if(event != lastEvent) {
      //   lastEvent = event;
      //   if(event != "Your session has expired. \n Please re-log in.") {
      //     showMyAlertDialog(context, "Error", event);
      //   } else {
      //     Navigator.of(context).pushNamedAndRemoveUntil(AppRoute.init, (route) => false);
      //   }
      // }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(GetIt.I.isRegistered<Session>()) {
      return const Home();
    }
    return const Login();
  }
}