import 'dart:convert';
import 'package:beathub/classes/Author.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/song.dart';
import 'package:beathub/classes/enums.dart';

typedef OnPlayerStateChanged = void Function();
typedef OnTrackChanged = void Function(int index);
typedef OnAlbumPressed = void Function();

class Player extends StatefulWidget {
  final OnPlayerStateChanged onPlayerStateChanged;
  final OnAlbumPressed onAlbumPressed;
  final OnTrackChanged onTrackChanged;

  const Player({
    super.key,
    required this.onPlayerStateChanged,
    required this.onAlbumPressed,
    required this.onTrackChanged,
  });

  @override
  PlayerState createState() => PlayerState();
}


class PlayerState extends State<Player> {
  final AudioPlayer audioPlayer = AudioPlayer();

  bool sliderTouch = false;
  IconData icon = Icons.audiotrack;
  Album queue = Album();

  Future<Map<String, dynamic>> loadSongs() async {
    // Load the JSON file from assets
    final String jsonString = await rootBundle.loadString('assets/songs/songs.json');

    // Decode the JSON string into a Map
    final Map<String, dynamic> jsonMap = json.decode(jsonString);

    return jsonMap;
  }

  @override
  void initState() {
    super.initState();

    loadSongs().then((value) {
      for (var json in value["songs"] ) {
        var name = json["name"];
        var path = json["path"];
        var image = json["image"];
        var color = json["color"];
        queue.add(Song(
          name: name,
          songAsset: AssetSource(path),
          author: Author(name: "My Group Name"),
          image: AssetImage(image),
          mainColor: color,
        ));
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          widget.onPlayerStateChanged();
          widget.onTrackChanged(queue.index);
        });
      });
    });

    audioPlayer.onDurationChanged.listen((Duration duration) => setState(() {
      queue.duration = duration;
      widget.onPlayerStateChanged();
    }));

    audioPlayer.onPositionChanged.listen((Duration position) => setState(() {
      if (!sliderTouch) {
        queue.position = position;
        widget.onPlayerStateChanged();
      }
    }));

    audioPlayer.onPlayerComplete.listen((_) {
      nextTrack();
    });
  }


  void updateIcon() {
    switch (queue.play) {
      case Play.notStarted:
        icon = Icons.audiotrack;
        break;
      case Play.paused:
        icon = Icons.play_arrow;
        break;
      case Play.playing:
        icon = Icons.pause;
        break;
    }
  }


  Future<void> playTrack(Song song) async {
    await audioPlayer.stop();
    await audioPlayer.play(song.songAsset);
    queue.updateIndex(song);
    setState(() {
      queue.play = Play.playing;
      updateIcon();
      widget.onPlayerStateChanged();
      widget.onTrackChanged(queue.index);
    });
  }


  Future<void> playTrackByIndex(int index) async {
    await playTrack(queue.get(index));
  }

  Future<void> playBtn() async {
    Play play;

    switch (queue.play) {
      case Play.notStarted:
        play = Play.playing;
        await audioPlayer.play(queue.getNextSong()!.songAsset);
        break;
      case Play.playing:
        play = Play.paused;
        await audioPlayer.pause();
        break;
      case Play.paused:
        play = Play.playing;
        await audioPlayer.resume();
        break;
    }

    setState(() {
      queue.play = play;
      updateIcon();
      widget.onPlayerStateChanged();
    });

  }

  Future<void> nextTrack() async {
    await playTrack(queue.getNextSong()!);
  }

  Future<void> nextTrackForce() async {
    await playTrack(queue.getNextSong(force: true)!);
  }

  Future<void> prevTrack() async {
    await playTrack(queue.getPrevSong()!);
  }

  void shuffleTracksBtn() => setState(() {
    queue.changeShuffled();
    widget.onPlayerStateChanged();
  });

  void repeatTracksBtn() => setState(() {
    queue.repeat = queue.repeat == Repeating.repeat
        ? Repeating.repeatOne
        : Repeating.repeat;
    widget.onPlayerStateChanged();
  });

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  Widget _buildSlider() {
    return Slider(
      min: 0.0,
      max: queue.duration?.inSeconds.toDouble() ?? 0,
      value: queue.position?.inSeconds.toDouble() ?? 0,
      activeColor: queue.getCurrent()?.mainColor.withAlpha(255),
      onChanged: (double value) => setState(() {
        queue.position = Duration(seconds: value.toInt());
      }),
      onChangeStart: (double value) => setState(() {
        sliderTouch = true;
      }),
      onChangeEnd: (double value) {
        sliderTouch = false;
        audioPlayer.seek(Duration(seconds: value.toInt()));
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return Column(
      children: [
        if (isPortrait)
          _buildSlider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.shuffle,
                    color: queue.shuffled
                      ? Colors.white
                      : Colors.blueGrey,
                    size: 36.0,
                  ),
                 onPressed: shuffleTracksBtn,
                ),
                IconButton(
                  icon: Icon(
                    queue.repeat == Repeating.repeatOne
                        ? Icons.repeat_one
                        : Icons.repeat,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: repeatTracksBtn,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.list,
                    color: Colors.white,
                    size: 36.0,
                  ),
                  onPressed: widget.onAlbumPressed,
                ),
              ]
            ),

            if (!isPortrait)
              Flexible(
                  fit: FlexFit.loose,
                  child: _buildSlider()
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    size: 36.0,
                  ),
                  onPressed: prevTrack,
                ),
                IconButton(
                  icon: Icon(
                    icon,
                    size: 36.0,
                  ),
                  onPressed: playBtn,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    size: 36.0,
                  ),
                  onPressed: nextTrackForce,
                ),
              ]
            ),

          ],
        ),
      ],
    );
  }
}