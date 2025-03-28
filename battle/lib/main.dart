import 'package:battle/Providers/TilemapProvider.dart';
import 'package:battle/Providers/PlayerProvider.dart';
import 'package:battle/Scenes/GameScene.dart';
import 'package:battle/Utils/ServerUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_it/get_it.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final getIt = GetIt.instance;
  getIt.registerSingleton<TilemapProvider>(TilemapProvider());
  getIt.registerSingleton<PlayerProvider>(PlayerProvider());
  final tilemapProvider = getIt<TilemapProvider>();
  tilemapProvider.loadTilemapData();

  ServerUtils.connectToServer(onDisconnect: null); // TODO: Handle disconnect

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => getIt<TilemapProvider>()),
      ChangeNotifierProvider(create: (_) => getIt<PlayerProvider>()),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScene(),
    );  
  }
}
