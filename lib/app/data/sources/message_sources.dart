import 'package:chat/app/data/models/message.dart';
import 'package:chat/core/const/api_path.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class MessageRemoteSource {
  Future<List<Message>> list(int conversation, int lastKnownMessageId) async {
    final res = await GetIt.I<Dio>().get(APIPath.listMessage,queryParameters: {
      "conversation": conversation,
      "pivot": lastKnownMessageId
    });
    final data = <Message>[];
    for(var i in res.data) {
      data.add(Message.fromMap(i));
    }
    return data;
  }
}