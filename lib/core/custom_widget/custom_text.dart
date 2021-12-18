import 'package:flutter/widgets.dart';

class CustomText extends StatelessWidget {
  final String data;
  final TextStyle? textStyle;
  final int?  maxLines;
  const CustomText(this.data, { Key? key, this.textStyle = const TextStyle(), this.maxLines })  : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(data,
      style: textStyle?.copyWith(fontFamily: "Roboto"),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
  }
}