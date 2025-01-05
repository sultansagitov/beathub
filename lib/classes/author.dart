import 'package:beathub/classes/album.dart';

class Author {
  final String name;
  final List<Album> albums = [];

  Author(this.name);

  void addAlbum(Album album) {
    album.author = this;
    albums.add(album);
  }
}
