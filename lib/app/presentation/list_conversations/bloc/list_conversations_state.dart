abstract class ListConversationsState {
  const ListConversationsState();
}

class ListConversationsLoadingState extends ListConversationsState {
  const ListConversationsLoadingState();
}

class ListConversationsErrorState extends ListConversationsState {
  final String message;
  ListConversationsErrorState({
    required this.message,
  });
}

class ListConversationConnectedState extends ListConversationsState {}

class ListConversationsCompleteState extends ListConversationsState {}

class ListConversationsNewSeenState extends ListConversationsState {}

class ListConversationsNewMessageState extends ListConversationsState {
  final int? oldPos;
  ListConversationsNewMessageState(this.oldPos);
}
