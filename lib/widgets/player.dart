import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/song.dart';
import 'package:beathub/classes/enums.dart';

typedef OnPlayerStateChanged = void Function();
typedef OnTrackChanged = void Function(int index);


class Player extends StatefulWidget {
  final OnPlayerStateChanged onPlayerStateChanged;
  final OnTrackChanged onTrackChanged;

  const Player({
    super.key,
    required this.onPlayerStateChanged,
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
        var song = Song(
          name: name,
          songAsset: AssetSource(path),
          image: AssetImage(image)
        );
        queue.add(song);
      }
    });

    audioPlayer.onDurationChanged.listen((Duration _duration) => setState(() {
      queue.duration = _duration;
      widget.onPlayerStateChanged();
    }));

    audioPlayer.onPositionChanged.listen((Duration _position) => setState(() {
      if (!sliderTouch) {
        queue.position = _position;
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


  Future<void> playTrack(Song song, {bool fromPageView = false}) async {
    await audioPlayer.stop();
    await audioPlayer.play(song.songAsset);
    queue.updateIndex(song);
    setState(() {
      queue.play = Play.playing;
      updateIcon();
      widget.onPlayerStateChanged();
      if (!fromPageView) {
        widget.onTrackChanged(queue.index);
      }
    });
  }


  Future<void> playTrackByIndex(int index, {bool fromPageView = false}) async {
    await playTrack(queue.get(index), fromPageView: fromPageView);

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
    if (queue.repeat == Repeating.repeat) {
      queue.repeat = Repeating.repeatOne;
    } else {
      queue.repeat = Repeating.repeat;
    }
    widget.onPlayerStateChanged();
  });


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) => Row(
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
        ]
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
  );
}
