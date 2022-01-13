import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_state.dart';
import 'package:chat/core/bloc_base/bloc_consumer.dart';
import 'package:chat/core/bloc_base/bloc_provider.dart';
import 'package:chat/core/const/app_colors.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _bloc = BlocProvider.of<ConversationBloc>(context);
    final currentUser = GetIt.I<User>();
    final other = widget.conversation.user1.id == currentUser.id
        ? widget.conversation.user2
        : widget.conversation.user1;

    return BlocConsumer<ConversationBloc, ConversationState>(
      bloc: _bloc!,
      listener: (context, state) {},
      builder: (context, state) {
        return Column(
          children: [
            Expanded(
              child: Theme(
                data: ThemeData(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent
                ),
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  itemCount: _bloc.messages.length,
                  itemBuilder: (context, index) {
                    final message = _bloc.messages[index];
                    if (message.sendBy == currentUser.id) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ChatLine(message: message, conversation: widget.conversation, isSender: true),
                          const SizedBox(
                            width: 30,
                          ),
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: (index == 0 || (index > 0 && message.sendBy != _bloc.messages[index-1].sendBy)) ? CircleAvatar(
                            radius: 15,
                            backgroundImage: (other.avatar == null
                                ? const AssetImage("assets/images/person.png")
                                : NetworkImage(other.avatar!)) as ImageProvider,
                          ): const SizedBox(width: 31,),
                        ),
                        ChatLine(message: message, conversation: widget.conversation, isSender: false),
                        const SizedBox(width: 100,)
                      ],
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom,)
          ],
        );
      },
    );
  }
}