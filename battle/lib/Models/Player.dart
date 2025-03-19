import 'package:flutter/foundation.dart';

enum Direction {
  up,
  down,
  left,
  right,
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
  }) : 
    displayX = tileX.toDouble(),
    displayY = tileY.toDouble();

  Player.fromJson(Map<String, dynamic> json) : 
    id = json['id'],
    tileX = json['x'],
    tileY = json['y'],
    health = json['health'],
    direction = json['direction'] != null ? Direction.values[json['direction']] : Direction.down,
    state = PlayerState.idle,
    frame = 0,
    displayX = json['x'].toDouble(),
    displayY = json['y'].toDouble(),
    isMoving = false;
}  