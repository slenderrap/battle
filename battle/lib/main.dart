import 'package:battle/Providers/app_data.dart';
import 'package:battle/Providers/TilemapProvider.dart';
import 'package:battle/Scenes/GameScene.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppData()),
      ChangeNotifierProvider(create: (_) => TilemapProvider()..loadTilemapData()),
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