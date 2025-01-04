import 'package:beathub/classes/song.dart';
import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';



typedef OnAlbumViewClose = void Function();

class QueueView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;
  final OnAlbumViewClose onAlbumViewClose;

  const QueueView({
    super.key,
    required this.playerKey,
    required this.onAlbumViewClose
  });

  @override
  State<QueueView> createState() => QueueViewState();
}

class QueueViewState extends State<QueueView> {
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
            itemCount: playerState.queue.getCount(),
            itemBuilder: (context, index) {
              final Song track = playerState.queue.get(index);
              final bool isCurrentTrack = playerState.queue.isCurrent(index);

              return ListTile(
                contentPadding: const EdgeInsets.all(4),
                onTap: () => playerState.playTrackByIndex(index),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image(
                    image: track.album.image,
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
                      ? track.album.light()
                      : Colors.white70,
                  ),
                ),
                subtitle: Text(
                  track.album.name,
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
