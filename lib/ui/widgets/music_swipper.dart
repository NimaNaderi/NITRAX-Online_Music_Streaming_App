import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:nitrax/data/models/music.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:provider/provider.dart';

class SwipeablePlayerBar extends StatefulWidget {
  final List<Music> playlist;
  final int initialIndex;
  final ValueChanged<int>? onSongChanged;
  final VoidCallback? onPlayPauseTapped;
  final PageController? controller;
  final bool radiusFromTop;
  final bool needsPadding;

  const SwipeablePlayerBar({
    super.key,
    required this.playlist,
    required this.radiusFromTop,
    this.initialIndex = 0,
    this.onSongChanged,
    this.onPlayPauseTapped,
    this.controller,
    this.needsPadding = false,
  });

  @override
  State<SwipeablePlayerBar> createState() => _SwipeablePlayerBarState();
}

enum SwipeDirection { left, right, none }

class _SwipeablePlayerBarState extends State<SwipeablePlayerBar>
    with AutomaticKeepAliveClientMixin {
  late final PageController _pageController;
  late int _currentIndex;
  int _dragStartIndex = 0;
  bool _isDragging = false;

  late CurrentMusicProvider _musicProvider;

  void _onProviderUpdate() {
    if (!mounted) return;

    if (_pageController.hasClients &&
        _musicProvider.currentIndex != null &&
        _musicProvider.currentIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(_musicProvider.currentIndex!);
          _currentIndex = _musicProvider.currentIndex!;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController =
        widget.controller ?? PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;

    _musicProvider = context.read<CurrentMusicProvider>();
    _musicProvider.addListener(_onProviderUpdate);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _pageController.dispose();
    }

    _musicProvider.removeListener(_onProviderUpdate);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final currentMusicProvider = Provider.of<CurrentMusicProvider>(context);

    if (widget.playlist.isEmpty) {
      return const SizedBox.shrink();
    }

    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(widget.radiusFromTop ? 20 : 0),
        topRight: Radius.circular(widget.radiusFromTop ? 20 : 0),
        bottomLeft: Radius.circular(widget.radiusFromTop ? 0 : 20),
        bottomRight: Radius.circular(widget.radiusFromTop ? 0 : 20),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),

        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification) {
              _isDragging = true;
              _dragStartIndex = _pageController.page!.round();
            } else if (notification is ScrollEndNotification && _isDragging) {
              final int endIndex = _pageController.page!.round();
              _isDragging = false;

              if (_dragStartIndex != endIndex) {
                WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                  SwipeDirection direction = (endIndex > _dragStartIndex)
                      ? SwipeDirection.left
                      : SwipeDirection.right;

                  if (direction == SwipeDirection.right) {
                    int nextSong = currentMusicProvider.currentIndex! - 1;
                    currentMusicProvider.currentIndex = nextSong;

                    currentMusicProvider.setNewMusic =
                        currentMusicProvider.currentMusicList[nextSong];

                    currentMusicProvider.changeLoopMode(true);

                    currentMusicProvider.getAudioPlayer.seekToPrevious();
                  } else {
                    int nextSong = currentMusicProvider.currentIndex! + 1;
                    currentMusicProvider.currentIndex = nextSong;

                    currentMusicProvider.setNewMusic =
                        currentMusicProvider.currentMusicList[nextSong];

                    currentMusicProvider.changeLoopMode(true);

                    currentMusicProvider.getAudioPlayer.seekToNext();
                  }
                });
              }
            }
            return true;
          },
          child: AnimatedContainer(
            padding: EdgeInsets.only(top: widget.needsPadding ? 36 : 0),
            duration: Duration(seconds: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  currentMusicProvider.stringToColor(
                    currentMusicProvider.currentMusic!.bg_colors[0],
                    0.55,
                  ),
                  Color.fromARGB(255, 48, 48, 48),
                ],
              ),
            ),
            child: SizedBox(
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.playlist.length,
                      itemBuilder: (context, index) {
                        return Consumer<CurrentMusicProvider>(
                          builder: (context, value, child) {
                            print(index);
                            return AnimatedBuilder(
                              animation: _pageController,
                              builder: (context, child) {
                                double opacity = 1.0;
                                if (_pageController.position.haveDimensions) {
                                  double page = _pageController.page ?? 0.0;
                                  double pageOffset = page - index;
                                  opacity = 1.0 - pageOffset.abs().clamp(0, 1);
                                }
                                return Opacity(opacity: opacity, child: child);
                              },
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),

                                    child: CachedNetworkImage(
                                      imageUrl: currentMusicProvider
                                          .currentMusicList[index]
                                          .photo,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          widget.playlist[index].song,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          widget.playlist[index].artist,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: StreamBuilder<PlayerState>(
                          stream: currentMusicProvider
                              .getAudioPlayer
                              .playerStateStream,
                          builder: (context, asyncSnapshot) {
                            final playerState = asyncSnapshot.data;
                            final processingState =
                                playerState?.processingState;

                            final playing = playerState?.playing;

                            if ((processingState == ProcessingState.buffering ||
                                processingState == ProcessingState.loading)) {
                              return Container(
                                margin: EdgeInsets.only(right: 10),
                                height: 24,
                                width: 24,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            }

                            return IconButton(
                              onPressed: () {
                                if (currentMusicProvider
                                    .getAudioPlayer
                                    .playing) {
                                  currentMusicProvider.getAudioPlayer.pause();
                                } else {
                                  currentMusicProvider.getAudioPlayer.play();
                                }

                                currentMusicProvider.changePlayingState();
                              },
                              iconSize: 30,
                              icon: Icon(
                                color: Colors.white,
                                playing == true ? Iconsax.pause : Iconsax.play,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
