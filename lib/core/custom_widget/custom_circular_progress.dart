import 'package:flutter/material.dart';

class CustomCircularProgress extends StatelessWidget {
  const CustomCircularProgress({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
          width: 50,
          height: 50,
          child: CircularProgressIndicator(
            color: Colors.blue,
            strokeWidth: 5,
          )),
    );
  }
}
