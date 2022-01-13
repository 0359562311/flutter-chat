import 'package:chat/app/presentation/login/bloc/login_bloc.dart';
import 'package:chat/app/presentation/login/bloc/login_event.dart';
import 'package:chat/app/presentation/login/bloc/login_state.dart';
import 'package:chat/core/const/app_routes.dart';
import 'package:chat/core/custom_widget/custom_circular_progress.dart';
import 'package:chat/core/custom_widget/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final LoginBloc _bloc;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _bloc = GetIt.I()
      ..stateStream.listen((state) {
        if (state is LoginFailState) {
          showMyAlertDialog(
              context, "Error while trying to log in", state.message);
        } else if (state is LoginSuccessfulState) {
          Navigator.of(context).pushReplacementNamed(AppRoute.home);
        }
      });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<LoginState>(
          stream: _bloc.stateStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data is LoginLoadingState) {
              return const CustomCircularProgress();
            }
            return Column(
              children: [
                Expanded(
                    child: Center(
                  child: Image.asset(
                    "assets/images/messenger.png",
                    width: 90,
                    height: 90,
                  ),
                )),
                Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          validator: (value) {
                            if((value?.length ?? 0) < 5) {
                              return "At least 5 characters";
                            }
                          },
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              hintText: "Username",
                              contentPadding: EdgeInsets.all(8)),
                        ),
                        TextFormField(
                          controller: _passwordController,
                          validator: (value) {
                            if((value?.length ?? 0) < 6) {
                              return "At least 6 characters";
                            }
                          },
                          decoration: const InputDecoration(
                              focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(color: Colors.blue)),
                              contentPadding: EdgeInsets.all(8),
                              hintText: "Password"),
                        ),
                        InkWell(
                          onTap: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              _bloc.addEvent(LoginWithUsernameEvent(
                                  username: _usernameController.text,
                                  password: _passwordController.text));
                            }
                          },
                          child: Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            margin: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8)),
                            width: double.infinity,
                            child: const Text(
                              "Log in",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const Text(
                          "Forgotten password",
                          style: TextStyle(color: Colors.blue),
                        ),
                        const SizedBox(
                          height: 32,
                        )
                      ],
                    ),
                  ),
                )
              ],
            );
          }),
    );
  }
}
