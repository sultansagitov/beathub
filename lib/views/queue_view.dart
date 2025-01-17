import 'package:beathub/classes/song.dart';
import 'package:beathub/main_page.dart';
import 'package:beathub/observer/album_view_closing_notifier.dart';
import 'package:beathub/observer/player_state_notifier.dart';
import 'package:beathub/widgets/horizontal_padding.dart';
import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';

class QueueView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const QueueView({
    super.key,
    required this.playerKey
  });

  @override
  State<QueueView> createState() => QueueViewState();
}

class QueueViewState extends State<QueueView> {
  ScrollController scrollController = ScrollController();

  void _onPlayerStateChanged() => setState(() {});

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      MainPageData.queueScroll = scrollController.position.pixels;
    });

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (scrollController.hasClients) {
        scrollController.jumpTo(MainPageData.queueScroll);
      }
    });

    PlayerStateNotifier().addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    PlayerStateNotifier().removeListener(_onPlayerStateChanged);
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playerState.queue.isEmpty()) {
      return const Center(child: Text('No tracks in queue'));
    }

    double padding = HorizontalPadding.of(context)?.horizontalPadding ?? 0;

    return Column(
      children: [
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              padding: const EdgeInsets.all(10),
              icon: const Icon(Icons.close),
              onPressed: AlbumViewClosingNotifier().notifyAll,
            )
          ],
        ),
        Expanded(
          child: ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: padding),
            itemCount: playerState.queue.getCount(),
            itemBuilder: (context, index) {
              final Song track = playerState.queue.get(index);
              final isCurrentTrack = playerState.queue.isCurrent(index);

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
