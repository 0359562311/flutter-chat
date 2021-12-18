import 'package:chat/app/data/repositories/authentication_repository.dart';
import 'package:chat/app/presentation/login/bloc/login_event.dart';
import 'package:chat/app/presentation/login/bloc/login_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';
import 'package:rxdart/subjects.dart';

class LoginBloc extends Bloc {

  late final BehaviorSubject<LoginState> _stateController;
  final AuthenticationRepository _authenticationRepository;

  LoginBloc(this._authenticationRepository) {
    _stateController = BehaviorSubject.seeded(const LoginInitState());
  }

  Stream<LoginState> get stateStream => _stateController.stream;

  Sink<LoginState> get _stateSink => _stateController.sink;

  void add(LoginEvent event) async {
    if(event is LoginWithUsernameEvent) {
      _stateSink.add(const LoginLoadingState());
      final res = await _authenticationRepository.logIn(event.username, event.password);
      if(res.isSuccess()) {
        _stateSink.add(const LoginSuccessfulState());
      } else {
        _stateSink.add(LoginFailState(message: res.getError()!.reason));
      }
    }
  }

  @override
  void dispose() {
    _stateController.close();
  }
}