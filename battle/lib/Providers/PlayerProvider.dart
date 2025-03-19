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

  void MovePlayer(String id, Direction direction) {
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

    // Save the current position as the starting point for animation
    player.displayX = player.tileX.toDouble();
    player.displayY = player.tileY.toDouble();
    // Set the new target position
    player.tileX = newTileX;
    player.tileY = newTileY;
    player.state = PlayerState.walking;
    player.isMoving = true;
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

  void checkPlayerHasMoved(Player player, int previousTileX, int previousTileY) {
    if (player == null) return;
    if (player.tileX != previousTileX || player.tileY != previousTileY) {
      late Direction direction;
      if (player.tileX < previousTileX) {
        direction = Direction.left;
      } else if (player.tileX > previousTileX) {
        direction = Direction.right;
      } else if (player.tileY < previousTileY) {
        direction = Direction.up;
      } else if (player.tileY > previousTileY) {
        direction = Direction.down;
      }
      MovePlayer(player.id, direction);
    }
  }

  void updatePlayers(Player localPlayer, List<Player> otherPlayers) {
    // Check for movement
    if (localPlayer == null) return;
    checkPlayerHasMoved(localPlayer, this._localPlayer!.tileX, this._localPlayer!.tileY);
    
    for (Player otherPlayer in otherPlayers) {
      if (players.containsKey(otherPlayer.id)) {
        checkPlayerHasMoved(otherPlayer, players[otherPlayer.id]!.tileX, players[otherPlayer.id]!.tileY);
      }
    }
    
    //Check for new players
    for (Player otherPlayer in otherPlayers) {
      if (!players.containsKey(otherPlayer.id)) {
        addPlayer(otherPlayer);
      }
    }
    
    //Check for deaths/disconnections - Fixed to avoid concurrent modification
    List<String> idsToRemove = [];
    for (String id in players.keys) {
      if (id != localPlayer.id && !otherPlayers.any((player) => player.id == id)) {
        idsToRemove.add(id);
      }
    }
    
    // Now remove the players after iteration is complete
    for (String id in idsToRemove) {
      removePlayer(id);
    }
    
    notifyListeners();
  }
} 