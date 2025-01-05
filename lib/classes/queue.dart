import 'dart:math';

import 'package:beathub/classes/enums.dart';
import 'package:beathub/classes/album.dart';
import 'package:beathub/classes/song.dart';

class Queue {
  int index = -1;
  List<Song> songs = [];

  Repeating repeat = Repeating.repeat;
  bool shuffled = false;
  Play play = Play.notStarted;

  Duration? duration;
  Duration? _position;
  Duration get position {
    if (_position == null) {
      return Duration.zero;
    }

    if (_position! > (duration ?? Duration.zero)) {
      return duration ?? Duration.zero;
    }
    return _position ?? Duration.zero;
  }

  set position(Duration? value) {
    _position = value;
  }

  Album? linkedAlbum;

  Queue();

  static Queue fromAlbum(Album album) {
    Queue queue = Queue();
    queue.linkedAlbum = album;
    queue.songs.addAll(album.songs);
    return queue;
  }

  void add(Song song) => songs.add(song);

  void updateIndex(Song song) => index = songs.indexOf(song);

  Song get(int index) => songs[index];

  Song? getCurrent() => isStarted() ? get(index) : null;

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

  void shuffle() {
    shuffled = !shuffled;

    Song? current = getCurrent();

    if (shuffled) {
      songs.shuffle(Random());
    } else if (linkedAlbum != null) {
      songs = [...linkedAlbum!.songs];
    }

    index = songs.indexOf(current!);
  }

  int getCount() => songs.length;

  bool isCurrent(int index) => this.index == index;
  bool isStarted() => index != -1;
  bool isFirst() => isCurrent(0);
  bool isLast() => isCurrent(songs.length - 1);
}