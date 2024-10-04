import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
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
    required String mainColor
  }) {
    this.mainColor = Color(int.parse("40$mainColor", radix: 16));
  }
}