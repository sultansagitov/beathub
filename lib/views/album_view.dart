import 'package:beathub/classes/song.dart';
import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';



typedef OnAlbumViewClose = void Function();

class AlbumView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;
  final OnAlbumViewClose onAlbumViewClose;

  const AlbumView({
    super.key,
    required this.playerKey,
    required this.onAlbumViewClose
  });

  @override
  State<AlbumView> createState() => AlbumViewState();
}

class AlbumViewState extends State<AlbumView> {
  void onPlayerStateChanged() {
    setState(() {});
  }

  void onTrackChanged(int index, {bool byScroll = false}) {}

  @override
  Widget build(BuildContext context) {
    final playerState = widget.playerKey.currentState;

    if (playerState == null || playerState.queue.getCount() == 0) {
      return const Center(child: Text('No tracks available'));
    }

    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              padding: const EdgeInsets.all(10),
              icon: const Icon(Icons.close),
              onPressed: widget.onAlbumViewClose,
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            itemCount: playerState.queue.getCount() * 10,
            itemBuilder: (context, index) {
              final Song track = playerState.queue.get(index % playerState.queue.getCount());
              final bool isCurrentTrack = playerState.queue.isCurrent(index);

              return ListTile(
                contentPadding: const EdgeInsets.all(4),
                onTap: () => playerState.playTrackByIndex(index % playerState.queue.getCount()),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: track.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  track.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrentTrack
                      ? track.light()
                      : Colors.white70,
                  ),
                ),
                subtitle: Text(
                  track.author.name,
                  style: TextStyle(
                    fontSize: 14,
                    color: isCurrentTrack
                      ? Colors.white
                      : Colors.grey,
                  ),
                ),
              );
            }
          ),
        ),
      ],
    );
  }
}
