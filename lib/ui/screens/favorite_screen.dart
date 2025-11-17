import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/ui/screens/player_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    final currentMusicProvider = Provider.of<CurrentMusicProvider>(context);

    return Scaffold(
      body: currentMusicProvider.getFavoriteMusics().isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.heart_slash,
                    size: 60,
                    color: const Color.fromARGB(255, 195, 69, 60),
                  ),
                  SizedBox(height: 16),
                  Text(
                    tr('favorite_empty'),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ],
              ),
            )
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                ListView.builder(
                  itemCount: currentMusicProvider.getFavoriteMusics().length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) => Consumer<CurrentMusicProvider>(
                    builder: (context, currentProvider, child) =>
                        GestureDetector(
                          onTap: () {
                            currentMusicProvider.currentMusicList =
                                currentMusicProvider.getFavoriteMusics();
                            currentMusicProvider.setPlaylist(
                              currentMusicProvider.getFavoriteMusics(),
                              index,
                            );

                            // currentMusicProvider.getAudioPlayer.play();

                            currentMusicProvider.setNewMusic =
                                currentMusicProvider.getFavoriteMusics()[index];

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
                          child: Dismissible(
                            onDismissed: (direction) {
                              currentMusicProvider
                                  .removeSpecificMusicFromFavorite(
                                    currentMusicProvider
                                        .getFavoriteMusics()[index],
                                  );
                            },
                            key: UniqueKey(),
                            child: Container(
                              margin: const EdgeInsets.all(10),
                              height: 100,
                              child: Card(
                                elevation: 6,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          child: CachedNetworkImage(
                                            width: 72,
                                            height: 72,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const SkeletonAvatar(),
                                            imageUrl: currentMusicProvider
                                                .getFavoriteMusics()[index]
                                                .photo,
                                          ),
                                        ),
                                      ),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        width: 160,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 16),
                                            Text(
                                              currentMusicProvider
                                                  .getFavoriteMusics()[index]
                                                  .song,
                                              maxLines: 1,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              currentMusicProvider
                                                  .getFavoriteMusics()[index]
                                                  .artist,
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
                                      if (currentProvider.currentMusic !=
                                              null &&
                                          currentProvider.currentMusic!.id ==
                                              currentMusicProvider
                                                  .getFavoriteMusics()[index]
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
                          ),
                        ),
                  ),
                ),
              ],
            ),
    );
  }
}
