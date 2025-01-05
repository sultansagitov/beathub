import 'package:flutter/material.dart';
import 'package:beathub/classes/album.dart';
import 'package:beathub/widgets/player.dart';
import 'package:beathub/widgets/album_list.dart';
import 'package:beathub/widgets/song_list.dart';

class AlbumView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const AlbumView({super.key, required this.playerKey});

  @override
  State<AlbumView> createState() => AlbumViewState();
}

class AlbumViewState extends State<AlbumView> {
  final GlobalKey<SongListState> songListKey = GlobalKey();

  void onPlayerStateChanged() {
    setState(() {});
  }

  void onTrackChanged(int index, {bool byScroll = false}) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Rizl",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: const Text(
            "Альбомы beathub",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 180,
          child: AlbumList(
            size: 100,
            playerKey: widget.playerKey,
            onSelect: (Album album) => setState(() => songListKey.currentState?.currentAlbum = album)
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SongList(key: songListKey, playerKey: widget.playerKey),
            ),
          )
        ),
        SizedBox(height: 40)
      ],
    );
  }
}