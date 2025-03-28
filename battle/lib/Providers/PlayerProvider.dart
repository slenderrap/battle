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
    _localPlayer!.isLocal = true;
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

  void movePlayer(String id, Direction direction) {
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
      case Direction.none:
        return;
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
      player.isMoving = false;
      player.state = PlayerState.idle;
      player.displayX = player.tileX.toDouble();
      player.displayY = player.tileY.toDouble();
      notifyListeners();
    }
  }

  void checkPlayerHasMoved(Player player, int previousTileX, int previousTileY) {
    if (player.tileX != previousTileX || player.tileY != previousTileY) {
      Direction? direction;

      if (previousTileX + 1 == player.tileX && previousTileY == player.tileY) {
        direction = Direction.right;
      } else if (previousTileX == player.tileX && previousTileY - 1 == player.tileY) {
        direction = Direction.up;
      } else if (previousTileX - 1 == player.tileX && previousTileY == player.tileY) {
        direction = Direction.left;
      } else if (previousTileX == player.tileX && previousTileY + 1 == player.tileY) {
        direction = Direction.down;
      }

      if (direction == null) {
        // Sync position instead
        print('Syncing position for player ${player.id}');
        movePlayerToTile(player.id, player.tileX, player.tileY);
      } else {
        movePlayer(player.id, direction);
      }
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

    //Check for life changes
    this._localPlayer!.health = localPlayer.health;
    print("local health: ${this._localPlayer!.health}");
    print("Server health: ${localPlayer.health}");
    for (Player otherPlayer in otherPlayers) {
      if (players.containsKey(otherPlayer.id)) {
        players[otherPlayer.id]!.health = otherPlayer.health;
      }
    }
    
    //Check for new players
    for (Player otherPlayer in otherPlayers) {
      if (!players.containsKey(otherPlayer.id)) {
        addPlayer(otherPlayer);
      }
    }
    
    //Check for disconnections
    List<String> idsToRemove = [];
    for (String id in players.keys) {
      if (id != localPlayer.id && !otherPlayers.any((player) => player.id == id)) {
        idsToRemove.add(id);
      }
    }
    //Check for deaths
    //local player
    this._localPlayer!.isAlive = localPlayer.isAlive;

    //other players
    for (Player otherPlayer in otherPlayers) {
      if (players.containsKey(otherPlayer.id)) {
        players[otherPlayer.id]!.isAlive = otherPlayer.isAlive;
      }
    }
    // Now remove the players after iteration is complete
    for (String id in idsToRemove) {
      removePlayer(id);
    }
    
    notifyListeners();
  }
} 