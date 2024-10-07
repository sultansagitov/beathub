import 'dart:math';

import 'package:beathub/classes/enums.dart';
import 'package:beathub/classes/song.dart';

class Album {
  int index = -1;
  List<Song> songs = [];

  Repeating repeat = Repeating.repeat;
  bool shuffled = false;
  Play play = Play.notStarted;

  Duration? duration;
  Duration? position;

  Album();

  void add(Song song) => songs.add(song);

  void updateIndex(Song song) => index = songs.indexOf(song);

  Song get(int index) => songs[index];

  Song? getCurrent() => index != -1 ? get(index) : null;

  getFirst() => songs.isNotEmpty ? get(0) : null;

  Song? getCurrentOrFirst() => getCurrent() ?? getFirst();

  int getRandomIndex() => Random().nextInt(songs.length);

  int getOtherRandomIndex() {
    int result;
    do {
      result = getRandomIndex();
    } while (result == index);
    return result;
  }

  Song? getNextSong({ bool force = false }) {
    if (!isStarted()) {
      index = 0;
    } else {
      switch (force ? Repeating.repeat : repeat) {
        case Repeating.repeat:
          index = (index + 1) % songs.length;
          break;
        case Repeating.repeatOne:
          break;
      }
    }

    return getCurrent();
  }

  Song? getPrevSong() {
    if (!isStarted()) {
      index = 0;
    } else {
      index = (index - 1) % songs.length;
    }

    return getCurrent();
  }

  void changeShuffled() => shuffled = !shuffled;
  int getCount() => songs.length;

  bool isCurrent(int index) => this.index == index;
  bool isStarted() => index != -1;
  bool isFirst() => index == 0;

  bool isLast() => index == songs.length - 1;
}