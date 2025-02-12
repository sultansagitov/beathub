import 'package:beathub/main_page.dart';
import 'package:beathub/observer/player_state_notifier.dart';
import 'package:beathub/widgets/headers.dart';
import 'package:beathub/widgets/horizontal_padding.dart';
import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';
import 'package:beathub/widgets/album_list.dart';
import 'package:beathub/widgets/song_list.dart';

import 'package:beathub/observer/track_index_observer.dart';

class AlbumView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const AlbumView({super.key, required this.playerKey});

  @override
  State<AlbumView> createState() => AlbumViewState();
}

class AlbumViewState extends State<AlbumView> {
  final GlobalKey<SongListState> songListKey = GlobalKey();

  void _onTrackChanged(_, {bool byScroll = false }) => setState(() {});

  void _onPlayerStateChanged() => setState(() {});

  @override
  void initState() {
    super.initState();

    TrackIndexObserver().addListener(_onTrackChanged);
    PlayerStateNotifier().addListener(_onPlayerStateChanged);
  }

  @override
  void dispose() {
    TrackIndexObserver().removeListener(_onTrackChanged);
    PlayerStateNotifier().removeListener(_onPlayerStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    double padding = HorizontalPadding.of(context)?.horizontalPadding ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Header1("Rizl"),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Header2("Beathub albums"),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: AlbumList(
            size: 100,
            playerKey: widget.playerKey,
            onSelect: (album) => setState(() {
              MainPageData.selectedAlbum = album;
            })
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SongList(
                key: songListKey,
                playerKey: widget.playerKey
              ),
            ),
          )
        ),
        const SizedBox(height: 40)
      ],
    );
  }
}