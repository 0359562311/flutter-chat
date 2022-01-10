import 'dart:async';
import 'dart:convert';

import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/repositories/conversation_repository.dart';
import 'package:chat/app/presentation/SocketHandler.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_event.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:chat/core/extensions/string_to_datetime.dart';

class ListConversationsBloc extends Bloc {
  final ConversationRepository _conversationRepository;

  late final BehaviorSubject<ListConversationsState> _stateController;
  ValueStream<ListConversationsState> get stateStream =>
      _stateController.stream;
  Sink<ListConversationsState> get _stateSink => _stateController.sink;

  late final PublishSubject<ListConversationsState> _listenerController;
  Stream<ListConversationsState> get listenerStream => _listenerController.stream;

  PublishSubject<SocketState>? _socketController;

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;

  ListConversationsBloc(
    this._conversationRepository,
  ) {
    _stateController =
        BehaviorSubject.seeded(const ListConversationsLoadingState());
    _listenerController = PublishSubject();
    _init();
  }

  void _init() async {
    add(ListConversationsReloadEvent());
    await _socketController?.drain();
    _socketController = PublishSubject();
    _socketController!.addStream(GetIt.I<SocketHandler>().socketController);
    _socketController!.stream.listen(_socketHandler);
  }

  Future<void> add(ListConversationsEvent event) async {
    if (event is ListConversationsReloadEvent) {
      final res = await _conversationRepository.getList(0);
      if (res.isSuccess()) {
        _conversations = (res.getSuccess()!);
        _stateSink.add(ListConversationsCompleteState());
        _listenerController.sink.add(ListConversationsCompleteState());
      } else {
        _stateSink
            .add(ListConversationsErrorState(message: res.getError()!.reason));
      }
    }
  }

  void _socketHandler(SocketState event) async {
    if(event is SocketNewEventState) {
      final data = jsonDecode(event.event);
      print(data['action']);
      if (data['action'] == "MESSAGE-SEEN") {
        int id1 = data['user1'];
        int id2 = data['user2'];
        if (id1 > id2) {
          int tmp = id1;
          id1 = id2;
          id2 = tmp;
        }
        DateTime seenAt = (data['seenAt'] as String).toDateTime();
        for (var c in _conversations) {
          if (c.user1.id == id1 && c.user2.id == id2) {
            if (data['user'] == id1) {
              c.lastSeen1 = seenAt;
            } else {
              c.lastSeen2 = seenAt;
            }
            _stateSink.add(ListConversationsNewSeenState());
            break;
          }
        }
      } else if (data['action'] == "NEW-PRIVATE-MESSAGE") {
        Message lastMessage = Message.fromMap(data);
        for (var i = 0; i < _conversations.length; i++) {
          if(_conversations[i].id == lastMessage.conversation) {
            _conversations[i].lastMessage = lastMessage;
            final c = _conversations[i];
            if(i != 0) {
              _conversations.removeAt(i);
              _conversations.insert(0, c);
              _listenerController.sink.add(ListConversationsNewMessageState(i));
            } else {
              _stateSink.add(ListConversationsNewSeenState());
            }
            return;
          }
        }
        final res = await _conversationRepository.getConversationById(lastMessage.conversation);
        if(res.isSuccess()) {
          Conversation lastConversation = res.getSuccess()!;
          _conversations.insert(0, lastConversation);
          _listenerController.sink.add(ListConversationsNewMessageState(null));
          return;
        }
      }
    } else if(event is SocketConnectingState) {
      _stateSink.add(const ListConversationsLoadingState());
    } else if (event is SocketConnectedState) {
      _stateSink.add(ListConversationsCompleteState());
      add(ListConversationsReloadEvent());
    } else if (event is SocketErrorState) {
      _stateSink.add(ListConversationsErrorState(message: "No internet connection."));
    }

  }

  @override
  void dispose() async {
    _stateController.close();
    _listenerController.close();
    await _socketController?.drain();
    _socketController?.close();
  }
}
