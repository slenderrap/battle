import 'package:battle/Scenes/GameScene.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(MultiProvider(
    providers: [],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScene(),
    );
  }
}

// TODO:

// 2. Game Scene
// 3. Input system
// 4. ServerUtils
// 5. Test TileMap

