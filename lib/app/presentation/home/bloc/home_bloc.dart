import 'package:chat/app/presentation/home/bloc/home_event.dart';
import 'package:rxdart/subjects.dart';

import 'package:chat/app/data/repositories/user_repository.dart';
import 'package:chat/app/presentation/home/bloc/home_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';

class HomeBloc extends Bloc {
  late final BehaviorSubject<HomeState> _stateController;
  Stream<HomeState> get stateStream => _stateController.stream;
  Sink<HomeState> get _stateSink => _stateController.sink;

  final UserRepository _userRepository;
  HomeBloc(
    this._userRepository,
  ) {
    _stateController = BehaviorSubject.seeded(HomeLoadingState());
    add(HomeGetUserEvent());
  }

  void add(HomeEvent event) async {
    if(event is HomeGetUserEvent) {
      final res = await _userRepository.me();
      if(res.isSuccess()) {
        _stateSink.add(HomeLoadingUserCompleteState());
      } else {
        _stateSink.add(HomeErrorState(message: res.getError()!.reason));
      }
    }
  }

  @override
  void dispose() {
    _stateController.close();
  }
}
