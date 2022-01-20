import 'package:chat/app/data/models/conversation.dart';
import 'package:chat/app/data/models/user.dart';
import 'package:chat/app/data/repositories/conversation_repository.dart';
import 'package:chat/app/data/repositories/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_it/get_it.dart';

class SearchProvider extends ChangeNotifier {

  late final UserRepository _userRepo;
  late final ConversationRepository _conversationRepo;

  SearchProvider() {
    _userRepo = GetIt.I();
    _conversationRepo = GetIt.I();
  }

  List<User> _data = [];
  List<User> get data => _data;

  String _searchedQuery = "";

  bool _creating = false;

  Future search(String name) async {
    if(name.length > 3) {
      _searchedQuery = name;
      await Future.delayed(const Duration(milliseconds: 200));
      if(_searchedQuery == name) {
        final res = await _userRepo.list(_searchedQuery);
        if(res.isSuccess()) {
          _data = res.getSuccess()!;
          notifyListeners();
        }
      }
    }
  }

  Future<Conversation?> createConversation(int to) async {
    if(!_creating) {
      _creating = true;
      final res = await _conversationRepo.create(to);
      _creating = false;
      return res.getSuccess();
    }
  }
}