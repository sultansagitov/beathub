import 'dart:math';
import 'dart:ui';

import 'package:beathub/views/album_view.dart';
import 'package:flutter/material.dart';
import 'package:beathub/views/queue_view.dart';
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
  final GlobalKey<AlbumViewState> _albumViewKey = GlobalKey<AlbumViewState>();
  final GlobalKey<MusicViewState> _musicViewKey = GlobalKey<MusicViewState>();
  final GlobalKey<QueueViewState> _queueViewKey = GlobalKey<QueueViewState>();
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
            _playerKey.currentState?.queue.getCurrent()?.album.mainColor
                ?? Colors.black;
        _nextColor =
            _playerKey.currentState!.queue.getCurrent()?.album.mainColor
                ?? Colors.black;
      }
    });

    _pageController.addListener(() {
      setState(() {});
    });

  }

  void _onPlayerStateChanged() {
    setState(() {
      _albumViewKey.currentState?.onPlayerStateChanged();
      _queueViewKey.currentState?.onPlayerStateChanged();
      if (_playerKey.currentState != null) {
        _currentColor =
            _playerKey.currentState?.queue.getCurrent()?.album.mainColor
                ?? Colors.black;
        _nextColor =
            _playerKey.currentState!.queue.getCurrent()?.album.mainColor
                ?? Colors.black;
      }
    });
  }

  void _onTrackChanged(int index, {bool byScroll = false}) {
    setState(() {
      _albumViewKey.currentState?.onTrackChanged(index, byScroll: byScroll);
      _queueViewKey.currentState?.onTrackChanged(index, byScroll: byScroll);
    });
  }

  void _onAlbumViewClose() {
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    var isLightMode = false;

    return Scaffold(
      body: TweenAnimationBuilder(
        tween: ColorTween(begin: _currentColor, end: _nextColor),
        duration: const Duration(seconds: 1),
        builder: (BuildContext context, Color? color, Widget? _) {
          return Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  color?.withAlpha(isLightMode ? 127 : 192) ?? Colors.white,
                  isLightMode ? (color?.withAlpha(127) ?? Colors.white) : Colors.black,
                ],
                radius: _pageController.hasClients
                    ? radiusFunc(_pageController.page!)
                    : 1,
                center: const Alignment(-1, -1),
              ),
            ),
            child: Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Expanded(
                      child: PageView(
                        controller: _pageController,
                        scrollDirection: Axis.vertical,
                        children: [
                          AlbumView(key: _albumViewKey, playerKey: _playerKey),
                          MusicView(key: _musicViewKey, playerKey: _playerKey),
                          QueueView(
                            key: _queueViewKey,
                            playerKey: _playerKey,
                            onAlbumViewClose: _onAlbumViewClose
                          )
                        ],
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
                if (_pageController.hasClients
                    && _pageController.positions.isNotEmpty)
                  Positioned(
                    left: 24,
                    top: _pageController.page != null
                        ? (textFunc(_pageController.page!) * textHeight() + 50) // 50-700
                        : 50,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _playerKey.currentState?.queue.getCurrentOrFirst()?.name ?? "",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
              ]
            ),
          );
        }
      )
    );
  }

  int textHeight() {
    final RenderBox renderBox = _playerKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    return position.dy.round() - 80;
  }

  double radiusFunc(double x) {
    return -1.5 * pow(1 - x, 2) + 2;
  }

  double textFunc(double x) {
    return clampDouble((18 - 9 * x) / 8, 0, 1);
  }

}
