import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/core/const/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:chat/core/extensions/datetime_exts.dart';

class ChatLine extends StatefulWidget {
  const ChatLine({
    Key? key,
    required this.message, required this.conversation, required this.isSender,
  }) : super(key: key);

  final Message message;
  final Conversation conversation;
  final bool isSender;

  @override
  State<ChatLine> createState() => _ChatLineState();
}

class _ChatLineState extends State<ChatLine> with TickerProviderStateMixin {

  late AnimationController _animationController;
  late Animation<Offset> _animationOffset;
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = false;
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 200),
        reverseDuration: const Duration(milliseconds: 200)
    );
    _animationOffset = Tween<Offset>(begin: const Offset(0, 1), end: const Offset(0, 0)).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          if(_isExpanded) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
          _isExpanded = !_isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: widget.isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          SlideTransition(
            child: _isExpanded ? Text("Sent at ${widget.message.sendAt.toMyDateTime()}") : const SizedBox.shrink(),
            position: _animationOffset,
          ),
          IntrinsicWidth(
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                  color: widget.isSender ? AppColors.blue : AppColors.brightGrey,
                  borderRadius: BorderRadius.circular(15)),
              alignment: widget.isSender ? Alignment.centerRight : Alignment.centerLeft,
              child:
              Text(widget.message.text ?? "This message has been removed",
                maxLines: 1000,
                style: TextStyle(color: widget.isSender ? Colors.white : Colors.black,
                  fontStyle: widget.message.text == null ? FontStyle.italic : FontStyle.normal
                ),
              ),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 64 - 100
              ),
            ),
          ),
          SlideTransition(
            child: _getMessageStatus(),
            position: _animationOffset,
          ),
        ],
      ),
    );
  }

  Widget _getMessageStatus() {
    if(_isExpanded) {
      if(widget.isSender) {
        if(widget.conversation.user1.id == GetIt.I<User>().id) {
          if(widget.conversation.lastSeen2.isBefore(widget.message.sendAt)) {
            return const Text("Not seen");
          }
          return const Text("Seen");
        } else if (widget.conversation.user2.id == GetIt.I<User>().id) {
          if(widget.conversation.lastSeen1.isBefore(widget.message.sendAt)) {
            return const Text("Not seen");
          }
          return const Text("Seen");
        }
      }
      return const Text("Seen");
    }

    return const SizedBox.shrink();
  }
}
