import 'package:chat/app/presentation/home/bloc/home_event.dart';

import 'package:chat/app/data/repositories/user_repository.dart';
import 'package:chat/app/presentation/home/bloc/home_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {

  final UserRepository _userRepository;
  HomeBloc(
    this._userRepository,
  ): super(HomeLoadingState()) {
    addEvent(HomeGetUserEvent());
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void addEvent(HomeEvent event) async {
    if(event is HomeGetUserEvent) {
      final res = await _userRepository.me();
      if(res.isSuccess()) {
        emit(HomeLoadingUserCompleteState());
      } else {
        emit(HomeErrorState(message: res.getError()!.reason));
      }
    }
  }
}
