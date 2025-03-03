import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class TileMap extends StatelessWidget {
  final List<List<List<int>>> mapData;
  final String spriteMapPath;
  final int tileSize;
  final int spriteMapColumns;
  final double scale;

  const TileMap({
    Key? key,
    required this.mapData,
    required this.spriteMapPath,
    required this.tileSize,
    required this.spriteMapColumns,
    this.scale = 1.0,
  }) : super(key: key);

  int get rows => mapData.isNotEmpty && mapData[0].isNotEmpty ? mapData[0].length : 0;
  int get columns => mapData.isNotEmpty && mapData[0].isNotEmpty && mapData[0][0].isNotEmpty ? mapData[0][0].length : 0;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TileMapPainter(
        mapData: mapData,
        spriteMapPath: spriteMapPath,
        tileSize: tileSize,
        spriteMapColumns: spriteMapColumns,
        scale: scale,
      ),
      size: Size(
        columns * tileSize * scale,
        rows * tileSize * scale,
      ),
    );
  }
}

class TileMapPainter extends CustomPainter {
  final List<List<List<int>>> mapData;
  final String spriteMapPath;
  final int tileSize;
  final int spriteMapColumns;
  final double scale;
  
  // Image cache
  ImageProvider? _imageProvider;
  ui.Image? _cachedImage;
  bool _isImageLoaded = false;

  TileMapPainter({
    required this.mapData,
    required this.spriteMapPath,
    required this.tileSize,
    required this.spriteMapColumns,
    required this.scale,
  }) {
    _imageProvider = AssetImage(spriteMapPath);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (!_isImageLoaded) {
      _loadImage();
      return; // Skip this paint cycle and wait for image to load
    }
    
    final Paint paint = Paint();
    
    // Draw each layer in order (bottom to top)
    for (int layer = 0; layer < mapData.length; layer++) {
      for (int row = 0; row < mapData[layer].length; row++) {
        for (int col = 0; col < mapData[layer][row].length; col++) {
          final int tileValue = mapData[layer][row][col];
          if (tileValue < 0) continue; // Skip negative values (empty tiles)
          
          // Calculate source rectangle in the spritemap
          final int spriteRow = tileValue ~/ spriteMapColumns;
          final int spriteCol = tileValue % spriteMapColumns;
          
          final Rect src = Rect.fromLTWH(
            spriteCol * tileSize * 1.0,
            spriteRow * tileSize  * 1.0,
            tileSize * 1.0,
            tileSize * 1.0,
          );
          
          // Calculate destination rectangle on the canvas
          final Rect dst = Rect.fromLTWH(
            col * tileSize * scale,
            row * tileSize * scale,
            tileSize * scale,
            tileSize * scale,
          );
          
          canvas.drawImageRect(
            _cachedImage!,
            src,
            dst,
            paint,
          );
        }
      }
    }
  }

  void _loadImage() {
    if (_imageProvider != null) {
      final ImageStream stream = _imageProvider!.resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener((ImageInfo info, bool _) {
        _cachedImage = info.image; // Directly store the ui.Image
        _isImageLoaded = true;
      }));
    }
  }

  @override
  bool shouldRepaint(TileMapPainter oldDelegate) {
    return oldDelegate.mapData != mapData ||
        oldDelegate.spriteMapPath != spriteMapPath ||
        oldDelegate.tileSize != tileSize ||
        oldDelegate.spriteMapColumns != spriteMapColumns ||
        oldDelegate.scale != scale;
  }
}

