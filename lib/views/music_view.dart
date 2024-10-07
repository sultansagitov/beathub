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

  void onTrackChanged() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        PlayerState? playerState = widget.playerKey.currentState;
        if (playerState != null) {
          _pageController.animateToPage(
            playerState.queue.index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                if (index != playerState.queue.index) {
                  await playerState.playTrackByIndex(index);
                }
              },
              itemCount: playerState.queue.getCount(),
              itemBuilder: (context, index) => Container(
                padding: const EdgeInsets.fromLTRB(40, 25, 40, 0),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image(
                      image: playerState.queue.get(index).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Container(),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              playerState.queue.getCurrentOrFirst()?.name ?? "",
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ],
    );
  }
}
