import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:beathub/classes/image_album.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class Song {
  final String name;
  final AssetSource songAsset;
  final ImageAlbum album;
  late final Color mainColor;

  Song({
    required this.name,
    required this.songAsset,
    required this.album,
  }) {
    _setMainColorFromImage();
  }

  Future<void> _setMainColorFromImage() async {
    PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(album.image);
    mainColor = paletteGenerator.dominantColor?.color ?? Colors.black;
  }

  Color light() {
    var summa = mainColor.red + mainColor.green + mainColor.blue;
    if (summa < 150) {
      return Colors.white;
    }

    int maximum = max(max(mainColor.red, mainColor.green), mainColor.blue);

    return Color.fromRGBO(
        (mainColor.red / maximum * 255).round(),
        (mainColor.green / maximum * 255).round(),
        (mainColor.blue / maximum * 255).round(),
        1.0
    );
  }
}
