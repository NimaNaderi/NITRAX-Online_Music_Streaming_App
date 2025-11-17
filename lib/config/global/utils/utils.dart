import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/data/models/music.dart';

class Utils {
  static bool isMusicInStorage(Music music) {
    return File(musicFilePathGenerator(music)).existsSync();
  }

  static String musicFilePathGenerator(Music music) =>
      "${AppConstants.appDownloadedMediaPath}/audio/${music.artist} - ${music.song}.mp3";
}

class SlideAndFadePageRoute extends PageRouteBuilder {
  final Widget page;
  SlideAndFadePageRoute({required this.page})
    : super(
        pageBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) => page,

        transitionDuration: const Duration(milliseconds: 700),
        transitionsBuilder:
            (
              BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child,
            ) {
              var slideAnimation =
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0), // شروع از پایین صفحه
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  );

              var fadeAnimation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(animation);

              return FadeTransition(
                opacity: fadeAnimation,
                child: SlideTransition(position: slideAnimation, child: child),
              );
            },
      );
}
