import 'package:flutter/material.dart';

import 'package:beathub/classes/enums.dart';
import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/song.dart';
import 'package:beathub/widgets/player.dart';

class MusicView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const MusicView({super.key, required this.playerKey});

  @override
  State<MusicView> createState() => MusicViewState();
}

class MusicViewState extends State<MusicView> {
  final PageController _pageController = PageController();
  PlayerState? playerState;
  Album? queue;
  Song? song;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onTrackChanged(int trackIndex) {
    _pageController.jumpToPage(trackIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child:
            (playerState != null && queue?.play != Play.notStarted) ?
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) async {
                  await playerState!.playTrackByIndex(index, fromPageView: true);
                  setState(() {});
                },
                itemCount: queue?.getCount(),
                itemBuilder: (context, index) {
                  return Image(
                    image: queue!.get(index).image,
                    width: double.infinity,
                    height: 100,
                    fit: BoxFit.contain,
                  );
                },
              )
              : Container(),
          ),

        if (playerState != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                song?.name ?? "",
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

        if (playerState != null)
          Slider(
            min: 0.0,
            max: playerState != null
                ? queue!.duration?.inSeconds.toDouble() ?? 0
                : 0,
            value: playerState != null
                ? queue!.position?.inSeconds.toDouble() ?? 0
                : 0,
            onChanged: (double value) {
              setState(() {
                if (playerState != null) {
                  queue!.position = Duration(seconds: value.toInt());
                }
              });
            },
            onChangeStart: (double value) {
              setState(() {
                playerState?.sliderTouch = true;
              });
            },
            onChangeEnd: (double value) {
              playerState?.sliderTouch = false;
              playerState?.audioPlayer
                  .seek(Duration(seconds: value.toInt()));
            },
          ),
      ],
    );
  }
}
