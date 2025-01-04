import 'dart:math';

import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ImageAlbum {
  final String name;
  final AssetImage image;
  late final Color mainColor;

  ImageAlbum(this.name, String imagePath) : image = AssetImage(imagePath) {
    _setMainColorFromImage();
  }

  Future<void> _setMainColorFromImage() async {
    PaletteGenerator pg = await PaletteGenerator.fromImageProvider(image);
    mainColor = pg.dominantColor?.color ?? Colors.black;
  }

  Color light() {
    var summa = mainColor.r + mainColor.g + mainColor.b;
    if (summa < 150) return Colors.white;

    double maximum = max(max(mainColor.r, mainColor.g), mainColor.b);

    return Color.fromRGBO(
        (mainColor.r / maximum * 255).round(),
        (mainColor.g / maximum * 255).round(),
        (mainColor.b / maximum * 255).round(),
        1.0
    );
  }
}