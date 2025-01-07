import 'package:beathub/classes/observer.dart';

typedef TrackIndexFunction = void Function(int index, { bool byScroll });

class TrackIndexObserver extends Observer<TrackIndexFunction> {
  static final TrackIndexObserver _instance = TrackIndexObserver._internal();
  TrackIndexObserver._internal();
  factory TrackIndexObserver() {
    return _instance;
  }

  void changeTrack(int index, { bool byScroll = false }) {
    for (TrackIndexFunction listener in listeners) {
      listener(index, byScroll: byScroll);
    }
  }
}