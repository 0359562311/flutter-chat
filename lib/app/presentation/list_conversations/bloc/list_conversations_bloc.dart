import 'dart:async';
import 'dart:convert';

import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/session.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/data/repositories/conversation_repository.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_event.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:chat/core/extensions/string_to_datetime.dart';

class ListConversationsBloc extends Bloc {
  final ConversationRepository _conversationRepository;

  late final BehaviorSubject<ListConversationsState> _stateController;
  ValueStream<ListConversationsState> get stateStream =>
      _stateController.stream;
  Sink<ListConversationsState> get _stateSink => _stateController.sink;

  late final PublishSubject _socketController;
  PublishSubject get socketController => _socketController;

  late final WebSocketChannel _socketChannel;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;


  ListConversationsBloc(
    this._conversationRepository,
  ) {
    _stateController =
        BehaviorSubject.seeded(const ListConversationsLoadingState());
    add(ListConversationsReloadEvent());

    _socketChannel = WebSocketChannel.connect(Uri.parse(
            'ws://192.168.0.101:8000/ws/chat/private/' +
                GetIt.I<User>().username + "/?token=" + GetIt.I<Session>().access));
    _socketController = PublishSubject();
    _socketController.addStream(_socketChannel.stream);
    _socketController.stream.listen(_socketHandler, onError: (ob,stacktrace) {
      print("TanKiem: error in socket");
    });
  }
  
  Future<void> add(ListConversationsEvent event) async {
    if (event is ListConversationsReloadEvent) {
      final res = await _conversationRepository.getList(0);
      if (res.isSuccess()) {
        _conversations = (res.getSuccess()!);
        _stateSink.add(ListConversationsCompleteState());
      } else {
        _stateSink
            .add(ListConversationsErrorState(message: res.getError()!.reason));
      }
    }
  }

  void _socketHandler(event) {
    final data = jsonDecode(event);
    
    if(data['action'] == "MESSAGE-SEEN") {
      print(data['action']);
      int id1 = data['user1'];
      int id2 = data['user2'];
      if(id1 > id2) {
        int tmp = id1;
        id1 = id2;
        id2 = tmp;
      }
      DateTime seenAt = (data['seenAt'] as String).toDateTime();
      print("seenAt $seenAt");
      for(var c in _conversations) {
        if(c.user1.id == id1 && c.user2.id == id2) {
          if(data['user'] == id1) {
            c.lastSeen1 = seenAt;
          } else {
            c.lastSeen2 = seenAt;
          }
          print(c);
          _stateSink.add(ListConversationsNewSeenState());
          break;
        }
      }
    } else if(data['action'] == "NEW-MESSAGE") {
      print(data['action']);
    }
  }

  @override
  void dispose() async {
    _stateController.close();
    _socketChannel.sink.close();
    await _socketController.drain();
    _socketController.close();
  }

  
}
