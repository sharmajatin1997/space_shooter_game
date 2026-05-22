import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

part 'models/models.dart';
part 'core/sound_manager.dart';
part 'painters/painters.dart';
part 'widgets/widgets.dart';
part 'screens/splash_screen.dart';
part 'screens/main_menu_screen.dart';
part 'screens/game_screen.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const SpaceShooterApp());
}

// ══════════════════════════════════════════════════════════════
// APP ROOT
// ══════════════════════════════════════════════════════════════

class SpaceShooterApp extends StatelessWidget {
  const SpaceShooterApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Space Shooter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const SplashScreen(),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// GAME SETTINGS  (sound / music / vibration)
// ══════════════════════════════════════════════════════════════

