import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';

class Song {
  late String name;
  late AssetImage image;
  late AssetSource songAsset;

  Song({
    required this.name,
    required this.songAsset,
    required this.image
  });
}