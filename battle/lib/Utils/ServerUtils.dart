import 'dart:convert';
import 'dart:async';
import 'package:battle/Models/Player.dart';
import 'package:battle/Providers/PlayerProvider.dart';
import 'package:get_it/get_it.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:battle/Models/ServerMessage.dart';


class ServerUtils {
  //static const String host = "aelbakhti.ieti.site";
  // static const int port = 443;
  static const String host = "localhost";
  static const int port = 8888;
  static WebSocketChannel? _channel;
  static StreamSubscription<dynamic>? _subscription;
  static Function? _onDisconnect;

  static Future<void> connectToServer({Function? onDisconnect}) async {
    try {
      _onDisconnect = onDisconnect;
      final uri = Uri.parse('ws://$host:$port');
      _channel = await IOWebSocketChannel.connect(uri);
      print('Connected to server at $uri');
      
      _subscription = _channel!.stream.listen(
        _handleRawMessage,
        onDone: _handleDisconnect,
        onError: (error) {
          print('WebSocket error: $error');
          _handleDisconnect();
        },
      );
    } catch (e) {
      print('Error connecting to server: $e');
      throw Exception('Failed to connect to server: $e');
    }
  }

  static void _handleDisconnect() {
    print('Connection to server closed');
    if (_channel != null) {
      _channel = null;
      if (_onDisconnect != null) {
        _onDisconnect!();
      }
    }
  }

  static void disconnectFromServer() {
    _subscription?.cancel();
    _channel?.sink.close();
    _channel = null;
    print('Disconnected from server');
    if (_onDisconnect != null) {
      _onDisconnect!();
    }
  }

  static Future<String> sendMessage(ServerMessage message) async {
    if (_channel == null) {
      throw Exception('Not connected to server');
    }
    
    final String json = jsonEncode(message.toJson());
    _channel!.sink.add(json);
    return json;
  }

  static void _handleRawMessage(dynamic data) {
    try {
      final String stringData = data.toString();
      final Map<String, dynamic> jsonData = jsonDecode(stringData);
      final ServerMessage message = ServerMessage.fromJson(jsonData);
      _handleServerMessage(message);
    } catch (e) {
      print('Error parsing message: $e, data: $data');
    }
  }

  static void _handleServerMessage(ServerMessage message) {
    final getIt = GetIt.instance;
    final playerProvider = getIt.get<PlayerProvider>();
    
    if (message.type == "connected") {
      Map<String, dynamic> jsonData = message.data;
      Player player = Player.fromJson(jsonData['clientPlayer']);
      playerProvider.addPlayer(player);
      playerProvider.setLocalPlayer(player.id);

      for (Map<String, dynamic> otherPlayers in jsonData['otherPlayers']) {
        Player otherPlayer = Player.fromJson(otherPlayers);
        playerProvider.addPlayer(otherPlayer);
      }
    }
    else if (message.type == "update") {
      Map<String, dynamic> jsonData = message.data;
      Player player = Player.fromJson(jsonData['clientPlayer']);
      
      List<Player> otherPlayersList = [];
      if (jsonData['otherPlayers'] != null) {
        for (var otherPlayerData in jsonData['otherPlayers']) {
          Player otherPlayer = Player.fromJson(otherPlayerData);
          otherPlayersList.add(otherPlayer);
        }
      }
      print("Received update for player ${player.state}");
      playerProvider.updatePlayers(player, otherPlayersList);
    }
  }
}