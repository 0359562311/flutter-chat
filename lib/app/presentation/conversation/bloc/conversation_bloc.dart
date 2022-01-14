import 'dart:async';
import 'dart:convert';

import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/models/session.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/data/repositories/conversation_repository.dart';
import 'package:chat/app/data/repositories/message_repository.dart';
import 'package:chat/app/presentation/SocketHandler.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_event.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';
import 'package:get_it/get_it.dart';
import 'package:chat/core/extensions/string_to_datetime.dart';

class ConversationBloc extends Bloc<ConversationEvent, ConversationState> {
  final ConversationRepository _conversationRepository;
  final MessageRepository _messageRepository;

  List<Message> _messages = [];
  List<Message> get messages => _messages;
  late SocketHandler _mySocketHandler, _otherSocketHandler;
  late StreamSubscription _subscription;

  bool _isLoadMoreMessages = false;
  bool get isLoadMoreMessages => _isLoadMoreMessages;

  bool get isError => _otherSocketHandler.isError || _mySocketHandler.isError;
  bool get isConnecting => _otherSocketHandler.isConnecting || _mySocketHandler.isConnecting;


  late Conversation _conversation;

  ConversationBloc(this._conversationRepository, this._messageRepository): super(ConversationLoadingState()) {
    _mySocketHandler = GetIt.I();
  }

  @override
  void addEvent(ConversationEvent event) {
    if(event is ConversationInitEvent) {
      _onInit(event);
    } else if(event is ConversationNewMessageEvent) {
      _onNewMessage(event);
    } else if (event is ConversationLoadMoreMessageEvent) {
      _onLoadMore(event);
    }
  }

  FutureOr<void> _onInit(
      ConversationInitEvent event) async {
    _conversation = event.conversation;
    _otherSocketHandler = SocketHandler(
        to: GetIt.I<User>().username != event.conversation.user1.username
            ? event.conversation.user1.username
            : event.conversation.user2.username);
    _subscription = _mySocketHandler.socketController.listen(_handleNewEvent);
    final res = await _messageRepository.list(_conversation.id,-1);
    if (res.isSuccess()) {
      _messages = res.getSuccess()!;
      emit(ConversationNewMessageState());
    } else {
      emit(ConversationErrorState());
    }
  }

  FutureOr<void> _onNewMessage(ConversationNewMessageEvent event) async {
    _otherSocketHandler.add({
      "token": GetIt.I<Session>().access,
      "action": "SEND",
      "message": event.content
    });
  }

  FutureOr<void> _onLoadMore(ConversationLoadMoreMessageEvent event) async {
    if(!_isLoadMoreMessages) {
      _isLoadMoreMessages = true;
      final res = await _messageRepository
          .list(_conversation.id,_messages.isEmpty ? -1 : _messages.last.id);
      if (res.isSuccess()) {
        _messages += res.getSuccess()!;
        _isLoadMoreMessages = false;
        emit(ConversationNewMessageState());
      } else {
        emit(ConversationErrorState(reason: res.getError()!.reason));
        Future.delayed(const Duration(seconds: 5)).then((value) {
          _onLoadMore(event);
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
    _otherSocketHandler.dispose();
  }

  void _handleNewEvent(SocketState value) {
    if(value is SocketNewEventState) {
      final data = jsonDecode(value.event);
      if(data['action'] == "NEW-PRIVATE-MESSAGE" && data['conversation'] == _conversation.id) {
        if(data['conversation'] == _conversation.id) {
          _messages.insert(0, Message.fromMap(data));
          _otherSocketHandler.add({
            "action":"SEEN",
            "token": GetIt.I<Session>().access
          });
        }
      } else if(data['action'] == "MESSAGE-SEEN") {
        if((_conversation.user1.id == data['user1'] && _conversation.user2.id == data['user2']) ||
            (_conversation.user1.id == data['user2'] && _conversation.user2 == data['user1'])) {
          if(data['user'] == _conversation.user1.id) {
            _conversation.lastSeen1 = (data['seenAt'] as String).toDateTime();
          } else {
            _conversation.lastSeen2 = (data['seenAt'] as String).toDateTime();
          }
        }
      }
      emit(ConversationNewMessageState());
    } else if(value is SocketConnectingState || value is SocketErrorState) {
      emit(ConversationErrorState());
    } else if(value is SocketConnectedState) {
      emit(ConversationConnectedState());
    }
  }
}
