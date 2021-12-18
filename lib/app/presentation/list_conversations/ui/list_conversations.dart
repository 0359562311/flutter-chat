import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_bloc.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_event.dart';
import 'package:chat/app/presentation/list_conversations/bloc/list_conversations_state.dart';
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

class ListConversationsScreenState extends State<ListConversationsScreen> {
  late final ListConversationsBloc _bloc;
  late final ScrollController _scrollController;
  final _sliverAnimatedListKey = GlobalKey<SliverAnimatedListState>();
  final DateFormat _timeFormat = DateFormat("HH:mm");
  final DateFormat _dateFormat = DateFormat("MMM dd yyyy");

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _bloc = GetIt.I();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  void reload() {
    _bloc.add(ListConversationsReloadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16.0),
            child: TextField(
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
        // SliverAnimatedList(
        //   key: _sliverAnimatedListKey,

        //   initialItemCount: 10,
        //   itemBuilder: (context, index, animation) {
        //     return Container();
        //   },
        // )
        StreamBuilder(builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data is ListConversationsErrorState) {
            return SliverToBoxAdapter(
                child: Text(
              (snapshot.data as ListConversationsErrorState).message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ));
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }),
        StreamBuilder<ListConversationsState>(
            stream: _bloc.stateStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SliverToBoxAdapter(
                    child: CustomCircularProgress());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == _bloc.conversations.length) {
                      return null;
                      // return const Text(
                      //   "Load more ...",
                      //   textAlign: TextAlign.center,
                      // );
                    } else if (index > _bloc.conversations.length) {
                      return null;
                    }
                    return Container(
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _getConversationName(_bloc.conversations[index]),
                                const SizedBox(
                                  height: 4,
                                ),
                                _getConversationLastMessage(
                                    _bloc.conversations[index]),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4,),
                          _getLastMessageState(_bloc.conversations[index])
                        ],
                      ),
                    );
                  },
                ),
              );
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
    if (user.id != conversation.lastMessage.sendBy) {
      if (user.id == conversation.user1.id) {
        isSeen =
            conversation.lastSeen1.isAfter(conversation.lastMessage.sendAt);
      } else {
        isSeen =
            conversation.lastSeen2.isAfter(conversation.lastMessage.sendAt);
      }
    }
    return Text(
      username,
      style: TextStyle(overflow: TextOverflow.ellipsis, fontSize: 14, fontWeight: isSeen ? FontWeight.normal : FontWeight.bold),
    );
  }

  Widget _getConversationLastMessage(Conversation conversation) {
    User user = GetIt.I();
    String res =
        conversation.lastMessage.text ?? "This message has been unsent.";
    var style = const TextStyle(overflow: TextOverflow.ellipsis, fontSize: 13);
    if (user.id == conversation.lastMessage.sendBy) {
      res = "You: " + res;
    } else {
      bool isSeen = false;
      if (user.id == conversation.user1.id) {
        isSeen =
            conversation.lastSeen1.isAfter(conversation.lastMessage.sendAt);
      } else {
        isSeen =
            conversation.lastSeen2.isAfter(conversation.lastMessage.sendAt);
      }
      style = isSeen ? style : style.copyWith(fontWeight: FontWeight.bold);
    }
    bool isSameDay = conversation.lastMessage.sendAt.isSameDay(DateTime.now());
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          child: Text(res, style: style,
            textAlign: TextAlign.start,
          ),
        ),
        const SizedBox(width: 4,),
        Text(
          isSameDay ? _timeFormat.format(conversation.lastMessage.sendAt) : _dateFormat.format(conversation.lastMessage.sendAt),
          style: style,
          textAlign: TextAlign.center,
        )
      ],
    );
  }

  Widget _getLastMessageState(Conversation conversation) {
    User user = GetIt.I();
    if(user.id != conversation.lastMessage.sendBy) {
      return const SizedBox.shrink();
    } else {
      return const SizedBox.shrink();
    }
  }
}