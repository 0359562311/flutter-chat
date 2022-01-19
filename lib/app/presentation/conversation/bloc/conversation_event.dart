import 'package:chat/app/data/models/conversation.dart';

abstract class ConversationEvent {}

class ConversationInitEvent extends ConversationEvent {
  final Conversation conversation;

  ConversationInitEvent(this.conversation);
}

class ConversationNewMessageEvent extends ConversationEvent {
  final String content;

  ConversationNewMessageEvent(this.content);
}

class ConversationLoadMoreMessageEvent extends ConversationEvent {}