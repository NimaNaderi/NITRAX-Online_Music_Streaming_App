import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/data/providers/music_list_provider.dart';
import 'package:nitrax/ui/screens/player_screen.dart';
import 'package:provider/provider.dart';
import 'package:skeletons/skeletons.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    final musicListProvider = Provider.of<MusicListProvider>(context);

    TextEditingController textEditingController = TextEditingController();
    FocusNode searchFocusNode = FocusNode();

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: double.infinity),
                Padding(
                  padding: const EdgeInsets.all(20),

                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 10,
                          child: AnimatedContainer(
                            height: 54,
                            duration: const Duration(milliseconds: 500),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: searchFocusNode.hasFocus
                                    ? Colors.white
                                    : Colors.blue,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 2,
                            ),
                            child: TextField(
                              onSubmitted: (value) {
                                if (textEditingController.text.isNotEmpty) {
                                  musicListProvider.fetchSearchedMusicsList(
                                    value,
                                    true,
                                  );
                                }
                              },
                              focusNode: searchFocusNode,
                              controller: textEditingController,
                              decoration: InputDecoration(
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                                hintText: tr('enter_music'),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onDoubleTap: () {
                          if (textEditingController.text.isNotEmpty) {
                            musicListProvider.fetchSearchedMusicsList(
                              textEditingController.value.text,
                              false,
                            );
                          }

                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        onTap: () {
                          if (textEditingController.text.isNotEmpty) {
                            musicListProvider.fetchSearchedMusicsList(
                              textEditingController.value.text,
                              true,
                            );
                          }

                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                        },
                        child: Container(
                          height: 54,
                          width: 54,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black87,
                                blurRadius: 1,
                                spreadRadius: 1,
                              ),
                            ],
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: musicListProvider.isLoading
                              ? const Center(
                                  child: SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                )
                              : const Icon(
                                  Iconsax.search_normal,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 6),
                MusicList(),
              ],
            ),
          ],
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
        if (provider.isLoading) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SkeletonListView(
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
                  ),
                ),
              ],
            ),
          );
        } else {
          return Expanded(
            child: ListView.builder(
              itemCount: provider.getSearchedMusicsList.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => Consumer<CurrentMusicProvider>(
                builder: (context, currentProvider, child) => GestureDetector(
                  onTap: () {
                    currentMusicProvider.isPlayingFromNew = false;

                    currentMusicProvider.currentMusicList =
                        provider.getSearchedMusicsList;
                    currentMusicProvider.setPlaylist(
                      provider.getSearchedMusicsList,
                      index,
                    );

                    // currentMusicProvider.getAudioPlayer.play();

                    currentMusicProvider.setNewMusic =
                        provider.getSearchedMusicsList[index];
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
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const SkeletonAvatar(),
                                      imageUrl: provider
                                          .getSearchedMusicsList[index]
                                          .photo,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 16),
                                      Text(
                                        provider
                                            .getSearchedMusicsList[index]
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
                                        provider
                                            .getSearchedMusicsList[index]
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
                                if (currentProvider.currentMusic != null &&
                                    currentProvider.currentMusic!.id ==
                                        musicListProvider
                                            .getSearchedMusicsList[index]
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
                        musicListProvider.getSearchedMusicsList[index],
                      )) ...{
                        Positioned(
                          top: -4,
                          right:
                              musicListProvider
                                      .getSearchedMusicsList[index]
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
                      if (musicListProvider
                              .getSearchedMusicsList[index]
                              .videoLink !=
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
            ),
          );
        }
      },
    );
  }
}
