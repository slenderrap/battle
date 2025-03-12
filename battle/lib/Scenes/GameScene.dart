import 'package:battle/Models/Player.dart';
import 'package:battle/Providers/PlayerProvider.dart';
import 'package:battle/Providers/TilemapProvider.dart';
import 'package:battle/Widgets/PlayerSprite.dart';
import 'package:battle/Widgets/TileMap.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
class GameScene extends StatefulWidget {
  const GameScene({super.key});
  static const int _TILE_SET_COLUMNS = 21;
  static const double _TILE_MAP_SCALE = 2.0;
  static const int _PLAUER_SPRITE_SIZE = 32;
  static const double _PLAYER_SPRITE_SCALE = 1.0;

  @override
  State<GameScene> createState() => _GameSceneState();
}

class _GameSceneState extends State<GameScene> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tilemapProvider = GetIt.I<TilemapProvider>();
      final playerProvider = GetIt.I<PlayerProvider>();

      if (!tilemapProvider.isLoaded) {
        tilemapProvider.loadTilemapData();
      }

      playerProvider.setTileProperties(
        GameScene._PLAUER_SPRITE_SIZE,
        GameScene._TILE_MAP_SCALE,
      );

      playerProvider.addPlayer(Player(
        id: 'local',
        tileX: 0,
        tileY: 0,
        direction: Direction.down,
      ));
      playerProvider.setLocalPlayer('local');
      //TestTileChange();
    });
  }

  Future<void> TestTileChange() async {
    await Future.delayed(const Duration(seconds: 2));
    final tilemapProvider = GetIt.I<TilemapProvider>();
    print('Changing tile at 0,0 to 7');
    tilemapProvider.setTile(0, 0, 0, 7);
  }

  void _handleKeyEvent(KeyEvent event) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final localPlayer = playerProvider.localPlayer;
    
    if (localPlayer == null) return;
    
    if (event is KeyDownEvent && !localPlayer.isMoving) {
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          playerProvider.tryMovePlayer(localPlayer.id, Direction.up);
          break;
        case LogicalKeyboardKey.arrowDown:
          playerProvider.tryMovePlayer(localPlayer.id, Direction.down);
          break;
        case LogicalKeyboardKey.arrowLeft:
          playerProvider.tryMovePlayer(localPlayer.id, Direction.left);
          break;
        case LogicalKeyboardKey.arrowRight:
          playerProvider.tryMovePlayer(localPlayer.id, Direction.right);
          break;
        case LogicalKeyboardKey.space:
          // You can implement an action here if needed
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
        body: Consumer2<TilemapProvider, PlayerProvider>(
          builder: (context, tilemapProvider, playerProvider, child) {
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
              child: Stack(
                children: [
                    TileMap(
                      mapData: tilemapProvider.tileMaps,
                      spriteMapPath: tilemapProvider.tilesSheetFile,
                      tileSize: tilemapProvider.tileWidth,
                      spriteMapColumns: GameScene._TILE_SET_COLUMNS,
                      scale: GameScene._TILE_MAP_SCALE,
                    ),
                  
                  ...playerProvider.players.values.map((player) {
                    print("player ${player.displayX}, ${player.displayY} to ${player.tileX}, ${player.tileY}");
                    return PlayerSprite(
                      player: player,
                      spriteSheetPath: 'pirate_walk.png',
                      tileSize: GameScene._PLAUER_SPRITE_SIZE,
                      scale: GameScene._PLAYER_SPRITE_SCALE,
                      onMoveComplete: () {
                        playerProvider.completePlayerMovement(player.id);
                      },
                    );
                  }).toList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}