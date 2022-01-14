import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:chat/app/data/models/session.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/core/const/api_path.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';

class SocketHandler {

  final PublishSubject<SocketState> _socketController = PublishSubject();
  PublishSubject<SocketState> get socketController => _socketController;

  late WebSocket _channel;

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  bool _isError = false;
  bool get isError => _isError;

  SocketHandler({String? to}) {
    initWebSocketConnection(to: to);
  }

  Future initWebSocketConnection({String? to}) async {
    print("connecting...");
    _isConnecting = true;
    _socketController.sink.add(SocketConnectingState());
    _channel = await connectWs(to: to);
    print("socket connection initialized");
    _isConnecting = false;
    _isError = false;
    _socketController.sink.add(SocketConnectedState());
    _channel.done.then((dynamic _) => _onDisconnected(to: to));
    broadcastNotifications(to: to);
  }

  broadcastNotifications({String? to}) {
    _channel.listen((streamData) {
      print(streamData);
      _socketController.sink.add(SocketNewEventState(streamData));
    }, onDone: () {
      print("connecting aborted");
      _socketController.sink.add(SocketErrorState());
      initWebSocketConnection(to: to);
    }, onError: (e) {
      print('Server error: $e');
      _socketController.sink.add(SocketErrorState());
      initWebSocketConnection(to: to);
    });
  }

  void add(Map<String,dynamic> data) {
    _channel.add(json.encode(data));
  }

  Future connectWs({String? to}) async{
    try {
      String wsUrl = "ws://${APIPath.serverIP}:8000/ws/chat/private/${to??GetIt.I<User>().username}/?token=${GetIt.I<Session>().access}";
      return await WebSocket.connect(wsUrl);
    } catch  (e) {
      print("Error! can not connect WS connectWs " + e.toString());
      _isError = true;
      await Future.delayed(const Duration(milliseconds: 5000));
      return await connectWs(to: to);
    }

  }

  void _onDisconnected({String? to}) {
    _isError = true;
    _socketController.sink.add(SocketErrorState());
    initWebSocketConnection(to: to);
  }

  void dispose() {
    _socketController.sink.close();
    _socketController.close();
  }
}

abstract class SocketState {}

class SocketConnectingState extends SocketState {}

class SocketConnectedState extends SocketState {}

class SocketNewEventState extends SocketState {
  final String event;
  SocketNewEventState(this.event);
}

class SocketErrorState extends SocketState {}