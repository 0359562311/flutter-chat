import 'package:chat/app/data/repositories/authentication_repository.dart';
import 'package:chat/app/presentation/login/bloc/login_event.dart';
import 'package:chat/app/presentation/login/bloc/login_state.dart';
import 'package:chat/core/bloc_base/bloc_base.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {

  final AuthenticationRepository _authenticationRepository;

  LoginBloc(this._authenticationRepository): super(const LoginInitState());

  @override
  void addEvent(LoginEvent event) async {
    if(event is LoginWithUsernameEvent) {
      emit(const LoginLoadingState());
      final res = await _authenticationRepository.logIn(event.username, event.password);
      if(res.isSuccess()) {
        emit(const LoginSuccessfulState());
      } else {
        emit(LoginFailState(message: res.getError()!.reason));
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}