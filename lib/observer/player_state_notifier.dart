import 'package:flutter/cupertino.dart';

class PlayerStateNotifier extends ChangeNotifier {
  static final PlayerStateNotifier _instance = PlayerStateNotifier._internal();
  PlayerStateNotifier._internal();
  factory PlayerStateNotifier() {
    return _instance;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}