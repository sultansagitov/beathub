import 'dart:math';

import 'package:beathub/classes/author.dart';
import 'package:beathub/classes/song.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class Album {
  final String name;
  final AssetImage image;
  Color mainColor = Colors.grey;
  final List<Song> songs = [];
  late Author author;

  Album(this.name, String imagePath)
      : image = AssetImage(imagePath)
  {
    _setMainColorFromImage();
  }

  Future<void> _setMainColorFromImage() async {
    var pg = await PaletteGenerator.fromImageProvider(image);
    mainColor = pg.dominantColor?.color ?? Colors.grey;
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

  void addSong(Song song) {
    songs.add(song);
    song.album = this;
  }
}