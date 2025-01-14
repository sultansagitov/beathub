import 'package:flutter/material.dart';

class HorizontalPadding extends InheritedWidget {
  final double horizontalPadding;

  const HorizontalPadding({
    super.key,
    required this.horizontalPadding,
    required super.child,
  });

  static HorizontalPadding? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HorizontalPadding>();
  }

  @override
  bool updateShouldNotify(HorizontalPadding oldWidget) {
    return oldWidget.horizontalPadding != horizontalPadding;
  }
}
