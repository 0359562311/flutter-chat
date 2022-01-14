abstract class ConversationState {}

class ConversationNewMessageState extends ConversationState {}

class ConversationLoadMoreMessageCompleteState extends ConversationState {}

class ConversationErrorState extends ConversationState {
  final String? reason;

  ConversationErrorState({this.reason});
}

class ConversationLoadingState extends ConversationState {}

class ConversationConnectedState extends ConversationState {}