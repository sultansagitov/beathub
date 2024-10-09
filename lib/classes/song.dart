import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:beathub/classes/Author.dart';

class Song {
  final String name;
  final Author author;
  final AssetImage image;
  final AssetSource songAsset;
  late final Color mainColor;

  Song({
    required this.name,
    required this.songAsset,
    required this.author,
    required this.image,
  }) {
    _setMainColorFromImage();
  }

  Future<void> _setMainColorFromImage() async {
    PaletteGenerator paletteGenerator =
      await PaletteGenerator.fromImageProvider(image);
    mainColor = paletteGenerator.dominantColor?.color ?? Colors.black;
  }
}
