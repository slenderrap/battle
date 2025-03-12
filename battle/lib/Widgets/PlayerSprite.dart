import 'dart:ui' as ui;
import 'package:battle/Models/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlayerSprite extends StatefulWidget {
  final Player player;
  final String spriteSheetPath;
  final int tileSize;
  final double scale;
  final VoidCallback onMoveComplete;

  const PlayerSprite({
    Key? key,
    required this.player,
    required this.spriteSheetPath,
    required this.tileSize,
    required this.scale,
    required this.onMoveComplete,
  }) : super(key: key);

  @override
  State<PlayerSprite> createState() => _PlayerSpriteState();
}

class _PlayerSpriteState extends State<PlayerSprite> with SingleTickerProviderStateMixin {
  ui.Image? image;
  bool _isImageLoaded = false;
  late AnimationController _controller;
  int _currentFrame = 0;
  
  late Animation<double> _moveAnimation;
  double _startX = 0;
  double _startY = 0;
  double _targetX = 0;
  double _targetY = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
    
    print('PlayerSprite initState - Player: ${widget.player.id} at tile (${widget.player.tileX},${widget.player.tileY}) display (${widget.player.displayX},${widget.player.displayY})');
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {
        if (widget.player.state == PlayerState.walking || 
            widget.player.state == PlayerState.attacking) {
          _currentFrame = (_controller.value * 4).floor() % 4;
        } else {
          _currentFrame = 0;
        }
      });
    });
    
    _moveAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    
    // Only repeat animation for idle state, not for movement
    if (widget.player.state == PlayerState.idle) {
      _controller.repeat();
    }
    
    _updatePositionValues();
  }
  
  @override
  void didUpdateWidget(PlayerSprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    print('PlayerSprite didUpdateWidget - Player: ${widget.player.id} at tile (${widget.player.tileX},${widget.player.tileY}) display (${widget.player.displayX},${widget.player.displayY}) - isMoving: ${widget.player.isMoving}');
    
    // Force update position values whenever the widget updates if player is moving
    if (widget.player.isMoving) {
      print('Player is moving, updating position values');
      _updatePositionValues();
      
      if (!_controller.isAnimating) {
        print('Starting animation');
        _controller.reset();
        _controller.forward().then((_) {
          print('Animation complete, calling onMoveComplete');
          widget.onMoveComplete();
        });
      }
    } else if (oldWidget.player.tileX != widget.player.tileX || 
        oldWidget.player.tileY != widget.player.tileY ||
        oldWidget.player.displayX != widget.player.displayX ||
        oldWidget.player.displayY != widget.player.displayY) {
      
      print('Position changed, updating position values');
      _updatePositionValues();
    }
    
    if (oldWidget.player.state != widget.player.state) {
      if (widget.player.state == PlayerState.idle) {
        _controller.repeat();
      } else if (widget.player.state == PlayerState.walking && !_controller.isAnimating) {
        _controller.reset();
        _controller.forward();
      }
    }
    
    if (oldWidget.player.direction != widget.player.direction) {
      setState(() {});
    }
  }
  
  void _updatePositionValues() {
    // Force these values to be calculated correctly
    final double displayX = widget.player.displayX;
    final double displayY = widget.player.displayY;
    final int tileX = widget.player.tileX;
    final int tileY = widget.player.tileY;
    
    _startX = displayX * widget.tileSize * widget.scale;
    _startY = displayY * widget.tileSize * widget.scale;
    _targetX = tileX * widget.tileSize * widget.scale;
    _targetY = tileY * widget.tileSize * widget.scale;
    
    print('Updated position values: Player at (${displayX},${displayY}) to (${tileX},${tileY})');
    print('Calculated positions: start (${_startX},${_startY}) target (${_targetX},${_targetY})');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/${widget.spriteSheetPath}');
    final Uint8List bytes = data.buffer.asUint8List();
    image = await decodeImageFromList(bytes);
    _isImageLoaded = true;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isImageLoaded) {
      return SizedBox(
        width: widget.tileSize * widget.scale,
        height: widget.tileSize * widget.scale,
      );
    }
    
    double currentX = _startX;
    double currentY = _startY;
    
    if (widget.player.isMoving) {
      // Recalculate these values every frame to ensure they're correct
      final double startX = widget.player.displayX * widget.tileSize * widget.scale;
      final double startY = widget.player.displayY * widget.tileSize * widget.scale;
      final double targetX = widget.player.tileX * widget.tileSize * widget.scale;
      final double targetY = widget.player.tileY * widget.tileSize * widget.scale;
      
      currentX = startX + (targetX - startX) * _moveAnimation.value;
      currentY = startY + (targetY - startY) * _moveAnimation.value;
      
      print('Player is moving from (${startX},${startY}) to (${targetX},${targetY}) - Current: (${currentX},${currentY}) - Animation value: ${_moveAnimation.value}');
      
      // Add threshold check to stop animation when close enough to target
      const double threshold = 0.95; // When animation is 95% complete
      if (_moveAnimation.value >= threshold && _controller.isAnimating) {
        print('Reached threshold, stopping animation and completing movement');
        _controller.stop();
        // Jump to final position
        currentX = targetX;
        currentY = targetY;
        // Call onMoveComplete to update the player state
        widget.onMoveComplete();
      }
    }
   
    return Positioned(
      left: currentX,
      top: currentY,
      child: CustomPaint(
        painter: PlayerSpritePainter(
          player: widget.player,
          image: image!,
          tileSize: widget.tileSize,
          scale: widget.scale,
          currentFrame: _currentFrame,
        ),
        size: Size(
          widget.tileSize * widget.scale,
          widget.tileSize * widget.scale,
        ),
      ),
    );
  }
}

class PlayerSpritePainter extends CustomPainter {
  final Player player;
  final ui.Image image;
  final int tileSize;
  final double scale;
  final int currentFrame;

  PlayerSpritePainter({
    required this.player,
    required this.image,
    required this.tileSize,
    required this.scale,
    required this.currentFrame,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    
    // Select row based on direction
    int row;
    switch (player.direction) {
      case Direction.down:
        row = 0;
        break;
      case Direction.left:
        row = 1;
        break;
      case Direction.right:
        row = 2;
        break;
      case Direction.up:
        row = 3;
        break;
      default:
        row = 0;
    }
    
    final Rect src = Rect.fromLTWH(
      currentFrame * tileSize * 1.0,
      0 * tileSize * 1.0,
      tileSize * 1.0,
      tileSize * 1.0,
    );
    
    final Rect dst = Rect.fromLTWH(
      0,
      0,
      tileSize * scale,
      tileSize * scale,
    );
    
    canvas.drawImageRect(
      image,
      src,
      dst,
      paint,
    );
  }

  @override
  bool shouldRepaint(PlayerSpritePainter oldDelegate) {
    return oldDelegate.player != player ||
        oldDelegate.image != image ||
        oldDelegate.currentFrame != currentFrame;
  }
} 