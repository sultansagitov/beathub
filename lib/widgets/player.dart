import 'dart:convert';
import 'package:beathub/classes/author.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/queue.dart';
import 'package:beathub/classes/song.dart';
import 'package:beathub/classes/enums.dart';

typedef OnPlayerStateChanged = void Function();
typedef OnTrackChanged = void Function(int index, {bool byScroll});

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
  String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));

  if (duration.inHours > 0) {
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  } else {
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}


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
  List<Author> authors = [];
  List<Album> imageAlbums = [];
  Queue queue = Queue();

  Future<Map<String, dynamic>> loadSongs() async {
    final String jsonString = await rootBundle.loadString('assets/songs.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    return jsonMap;
  }

  @override
  void initState() {
    super.initState();
    loadSongs().then((value) {
      try {
        // Create a map of album names to their image paths
        authors = [];
        imageAlbums = [];

        for (var authorData in value["authors"]) {
          authors.add(Author(authorData["name"]));
        }

        for (var albumData in value["albums"]) {
          String name = albumData["name"];
          String imagePath = albumData["image"];
          String authorName = albumData["author"];

          var author = authors.firstWhere((al) => al.name == authorName);
          var album = Album(name, imagePath);

          author.addAlbum(album);
          imageAlbums.add(album);
        }

        for (var json in value["songs"]) {
          var name = json["name"];
          var albumName = json["album"];
          var path = json["song"];

          var album = imageAlbums.firstWhere((al) => al.name == albumName);

          album.addSong(Song(name: name, path: path));
        }

        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() {
            widget.onPlayerStateChanged();
            widget.onTrackChanged(queue.index);
          });
        });
      } catch (e) {
        print("Error loading songs: $e");
      }
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


  Future<void> playTrack(Song song, {bool byScroll = false}) async {
    await audioPlayer.stop();
    await audioPlayer.play(song.songAsset);
    queue.updateIndex(song);
    setState(() {
      queue.play = Play.playing;
      updateIcon();
      widget.onPlayerStateChanged();
      widget.onTrackChanged(queue.index, byScroll: byScroll);
    });
  }


  Future<void> playTrackByIndex(int index, {bool byScroll = false}) async {
    await playTrack(queue.get(index), byScroll: byScroll);
  }

  Future<void> playBtn() async {
    if (queue.songs.isEmpty) {
      return;
    }

    switch (queue.play) {
      case Play.notStarted:
        await play();
        return;
      case Play.playing:
        await pause();
        return;
      case Play.paused:
        await audioPlayer.resume();
        setState(() {
          queue.play = Play.playing;
          updateIcon();
          widget.onPlayerStateChanged();
        });
    }
  }

  Future<void> nextTrack() async => await playTrack(queue.getNextSong()!);
  Future<void> nextTrackForce() async => await playTrack(queue.getNextSong(force: true)!);
  Future<void> prevTrack() async => await playTrack(queue.getPrevSong()!);

  void shuffleTracksBtn() => setState(() {
    queue.shuffle();
    widget.onPlayerStateChanged();
  });

  void repeatTracksBtn() => setState(() {
    queue.repeat = queue.repeat == Repeating.repeat
        ? Repeating.repeatOne
        : Repeating.repeat;
    widget.onPlayerStateChanged();
  });

  Future<void> play() async {
    await audioPlayer.play(queue.getNextSong()!.songAsset);
    setState(() {
      queue.play = Play.playing;
      updateIcon();
      widget.onPlayerStateChanged();
    });
  }

  Future<void> pause() async {
    await audioPlayer.pause();
    setState(() {
      queue.play = Play.paused;
      updateIcon();
      widget.onPlayerStateChanged();
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  Widget _buildSlider() => Column(
    children: <Widget>[
      if (queue.duration != null)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(formatDuration(queue.position)),
              Text(formatDuration(queue.duration!)),
            ]
          ),
        ),

      Slider(
        min: 0.0,
        max: queue.duration?.inSeconds.toDouble() ?? 0,
        value: queue.position.inSeconds.toDouble(),
        activeColor: queue.getCurrent()?.album.light(),
        onChanged: (double value) => setState(() {
          queue.position = Duration(seconds: value.toInt());
        }),
        onChangeStart: (double value) => setState(() => sliderTouch = true),
        onChangeEnd: (double value) {
          sliderTouch = false;
          audioPlayer.seek(Duration(seconds: value.toInt()));
        }
      ),
    ],
  );

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
                  icon: const Icon(Icons.skip_previous, size: 36),
                  onPressed: prevTrack,
                ),
                IconButton(
                  icon: Icon(icon, size: 36),
                  onPressed: playBtn,
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 36),
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
