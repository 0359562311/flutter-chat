import 'dart:io';

import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_event.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_state.dart';
import 'package:chat/app/presentation/conversation/ui/seen_status.dart';
import 'package:chat/core/bloc_base/bloc_consumer.dart';
import 'package:chat/core/bloc_base/bloc_provider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';

import 'chat_line.dart';

class ConversationBody extends StatefulWidget {
  final Conversation conversation;
  const ConversationBody(this.conversation, {Key? key}) : super(key: key);

  @override
  _ConversationBodyState createState() => _ConversationBodyState();
}

class _ConversationBodyState extends State<ConversationBody> {
  late final ScrollController _scrollController;
  late ConversationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(() {
      if(_scrollController.offset == _scrollController.position.maxScrollExtent) {
        _bloc.addEvent(ConversationLoadMoreMessageEvent(isInit: false));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = BlocProvider.of<ConversationBloc>(context)!;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = GetIt.I<User>();
    final other = widget.conversation.user1.id == currentUser.id
        ? widget.conversation.user2
        : widget.conversation.user1;

    return BlocConsumer<ConversationBloc, ConversationState>(
      bloc: _bloc,
      listener: (context, state) {
        if (state is ConversationErrorState) {
          Fluttertoast.showToast(
              msg: state.reason!,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              fontSize: 16.0
          );
        }
      },
      listenWhen: (oldState, newState) {
        return newState is ConversationErrorState && newState.reason != null;
      },
      buildWhen: (oldState, newState) {
        return newState is ConversationNewMessageState || newState is ConversationLoadMoreMessageCompleteState;
      },
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent),
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _bloc.messages.length,
                  itemBuilder: (context, index) {
                    final message = _bloc.messages[index];
                    if (message.sendBy == currentUser.id) {
                      return Row(
                        key: ValueKey(message.id),
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ChatLine(
                              message: message,
                              conversation: widget.conversation,
                              isSender: true),
                          const SizedBox(
                            width: 8,
                          ),
                          _getSeenStatus(widget.conversation, message, index == 0 ? null : _bloc.messages[index-1],context),
                          const SizedBox(
                            width: 8,
                          )
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      key: ValueKey(message.id),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: (index == 0 ||
                                  (index > 0 &&
                                      message.sendBy !=
                                          _bloc.messages[index - 1].sendBy))
                              ? CircleAvatar(
                                  radius: 15,
                                  backgroundImage: (other.avatar == null
                                          ? const AssetImage(
                                              "assets/images/person.png")
                                          : NetworkImage(other.avatar!))
                                      as ImageProvider,
                                )
                              : const SizedBox(
                                  width: 31,
                                ),
                        ),
                        ChatLine(
                            message: message,
                            conversation: widget.conversation,
                            isSender: false),
                        const Spacer(),
                        _getSeenStatus(widget.conversation, message, index == 0 ? null : _bloc.messages[index-1],context),
                        const SizedBox(
                          width: 8,
                        )
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
            if (MediaQuery.of(context).padding.bottom == 0)
              const SizedBox(height: 35,)
          ],
        );
      },
    );
  }

  Widget _getSeenStatus(
      Conversation conversation, Message message, Message? nextMessage,BuildContext context) {
    if(nextMessage != null) {
      if(nextMessage.sendAt.isAfter(conversation.getOtherLastSeen())) {
        if(message.sendAt.isBefore(conversation.getOtherLastSeen())) {
          return SeenStatus(
              avatar: conversation.getOther().avatar,
              initOffset: _getTextHeight(
                  message.text, MediaQuery.of(context).size.width - 64 - 100));
        }
      }
      return const SizedBox(width: 14,);
    }
    else {
      if(message.sendAt.isAfter(conversation.getOtherLastSeen())) {
        return const SizedBox(width: 14,);
      }
      return SeenStatus(
          avatar: conversation.getOther().avatar,
          initOffset: _getTextHeight(
              message.text, MediaQuery.of(context).size.width - 64 - 100));
    }
  }

  double _getTextHeight(String? s, double maxWidth) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
          text: s ?? "This message has been removed.",
          style: TextStyle(
              fontStyle: s == null ? FontStyle.italic : FontStyle.normal)),
      textDirection: TextDirection.ltr,
      maxLines: 1000,
    )..layout(minWidth: 0, maxWidth: maxWidth);

    final countLines = (textPainter.size.width / maxWidth).ceil();
    final height = countLines * textPainter.size.height;
    return height + 20;
  }
}
