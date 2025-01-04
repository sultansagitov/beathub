import 'package:audioplayers/audioplayers.dart';
import 'package:beathub/classes/image_album.dart';

class Song {
  final String name;
  final ImageAlbum album;
  final String path;
  AssetSource? _songAsset;

  AssetSource get songAsset {
    _songAsset ??= AssetSource(path);
    return _songAsset!;
  }

  Song({
    required this.name,
    required this.album,
    required this.path,
  });
}
