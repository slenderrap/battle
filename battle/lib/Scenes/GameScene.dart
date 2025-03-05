import 'package:battle/Providers/TilemapProvider.dart';
import 'package:battle/Widgets/TileMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

class GameScene extends StatefulWidget {
  const GameScene({super.key});
  static const int _TILE_SET_COLUMNS = 21;
  static const double _TILE_MAP_SCALE = 2.0;

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  @override
  void initState() {
    super.initState();
    // Ensure the tilemap data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tilemapProvider = Provider.of<TilemapProvider>(context, listen: false);
      if (!tilemapProvider.isLoaded) {
        tilemapProvider.loadTilemapData();
      }
    });
  }

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
        backgroundColor: Colors.black,
        body: Consumer<TilemapProvider>(
          builder: (context, tilemapProvider, child) {
            if (!tilemapProvider.isLoaded) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading tilemap...', style: TextStyle(color: Colors.white)),
                  ],
                ),
              );
            }

            if (tilemapProvider.tileMaps.isEmpty) {
              if (kDebugMode) {
                print('No tilemap data available. Attempting to reload...');
                // Try to reload the data
                Future.delayed(Duration.zero, () {
                  tilemapProvider.loadTilemapData();
                });
              }
              
              return const Center(
                child: Text('No tilemap data available', style: TextStyle(color: Colors.white)),
              );
            }
            
            if (kDebugMode) {
              print('Rendering tilemap with ${tilemapProvider.tileMaps.length} layers');
              print('Using tileset: ${tilemapProvider.tilesSheetFile}');
            }
            
            return Center(
              child: TileMap(
                mapData: tilemapProvider.tileMaps,
                spriteMapPath: tilemapProvider.tilesSheetFile,
                tileSize: tilemapProvider.tileWidth,
                spriteMapColumns: GameScene._TILE_SET_COLUMNS,
                scale: GameScene._TILE_MAP_SCALE,
              ),
            );
          },
        ),
      ),
    );
  }
}