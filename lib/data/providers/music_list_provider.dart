import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nitrax/config/services/remote/api_service.dart';
import 'package:nitrax/data/models/music.dart';

class MusicListProvider with ChangeNotifier {
  List<Music> _musicList = [];
  List<Music> _newMusicsList = [];
  var latestMusicListBox = Hive.box('latestMusicListBox');

  bool _isLoading = false;
  bool _isNewLoading = false;

  bool get isLoading => _isLoading;
  bool get isNewLoading => _isNewLoading;
  List<Music> get getSearchedMusicsList => _musicList;
  List<Music> get getNewMusicsList => _newMusicsList;

  set isLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  List<Music> getCachedNewMusicsList() {
    final List list = latestMusicListBox.get(3) ?? [];
    List<Music> musics = list.cast<Music>();

    if (list.isEmpty) {
      musics = [];
    }

    return musics;
  }

  List<Music> getRecentlySearchedMusicsList() {
    final List list = latestMusicListBox.get(4) ?? [];
    List<Music> musics = list.cast<Music>();

    if (list.isEmpty) {
      musics = [];
    }

    return musics;
  }

  Future<void> fetchSearchedMusicsList(String query, bool custom) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (custom) {
        _musicList = await ApiService.getCustomMusicsFromServer(query);
      } else {
        _musicList = await ApiService.getMusicFromServer(query);
      }

      _musicList = mergedMusics(_musicList)
          .where((element) => element.type == "mp3" && element.artist != null)
          .toList();

      if (_musicList.isNotEmpty) {}
    } catch (e) {
      throw (e.toString());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNewMusicsList(bool checkCache) async {
    List<Music> updatedNewMusicsList = [];

    if (getCachedNewMusicsList().isEmpty || !checkCache) {
      _isNewLoading = true;
      notifyListeners();
    } else {
      _newMusicsList = getCachedNewMusicsList();
      notifyListeners();
    }

    try {
      updatedNewMusicsList = await ApiService.getNewMusics();

      if (updatedNewMusicsList.isNotEmpty) {
        _newMusicsList = mergedMusics(updatedNewMusicsList)
            .where((element) => element.type == "mp3" && element.artist != null)
            .toList();

        latestMusicListBox.put(3, updatedNewMusicsList);
      }
    } catch (e) {
      throw (e.toString());
    } finally {
      if (updatedNewMusicsList.isEmpty && getCachedNewMusicsList().isNotEmpty) {
        _newMusicsList = getCachedNewMusicsList();
      }
      _isNewLoading = false;
      notifyListeners();
    }
  }

  void rebuildWidgets() {
    notifyListeners();
  }
}

List<Music> mergedMusics(List<Music> musicList) {
  Map<String, Music> processedMusics = {};

  for (final currentMusic in musicList) {
    final compositeKey = '${currentMusic.song}_${currentMusic.artist}';

    if (processedMusics.containsKey(compositeKey)) {
      final existingMusic = processedMusics[compositeKey]!;

      if (currentMusic.type == 'video') {
        existingMusic.videoLink = currentMusic.audioLink;
      } else {
        currentMusic.videoLink = existingMusic.audioLink;
        processedMusics[compositeKey] = currentMusic;
      }
    } else {
      processedMusics[compositeKey] = currentMusic;
    }
  }

  return processedMusics.values.toList();
}
