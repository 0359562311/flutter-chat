import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_event.dart';
import 'package:chat/app/presentation/conversation/ui/conversation_bottom_sheet.dart';
import 'package:chat/core/bloc_base/bloc_provider.dart';
import 'package:chat/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'conversation_body.dart';

class ConversationScreen extends StatefulWidget {
  final Conversation conversation;
  const ConversationScreen({Key? key, required this.conversation})
      : super(key: key);

  @override
  _ConversationScreenState createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {

  late final ConversationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = GetIt.I()..addEvent(ConversationInitEvent(widget.conversation));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final other = widget.conversation.user1.id == GetIt.I<User>().id
        ? widget.conversation.user2
        : widget.conversation.user1;
    return BlocProvider(
      bloc: _bloc,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: InkWell(
            child: const Icon(
              Icons.arrow_back,
              color: AppColors.blue,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: (other.avatar == null
                    ? const AssetImage("assets/images/person.png")
                    : NetworkImage(other.avatar!)) as ImageProvider,
                radius: 20,
                backgroundColor: Colors.white,
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      other.username,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black),
                    ),
                    Text(
                      _getActive(other.lastOnline),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        bottomSheet: ConversationBottomSheet(MediaQuery.of(context).padding.bottom),
        body: ConversationBody(widget.conversation),
      ),
    );
  }

  String _getActive(DateTime lastOnline) {
    return "Active 1 hour ago";
  }
}
