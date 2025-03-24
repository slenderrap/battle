import 'package:battle/Models/Player.dart';
import 'package:battle/Models/ServerMessage.dart';
import 'package:battle/Providers/PlayerProvider.dart';
import 'package:battle/Providers/TilemapProvider.dart';
import 'package:battle/Utils/ServerUtils.dart';
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

    });
  }

  void _handleKeyEvent(KeyEvent event) {
    final playerProvider = Provider.of<PlayerProvider>(context, listen: false);
    final localPlayer = playerProvider.localPlayer;
    
    if (localPlayer == null) return;
    
    if (event is KeyDownEvent && !localPlayer.isMoving) {
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          ServerUtils.sendMessage(ServerMessage("direction", {"direction": "up"}));
          break;
        case LogicalKeyboardKey.arrowDown:
          ServerUtils.sendMessage(ServerMessage("direction", {"direction": "down"}));
          break;
        case LogicalKeyboardKey.arrowLeft:
          ServerUtils.sendMessage(ServerMessage("direction", {"direction": "left"}));
          break;
        case LogicalKeyboardKey.arrowRight:
          ServerUtils.sendMessage(ServerMessage("direction", {"direction": "right"}));
          break;
        case LogicalKeyboardKey.space:
          ServerUtils.sendMessage(ServerMessage("attack", {}));
          break;
      } 
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space)
        return;
      ServerUtils.sendMessage(ServerMessage("direction", {"direction": "none"}));
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
              
              return const Center(
                child: Text('No tilemap data available', style: TextStyle(color: Colors.white)),
              );
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