import 'package:beathub/classes/song.dart';
import 'package:beathub/main_page.dart';
import 'package:flutter/material.dart';
import 'package:beathub/classes/queue.dart';
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
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      MainPageData.selectedAlbumScroll = scrollController.position.pixels;
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(MainPageData.selectedAlbumScroll);
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null || MainPageData.selectedAlbum == null) {
      return Container(
        color: Colors.grey.withAlpha(100),
        child: Center(child: Text("Select album")),
      );
    }

    return Container(
      width: double.maxFinite,
      color: MainPageData.selectedAlbum?.mainColor.withAlpha(100),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    MainPageData.selectedAlbum!.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)
                ),
                if (playerState.queue.linkedAlbum == MainPageData.selectedAlbum!)
                  Row(
                    children: [
                      Text("in queue"),
                      IconButton(
                        icon: Icon(playerState.icon, size: 30),
                        onPressed: playerState.playBtn,
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(Icons.play_arrow, size: 30),
                    onPressed: () async {
                      await playerState.pause();
                      playerState.queue.position = Duration(seconds: 0);
                      playerState.queue = Queue.fromAlbum(MainPageData.selectedAlbum!);
                      playerState.playBtn();
                    },
                  )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.all(0.0),
              itemCount: MainPageData.selectedAlbum!.songs.length,
              itemBuilder: (BuildContext context, int index) {
                Song song = MainPageData.selectedAlbum!.songs[index];
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await playerState.pause();
                    if (playerState.queue.linkedAlbum != MainPageData.selectedAlbum!) {
                      playerState.queue = Queue.fromAlbum(MainPageData.selectedAlbum!);
                    }
                    await playerState.playTrackByIndex(index);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: playerState.queue.linkedAlbum == MainPageData.selectedAlbum!
                          && playerState.queue.isCurrent(index)
                          ? Colors.white.withAlpha(64)
                          : null
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2, horizontal: 24),
                      child: Container(
                        decoration: playerState.queue.linkedAlbum != MainPageData.selectedAlbum!
                            || !playerState.queue.isCurrent(index)
                            && !playerState.queue.isCurrent(index - 1)
                          ? BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                width: 1,
                                color: Colors.black.withAlpha(128)
                              )
                            ),
                          )
                          : null,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  song.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: playerState.queue.getCurrent() == song
                                      ? FontWeight.bold
                                      : FontWeight.w300,
                                  ),
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text("10:00")
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}