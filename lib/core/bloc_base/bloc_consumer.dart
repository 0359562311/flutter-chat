import 'dart:async';

import 'package:chat/core/bloc_base/bloc_base.dart';
import 'package:flutter/material.dart';

class BlocConsumer<B extends Bloc, S> extends StatefulWidget {
  final Widget Function(BuildContext, S) builder;
  final void Function(BuildContext, S) listener;
  final bool Function(S, S)? listenWhen;
  final bool Function(S, S)? buildWhen;
  final B bloc;
  const BlocConsumer(
      {Key? key, required this.bloc,
      required this.builder,
      required this.listener,
      this.listenWhen,
      this.buildWhen})
      : super(key: key);

  @override
  _BlocConsumerState<B,S> createState() => _BlocConsumerState<B,S>();
}

class _BlocConsumerState<B extends Bloc,S> extends State<BlocConsumer<B,S>> {

  S? oldState, newState;
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.bloc.stateStream.listen((state) {
      oldState = newState;
      newState = state;
      if(widget.listenWhen == null || widget.listenWhen!(oldState??(newState!), newState!)) {
        print(newState);
          widget.listener(context, newState!);
      }

      if(widget.buildWhen == null || widget.buildWhen!(oldState??(newState!), newState!)) {
        if(mounted) {
          setState(() {
            newState = state;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(newState == null) {
      return const SizedBox.shrink();
    } else {
      return widget.builder(context, newState!);
    }
  }
}
