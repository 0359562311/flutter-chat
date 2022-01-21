import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_bloc.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_event.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_state.dart';
import 'package:chat/core/bloc_base/bloc_consumer.dart';
import 'package:chat/core/const/app_routes.dart';
import 'package:chat/core/custom_widget/custom_circular_progress.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chat/core/extensions/datetime_exts.dart';
import 'package:intl/intl.dart';

class ListConversationsScreen extends StatefulWidget {
  const ListConversationsScreen({Key? key}) : super(key: key);

  @override
  ListConversationsScreenState createState() => ListConversationsScreenState();
}

final DateFormat _timeFormat = DateFormat("HH:mm");
final DateFormat _dateFormat = DateFormat("MMM dd yyyy");

class ListConversationsScreenState extends State<ListConversationsScreen> {
  late final ListConversationsBloc _bloc;
  late final ScrollController _scrollController;
  late final FocusNode _focusNode;
  final _sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _focusNode = FocusNode()..addListener(() {
      if(_focusNode.hasFocus) {
        Navigator.of(context).pushNamed(AppRoute.search);
        _focusNode.unfocus();
      }
    });
    _bloc = GetIt.I()
      ..listenerStream.listen((event) {
        if (event is ListConversationsNewMessageState) {
          if (event.oldPos != null) {
            _sliverAnimatedListKey.currentState?.removeItem(
                event.oldPos!,
                (context, animation) => FadeTransition(
                    opacity: animation.drive(Tween(begin: 1.0, end: 0.0))),
                duration: const Duration(milliseconds: 200));
          }
          _sliverAnimatedListKey.currentState
              ?.insertItem(0, duration: const Duration(milliseconds: 200));
        } else if (event is ListConversationsCompleteState) {
          for (int i = 0; i < _bloc.conversations.length; i++) {
            _sliverAnimatedListKey.currentState?.insertItem(i);
          }
        }
      });
  }

  @override
  void dispose() {
    print("dispose list conversation");
    _scrollController.dispose();
    _focusNode.dispose();
    _bloc.dispose();
    super.dispose();
  }

  void reload() {
    _bloc.addEvent(ListConversationsReloadEvent());
  }

  @override
  Widget build(BuildContext context) {
    final tweenIn = Tween(begin: const Offset(0, 1), end: const Offset(0, 0));
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            child: TextField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.black54,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  fillColor: Colors.grey.shade300,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  filled: true),
              maxLines: 1,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: BlocConsumer(
            bloc: _bloc,
            buildWhen: (oldState, newState) {
              return newState is ListConversationsLoadingState ||
                  newState is ListConversationsErrorState ||
                  newState is ListConversationConnectedState;
            },
            listener: (_,state){},
            builder: (context, state) {
              if(state is ListConversationConnectedState) {
                return const SizedBox.shrink();
              }
              return Column(
                children: [
                  if(_bloc.isConnecting) const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text("Connecting..."),
                  ),
                  if(_bloc.isError) const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Text("No internet connection.",
                      style: TextStyle(color: Colors.red),
                    ),
                  )
                ],
              );
            },
          ),
        ),
        StreamBuilder<ListConversationsState>(
            stream: _bloc.stateStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return SliverToBoxAdapter(
                    child: Center(
                  child: Image.asset("assets/images/messenger.png"),
                ));
              }
              return SliverAnimatedList(
                  key: _sliverAnimatedListKey,
                  initialItemCount: _bloc.conversations.length,
                  itemBuilder: (context, index, animation) {
                    if (index == _bloc.conversations.length) {
                      if (_scrollController.offset < 25) {
                        return const SizedBox.shrink();
                      }
                      return const Text(
                        "Load more ...",
                        textAlign: TextAlign.center,
                      );
                    } else if (index > _bloc.conversations.length) {
                      return const SizedBox.shrink();
                    }
                    return InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoute.conversation,
                            arguments: _bloc.conversations[index]);
                      },
                      child: SlideTransition(
                        position: animation.drive(tweenIn),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: Row(
                            children: [
                              _getCircularAvatar(_bloc.conversations[index]),
                              const SizedBox(
                                width: 16,
                              ),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _getConversationName(
                                        _bloc.conversations[index]),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    _getConversationLastMessage(
                                        _bloc.conversations[index]),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 4,
                              ),
                              _getLastMessageState(_bloc.conversations[index])
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            })
      ],
    );
  }

  Widget _getCircularAvatar(Conversation conversation) {
    User user = GetIt.I();
    late ImageProvider imageProvider;
    if (user.id == conversation.user1.id)
      // ignore: curly_braces_in_flow_control_structures
      imageProvider = (conversation.user2.avatar == null
          ? const AssetImage("assets/images/person.png")
          : NetworkImage(conversation.user2.avatar!)) as ImageProvider;
    else
      // ignore: curly_braces_in_flow_control_structures
      imageProvider = (conversation.user1.avatar == null
          ? const AssetImage(
              "assets/images/person.png",
            )
          : NetworkImage(conversation.user1.avatar!)) as ImageProvider;
    return CircleAvatar(
      backgroundImage: imageProvider,
      radius: 30,
      backgroundColor: Colors.white,
    );
  }

  Widget _getConversationName(Conversation conversation) {
    User user = GetIt.I();
    late String username;
    if (user.id == conversation.user1.id) {
      username = conversation.user2.username;
    } else {
      username = conversation.user1.username;
    }

    bool isSeen = false;
    if (conversation.lastMessage != null && user.id != conversation.lastMessage!.sendBy) {
      if (user.id == conversation.user1.id) {
        isSeen =
            conversation.lastSeen1.isAfter(conversation.lastMessage!.sendAt);
      } else {
        isSeen =
            conversation.lastSeen2.isAfter(conversation.lastMessage!.sendAt);
      }
    }
    return Text(
      username,
      style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 14,
          fontWeight: isSeen ? FontWeight.normal : FontWeight.bold),
    );
  }

  Widget _getConversationLastMessage(Conversation conversation) {
    if(conversation.lastMessage == null) {
      return const Text('(no message)');
    }

    User user = GetIt.I();
    String res =
        conversation.lastMessage!.text ?? "This message has been unsent.";
    var style = const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13);
    if (user.id == conversation.lastMessage!.sendBy) {
      res = "You: " + res;
    } else {
      bool isSeen = false;
      if (user.id == conversation.user1.id) {
        isSeen =
            conversation.lastSeen1.isAfter(conversation.lastMessage!.sendAt);
      } else {
        isSeen =
            conversation.lastSeen2.isAfter(conversation.lastMessage!.sendAt);
      }
      style = isSeen ? style : style.copyWith(fontWeight: FontWeight.bold);
    }
    bool isSameDay = conversation.lastMessage!.sendAt.isSameDay(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            res,
            style: style,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          isSameDay
              ? _timeFormat.format(conversation.lastMessage!.sendAt)
              : _dateFormat.format(conversation.lastMessage!.sendAt),
          style: style,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _getLastMessageState(Conversation conversation) {
    User user = GetIt.I();
    if (user.id != conversation.lastMessage!.sendBy) {
      return const SizedBox.shrink();
    } else {
      return const SizedBox.shrink();
    }
  }
}
