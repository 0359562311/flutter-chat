import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class TestSocket extends StatefulWidget {
  const TestSocket({Key? key}) : super(key: key);

  @override
  _TestSocketState createState() => _TestSocketState();
}

class _TestSocketState extends State<TestSocket> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var channel = WebSocketChannel.connect(Uri.parse('ws://192.168.0.101:8000/ws/chat/js/'));
    // channel.stream.listen((message) {
    //   channel.sink.add('received!');
    //   channel.sink.close(4123);
    // });
    return StreamBuilder(
      stream: channel.stream,
      builder: (context, snapshot) {
        return Text(snapshot.hasData ? '${snapshot.data}' : 'khum co data');
      },
    );
  }
}
