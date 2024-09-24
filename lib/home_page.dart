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

class HomePage extends StatefulWidget {
  final String title;

  const HomePage({super.key, required this.title});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  Repeating _repeat = Repeating.noRepeat;
  bool _shuffle = false;

  Play _play = Play.notStarted;
  bool _sliderTouch = false;

  IconData _icon = Icons.audiotrack;

  int _currentTrackIndex = -1;

  List<dynamic> _tracks = [];

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
      _tracks = value["songs"];
    });

    _audioPlayer = AudioPlayer();
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        if (!_sliderTouch) {
          _position = position;
        }
      });
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      _nextTrack();
    });
  }

  void updateIcon() {
    switch (_play) {
      case Play.notStarted:
        _icon = Icons.audiotrack;
        break;
      case Play.paused:
        _icon = Icons.play_arrow;
        break;
      case Play.playing:
        _icon = Icons.pause;
        break;
    }
  }


  Future<void> _playTrack(int index) async {
    await _audioPlayer.stop();
    await _audioPlayer.play(AssetSource(_tracks[index]["path"]!));
    setState(() {
      _play = Play.playing;
      updateIcon();
    });
  }


  Future<void> _playBtn() async {
    Play play;
    int curr = _currentTrackIndex;

    switch (_play) {
      case Play.notStarted:
        play = Play.playing;
        curr = 0;
        await _audioPlayer.play(AssetSource(_tracks[curr]["path"]!));
        break;
      case Play.playing:
        play = Play.paused;
        await _audioPlayer.pause();
        break;
      case Play.paused:
        play = Play.playing;
        await _audioPlayer.resume();
        break;
    }

    setState(() {
      _currentTrackIndex = curr;
      _play = play;
      updateIcon();
    });
  }

  Future<void> _nextTrack() async {
    int curr = _currentTrackIndex;
    if (_currentTrackIndex == -1) {
      curr = 0;
    } else if (_shuffle) {
      int rand;
      do {
        rand = Random().nextInt(_tracks.length);
      } while (curr == rand);
      curr = rand;
    } else {
      switch (_repeat) {
        case Repeating.noRepeat:
          if (_currentTrackIndex == _tracks.length - 1) {
            curr = _currentTrackIndex + 1;
          } else {
            curr = -1;
          }
          break;
        case Repeating.repeat:
          curr = (_currentTrackIndex + 1) % _tracks.length;
          break;
        case Repeating.repeatOne:
          break;
      }
    }

    await _audioPlayer.play(AssetSource(_tracks[curr]["path"]!));
  
    setState(() {
      _currentTrackIndex = curr;
    });
  }

  Future<void> _nextTrackBtn() async {
    int curr = _currentTrackIndex;

    if (_currentTrackIndex == -1) {
      curr = 0;
    } else if (_shuffle) {
      int rand;
   
      do {
        rand = Random().nextInt(_tracks.length);
      } while (curr == rand);
   
      curr = rand;
    } else {
      curr = (_currentTrackIndex + 1) % _tracks.length;
    }

    await _audioPlayer.play(AssetSource(_tracks[curr]["path"]!));
  
    setState(() {
      _currentTrackIndex = curr;
    });
  }

  Future<void> _prevTrackBtn() async {
    int curr = _currentTrackIndex;
    if (_currentTrackIndex == -1) {
      curr = 0;
    } else if (_shuffle) {
      int rand;
      do {
        rand = Random().nextInt(_tracks.length);
      } while (curr == rand);
      curr = rand;
    } else {
      curr = (_currentTrackIndex - 1) % _tracks.length;
    }
    await _playTrack(curr);

    setState(() {
      _currentTrackIndex = curr;
    });
  }

  void _shuffleTracksBtn() {
    setState(() {
      _shuffle = !_shuffle;
    });
  }

  void _repeatTracksBtn() {
    setState(() {
      List<Repeating> list = Repeating.values;
      _repeat = list.elementAt((list.indexOf(_repeat) + 1) % list.length);
    });
  }


  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _play != Play.notStarted ? Expanded(
              child: Image(
                image: AssetImage(_tracks[_currentTrackIndex]["image"]),
                width: 423
              )
            ) : Container(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Text(
                          _currentTrackIndex != -1
                              ? _tracks[_currentTrackIndex]["name"]!
                              : ""),
                    )
                ),

                Slider(
                  min: 0.0,
                  max: _duration.inSeconds.toDouble(),
                  value: _position.inSeconds.toDouble(),
                  onChanged: (double value) {
                    setState(() {
                      _position = Duration(seconds: value.toInt());
                    });
                  },
                  onChangeStart: (double value) {
                    setState(() {
                      _sliderTouch = true;
                    });
                  },
                  onChangeEnd: (double value) {
                    _sliderTouch = false;
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                  },
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[

                    Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(
                              Icons.shuffle,
                              color: _shuffle ? Colors.white : Colors.blueGrey,
                              size: 36.0,
                            ),
                            onPressed: _shuffleTracksBtn,
                          ),
                          IconButton(
                            icon: Icon(
                              _repeat == Repeating.repeatOne
                                  ? Icons.repeat_one
                                  : Icons.repeat,
                              color: _repeat == Repeating.noRepeat
                                  ? Colors.blueGrey
                                  : Colors.white,
                              size: 36.0,
                            ),
                            onPressed: _repeatTracksBtn,
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
                            onPressed: _prevTrackBtn,
                          ),
                          IconButton(
                            icon: Icon(
                              _icon,
                              size: 36.0,
                            ),
                            onPressed: _playBtn,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              size: 36.0,
                            ),
                            onPressed: _nextTrackBtn,
                          ),
                        ]
                    ),

                  ],
                ),
                const SizedBox(height: 20)
              ]
            )


          ],
        ),
      )
    );
  }
}
