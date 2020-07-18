import 'package:engine/engine.dart';

class CreateLobbyRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.createLobbyRequest;

  final String gameName;
  final String playerName;
  final String password;

  CreateLobbyRequest(String ownerId, this.gameName, this.playerName, this.password)
      : super('create', ownerId, 'createLobby request');

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['gameName'] = gameName;
    ret['playerName'] = playerName;
    ret['password'] = password;
    return ret;
  }

  CreateLobbyRequest.fromJson(Map<String, dynamic> json)
      : gameName = json['gameName'] as String,
        playerName = json['playerName'] as String,
        password = json['password'] as String,
        super.fromJson(json);
}
