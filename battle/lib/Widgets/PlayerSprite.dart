import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:battle/Models/Player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:battle/Providers/PlayerProvider.dart';

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
  int _animationId = 0;

  late Animation<double> _moveAnimation;
  double _startX = 0;
  double _startY = 0;
  double _targetX = 0;
  double _targetY = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..addListener(() {
      setState(() {
        if (widget.player.state == PlayerState.walking || 
            widget.player.state == PlayerState.attacking) {
          _currentFrame = (_controller.value * 12).floor() % 12;
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
    if (widget.player.isMoving || widget.player.state == PlayerState.attacking) {
      _updatePositionValues();
      
      if (!_controller.isAnimating) {
        _controller.reset();
        _animationId++;
        final int currentMoveId = _animationId;

        _controller.forward().then((_) {
          if (mounted && currentMoveId == _animationId) {
            widget.onMoveComplete();
          }
        });
      }
    } else if (oldWidget.player.tileX != widget.player.tileX || 
        oldWidget.player.tileY != widget.player.tileY ||
        oldWidget.player.displayX != widget.player.displayX ||
        oldWidget.player.displayY != widget.player.displayY) {
       
      _updatePositionValues();
    }
    if (oldWidget.player.state != widget.player.state) {
      print("Player state changed");
      _controller.stop();
      _controller.reset();
      _animationId++;
      final int currentAnimationInstanceId = _animationId;

      if (widget.player.state == PlayerState.idle) {
        _controller.repeat();
      } else if (widget.player.state == PlayerState.walking) {
        _controller.forward();
      }
    }
    
    if (oldWidget.player.direction != widget.player.direction) {
      setState(() {});
    }

    if (oldWidget.player.health != widget.player.health) {
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
    
    // Calculate positions once
    final double startX = widget.player.displayX * widget.tileSize * widget.scale;
    final double startY = widget.player.displayY * widget.tileSize * widget.scale;
    final double targetX = widget.player.tileX * widget.tileSize * widget.scale;
    final double targetY = widget.player.tileY * widget.tileSize * widget.scale;
    
    double currentX = startX;
    double currentY = startY;
    
    if (widget.player.isMoving) {
      currentX = startX + (targetX - startX) * _moveAnimation.value;
      currentY = startY + (targetY - startY) * _moveAnimation.value;      
      
      const double threshold = 0.95; 
      if (_moveAnimation.value >= threshold && _controller.isAnimating) {        
        final int currentMoveIdForThreshold = _animationId;
        _controller.stop();
        
        currentX = targetX;
        currentY = targetY;
        
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && currentMoveIdForThreshold == _animationId) {
            widget.onMoveComplete();
          }
        });
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
          playerLife: widget.player.health,
          isAlive: widget.player.isAlive,
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
  final int playerLife;
  final int playerMaxLife = 100;
  final bool isAlive;

  PlayerSpritePainter({
    required this.player,
    required this.image,
    required this.tileSize,
    required this.scale,
    required this.currentFrame,
    this.playerLife = 100, // Default value
    this.isAlive = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    // Select row based on direction
    print("painter: " + player.state.toString());
    int row = 0;
    if (player.isLocal) {
      if (player.state == PlayerState.attacking) {
        row = 1;
      }
      else {
        row = 3;
      }
    }
    else {
      if (player.state == PlayerState.attacking) {
        row = 2;
      }
      else {
        row = 0;
      }
    }
    bool reverse = false;
    if (player.direction == Direction.left) {
        reverse = true;
    }
    //Render Player Sprite
    final Rect src = Rect.fromLTWH(
      currentFrame * tileSize * 1.0,
      row * tileSize * 1.0,
      tileSize * 1.0,
      tileSize * 1.0,
    );
    
    final Rect dst = Rect.fromLTWH(
      0,
      0,
      tileSize * scale,
      tileSize * scale,
    );

    canvas.save();
    if (reverse) {
      canvas.translate(tileSize * scale, 0);
      canvas.scale(-1, 1);
    }
    if (!isAlive) {
      canvas.translate(tileSize * scale, 0);
      canvas.rotate(math.pi/2);
      canvas.scale(1, 1);
    }
    canvas.drawImageRect(
      image,
      src,
      dst,
      paint,
    );
    canvas.restore();

    //Render Player Life Bar
    final Color lifeBarBackgroundColor = Colors.black;
    final Color lifeBarForegroundColor = const ui.Color.fromARGB(255, 110, 8, 8);
    final Color lifeBarFillColor = Colors.red;
    final int lifeBarBackgroundPadding = 2;
    final double lifeBarHeight = 4;
    final double lifeBarWidth = tileSize * scale * 0.8;
    final double lifeBarX = (tileSize * scale - lifeBarWidth) / 2;
    final double lifeBarY = tileSize * scale + 2;

    // Draw life bar background
    final Paint backgroundPaint = Paint()
      ..color = lifeBarBackgroundColor
      ..style = PaintingStyle.fill;
    
    final Rect backgroundRect = Rect.fromLTWH(
      lifeBarX - lifeBarBackgroundPadding,
      lifeBarY - lifeBarBackgroundPadding,
      lifeBarWidth + (lifeBarBackgroundPadding * 2),
      lifeBarHeight + (lifeBarBackgroundPadding * 2),
    );
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Draw life bar border
    final Paint borderPaint = Paint()
      ..color = lifeBarForegroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    final Rect borderRect = Rect.fromLTWH(
      lifeBarX,
      lifeBarY,
      lifeBarWidth,
      lifeBarHeight,
    );
    canvas.drawRect(borderRect, borderPaint);

    // Draw life bar fill
    final Paint fillPaint = Paint()
      ..color = lifeBarFillColor
      ..style = PaintingStyle.fill;
    
    final double lifePercentage = playerLife / playerMaxLife;
    final Rect fillRect = Rect.fromLTWH(
      lifeBarX,
      lifeBarY,
      lifeBarWidth * lifePercentage,
      lifeBarHeight,
    );
    canvas.drawRect(fillRect, fillPaint);
  }

  @override
  bool shouldRepaint(PlayerSpritePainter oldDelegate) {
    return oldDelegate.player != player ||
        oldDelegate.image != image ||
        oldDelegate.currentFrame != currentFrame ||
        playerLife != oldDelegate.playerLife ||
        player.state != oldDelegate.player.state;
  }
} 