
abstract class LoginState {
  const LoginState();
}

class LoginInitState extends LoginState {
  const LoginInitState();
}

class LoginLoadingState extends LoginState {
  const LoginLoadingState();
}

class LoginFailState extends LoginState {
  final String message;
  const LoginFailState({
    required this.message,
  });
}

class LoginSuccessfulState extends LoginState {
  const LoginSuccessfulState();
}