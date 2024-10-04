import 'package:beathub/views/album_view.dart';
import 'package:beathub/views/view.dart';
import 'package:flutter/material.dart';
import 'package:beathub/views/music_view.dart';
import 'package:beathub/widgets/player.dart';

class MainPage extends StatefulWidget {
  final String title;

  const MainPage({super.key, required this.title});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final GlobalKey<PlayerState> _playerKey = GlobalKey<PlayerState>();
  final GlobalKey<ViewState> _viewKey = GlobalKey<ViewState>();
  bool albumOpened = false;

  void _onTrackChanged(int trackIndex) =>
      _viewKey.currentState?.onTrackChanged(trackIndex);

  void _onPlayerStateChanged() =>
      _viewKey.currentState?.onPlayerStateChanged();

  void _onAlbumPressed() {
    setState(() {
      albumOpened = !albumOpened;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child:  albumOpened
              ? AlbumView(
                  key: _viewKey,
                  playerKey: _playerKey,
                )
              : MusicView(
                  key: _viewKey,
                  playerKey: _playerKey
                ),
          ),
          Player(
            key: _playerKey,
            onPlayerStateChanged: _onPlayerStateChanged,
            onTrackChanged: _onTrackChanged,
            onAlbumPressed: _onAlbumPressed,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
