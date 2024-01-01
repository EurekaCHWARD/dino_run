import 'package:dino_run/auth/pages/login_or_registerPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


import 'views/hud.dart';
import 'controllers/dino_run.dart';
import 'models/settings.dart';
import 'views/main_menu.dart';
import 'models/player_data.dart';
import 'views/pause_menu.dart';
import 'views/settings_menu.dart';
import 'views/game_over_menu.dart';

Future<void> main() async {
  //await Flame.device.setPortrait();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initHive();
  runApp(const DinoRunApp());
}

Future<void> initHive() async {
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  }

  Hive.registerAdapter<PlayerData>(PlayerDataAdapter());
  Hive.registerAdapter<Settings>(SettingsAdapter());
}

class DinoRunApp extends StatelessWidget {
  const DinoRunApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dino Run',
      theme: ThemeData(
        fontFamily: 'Audiowide',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Settings up some default theme for elevated buttons.
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            fixedSize: const Size(200, 60),
          ),
        ),
      ),
      home: AuthWidget(),
    );
  }
}

class AuthWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return GameWidget<DinoRun>.controlled(
            loadingBuilder: (context) => const Center(
              child: SizedBox(
                width: 200,
                child: LinearProgressIndicator(),
              ),
            ),
            overlayBuilderMap: {
              //AuthPage.id: (_, game) => AuthPage(game),
              MainMenu.id: (_, game) => MainMenu(game),
              PauseMenu.id: (_, game) => PauseMenu(game),
              Hud.id: (_, game) => Hud(game),
              GameOverMenu.id: (_, game) => GameOverMenu(game),
              SettingsMenu.id: (_, game) => SettingsMenu(game),
            },
            initialActiveOverlays: const [MainMenu.id],
            gameFactory: () => DinoRun(
              camera: CameraComponent.withFixedResolution(
                width: 360,
                height: 180,
              ),
            ),
          );
        } else {
          return LoginOrRegisterPage();
        }
      },
    );
  }
}
