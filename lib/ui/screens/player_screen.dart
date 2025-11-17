import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/config/global/utils/utils.dart';
import 'package:nitrax/data/models/position.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/data/providers/music_download_provider.dart';
import 'package:nitrax/data/providers/music_list_provider.dart';
import 'package:nitrax/ui/widgets/music_swipper.dart';
import 'package:nitrax/ui/widgets/video_player.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:skeletons/skeletons.dart';
import 'package:zo_animated_border/widget/zo_breathing_border.dart';

class PlayerScreen extends StatefulWidget {
  PlayerScreen({super.key});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  late final CurrentMusicProvider _currentMusicProvider;
  bool showJustVideo = false;

  @override
  void initState() {
    super.initState();

    _currentMusicProvider = Provider.of<CurrentMusicProvider>(
      context,
      listen: false,
    );

    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_currentMusicProvider.currentMusicList.length < 5) {
      return;
    }
    double currentPixels = _scrollController.position.pixels;

    double maxScroll = _scrollController.position.maxScrollExtent;

    double percentage = (maxScroll > 0) ? (currentPixels / maxScroll) * 100 : 0;

    if (percentage >
            calculateTargetPercentage(
              _currentMusicProvider.currentMusicList.length,
            ) &&
        !_currentMusicProvider.showingSwipeable) {
      _currentMusicProvider.setShowSwipeable(true);
    } else if (percentage <
            calculateTargetPercentage(
              _currentMusicProvider.currentMusicList.length,
            ) &&
        _currentMusicProvider.showingSwipeable) {
      _currentMusicProvider.setShowSwipeable(false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();

    _currentMusicProvider.setShowSwipeable(false, notify: false);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musicListProvider = Provider.of<MusicListProvider>(context);
    final currentMusicProvider = Provider.of<CurrentMusicProvider>(context);
    final downloadMusicProvider = Provider.of<DownloadMusicProvider>(context);

    return AnimatedContainer(
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            currentMusicProvider.stringToColor(
              currentMusicProvider.currentMusic!.bg_colors[0],
              0.45,
            ),
            Color.fromARGB(255, 42, 42, 42),
          ],
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      if (currentMusicProvider.currentMusic!.videoCover !=
                          null) ...{
                        Stack(
                          children: [
                            CachedNetworkImage(
                              placeholder: (context, url) => Align(
                                child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              imageUrl:
                                  currentMusicProvider.currentMusic!.videoCover,
                              fit: BoxFit.cover,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                            ),
                          ],
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF191A1E),
                                Colors.black.withOpacity(.28),
                              ],

                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              stops: [
                                0.0,
                                currentMusicProvider.currentMusic!.videoCover !=
                                        null
                                    ? 0.5
                                    : 0.2,
                              ],
                            ),
                          ),
                        ),
                      },
                      Column(
                        children: [
                          SizedBox(height: 42),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    Iconsax.arrow_up4,
                                    size: 32,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),

                                Column(
                                  children: [
                                    Consumer<CurrentMusicProvider>(
                                      builder: (context, provider, child) {
                                        return Text(
                                          provider.isVideoMode
                                              ? "VIDEO"
                                              : tr('now_playing_music'),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                    Consumer<CurrentMusicProvider>(
                                      builder: (context, value, child) {
                                        return Row(
                                          children: [
                                            Icon(
                                              Iconsax.speaker,
                                              size: 14,
                                              color: Colors.white60,
                                            ),
                                            SizedBox(width: 2),
                                            Text(
                                              value.currentDeviceName,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white60,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ],
                                ),

                                Spacer(),

                                Consumer<CurrentMusicProvider>(
                                  builder: (context, provider, child) {
                                    if (currentMusicProvider
                                            .currentMusic!
                                            .videoLink !=
                                        null) {
                                      return IconButton(
                                        onPressed: () {
                                          currentMusicProvider
                                              .changeMediaType();
                                        },
                                        icon: Icon(
                                          provider.isVideoMode
                                              ? Iconsax.music
                                              : Iconsax.video,
                                          size: 28,
                                        ),
                                      );
                                    } else {
                                      return SizedBox(width: 48);
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                          Consumer<CurrentMusicProvider>(
                            builder: (context, provider, child) {
                              return Column(
                                children: [
                                  Opacity(
                                    opacity:
                                        currentMusicProvider
                                                .currentMusic!
                                                .videoCover !=
                                            null
                                        ? 0
                                        : 1,
                                    child: ZoBreathingBorder(
                                      borderWidth: .7,
                                      animationDuration: Duration(seconds: 4),
                                      colors: [
                                        Colors.red.withAlpha(110),
                                        AppConstants.primaryColor.withAlpha(
                                          110,
                                        ),
                                        Colors.green.withAlpha(110),
                                        Colors.yellow.withAlpha(110),
                                        Colors.pink.withAlpha(110),
                                        Colors.orange.withAlpha(110),
                                        Colors.deepPurpleAccent.withAlpha(110),
                                      ],
                                      borderRadius: BorderRadius.circular(18),
                                      child: Card(
                                        child: !provider.isVideoMode
                                            ? Stack(
                                                alignment: Alignment.topCenter,
                                                clipBehavior: Clip.none,
                                                children: [
                                                  Container(
                                                    height: 340,
                                                    width: 340,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image:
                                                            CachedNetworkImageProvider(
                                                              provider
                                                                  .currentMusic!
                                                                  .photo,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: -14,
                                                    right: 0,
                                                    child: Container(
                                                      width: 36,
                                                      height: 36,
                                                      decoration: BoxDecoration(
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color:
                                                                const Color.fromARGB(
                                                                  255,
                                                                  62,
                                                                  59,
                                                                  59,
                                                                ),
                                                            blurRadius: 2,
                                                            spreadRadius: 1,
                                                          ),
                                                        ],
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              222,
                                                            ),
                                                      ),
                                                      child: Center(
                                                        child: Consumer<CurrentMusicProvider>(
                                                          builder:
                                                              (
                                                                context,
                                                                provider,
                                                                child,
                                                              ) {
                                                                if (currentMusicProvider
                                                                    .isMusicInFavorites()) {
                                                                  return GestureDetector(
                                                                    onTap: () {
                                                                      currentMusicProvider
                                                                          .addOrRemoveCurrentToFavorite();
                                                                    },
                                                                    child: Image.asset(
                                                                      'assets/images/heart.png',
                                                                      height:
                                                                          20,
                                                                    ),
                                                                  );
                                                                } else {
                                                                  return Center(
                                                                    child: IconButton(
                                                                      onPressed: () {
                                                                        currentMusicProvider
                                                                            .addOrRemoveCurrentToFavorite();
                                                                      },
                                                                      icon: Icon(
                                                                        Iconsax
                                                                            .heart,
                                                                        size:
                                                                            22,
                                                                        color: Colors
                                                                            .black,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : SizedBox(
                                                height: 340,
                                                width: 340,
                                                child: VideoScreen(
                                                  url: provider
                                                      .currentMusic!
                                                      .videoLink,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 34),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            if (currentMusicProvider
                                                    .currentMusic!
                                                    .videoCover !=
                                                null) ...{
                                              Container(
                                                margin: EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Card(
                                                  elevation: 14,
                                                  color: Colors.transparent,
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                    child: CachedNetworkImage(
                                                      width: 44,
                                                      height: 44,
                                                      fit: BoxFit.cover,
                                                      placeholder: (context, url) =>
                                                          const SkeletonAvatar(),
                                                      imageUrl:
                                                          currentMusicProvider
                                                              .currentMusic!
                                                              .photo,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            },
                                            SizedBox(
                                              width: 240,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    provider.currentMusic!.song,
                                                    style: TextStyle(
                                                      height: 1.4,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    provider
                                                        .currentMusic!
                                                        .artist,
                                                    style: TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 16,

                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Spacer(),

                                        Consumer<DownloadMusicProvider>(
                                          builder: (context, value, child) {
                                            if (Utils.isMusicInStorage(
                                                  currentMusicProvider
                                                      .currentMusic!,
                                                ) &&
                                                !downloadMusicProvider
                                                    .isDownloading) {
                                              return Container(
                                                height: 34,
                                                width: 34,
                                                margin: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black,
                                                      blurRadius: 2.2,
                                                    ),
                                                  ],
                                                  color:
                                                      AppConstants.primaryColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                        2000,
                                                      ),
                                                ),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.check,
                                                    size: 26,
                                                  ),
                                                ),
                                              );
                                            }

                                            if (!Utils.isMusicInStorage(
                                                  currentMusicProvider
                                                      .currentMusic!,
                                                ) &&
                                                !downloadMusicProvider
                                                    .isDownloading) {
                                              return Container(
                                                height: 34,
                                                width: 34,
                                                margin: EdgeInsets.only(
                                                  bottom: 4,
                                                  right: 10,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    downloadMusicProvider
                                                        .downloadMusic(
                                                          currentMusicProvider
                                                              .currentMusic!,
                                                        );
                                                  },
                                                  child: Icon(
                                                    Icons.downloading,
                                                    color: Colors.white70,
                                                    size: 36,
                                                  ),
                                                ),
                                              );
                                            }

                                            if (downloadMusicProvider
                                                    .isDownloading &&
                                                currentMusicProvider
                                                        .currentMusic!
                                                        .id ==
                                                    downloadMusicProvider
                                                        .currentDownloadingId) {
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: CircularPercentIndicator(
                                                  radius: 20,
                                                  curve: Curves.easeIn,
                                                  backgroundColor:
                                                      const Color.fromARGB(
                                                        255,
                                                        23,
                                                        101,
                                                        165,
                                                      ),
                                                  percent:
                                                      downloadMusicProvider
                                                          .getDownloadProgress /
                                                      100,
                                                  progressColor: Colors.blue,
                                                  center: Text(
                                                    '${downloadMusicProvider.getDownloadProgress}%',
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            }

                                            return SizedBox();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          SizedBox(height: 24),
                          StreamBuilder<PositionData>(
                            stream: currentMusicProvider.positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: ProgressBar(
                                  thumbRadius: 9,
                                  timeLabelTextStyle: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                  timeLabelPadding: 4,
                                  barHeight: 5.5,
                                  baseBarColor: Colors.white,

                                  bufferedBarColor: AppConstants.primaryColor
                                      .withAlpha(160),
                                  progressBarColor: Colors.blue,
                                  thumbColor: Colors.blue,
                                  progress:
                                      positionData?.position ?? Duration.zero,
                                  total:
                                      positionData?.duration ?? Duration.zero,
                                  buffered:
                                      positionData?.bufferedPosition ??
                                      Duration.zero,
                                  onSeek:
                                      currentMusicProvider.getAudioPlayer.seek,
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 10),

                          Padding(
                            padding: const EdgeInsets.only(right: 38, left: 34),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  child: Consumer<CurrentMusicProvider>(
                                    builder: (context, currentProvider, child) {
                                      return IconButton(
                                        icon: Icon(
                                          Iconsax.shuffle,
                                          size: 30,
                                          color:
                                              currentProvider
                                                  .isShuffelModeEnabled
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                        onPressed: () {
                                          currentMusicProvider
                                              .changeShuffelMode();
                                        },
                                      );
                                    },
                                  ),
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    if (currentMusicProvider.isPlayingFromNew) {
                                      if (currentMusicProvider.currentIndex ==
                                          0) {
                                        return;
                                      }
                                      int nextSong =
                                          currentMusicProvider.currentIndex! -
                                          1;
                                      currentMusicProvider.currentIndex =
                                          nextSong;

                                      currentMusicProvider.setNewMusic =
                                          musicListProvider
                                              .getNewMusicsList[nextSong];
                                    } else {
                                      if (currentMusicProvider.currentIndex ==
                                          0) {
                                        return;
                                      }
                                      int nextSong =
                                          currentMusicProvider.currentIndex! -
                                          1;
                                      currentMusicProvider.currentIndex =
                                          nextSong;

                                      currentMusicProvider.setNewMusic =
                                          currentMusicProvider
                                              .currentMusicList[nextSong];
                                    }

                                    currentMusicProvider.changeLoopMode(true);

                                    currentMusicProvider.getAudioPlayer
                                        .seekToPrevious();
                                  },
                                  child: Icon(
                                    Iconsax.backward,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),

                                SizedBox(width: 20),

                                SizedBox(
                                  width: 66,
                                  height: 66,
                                  child: StreamBuilder<PlayerState>(
                                    stream: currentMusicProvider
                                        .getAudioPlayer
                                        .playerStateStream,
                                    builder: (context, snapshot) {
                                      final playerState = snapshot.data;
                                      final processingState =
                                          playerState?.processingState;
                                      final playing = playerState?.playing;

                                      if ((processingState ==
                                              ProcessingState.buffering ||
                                          processingState ==
                                              ProcessingState.loading)) {
                                        return SizedBox(
                                          height: 42,
                                          width: 42,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                              color: Colors.white,
                                            ),
                                          ),
                                        );
                                      }
                                      if (!(playing ?? false)) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 2,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(300),
                                              color: AppConstants.primaryColor,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                currentMusicProvider
                                                    .getAudioPlayer
                                                    .play();
                                                currentMusicProvider
                                                    .changePlayingState();
                                              },
                                              iconSize: 32,
                                              icon: const Icon(
                                                Iconsax.play,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      } else if (processingState !=
                                          ProcessingState.completed) {
                                        return Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black87,
                                                  blurRadius: 2,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                              borderRadius:
                                                  BorderRadius.circular(300),
                                              color: AppConstants.primaryColor,
                                            ),
                                            child: IconButton(
                                              onPressed: () {
                                                currentMusicProvider
                                                    .getAudioPlayer
                                                    .pause();
                                                currentMusicProvider
                                                    .changePlayingState();
                                              },
                                              iconSize: 32,
                                              icon: const Icon(
                                                Iconsax.pause,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              300,
                                            ),
                                            color: Colors.blue,
                                          ),

                                          child: IconButton(
                                            onPressed: currentMusicProvider
                                                .getAudioPlayer
                                                .load,
                                            iconSize: 32,
                                            color: Colors.white,
                                            icon: const Icon(Iconsax.play),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                SizedBox(width: 20),

                                GestureDetector(
                                  onTap: () {
                                    if (currentMusicProvider.isPlayingFromNew) {
                                      if (currentMusicProvider.currentIndex ==
                                          musicListProvider
                                                  .getNewMusicsList
                                                  .length -
                                              1) {
                                        return;
                                      }
                                      int nextSong =
                                          currentMusicProvider.currentIndex! +
                                          1;
                                      currentMusicProvider.currentIndex =
                                          nextSong;

                                      currentMusicProvider.setNewMusic =
                                          musicListProvider
                                              .getNewMusicsList[nextSong];
                                    } else {
                                      if (currentMusicProvider.currentIndex ==
                                          musicListProvider
                                                  .getSearchedMusicsList
                                                  .length -
                                              1) {
                                        return;
                                      }
                                      int nextSong =
                                          currentMusicProvider.currentIndex! +
                                          1;
                                      currentMusicProvider.currentIndex =
                                          nextSong;

                                      currentMusicProvider.setNewMusic =
                                          currentMusicProvider
                                              .currentMusicList[nextSong];
                                    }

                                    currentMusicProvider.changeLoopMode(true);

                                    currentMusicProvider.getAudioPlayer
                                        .seekToNext();
                                  },
                                  child: Icon(
                                    Iconsax.forward,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                SizedBox(
                                  width: 30,
                                  child: Consumer<CurrentMusicProvider>(
                                    builder: (context, currentProvider, child) {
                                      return IconButton(
                                        icon: Icon(
                                          Iconsax.repeat,
                                          size: 30,
                                          color:
                                              currentProvider.isLoopModeEnabled
                                              ? Colors.blue
                                              : Colors.white,
                                        ),
                                        onPressed: () {
                                          currentMusicProvider.changeLoopMode(
                                            false,
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                          SizedBox(height: 50),
                          Row(
                            children: [
                              SizedBox(width: 22),
                              Text(
                                tr('current_playlist'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 6),
                        ],
                      ),
                    ],
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    return Consumer<CurrentMusicProvider>(
                      builder: (context, currentProvider, child) =>
                          GestureDetector(
                            onTap: () {
                              if (currentProvider.currentMusic ==
                                  currentProvider.currentMusicList[index]) {
                                _scrollController.animateTo(
                                  0,
                                  duration: Duration(seconds: 2),
                                  curve: Curves.ease,
                                );
                              } else {
                                currentMusicProvider.isPlayingFromNew = false;

                                currentMusicProvider.currentMusicList =
                                    currentMusicProvider.currentMusicList;
                                currentMusicProvider.setPlaylist(
                                  currentMusicProvider.currentMusicList,
                                  index,
                                );

                                // currentMusicProvider.getAudioPlayer.play();

                                currentMusicProvider.setNewMusic =
                                    currentMusicProvider
                                        .currentMusicList[index];
                                currentMusicProvider.currentIndex = index;
                              }
                            },
                            child: Container(
                              color:
                                  currentMusicProvider
                                          .currentMusic!
                                          .videoCover !=
                                      null
                                  ? Color(0xFF191A1E)
                                  : Colors.transparent,
                              child: Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(10),
                                    height: 100,
                                    child: Card(
                                      elevation: 6,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          15.0,
                                        ),
                                        side: BorderSide(
                                          width: 2,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: EdgeInsetsGeometry.all(6),
                                        child: Row(
                                          children: [
                                            Card(
                                              elevation: 14,
                                              color: Colors.transparent,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: CachedNetworkImage(
                                                  width: 72,
                                                  height: 72,
                                                  fit: BoxFit.cover,
                                                  placeholder: (context, url) =>
                                                      const SkeletonAvatar(),
                                                  imageUrl: currentMusicProvider
                                                      .currentMusicList[index]
                                                      .photo,
                                                ),
                                              ),
                                            ),

                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                  ),
                                              width: 180,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    currentMusicProvider
                                                        .currentMusicList[index]
                                                        .song,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    currentMusicProvider
                                                        .currentMusicList[index]
                                                        .artist,
                                                    maxLines: 1,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const Spacer(),
                                            if (currentProvider.currentMusic !=
                                                    null &&
                                                currentProvider
                                                        .currentMusic!
                                                        .id ==
                                                    currentProvider
                                                        .currentMusicList[index]
                                                        .id)
                                              Lottie.asset(
                                                'assets/animations/wave-anim.json',
                                                animate: currentProvider
                                                    .getAudioPlayer
                                                    .playing,
                                                height: 36,
                                                addRepaintBoundary: true,
                                                reverse: true,
                                                frameRate: FrameRate(144),
                                                filterQuality:
                                                    FilterQuality.high,
                                              )
                                            else
                                              const Icon(Iconsax.music),

                                            const SizedBox(width: 12),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (currentMusicProvider
                                      .isSpecificMusicInFavorites(
                                        currentProvider.currentMusicList[index],
                                      )) ...{
                                    Positioned(
                                      top: -4,
                                      right:
                                          currentProvider
                                                  .currentMusicList[index]
                                                  .videoLink !=
                                              null
                                          ? 60
                                          : 24,
                                      child: Card(
                                        elevation: 10,
                                        color: const Color.fromARGB(
                                          255,
                                          195,
                                          38,
                                          93,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Icon(
                                            Iconsax.heart,
                                            size: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                                  if (musicListProvider
                                          .getNewMusicsList[index]
                                          .videoLink !=
                                      null) ...{
                                    Positioned(
                                      top: -4,
                                      right: 24,
                                      child: Card(
                                        elevation: 10,
                                        color: const Color.fromARGB(
                                          255,
                                          204,
                                          204,
                                          204,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: SizedBox(
                                          width: 28,
                                          height: 28,
                                          child: Icon(
                                            Iconsax.video,
                                            size: 18,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  },
                                ],
                              ),
                            ),
                          ),
                    );
                  }, childCount: currentMusicProvider.currentMusicList.length),
                ),
              ],
            ),

            GestureDetector(
              onTap: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(seconds: 2),
                  curve: Curves.ease,
                );
              },
              child: Selector<CurrentMusicProvider, bool>(
                builder: (context, value, child) => AnimatedOpacity(
                  duration: Duration(milliseconds: 400),
                  opacity: currentMusicProvider.showingSwipeable ? 1 : 0,
                  child: Visibility(
                    visible: currentMusicProvider.showingSwipeable,
                    child: SwipeablePlayerBar(
                      needsPadding: true,
                      radiusFromTop: false,
                      playlist: currentMusicProvider.currentMusicList,
                      initialIndex: currentMusicProvider.currentIndex!,
                    ),
                  ),
                ),
                selector: (p0, p1) => p1.showingSwipeable,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

double calculateTargetPercentage(int totalItemCount) {
  const int targetItemIndex = 6;

  if (totalItemCount <= 1) {
    return 0.0;
  }

  final double percentage = (targetItemIndex / (totalItemCount - 1));

  return percentage * 100;
}
