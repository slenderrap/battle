class ServerMessage {
  String type;
  dynamic data;

  ServerMessage(this.type, this.data);

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
    };
  }

  static ServerMessage fromJson(Map<String, dynamic> json) {
    return ServerMessage(
      json['type'],
      json['data'],
    );
  }
}