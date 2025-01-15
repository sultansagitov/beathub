import 'package:flutter/cupertino.dart';
class AlbumViewClosingNotifier extends ChangeNotifier {
  static final _instance = AlbumViewClosingNotifier._internal();
  AlbumViewClosingNotifier._internal();

  factory AlbumViewClosingNotifier() => _instance;

  void notifyAll() => super.notifyListeners();
}