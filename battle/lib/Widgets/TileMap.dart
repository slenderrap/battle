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

  @override
  State<TileMap> createState() => _TileMapState();
}

class _TileMapState extends State<TileMap> {
  ui.Image? image;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/${widget.spriteMapPath}');
    final Uint8List bytes = data.buffer.asUint8List();
    image = await decodeImageFromList(bytes);
    _isImageLoaded = true;
    setState(() {});
  }

  int get rows => widget.mapData.isNotEmpty && widget.mapData[0].isNotEmpty ? widget.mapData[0].length : 0;
  int get columns => widget.mapData.isNotEmpty && widget.mapData[0].isNotEmpty && widget.mapData[0][0].isNotEmpty ? widget.mapData[0][0].length : 0;

  @override
  Widget build(BuildContext context) {
    if (!_isImageLoaded) {
      return SizedBox(
        width: columns * widget.tileSize * widget.scale,
        height: rows * widget.tileSize * widget.scale,
      );
    }

    return CustomPaint(
      painter: TileMapPainter(
        mapData: widget.mapData,
        image: image!,
        tileSize: widget.tileSize,
        spriteMapColumns: widget.spriteMapColumns,
        scale: widget.scale,
      ),
      size: Size(
        columns * widget.tileSize * widget.scale,
        rows * widget.tileSize * widget.scale,
      ),
    );
  }
}

class TileMapPainter extends CustomPainter {
  final List<List<List<int>>> mapData;
  final ui.Image image;
  final int tileSize;
  final int spriteMapColumns;
  final double scale;

  TileMapPainter({
    required this.mapData,
    required this.image,
    required this.tileSize,
    required this.spriteMapColumns,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    if (image == null) return;
    
    for (int layer = 0; layer < mapData.length; layer++) {
      for (int row = 0; row < mapData[layer].length; row++) {
        for (int col = 0; col < mapData[layer][row].length; col++) {
          final int tileValue = mapData[layer][row][col];
          if (tileValue < 0) continue; 
          
          final int spriteRow = tileValue ~/ spriteMapColumns;
          final int spriteCol = tileValue % spriteMapColumns;
          
          final Rect src = Rect.fromLTWH(
            spriteCol * tileSize * 1.0,
            spriteRow * tileSize * 1.0,
            tileSize * 1.0,
            tileSize * 1.0,
          );
          
          final Rect dst = Rect.fromLTWH(
            col * tileSize * scale,
            row * tileSize * scale,
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
      }
    }
  }

  @override
  bool shouldRepaint(TileMapPainter oldDelegate) {
    return oldDelegate.mapData != mapData ||
        oldDelegate.image != image ||
        oldDelegate.tileSize != tileSize ||
        oldDelegate.spriteMapColumns != spriteMapColumns ||
        oldDelegate.scale != scale;
  }
}

