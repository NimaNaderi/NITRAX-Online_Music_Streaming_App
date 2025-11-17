import 'dart:io';

import 'package:dio/dio.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:nitrax/config/global/constants/api_constants.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/data/models/music.dart';
import 'package:permission_handler/permission_handler.dart';

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: ApiConstants.apiUrl));

  static Future<List<Music>> getMusicFromServer(String musicName) async {
    try {
      var response = await _dio.get('&q=$musicName&action=search&');

      List<Music> musicList = response.data['result']['top']
          .map<Music>((jsonMapObject) => Music.fromJson(jsonMapObject))
          .toList();

      return musicList;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Music>> getCustomMusicsFromServer(String musicName) async {
    try {
      var response = await Dio().get(
        'https://php-03sijn.chbk.app/api.php?q=$musicName',
      );

      List<Music> musicList = response.data['data']
          .map<Music>((jsonMapObject) => Music.fromJson(jsonMapObject))
          .toList();

      musicList.forEach(
        (element) => element.bg_colors = ["#412511", "#412511"],
      );

      return musicList;
    } catch (e) {
      return [];
    }
  }

  static Future<List<Music>> getNewMusics() async {
    try {
      var response = await _dio.get('&action=new_songs');

      List<Music> musicList = response.data['result']
          .map<Music>((jsonMapObject) => Music.fromJson(jsonMapObject))
          .toList();

      return musicList;
    } catch (e) {
      return [];
    }
  }

  static Future<void> downloadMedia(
    Music music,
    Function(int count, int total) onReceiveProgress,
    String mediaFormat,
    CancelToken cancelToken,
  ) async {
    // if (mediaFormat == '.mp4') {
    //   await Utils.requestMainPermissions();
    // }

    await createDirectory(".mp3");

    if (!await checkIfFileExistsAlready(music, ".mp3")) {
      await _dio.download(
        music.audioLink,
        '${AppConstants.appDownloadedMediaPath}/${getDirectoryNameByMediaFormat(".mp3")}/${music.artist} - ${music.song}.mp3',
        onReceiveProgress: (count, total) {
          onReceiveProgress(count, total);
        },
        cancelToken: cancelToken,
        deleteOnError: true,
      );

      await MediaScanner.loadMedia(
        path: "${AppConstants.appDownloadedMediaPath}/",
      );
    }
  }

  static Future<bool> checkIfFileExistsAlready(
    Music music,
    String mediaType,
  ) => File(
    '${AppConstants.appDownloadedMediaPath}/${getDirectoryNameByMediaFormat(".mp3")}/${music.artist} - ${music.song}.mp3',
  ).exists();

  static Future<void> createDirectory(String dirName) async {
    if (!await Directory(AppConstants.appDownloadedMediaPath).exists()) {
      await Directory(AppConstants.appDownloadedMediaPath).create();
    }

    if (!await Directory(
      '${AppConstants.appDownloadedMediaPath}/$dirName',
    ).exists()) {
      await Directory(
        '${AppConstants.appDownloadedMediaPath}/$dirName',
      ).create();
    }
  }

  static String getDirectoryNameByMediaFormat(String mediaFormat) =>
      mediaFormat == '.mp4' ? 'video' : 'audio';

  static Future<bool> requestMainPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
      Permission.manageExternalStorage,
    ].request();

    if (statuses[Permission.storage]!.isDenied ||
        statuses[Permission.manageExternalStorage]!.isDenied) {
      return false;
    }
    return true;
  }
}
