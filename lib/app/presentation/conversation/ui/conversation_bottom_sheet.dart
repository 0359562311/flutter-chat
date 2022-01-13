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

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32 + widget.bottom,
      width: double.infinity,
      child: Row(
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
            alignment: Alignment.center,
            child: TextField(
              maxLines: 6,
              controller: _textEditingController,
              decoration: InputDecoration(
                  isDense: true,
                  fillColor: AppColors.brightGrey,
                  focusColor: Colors.grey,
                  filled: true,
                  hintText: "Text",
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.blue,
                    ),
                    onPressed: () {},
                  ),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          width: 0, color: Colors.transparent)),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                          width: 0, color: Colors.transparent))),
            ),
          )),
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.send,
                color: AppColors.blue,
              ))
        ],
      ),
    );
  }
}
