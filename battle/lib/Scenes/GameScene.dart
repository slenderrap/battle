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
  final List<List<List<int>>> map = const [];

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
        body: Center(
          child: TileMap(
            mapData: map,
            spriteMapPath: 'assets/tileset.png',
            tileSize: 32,
            spriteMapColumns: 10,
            scale: 2.0,
          ),
        ),
      ),
    );
  }
}