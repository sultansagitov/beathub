import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

enum Play {
  notStarted,
  playing,
  paused,
}

enum Repeating {
  noRepeat,
  repeat,
  repeatOne,
}

typedef OnPlayerStateChanged = void Function();

class Player extends StatefulWidget {
  final OnPlayerStateChanged onPlayerStateChanged;
  const Player({super.key, required this.onPlayerStateChanged});

  @override
  PlayerState createState() => PlayerState();
}

class PlayerState extends State<Player> {
  late final AudioPlayer audioPlayer;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  Repeating repeat = Repeating.noRepeat;
  bool shuffle = false;

  Play play = Play.notStarted;
  bool sliderTouch = false;

  IconData icon = Icons.audiotrack;

  int currentTrackIndex = -1;

  List<dynamic> tracks = [];

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
      tracks = value["songs"];
    });

    audioPlayer = AudioPlayer();
    audioPlayer.onDurationChanged.listen((Duration _duration) {
      setState(() {
        duration = _duration;
        widget.onPlayerStateChanged();
      });
    });
    audioPlayer.onPositionChanged.listen((Duration _position) {
      setState(() {
        if (!sliderTouch) {
          position = _position;
          widget.onPlayerStateChanged();
        }
      });
    });
    audioPlayer.onPlayerComplete.listen((_) {
      nextTrack();
    });
  }

  void updateIcon() {
    switch (play) {
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


  Future<void> playTrack(int index) async {
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(tracks[index]["path"]!));
    setState(() {
      play = Play.playing;
      updateIcon();
      widget.onPlayerStateChanged();
    });
  }


  Future<void> playBtn() async {
    Play _play;
    int _curr = currentTrackIndex;

    switch (play) {
      case Play.notStarted:
        _play = Play.playing;
        _curr = 0;
        await audioPlayer.play(AssetSource(tracks[_curr]["path"]!));
        break;
      case Play.playing:
        _play = Play.paused;
        await audioPlayer.pause();
        break;
      case Play.paused:
        _play = Play.playing;
        await audioPlayer.resume();
        break;
    }

    setState(() {
      currentTrackIndex = _curr;
      play = _play;
      updateIcon();
      widget.onPlayerStateChanged();
    });
  }

  Future<void> nextTrack() async {
    int curr = currentTrackIndex;
    if (currentTrackIndex == -1) {
      curr = 0;
    } else if (shuffle) {
      int rand;
      do {
        rand = Random().nextInt(tracks.length);
      } while (curr == rand);
      curr = rand;
    } else {
      switch (repeat) {
        case Repeating.noRepeat:
          if (currentTrackIndex == tracks.length - 1) {
            curr = currentTrackIndex + 1;
          } else {
            curr = -1;
          }
          break;
        case Repeating.repeat:
          curr = (currentTrackIndex + 1) % tracks.length;
          break;
        case Repeating.repeatOne:
          break;
      }
    }

    await audioPlayer.play(AssetSource(tracks[curr]["path"]!));
  
    setState(() {
      currentTrackIndex = curr;
      widget.onPlayerStateChanged();
    });
  }

  Future<void> nextTrackBtn() async {
    int curr = currentTrackIndex;

    if (currentTrackIndex == -1) {
      curr = 0;
    } else if (shuffle) {
      int rand;
   
      do {
        rand = Random().nextInt(tracks.length);
      } while (curr == rand);
   
      curr = rand;
    } else {
      curr = (currentTrackIndex + 1) % tracks.length;
    }

    await audioPlayer.play(AssetSource(tracks[curr]["path"]!));
  
    setState(() {
      currentTrackIndex = curr;
      widget.onPlayerStateChanged();
    });
  }

  Future<void> prevTrackBtn() async {
    int curr = currentTrackIndex;
    if (currentTrackIndex == -1) {
      curr = 0;
    } else if (shuffle) {
      int rand;
      do {
        rand = Random().nextInt(tracks.length);
      } while (curr == rand);
      curr = rand;
    } else {
      curr = (currentTrackIndex - 1) % tracks.length;
    }
    await playTrack(curr);

    setState(() {
      currentTrackIndex = curr;
      widget.onPlayerStateChanged();
    });
  }

  void shuffleTracksBtn() {
    setState(() {
      shuffle = !shuffle;
      widget.onPlayerStateChanged();
    });
  }

  void repeatTracksBtn() {
    setState(() {
      List<Repeating> list = Repeating.values;
      repeat = list.elementAt((list.indexOf(repeat) + 1) % list.length);
      widget.onPlayerStateChanged();
    });
  }


  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[

        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color: shuffle
                  ? Colors.white
                  : Colors.blueGrey,
                size: 36.0,
              ),
             onPressed: shuffleTracksBtn,
            ),
            IconButton(
              icon: Icon(
                repeat == Repeating.repeatOne
                    ? Icons.repeat_one
                    : Icons.repeat,
                color: repeat == Repeating.noRepeat
                    ? Colors.blueGrey
                    : Colors.white,
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
              onPressed: prevTrackBtn,
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
              onPressed: nextTrackBtn,
            ),
          ]
        ),

      ],
    );
  }
}
