import 'dart:io';

import 'package:chat/app/presentation/conversation/bloc/conversation_bloc.dart';
import 'package:chat/app/presentation/conversation/bloc/conversation_event.dart';
import 'package:chat/core/bloc_base/bloc_provider.dart';
import 'package:chat/core/const/app_colors.dart';
import 'package:flutter/material.dart';

class ConversationBottomSheet extends StatefulWidget {
  final double bottom;
  const ConversationBottomSheet(this.bottom, {Key? key}) : super(key: key);

  @override
  _ConversationBottomSheetState createState() =>
      _ConversationBottomSheetState();
}

class _ConversationBottomSheetState extends State<ConversationBottomSheet> {
  late final TextEditingController _textEditingController;
  late FocusNode _focusNode;
  bool _isEditing = false;
  late ConversationBloc _bloc;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _focusNode = FocusNode()..addListener(() {
      if(_isEditing != _focusNode.hasFocus) {
        setState(() {
          _isEditing = _focusNode.hasFocus;
        });
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
    _textEditingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32 + widget.bottom,
      width: double.infinity,
      // color: Colors.grey,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.menu,
                color: AppColors.blue,
              )),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt_rounded,
                color: AppColors.blue,
              )),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.image,
                color: AppColors.blue,
              )),
          Expanded(
              child: Container(
            height: 32,
            alignment: Alignment.centerLeft,
            child: TextField(
              minLines: 1,
              keyboardType: TextInputType.multiline,
              focusNode: _focusNode,
              controller: _textEditingController,
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                  // isDense: true,
                  fillColor: AppColors.brightGrey,
                  focusColor: Colors.grey,
                  filled: true,
                  hintText: "Text",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  suffixIcon: InkWell(
                    child: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.blue,
                    ),
                    onTap: () {},
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(
                          width: 0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40),
                      borderSide: const BorderSide(
                          width: 0, color: Colors.transparent))),
            ),
          )),
          IconButton(
              onPressed: () {
                if(_textEditingController.text.isNotEmpty) {
                  _bloc.addEvent(ConversationNewMessageEvent(_textEditingController.text));
                  _textEditingController.text = "";
                }
              },
              icon: const Icon(
                Icons.send,
                color: AppColors.blue,
              ))
        ],
      ),
    );
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
