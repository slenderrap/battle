import 'package:flutter/foundation.dart';

enum Direction {
  up, 
  down,
  left,
  right,
  none, //Used when a player is not moving
}

enum PlayerState {
  idle,
  walking,
  attacking,
}

class Player {
  final String id;
  int health;
  int tileX;
  int tileY;
  Direction direction;
  PlayerState state;
  int frame;
  bool isAlive;
  bool isLocal;
  
  double displayX;
  double displayY;
  bool isMoving = false;

  Player({
    required this.id,
    this.tileX = 0,
    this.tileY = 0,
    this.health = 100,
    this.direction = Direction.down,
    this.state = PlayerState.idle,
    this.frame = 0,
    this.isAlive = true,
    this.isLocal = false,
  }) : 
    displayX = tileX.toDouble(),
    displayY = tileY.toDouble();

  static Direction _parseDirection(Map<String, dynamic> direction) {
    if (direction['dx'] == 0 && direction['dy'] == 0) return Direction.none;
    if (direction['dx'] == 0) {
      if (direction['dy'] == 1) {
        return Direction.up;
      } else if (direction['dy'] == -1) {
        return Direction.down;
      }
    } else if (direction['dy'] == 0) {
      if (direction['dx'] == 1) {
        return Direction.right;
      } else if (direction['dx'] == -1) {
        return Direction.left;
      }
    }
    throw Exception('Invalid direction received from server: $direction');
  }
   static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  Player.fromJson(Map<String, dynamic> json) : 
    id = json['id'],
    tileX = json['x'],
    tileY = json['y'],
    health = json['health'],
    direction = Player._parseDirection(json['direction']),
    state = PlayerState.idle,
    frame = 0,
    displayX = json['x'].toDouble(),
    displayY = json['y'].toDouble(),
    isMoving = false,
    isAlive = _parseBool(json['isAlive']),
    isLocal = false;

}  