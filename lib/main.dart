import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'game/game_engine.dart';
import 'services/audio_service.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait on mobile.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Load persisted settings.
  final storageService = StorageService();
  final savedSettings = await storageService.loadSettings();

  // Initialize audio service.
  final audioService = AudioService();
  audioService.setSoundEnabled(savedSettings.soundEnabled);
  await audioService.initialize();

  // Create the game engine with saved settings.
  final engine = GameEngine();
  engine.updateSettings(savedSettings);

  runApp(
    ChangeNotifierProvider.value(
      value: engine,
      child: const WhoKnowsApp(),
    ),
  );
}
