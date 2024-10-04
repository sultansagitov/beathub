import 'package:flutter/material.dart';

import 'package:beathub/classes/enums.dart';
import 'package:beathub/views/view.dart';
import 'package:beathub/widgets/player.dart';

class MusicView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const MusicView({super.key, required this.playerKey});

  @override
  State<MusicView> createState() => MusicViewState();
}

class MusicViewState extends ViewState<MusicView> {
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void onTrackChanged(int trackIndex) {
    _pageController.animateToPage(
      trackIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onPlayerStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [widget.playerKey.currentState?.queue.getCurrent()?.mainColor ?? Colors.white, Colors.black],
          radius: 2,
          center: const Alignment(-1, -1)
        )
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: (
              widget.playerKey.currentState != null &&
              widget.playerKey.currentState?.queue.play != Play.notStarted
            )
              ? PageView.builder(
                  controller: _pageController,

                  onPageChanged: (index) async {
                    await widget.playerKey.currentState!.playTrackByIndex(index, fromView: true);
                    setState(() {});
                  },
                  itemCount: widget.playerKey.currentState?.queue.getCount(),
                  itemBuilder: (context, index) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 0
                    ),
                    child: Image(
                        image: widget.playerKey.currentState!.queue.get(index).image,
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                      ),
                  ),
                )
              : Container(),
            ),

          if (widget.playerKey.currentState != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  widget.playerKey.currentState?.queue.getCurrent()?.name ?? "",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),

          if (widget.playerKey.currentState != null)
            Slider(
              min: 0.0,
              max: widget.playerKey.currentState != null
                ? widget.playerKey.currentState!.queue.duration?.inSeconds.toDouble() ?? 0
                : 0,
              value: widget.playerKey.currentState != null
                ? widget.playerKey.currentState!.queue.position?.inSeconds.toDouble() ?? 0
                : 0,
              onChanged: (double value) {
                setState(() {
                  if (widget.playerKey.currentState != null) {
                    widget.playerKey.currentState!.queue.position = Duration(seconds: value.toInt());
                  }
                });
              },
              onChangeStart: (double value) {
                setState(() {
                  widget.playerKey.currentState?.sliderTouch = true;
                });
              },
              onChangeEnd: (double value) {
                widget.playerKey.currentState?.sliderTouch = false;
                widget.playerKey.currentState?.audioPlayer
                  .seek(Duration(seconds: value.toInt()));
              },
            ),
        ],
      ),
    );
  }
}
