import 'package:beathub/classes/enums.dart';
import 'package:beathub/observer/track_index_observer.dart';
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

  Future<void> _onTrackChanged(index, { bool byScroll = false }) async {
    PlayerState? playerState = widget.playerKey.currentState;
    if (
    playerState != null
        && !byScroll
        && _pageController.positions.isNotEmpty
    ) {
      scrolling = true;
      await _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      scrolling = false;
    }
  }

  @override
  void initState() {
    super.initState();

    TrackIndexObserver().addListener(_onTrackChanged);

    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      PlayerState? playerState = widget.playerKey.currentState;

      if (
          _pageController.hasClients &&
          playerState != null &&
          playerState.queue.isStarted()
      ) {
        _pageController.jumpToPage(playerState.queue.index);
      }
    });
  }

  @override
  void dispose() {
    TrackIndexObserver().removeListener(_onTrackChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    PlayerState? playerState = widget.playerKey.currentState;

    if (playerState == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (playerState.queue.play == Play.notStarted) {
      return const Center(child: Text("Track is not started"));
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (!playerState.queue.isEmpty())
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) async {
                if (!scrolling && !playerState.queue.isCurrent(index)) {
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
                      height: !isPortrait ? double.maxFinite : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
