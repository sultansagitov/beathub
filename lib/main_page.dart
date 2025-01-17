import 'dart:math';
import 'dart:ui';

import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/enums.dart';
import 'package:beathub/classes/queue.dart';
import 'package:beathub/observer/album_view_closing_notifier.dart';
import 'package:beathub/observer/player_state_notifier.dart';
import 'package:beathub/views/album_view.dart';
import 'package:beathub/widgets/horizontal_padding.dart';
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
  final PageController _pageController = PageController();

  Color _currentColor = Colors.black;
  Color _nextColor = Colors.black;

  void _onPlayerStateChanged() {
    setState(() {
      PlayerState? playerState = _playerKey.currentState;
      if (playerState != null) {
        Queue queue = playerState.queue;
        Color? mainColor = queue.getCurrent()?.album.mainColor;
        _nextColor = _currentColor = mainColor ?? Colors.black;
      }
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
  void initState() {
    super.initState();
    _pageController.addListener(() => setState(() {}));
    PlayerStateNotifier().addListener(_onPlayerStateChanged);
    AlbumViewClosingNotifier().addListener(_onAlbumViewClose);
  }

  @override
  void dispose() {
    PlayerStateNotifier().removeListener(_onPlayerStateChanged);
    AlbumViewClosingNotifier().removeListener(_onAlbumViewClose);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var brightness = MediaQuery.of(context).platformBrightness;
    bool isLightMode = brightness == Brightness.light;
    Queue? queue = _playerKey.currentState?.queue;

    double padding = 16;

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
                  isLightMode
                      ? (color?.withAlpha(127) ?? Colors.white)
                      : Colors.black,
                ],
                radius: _pageController.hasClients
                  ? radiusFunc(_pageController.page!)
                  : 1,
                center: const Alignment(-1, -1),
              ),
            ),
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      child: HorizontalPadding(
                        horizontalPadding: padding,
                        child: PageView(
                          controller: _pageController,
                          scrollDirection: Axis.vertical,
                          children: [
                            AlbumView(playerKey: _playerKey),
                            if (queue?.play != Play.notStarted)
                              MusicView(playerKey: _playerKey),
                            if (queue?.play != Play.notStarted)
                              QueueView(playerKey: _playerKey)
                          ],
                        ),
                      ),
                    ),
                    Player(key: _playerKey),
                    const SizedBox(height: 20),
                  ],
                ),
                if (_pageController.positions.isNotEmpty)
                  Positioned(
                    left: padding + 8,
                    top: 50 + textFunc(_pageController.page!) * textHeight(),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(queue?.getCurrentOrFirst()?.name ?? ""),
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
    BuildContext? currentContext = _playerKey.currentContext;
    if (currentContext == null) return 0;

    final renderBox = currentContext.findRenderObject() as RenderBox;
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

class MainPageData {
  static double albumScroll = 0;
  static Album? selectedAlbum;
  static double selectedAlbumScroll = 0;
  static double queueScroll = 0;
}