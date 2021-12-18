import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/sources/conversation_sources.dart';
import 'package:chat/core/failure.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:dio/dio.dart';

class ConversationRepository {
  final ConversationRemoteSources _remoteSources;
  final ConversationLocalSources _localSources;
  const ConversationRepository(
    this._remoteSources,
    this._localSources,
  );

  Future<Result<Failure,List<Conversation>>> getList(int offset) async {
    try {
      final res = await _remoteSources.getList(offset);
      _localSources.cache(offset, res);
      return Success(res);
    } on DioError catch (e) {
      return Error(Failure(e.response?.data['detail']??"Something happened"));
    }
  }
}
