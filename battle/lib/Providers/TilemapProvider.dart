import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class TilemapProvider extends ChangeNotifier {
  List<List<List<int>>> _tileMaps = [];
  String _tilesSheetFile = '';
  int _tileWidth = 16;
  int _tileHeight = 16;
  bool _isLoaded = false;

  List<List<List<int>>> get tileMaps => _tileMaps;
  String get tilesSheetFile => _tilesSheetFile;
  int get tileWidth => _tileWidth;
  int get tileHeight => _tileHeight;
  bool get isLoaded => _isLoaded;

  Future<void> loadTilemapData() async {
    try {
      const String jsonPath = 'assets/game_data.json';
      if (kDebugMode) {
        print('Loading tilemap data from: $jsonPath');
      }
      
      final String jsonData = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> data = json.decode(jsonData);
      
      if (data['levels'] != null && data['levels'].isNotEmpty) {
        final levelData = data['levels'][0];
        
        if (levelData['layers'] != null && levelData['layers'].isNotEmpty) {
          _tileMaps = [];
          
          List<dynamic> layers = List.from(levelData['layers']);
          layers.sort((a, b) => a['depth'].compareTo(b['depth']));
          
          for (var layer in layers) {
            if (layer['visible'] == true) {
              List<List<int>> tileMap = [];
              List<dynamic> rows = layer['tileMap'];
              
              for (var row in rows) {
                List<int> parsedRow = List<int>.from(row);
                tileMap.add(parsedRow);
              }
              
              _tileMaps.add(tileMap);
              
              if (_tileMaps.length == 1) {
                _tilesSheetFile = layer['tilesSheetFile'];
                _tileWidth = layer['tilesWidth'];
                _tileHeight = layer['tilesHeight'];
              }
            }
          }
          
          _isLoaded = true;
          if (kDebugMode) {
            print('Successfully loaded tilemap with ${_tileMaps.length} layers');
            print('Using tileset: $_tilesSheetFile');
          }
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading tilemap data: $e');
      }
      _isLoaded = false;
    }
  }

  void setTile(int layerIndex, int row, int col, int tileValue) {
    if (_tileMaps.isEmpty) return;
    if (layerIndex < 0 || layerIndex >= _tileMaps.length) return;
    
    var layer = _tileMaps[layerIndex];
    if (row < 0 || row >= layer.length) return;
    if (col < 0 || col >= layer[row].length) return;
    
    var updatedLayer = List<List<int>>.from(
      layer.map((row) => List<int>.from(row))
    );
    
    updatedLayer[row][col] = tileValue;
    
    _tileMaps[layerIndex] = updatedLayer;
    
    notifyListeners();
  }

  void fillArea(int layerIndex, int startRow, int startCol, int width, int height, int tileValue) {
    if (_tileMaps.isEmpty) return;
    if (layerIndex < 0 || layerIndex >= _tileMaps.length) return;
    
    var layer = _tileMaps[layerIndex];
    
    var updatedLayer = List<List<int>>.from(
      layer.map((row) => List<int>.from(row))
    );
    
    for (int r = startRow; r < startRow + height; r++) {
      if (r < 0 || r >= updatedLayer.length) continue;
      
      for (int c = startCol; c < startCol + width; c++) {
        if (c < 0 || c >= updatedLayer[r].length) continue;
        updatedLayer[r][c] = tileValue;
      }
    }
    
    _tileMaps[layerIndex] = updatedLayer;
    
    notifyListeners();
  }

  void addLayer() {
    if (_tileMaps.isEmpty) return;
    
    int rows = _tileMaps[0].length;
    int cols = _tileMaps[0][0].length;
    
    List<List<int>> emptyTileMap = List.generate(
      rows, 
      (_) => List.filled(cols, -1)
    );
    
    _tileMaps.add(emptyTileMap);
    
    notifyListeners();
  }

  void removeLayer(int layerIndex) {
    if (_tileMaps.isEmpty) return;
    if (layerIndex < 0 || layerIndex >= _tileMaps.length) return;
    
    _tileMaps.removeAt(layerIndex);
    
    notifyListeners();
  }
}
