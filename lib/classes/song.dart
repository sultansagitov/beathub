import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:beathub/classes/Author.dart';

class Song {
  final String name;
  final Author author;
  final AssetImage image;
  final AssetSource songAsset;

  Song({
    required this.name,
    required this.songAsset,
    required this.author,
    required this.image
  });
}