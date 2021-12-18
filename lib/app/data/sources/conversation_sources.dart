import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/core/const/api_path.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

class ConversationRemoteSources {
  Future<List<Conversation>> getList(int offset) async {
    final res = await GetIt.I<Dio>().get(APIPath.conversation,
        queryParameters: {"limit": 10, "offset": offset});
    return (res.data['results'] as List)
        .map((e) => Conversation.fromMap(e))
        .toList();
  }
}

class ConversationLocalSources {
  Future<void> cache(int offset, List<Conversation> data) async {
    // TODO
    return;
  }
}