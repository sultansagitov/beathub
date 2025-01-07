import 'package:flutter/cupertino.dart';
class AlbumViewClosingNotifier extends ChangeNotifier {
  static final AlbumViewClosingNotifier _instance = AlbumViewClosingNotifier._internal();
  AlbumViewClosingNotifier._internal();
  factory AlbumViewClosingNotifier() {
    return _instance;
  }

  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}