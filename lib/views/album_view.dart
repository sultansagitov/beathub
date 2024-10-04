import 'package:beathub/classes/song.dart';
import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';
import 'package:beathub/views/view.dart';

class AlbumView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const AlbumView({super.key, required this.playerKey});

  @override
  State<AlbumView> createState() => AlbumViewState();
}

class AlbumViewState extends ViewState<AlbumView> {
  @override
  void onPlayerStateChanged() {
    setState(() {});
  }

  @override
  void onTrackChanged(int trackIndex) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final playerState = widget.playerKey.currentState;

    if (playerState == null || playerState.queue.getCount() == 0) {
      return const Center(child: Text('No tracks available'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
            colors: [playerState.queue.getCurrent()?.mainColor ?? Colors.black, Colors.black],
            radius: 1,
            center: const Alignment(-1, -1)
        )
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 10,
        ),
        itemCount: playerState.queue.getCount(),
        itemBuilder: (context, index) {
          final Song track = playerState.queue.get(index);
          final bool isCurrentTrack = playerState.queue.isCurrent(index);

          return ListTile(
            contentPadding: const EdgeInsets.all(4),
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
                color: isCurrentTrack ? Colors.orange : Colors.white70,
              ),
            ),
            subtitle: Text(
              track.author.name,
              style: TextStyle(
                fontSize: 14,
                color: isCurrentTrack ? Colors.white : Colors.grey,
              ),
            ),
            onTap: () {
              playerState.playTrackByIndex(index);
            }
          );
        }
      ),
    );
  }
}
