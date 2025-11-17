import 'dart:ui';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/data/models/music.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nitrax/data/models/position.dart';
import 'package:rxdart/streams.dart';

class CurrentMusicProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();

  var musicBox = Hive.box<Music>('musicBox');
  var latestMusicListBox = Hive.box('latestMusicListBox');

  Music? currentMusic = null;
  int? currentIndex = null;
  bool showingSwipeable = false;
  bool isShuffelModeEnabled = false;
  bool isPlayingFromNew = true;
  bool isLoopModeEnabled = false;
  bool isVideoMode = false;
  String _currentDeviceName = "";
  List<Music> currentMusicList = [];
  List<int> indexes = [];
  AudioPlayer get getAudioPlayer => _audioPlayer;
  String get currentDeviceName => _currentDeviceName;

  set setNewMusic(Music newMusic) {
    currentMusic = newMusic;
    notifyListeners();
  }

  void setShowSwipeable(bool showing, {bool notify = true}) {
    showingSwipeable = showing;

    if (notify) {
      notifyListeners();
    }
  }

  Color stringToColor(String color, double amount) {
    return Color.lerp(
      Color(int.parse("0xff${color.split('#')[1]}")),
      Colors.black,
      amount,
    )!;
  }

  void removeCurrentFromFavorite() async {
    await musicBox.values
        .toList()
        .firstWhere((element) => element.id == currentMusic!.id)
        .delete();

    notifyListeners();
  }

  void removeSpecificMusicFromFavorite(Music music) async {
    await musicBox.values
        .toList()
        .firstWhere((element) => element.id == music.id)
        .delete();

    notifyListeners();
  }

  void addOrRemoveCurrentToFavorite() async {
    if (!musicBox.values.toList().any(
      (element) => element.id == currentMusic!.id,
    )) {
      await musicBox.add(currentMusic!);
      print("add ${currentMusic!.song}");
    } else {
      await musicBox.values
          .toList()
          .firstWhere((element) => element.id == currentMusic!.id)
          .delete();
    }

    notifyListeners();
  }

  List<Music> getFavoriteMusics() => musicBox.values.toList();

  Stream<PositionData> get positionDataStream => CombineLatestStream.combine3(
    getAudioPlayer.positionStream,
    getAudioPlayer.bufferedPositionStream,
    getAudioPlayer.durationStream,
    (a, b, c) => PositionData(a, b, c ?? Duration.zero),
  );

  void changeMediaType() {
    if (isVideoMode) {
      isVideoMode = false;
    } else {
      isVideoMode = true;
    }

    notifyListeners();
  }

  bool isMusicInFavorites() {
    if (musicBox.values.toList().any(
      (element) => element.id == currentMusic!.id,
    )) {
      return true;
    } else {
      return false;
    }
  }

  bool isSpecificMusicInFavorites(Music music) {
    if (musicBox.values.toList().any((element) => element.id == music.id)) {
      return true;
    } else {
      return false;
    }
  }

  void changeShuffelMode() {
    isLoopModeEnabled = false;
    getAudioPlayer.setLoopMode(LoopMode.off);

    if (isShuffelModeEnabled) {
      getAudioPlayer.setShuffleModeEnabled(false);
      isShuffelModeEnabled = false;
    } else {
      getAudioPlayer.setShuffleModeEnabled(true);
      isShuffelModeEnabled = true;
    }

    notifyListeners();
  }

  void changePlayingState() {
    notifyListeners();
  }

  void changeLoopMode(bool off) {
    getAudioPlayer.setShuffleModeEnabled(false);
    isShuffelModeEnabled = false;

    if (isLoopModeEnabled) {
      isLoopModeEnabled = false;
      getAudioPlayer.setLoopMode(LoopMode.off);
    } else {
      isLoopModeEnabled = true;
      getAudioPlayer.setLoopMode(LoopMode.one);
    }

    if (off) {
      isLoopModeEnabled = false;
      getAudioPlayer.setLoopMode(LoopMode.off);
    }

    notifyListeners();
  }

  void setPlaylist(List<Music> musicList, int newIndex) async {
    AppConstants.isPlayerNull = false;

    List<AudioSource> playlist = musicList.map((e) {
      return AudioSource.uri(
        Uri.parse(e.audioLink),
        tag: MediaItem(
          id: e.id.toString(),
          title: e.song,
          artUri: Uri.parse(e.photo),
          duration: Duration(milliseconds: e.duration.round()),
          artist: e.artist,
          playable: true,
        ),
      );
    }).toList();

    // Ändert Playlist, wird abgerufen, wenn sich Playlist ändert
    // Oder der Music zum ersten Mal gespielt wird.

    if (getAudioPlayer.currentIndex == null ||
        (currentMusic != null &&
            currentMusic!.id != currentMusicList[newIndex].id)) {
      getAudioPlayer.setAudioSources(
        playlist,
        preload: true,
        initialIndex: newIndex,
        shuffleOrder: DefaultShuffleOrder(),
      );

      getAudioPlayer.play();
    }

    getAudioPlayer.currentIndexStream.listen((index) {
      if (index != null && index != currentIndex) {
        // Music has been changed when true

        indexes.add(index);
        currentIndex = index;
        currentMusic = currentMusicList[index];

        if (isVideoMode) {
          isVideoMode = false;
          getAudioPlayer.play();
        }

        print("Indexema: ${currentMusicList[index].song} ${index}");

        if (indexes.length == 2) {
          notifyListeners();
          indexes = [];
          latestMusicListBox.put(0, currentMusicList);
          latestMusicListBox.put(1, currentIndex);
        } else if (indexes.length == 1) {
          Future.delayed(Duration(milliseconds: 200), () {
            if (indexes.length == 1) {
              notifyListeners();
              indexes = [];
              latestMusicListBox.put(0, currentMusicList);
              latestMusicListBox.put(1, currentIndex);
            }
          });
        }
      }
    });
    final session = await AudioSession.instance;

    session.devicesStream.listen((e) {
      final deviceName = e.toList().last.name;

      if (deviceName != currentDeviceName) {
        _currentDeviceName = deviceName;
        notifyListeners();
      }
    });
  }

  List<Music> getLatestMusicList() {
    final List list = latestMusicListBox.get(0);
    final List<Music> musics = list.cast<Music>();

    return musics;
  }

  int? getLatestMusicListIndex() => latestMusicListBox.get(1);
  String? getLastDuration() => latestMusicListBox.get(2);
  void setLastDuration(Duration duration) {
    latestMusicListBox.put(2, duration.toString());
  }

  Duration parseDuration(String input) {
    try {
      input = input.trim();

      if (input.contains(':')) {
        List<String> parts = input.split(':');

        int hours = 0;
        int minutes = 0;
        double seconds = 0;

        if (parts.length == 3) {
          hours = int.parse(parts[0]);
          minutes = int.parse(parts[1]);
          seconds = double.parse(parts[2]);
        } else if (parts.length == 2) {
          minutes = int.parse(parts[0]);
          seconds = double.parse(parts[1]);
        } else if (parts.length == 1) {
          seconds = double.parse(parts[0]);
        }

        return Duration(
          hours: hours,
          minutes: minutes,
          milliseconds: (seconds * 1000).round(),
        );
      } else {
        // فقط عدد هست، ممکنه اعشاری باشه (مثل 31.885)
        double seconds = double.parse(input);
        return Duration(milliseconds: (seconds * 1000).round());
      }
    } catch (e) {
      print('❌ Invalid duration format: $input');
      return Duration.zero;
    }
  }
}
