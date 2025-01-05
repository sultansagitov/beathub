import 'package:flutter/material.dart';
import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/queue.dart';
import 'package:beathub/classes/song.dart';
import 'package:beathub/widgets/player.dart';

class SongList extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const SongList({super.key, required this.playerKey});

  @override
  SongListState createState() {
    return SongListState();
  }
}

class SongListState extends State<SongList> {
  Album? currentAlbum;

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null || currentAlbum == null) {
      return Container(
        color: Colors.grey.withAlpha(100),
        child: Center(child: Text("Select album")),
      );
    }

    currentAlbum ??= playerState.queue.getCurrentOrFirst()?.album;

    return Container(
      width: double.maxFinite,
      color: currentAlbum?.mainColor.withAlpha(100),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currentAlbum!.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20
                  )
                ),
                IconButton(
                  icon: Icon(
                    playerState.queue.linkedAlbum == currentAlbum!
                        ? playerState.icon
                        : Icons.play_arrow
                    ,
                    size: 30,
                  ),
                  onPressed: () async {
                    if (playerState.queue.linkedAlbum != currentAlbum!) {
                      await playerState.pause();
                      playerState.queue.position = Duration(seconds: 0);
                      playerState.queue = Queue.fromAlbum(currentAlbum!);
                    }
                    playerState.playBtn();
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: currentAlbum!.songs.length,
                itemBuilder: (context, index) {
                  Song song = currentAlbum!.songs[index];
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      await playerState.pause();
                      if (playerState.queue.linkedAlbum != currentAlbum!) {
                        playerState.queue = Queue.fromAlbum(currentAlbum!);
                      }
                      await playerState.playTrackByIndex(
                          index,
                          byScroll: false
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 2
                      ),
                      child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                song.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight:
                                      playerState.queue.getCurrent() == song
                                        ? FontWeight.bold
                                        : FontWeight.w300
                                ),
                              ),
                            )
                          ]
                      ),
                    ),
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}