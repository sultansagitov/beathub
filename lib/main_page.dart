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
  final GlobalKey<MusicViewState> _musicViewKey = GlobalKey<MusicViewState>();

  _onPlayerStateChanged() {
    setState(() {
      _musicViewKey.currentState?.playerState = _playerKey.currentState;
      _musicViewKey.currentState?.queue = _playerKey.currentState?.queue;
      _musicViewKey.currentState?.song = _playerKey.currentState?.queue.getCurrent();
    });
  }

  void _onTrackChanged(int trackIndex) {
    _musicViewKey.currentState?.onTrackChanged(trackIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: MusicView(
              key: _musicViewKey,
              playerKey: _playerKey,
            ),
          ),
          Player(
            key: _playerKey,
            onPlayerStateChanged: _onPlayerStateChanged,
            onTrackChanged: _onTrackChanged,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
