import 'package:flutter/material.dart';
import 'package:beathub/widgets/player.dart';

class MusicView extends StatefulWidget {
  final GlobalKey<PlayerState> playerKey;

  const MusicView({super.key, required this.playerKey});

  @override
  State<MusicView> createState() => MusicViewState();
}

class MusicViewState extends State<MusicView> {
  final PageController _pageController = PageController();

  bool scrolling = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      PlayerState? playerState = widget.playerKey.currentState;

      if (playerState != null && _pageController.hasClients) {
        int index = playerState.queue.index;

        if (index >= 0) {
          _pageController.jumpToPage(index);
        }
      }
    });
  }

  void onPlayerStateChanged() {
  }

  Future<void> onTrackChanged(int index, {bool byScroll = false}) async {
    PlayerState? playerState = widget.playerKey.currentState;
    if (
        playerState != null
        && !byScroll
        && _pageController.positions.isNotEmpty
    ) {
      scrolling = true;
      await _pageController.animateToPage(
        playerState.queue.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      scrolling = false;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Text("No tracks");
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (playerState.queue.getCount() > 0)
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                if (
                    !scrolling
                    && index != playerState.queue.index
                    // && _pageController.page == _pageController.page?.round()
                ) {
                  await playerState.playTrackByIndex(index, byScroll: true);
                }
              },
              itemCount: playerState.queue.getCount(),
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.fromLTRB(40, 25, 40, 0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: playerState.queue.get(index).album.image,
                      fit: BoxFit.cover,
                      width: isPortrait ? double.maxFinite : null,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Container(),
      ],
    );
  }
}
