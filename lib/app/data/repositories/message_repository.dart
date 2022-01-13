import 'package:chat/app/data/models/message.dart';
import 'package:chat/app/data/sources/message_sources.dart';
import 'package:chat/core/failure.dart';
import 'package:multiple_result/multiple_result.dart';
import 'package:dio/dio.dart';

class MessageRepository {
  final MessageRemoteSource _remoteSource;

  MessageRepository(this._remoteSource);

  Future<Result<Failure, List<Message>>> list(int conversationID,int lastKnownMessageId) async {
    try {
      return Success(await _remoteSource.list(conversationID, lastKnownMessageId));
    } on DioError catch (e) {
      return Error(Failure(e.response?.data['detail']));
    }
  }

  Future<Result<Failure,Message>> send(int conversationId, String content) async {
    return Error(Failure("reason"));
  }
}