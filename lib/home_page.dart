import 'package:flutter/material.dart';
import 'player.dart';

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<PlayerState> _playerKey = GlobalKey<PlayerState>();
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTrackChanged(int trackIndex) {
    _pageController.jumpToPage(trackIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _playerKey.currentState != null &&
              _playerKey.currentState!.play != Play.notStarted
                ? Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) async {
                      await _playerKey.currentState!.playTrack(index, fromPageView: true);
                      setState(() {});
                    },
                    itemCount: _playerKey.currentState!.tracks.length,
                    itemBuilder: (context, index) {
                      return Image(
                        image: AssetImage(_playerKey.currentState!.tracks[index]["image"]),
                        width: 370,
                      );
                    },
                  ),
                )
                : Container(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                _playerKey.currentState != null ?
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                        _playerKey.currentState!.currentTrackIndex != -1 ?
                          _playerKey.currentState!.tracks[
                            _playerKey.currentState!.currentTrackIndex
                          ]["name"]!
                          : "",
                      ),
                    ),
                  )
                  : Container(),
                Slider(
                  min: 0.0,
                  max: _playerKey.currentState != null
                      ? _playerKey.currentState!.duration.inSeconds.toDouble()
                      : 0,
                  value: _playerKey.currentState != null
                      ? _playerKey.currentState!.position.inSeconds.toDouble()
                      : 0,
                  onChanged: (double value) {
                    setState(() {
                      if (_playerKey.currentState != null) {
                        _playerKey.currentState!.position =
                            Duration(seconds: value.toInt());
                      }
                    });
                  },
                  onChangeStart: (double value) {
                    setState(() {
                      if (_playerKey.currentState != null) {
                        _playerKey.currentState!.sliderTouch = true;
                      }
                    });
                  },
                  onChangeEnd: (double value) {
                    if (_playerKey.currentState != null) {
                      _playerKey.currentState!.sliderTouch = false;
                      _playerKey.currentState!.audioPlayer
                          .seek(Duration(seconds: value.toInt()));
                    }
                  },
                ),
                Player(
                  key: _playerKey,
                  onPlayerStateChanged: () { setState(() {}); },
                  onTrackChanged: _onTrackChanged,
                ),
                const SizedBox(width: 40, height: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
