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
    this.direction = Direction.down,
    this.state = PlayerState.idle,
    this.frame = 0,
  }) : 
    displayX = tileX.toDouble(),
    displayY = tileY.toDouble();
} 