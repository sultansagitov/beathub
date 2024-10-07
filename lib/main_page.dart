import 'package:beathub/views/album_view.dart';
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
  final GlobalKey<AlbumViewState> _albumViewKey = GlobalKey<AlbumViewState>();
  final PageController _pageController = PageController();

  Color _currentColor = Colors.black;
  Color _nextColor = Colors.black;

  late List<Widget> pages;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (_playerKey.currentState != null) {
        _currentColor =
            _playerKey.currentState?.queue.getCurrent()?.mainColor
                ?? Colors.black;
        _nextColor =
            _playerKey.currentState!.queue.getCurrent()?.mainColor
                ?? Colors.black;
      }
    });
  }

  void _onPlayerStateChanged() {
    setState(() {
      _musicViewKey.currentState?.onPlayerStateChanged();
      _albumViewKey.currentState?.onPlayerStateChanged();
      if (_playerKey.currentState != null) {
        _currentColor =
            _playerKey.currentState?.queue.getCurrent()?.mainColor
                ?? Colors.black;
        _nextColor =
            _playerKey.currentState!.queue.getCurrent()?.mainColor
                ?? Colors.black;
      }
    });
  }

  void _onAlbumPressed() {
    _pageController.jumpTo(0);
  }

  void _onTrackChanged(int index) {
    setState(() {
      _musicViewKey.currentState?.onTrackChanged();
      _albumViewKey.currentState?.onTrackChanged();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TweenAnimationBuilder(
        tween: ColorTween(begin: _currentColor, end: _nextColor),
        duration: const Duration(milliseconds: 300),
        builder: (BuildContext context, Color? color, Widget? _) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [color ?? Colors.black, Colors.black],
                radius: 1.7,
                center: const Alignment(-1, -1),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    children: [
                      MusicView(key: _musicViewKey, playerKey: _playerKey),
                      AlbumView(key: _albumViewKey, playerKey: _playerKey)
                    ],
                  ),
                ),
                Player(
                  key: _playerKey,
                  onPlayerStateChanged: _onPlayerStateChanged,
                  onAlbumPressed: _onAlbumPressed,
                  onTrackChanged: _onTrackChanged,
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        }
      )
    );
  }
}
