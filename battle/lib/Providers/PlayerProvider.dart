import 'package:flutter/foundation.dart';
import 'package:battle/Models/Player.dart';

class PlayerProvider extends ChangeNotifier {
  final Map<String, Player> _players = {};
  Player? _localPlayer;
  int _tileSize = 16; 
  double _scale = 2.0; 

  Map<String, Player> get players => _players;
  Player? get localPlayer => _localPlayer;
  
  void setTileProperties(int tileSize, double scale) {
    _tileSize = tileSize;
    _scale = scale;
    notifyListeners();
  }

  void addPlayer(Player player) {
    _players[player.id] = player;
    notifyListeners();
  }

  void removePlayer(String id) {
    _players.remove(id);
    notifyListeners();
  }

  void setLocalPlayer(String id) {
    _localPlayer = _players[id];
    notifyListeners();
  }

  void movePlayerToTile(String id, int tileX, int tileY) {
    if (_players.containsKey(id)) {
      final player = _players[id]!;
      player.displayX = player.tileX.toDouble();
      player.displayY = player.tileY.toDouble();
      player.tileX = tileX;
      player.tileY = tileY;
      player.state = PlayerState.walking;
      player.isMoving = true;
      notifyListeners();
    }
  }

  void tryMovePlayer(String id, Direction direction) {
    if (!_players.containsKey(id) || _players[id]!.isMoving) {
      print('Cannot move player $id: player not found or already moving');
      return;
    }

    final player = _players[id]!;
    int newTileX = player.tileX;
    int newTileY = player.tileY;
    
    player.direction = direction;

    switch (direction) {
      case Direction.up:
        newTileY--;
        break;
      case Direction.down:
        newTileY++;
        break;
      case Direction.left:
        newTileX--;
        break;
      case Direction.right:
        newTileX++;
        break;
    }

    print('Moving player $id from (${player.tileX},${player.tileY}) to ($newTileX,$newTileY)');
    // Save the current position as the starting point for animation
    player.displayX = player.tileX.toDouble();
    player.displayY = player.tileY.toDouble();
    // Set the new target position
    player.tileX = newTileX;
    player.tileY = newTileY;
    player.state = PlayerState.walking;
    player.isMoving = true;
    print('Player $id is now moving from (${player.displayX},${player.displayY}) to (${player.tileX},${player.tileY})');
    notifyListeners();
  }

  void updatePlayerDirection(String id, Direction direction) {
    if (_players.containsKey(id)) {
      _players[id]!.direction = direction;
      notifyListeners();
    }
  }

  void updatePlayerState(String id, PlayerState state) {
    if (_players.containsKey(id)) {
      _players[id]!.state = state;
      notifyListeners();
    }
  }

  double getTilePositionX(int tileX) {
    return tileX * _tileSize * _scale;
  }
  
  double getTilePositionY(int tileY) {
    return tileY * _tileSize * _scale;
  }
  
  void completePlayerMovement(String id) {
    if (_players.containsKey(id)) {
      final player = _players[id]!;
      print('Completing movement for player $id at position (${player.tileX},${player.tileY})');
      player.isMoving = false;
      player.state = PlayerState.idle;
      player.displayX = player.tileX.toDouble();
      player.displayY = player.tileY.toDouble();
      notifyListeners();
    }
  }
} 