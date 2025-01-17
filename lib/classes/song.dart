import 'package:audioplayers/audioplayers.dart';
import 'package:beathub/classes/album.dart';

class Song {
  final String name;
  final String path;
  final Duration duration;
  AssetSource? _songAsset;

  late Album album;

  AssetSource get songAsset {
    _songAsset ??= AssetSource(path);
    return _songAsset!;
  }

  Song({
    required this.name,
    required this.path,
    required this.duration
  });
}
