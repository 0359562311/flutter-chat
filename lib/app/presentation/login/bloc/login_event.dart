abstract class LoginEvent {
  const LoginEvent();
}

class LoginWithUsernameEvent extends LoginEvent {
  final String username;
  final String password;
  const LoginWithUsernameEvent({
    required this.username,
    required this.password,
  });
}
