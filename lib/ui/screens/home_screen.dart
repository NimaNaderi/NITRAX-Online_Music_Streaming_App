import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:just_audio/just_audio.dart';
import 'package:lottie/lottie.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/data/providers/music_list_provider.dart';
import 'package:nitrax/ui/screens/player_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin, WidgetsBindingObserver {
  bool isFirst = true;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
    } else if (state == AppLifecycleState.paused) {
      final currentMusicProvider = Provider.of<CurrentMusicProvider>(
        context,
        listen: false,
      );

      currentMusicProvider.setLastDuration(
        currentMusicProvider.getAudioPlayer.position,
      );
    } else if (state == AppLifecycleState.detached) {
      final currentMusicProvider = Provider.of<CurrentMusicProvider>(
        context,
        listen: false,
      );

      currentMusicProvider.setLastDuration(
        currentMusicProvider.getAudioPlayer.position,
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final musicListProvider = Provider.of<MusicListProvider>(
        context,
        listen: false,
      );
      final currentMusicProvider = Provider.of<CurrentMusicProvider>(
        context,
        listen: false,
      );

      // Ladt das letze Lied, das Nutzer gehort hat, bevor sich die App Schliesst.
      if (currentMusicProvider.getLatestMusicListIndex() != null) {
        final lastIndex = currentMusicProvider.getLatestMusicListIndex();
        currentMusicProvider.currentIndex = lastIndex;

        currentMusicProvider.currentMusicList = currentMusicProvider
            .getLatestMusicList();

        currentMusicProvider.setPlaylist(
          currentMusicProvider.getLatestMusicList(),
          lastIndex!,
        );

        currentMusicProvider.setNewMusic = currentMusicProvider
            .getLatestMusicList()[lastIndex];

        await currentMusicProvider.getAudioPlayer.stop();

        currentMusicProvider.getAudioPlayer.processingStateStream.listen((
          event,
        ) async {
          if (event == ProcessingState.ready && isFirst) {
            await currentMusicProvider.getAudioPlayer.seek(
              currentMusicProvider.parseDuration(
                currentMusicProvider.getLastDuration() ?? "0",
              ),
            );
            isFirst = false;
          }
        });
      }
      await musicListProvider.fetchNewMusicsList(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musicListProvider = Provider.of<MusicListProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            musicListProvider.fetchNewMusicsList(false);
          },
          child: MusicList(),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

class MusicList extends StatelessWidget {
  const MusicList({super.key});

  @override
  Widget build(BuildContext context) {
    final musicListProvider = Provider.of<MusicListProvider>(context);
    final currentMusicProvider = Provider.of<CurrentMusicProvider>(context);

    return Consumer<MusicListProvider>(
      builder: (context, provider, child) {
        if (provider.isNewLoading) {
          return SkeletonListView(
            scrollable: false,
            itemCount: 9,
            itemBuilder: (p0, p1) {
              return const SkeletonAvatar(
                style: SkeletonAvatarStyle(
                  // height: 100,
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              );
            },
          );
        } else {
          return ListView.builder(
            itemCount: provider.getNewMusicsList.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) => Consumer<CurrentMusicProvider>(
              builder: (context, currentProvider, child) => GestureDetector(
                onTap: () {
                  currentMusicProvider.isPlayingFromNew = true;

                  currentMusicProvider.currentMusicList =
                      provider.getNewMusicsList;
                  currentMusicProvider.setPlaylist(
                    provider.getNewMusicsList,
                    index,
                  );

                  // currentMusicProvider.getAudioPlayer.play();

                  currentMusicProvider.setNewMusic =
                      provider.getNewMusicsList[index];
                  currentMusicProvider.currentIndex = index;

                  showModalBottomSheet(
                    context: context,
                    sheetAnimationStyle: AnimationStyle(
                      duration: Duration(milliseconds: 800),
                    ),

                    builder: (context) => PlayerScreen(),
                    isScrollControlled: true,
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.all(10),
                      height: 100,
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                          side: BorderSide(width: 2, color: Colors.blue),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.all(6),
                          child: Row(
                            children: [
                              Card(
                                elevation: 14,
                                color: Colors.transparent,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    width: 72,
                                    height: 72,
                                    fadeInDuration: Duration(
                                      milliseconds: 1500,
                                    ),
                                    fadeOutDuration: Duration(
                                      milliseconds: 1500,
                                    ),
                                    fadeInCurve: FlippedCurve(Curves.easeIn),
                                    fadeOutCurve: FlippedCurve(Curves.easeIn),
                                    placeholderFadeInDuration: Duration(
                                      milliseconds: 1500,
                                    ),

                                    errorWidget: (context, url, error) =>
                                        Icon(Iconsax.music),
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        const SkeletonAvatar(),
                                    imageUrl:
                                        provider.getNewMusicsList[index].photo,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                width: 180,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 16),
                                    Text(
                                      provider.getNewMusicsList[index].song,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      provider.getNewMusicsList[index].artist,
                                      maxLines: 1,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        overflow: TextOverflow.ellipsis,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),
                              if (currentProvider.currentMusic != null &&
                                  currentProvider.currentMusic!.id ==
                                      musicListProvider
                                          .getNewMusicsList[index]
                                          .id)
                                Lottie.asset(
                                  'assets/animations/wave-anim.json',
                                  animate:
                                      currentProvider.getAudioPlayer.playing,
                                  height: 36,
                                  addRepaintBoundary: true,
                                  reverse: true,
                                  frameRate: FrameRate(144),
                                  filterQuality: FilterQuality.high,
                                )
                              else
                                const Icon(Iconsax.music),

                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (currentMusicProvider.isSpecificMusicInFavorites(
                      musicListProvider.getNewMusicsList[index],
                    )) ...{
                      Positioned(
                        top: -4,
                        right:
                            musicListProvider
                                    .getNewMusicsList[index]
                                    .videoLink !=
                                null
                            ? 60
                            : 24,
                        child: Card(
                          elevation: 10,
                          color: const Color.fromARGB(255, 195, 38, 93),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
                    if (musicListProvider.getNewMusicsList[index].videoLink !=
                        null) ...{
                      Positioned(
                        top: -4,
                        right: 24,
                        child: Card(
                          elevation: 10,
                          color: const Color.fromARGB(255, 204, 204, 204),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
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
        }
      },
    );
  }
}
