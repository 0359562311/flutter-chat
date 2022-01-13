import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';

abstract class Bloc<E,S> {

  late final BehaviorSubject<S> _stateController;
  Stream<S> get stateStream => _stateController.stream;

  Bloc(S initState) {
    _stateController = BehaviorSubject.seeded(initState);
  }

  void emit(S state) {
    _stateController.sink.add(state);
  }

  FutureOr<void> addEvent(E event);

  @mustCallSuper
  void dispose() {
    _stateController.sink.close();
    _stateController.close();
  }
}