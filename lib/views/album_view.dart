import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';

class AlbumView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const AlbumView({super.key, required this.playerKey});

  @override
  State<AlbumView> createState() => AlbumViewState();
}

class AlbumViewState extends State<AlbumView> {
  void onPlayerStateChanged() {}

  Future<void> onTrackChanged(int index, {bool byScroll = false}) async {}

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Text("No tracks");
    }

    if (playerState.queue.getCount() == 0) {
      return const Center(
        child: Text(
          "No albums available",
          style: TextStyle(fontSize: 18),
        ),
      );
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
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: playerState.imageAlbums.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final album = playerState.imageAlbums[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image(
                        image: album.image,
                        fit: BoxFit.cover,
                        width: 140,
                        height: 140,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: 140,
                      child: Text(
                        album.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: Text(
                        album.name,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
