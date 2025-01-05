import 'package:beathub/classes/album.dart';
import 'package:beathub/widgets/player.dart';
import 'package:flutter/material.dart';

typedef OnSelect = void Function(Album album);

class AlbumList extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;
  final OnSelect onSelect;
  final double size;

  const AlbumList({
    super.key,
    required this.size,
    required this.playerKey,
    required this.onSelect
  });

  @override
  AlbumListState createState() {
    return AlbumListState();
  }
}

class AlbumListState extends State<AlbumList> {
  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Text("No tracks");
    }
    
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: playerState.imageAlbums.length,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (context, index) {
        print(playerState.imageAlbums.length);
        final album = playerState.imageAlbums[index];
        return GestureDetector(
          onTap: () => setState(() => widget.onSelect(album)),
          child: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: album.image,
                    fit: BoxFit.cover,
                    width: widget.size,
                    height: widget.size,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: widget.size,
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
                  width: widget.size,
                  child: Text(
                    album.author.name,
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
          ),
        );
      },
    );
  }
}
