import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:nitrax/data/models/music.dart';
import 'package:nitrax/data/providers/current_music_provider.dart';
import 'package:nitrax/data/providers/music_download_provider.dart';
import 'package:nitrax/data/providers/music_list_provider.dart';
import 'package:nitrax/data/providers/theme_provider.dart';
import 'package:nitrax/ui/screens/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  await Hive.initFlutter();

  Hive.registerAdapter(MusicAdapter());

  await Hive.openBox<Music>('musicBox');
  await Hive.openBox('latestMusicListBox');

  await EasyLocalization.ensureInitialized();

  final status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }

  runApp(
    EasyLocalization(
      path: "assets/translations",
      supportedLocales: [Locale('en'), Locale('de')],
      fallbackLocale: Locale('de'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeNotifier(ThemeMode.dark),
        ),
        ChangeNotifierProvider(create: (context) => MusicListProvider()),
        ChangeNotifierProvider(create: (context) => CurrentMusicProvider()),
        ChangeNotifierProvider(create: (context) => DownloadMusicProvider()),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, theme, child) => MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          home: SplashNitrax(),
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: theme.currentTheme,
        ),
      ),
    );
  }
}
