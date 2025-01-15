import 'package:flutter/cupertino.dart';

class PlayerStateNotifier extends ChangeNotifier {
  static final _instance = PlayerStateNotifier._internal();
  PlayerStateNotifier._internal();
  factory PlayerStateNotifier() {
    return _instance;
  }

  void notifyAll() => super.notifyListeners();
}