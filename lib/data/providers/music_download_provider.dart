import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:nitrax/config/services/remote/api_service.dart';
import 'package:nitrax/data/models/music.dart';

class DownloadMusicProvider with ChangeNotifier {
  bool isDownloading = false;
  int currentDownloadingId = 0;
  int _downloadProgress = 0;

  get getDownloadProgress => _downloadProgress;

  Future<void> downloadMusic(Music music) async {
    isDownloading = true;
    notifyListeners();
    currentDownloadingId = music.id;

    await ApiService.downloadMedia(
      music,
      (count, total) {
        if (total != -1) {
          final progress = (count / total * 100).toStringAsFixed(0);
          _downloadProgress = int.parse(progress);
          print('Download progress: $progress%');
          notifyListeners();
        }
      },
      '.mp3',
      CancelToken(),
    );

    currentDownloadingId = 0;

    isDownloading = false;

    notifyListeners();
  }
}
