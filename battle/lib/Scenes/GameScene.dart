import 'package:battle/Widgets/TileMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameScene extends StatefulWidget {
  const GameScene({super.key});

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  //TODO: change to a provider
  final List<List<List<int>>> map = [
    // Single layer with just one tile
    [
      [0, 0, 0, 0, 0],
      [0, 1, 1, 1, 0],
      [0, 1, 1, 1, 0],
      [0, 0, 0, 0, 0],
    ],
    [
      [-1, -1, -1, -1, -1],
      [-1, -1, 5, -1, -1],
      [-1, -1, -1, -1, 1],
      [-1, -1, -1, -1, -1],
    ]
  ];

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          print('Up arrow pressed');
          break;
        case LogicalKeyboardKey.arrowDown:
          print('Down arrow pressed');
          break;
        case LogicalKeyboardKey.arrowLeft:
          print('Left arrow pressed');
          break;
        case LogicalKeyboardKey.arrowRight:
          print('Right arrow pressed');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black, // Changed from purple to black
        body: Center(
          child: TileMap( // Removed the Container with yellow border
            mapData: map,
            spriteMapPath: 'tileset_0.png',
            tileSize: 16,
            spriteMapColumns: 21,
            scale: 2.0,
          ),
        ),
      ),
    );
  }
}