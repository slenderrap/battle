import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class TileMap extends StatefulWidget {
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
  State<StatefulWidget> createState() => _TileMapState();
}

class _TileMapState extends State<TileMap> {

  ui.Image? image;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TileMapPainter(
        mapData: widget.mapData,
        spriteMapPath: widget.spriteMapPath,
        tileSize: widget.tileSize,
        spriteMapColumns: widget.spriteMapColumns,
        scale: widget.scale,
        image: image,
      ),
      size: Size(
        widget.columns * widget.tileSize * widget.scale,
        widget.rows * widget.tileSize * widget.scale,
      ),
    );
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/${widget.spriteMapPath}');
    final Uint8List bytes = data.buffer.asUint8List();
    image = await decodeImageFromList(bytes);
    setState(() {});
  }
}

class TileMapPainter extends CustomPainter {
  final List<List<List<int>>> mapData;
  final String spriteMapPath;
  final int tileSize;
  final int spriteMapColumns;
  final double scale;
  
  ui.Image? image;

  TileMapPainter({
    required this.mapData,
    required this.spriteMapPath,
    required this.tileSize,
    required this.spriteMapColumns,
    required this.scale,
    required this.image,
  });
    
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    if (image == null) return;
    
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
            image!,
            src,
            dst,
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(TileMapPainter oldDelegate) => true; // Always repaint until image is loaded
}

