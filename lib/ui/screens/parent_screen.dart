import 'dart:ui';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:nitrax/config/global/constants/app_constants.dart';
import 'package:nitrax/data/models/position.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/data/providers/theme_provider.dart';
import 'package:nitrax/ui/screens/favorite_screen.dart';
import 'package:nitrax/ui/screens/home_screen.dart';
import 'package:nitrax/ui/widgets/music_swipper.dart';
import 'package:nitrax/ui/screens/player_screen.dart';
import 'package:nitrax/ui/screens/search_screen.dart';
import 'package:provider/provider.dart';

class ParentScreen extends StatefulWidget {
  const ParentScreen({super.key});

  @override
  State<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends State<ParentScreen>
    with AutomaticKeepAliveClientMixin {
  int _selectedIndex = 0;
  late final PageController _pageController;

  final List<Widget> _pages = [
    const HomeScreen(),
    const SearchScreen(),
    const FavoriteScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final themeProvider = Provider.of<ThemeNotifier>(context);

    return Scaffold(
      appBar: AppBar(
        systemOverlayStyle: themeProvider.currentTheme == ThemeMode.light
            ? SystemUiOverlayStyle.dark
            : SystemUiOverlayStyle.light,
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Row(
          children: [
            SizedBox(width: 10),
            Text("NITRAX", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        automaticallyImplyLeading: true,
        actionsPadding: EdgeInsets.only(right: 16),
        actions: [
          TextButton(
            onPressed: () {
              if (context.locale.languageCode == 'en') {
                context.setLocale(const Locale('de'));
              } else {
                context.setLocale(const Locale('en'));
              }
            },
            child: Text(context.locale.languageCode == 'en' ? "DE" : "EN"),
          ),
          GestureDetector(
            child: Icon(Iconsax.moon, size: 26),
            onTap: () {
              Provider.of<ThemeNotifier>(context, listen: false).changeTheme();
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
          child: BottomNavigationBar(
            backgroundColor: themeProvider.currentTheme == ThemeMode.dark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.6),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Iconsax.home),
                label: tr('new_musics'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Iconsax.music_square_search),
                label: tr('search'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Iconsax.heart),
                label: tr('favorite'),
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white70,
            onTap: _onItemTapped,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const BouncingScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return _pages[index];
              },
            ),
          ),

          Consumer<CurrentMusicProvider>(
            builder: (context, currentProvider, child) {
              if (!AppConstants.isPlayerNull) {
                return GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      sheetAnimationStyle: AnimationStyle(
                        duration: Duration(milliseconds: 800),
                      ),

                      builder: (context) => PlayerScreen(),
                      isScrollControlled: true,
                    );
                  },
                  child: SizedBox(
                    height: 70,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SwipeablePlayerBar(
                          radiusFromTop: true,
                          playlist: currentProvider.currentMusicList,
                          initialIndex: currentProvider.currentIndex!,
                        ),
                        Positioned(
                          bottom: -1,
                          left: 0,
                          right: 0,
                          child: StreamBuilder<PositionData>(
                            stream: currentProvider.positionDataStream,
                            builder: (context, snapshot) {
                              final positionData = snapshot.data;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: ProgressBar(
                                  timeLabelTextStyle: const TextStyle(
                                    fontSize: 0,
                                  ),
                                  barHeight: 2.2,
                                  baseBarColor: Colors.white.withOpacity(0.2),
                                  progressBarColor: Colors.white.withOpacity(
                                    0.8,
                                  ),
                                  thumbColor: Colors.white,
                                  thumbRadius: 1,
                                  progress:
                                      positionData?.position ?? Duration.zero,
                                  total:
                                      positionData?.duration ?? Duration.zero,
                                  buffered:
                                      positionData?.bufferedPosition ??
                                      Duration.zero,
                                  onSeek: currentProvider.getAudioPlayer.seek,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
