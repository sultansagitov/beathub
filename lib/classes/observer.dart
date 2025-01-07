import 'package:flutter/cupertino.dart';

class Observer<T extends Function> {
  @protected
  final List<T> listeners = [];

  void addListener(T listener) {
    listeners.add(listener);
  }

  void removeListener(T listener) {
    listeners.remove(listener);
  }
}