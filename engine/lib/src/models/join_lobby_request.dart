import 'package:engine/engine.dart';

class JoinLobbyRequest extends GameModel {
  @override
  GameModelType get modelType => GameModelType.joinLobbyRequest;

  final String gameId;
  final String playerName;
  final String? password;

  JoinLobbyRequest(String ownerId, this.gameId, this.playerName, this.password) : super('create', ownerId, 'joinLobby request');

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['gameId'] = gameId;
    ret['playerName'] = playerName;
    ret['password'] = password;
    return ret;
  }

  JoinLobbyRequest.fromJson(Map<String, dynamic> json)
      : gameId = json['gameId'] as String,
        playerName = json['playerName'] as String,
        password = json['password'] as String?,
        super.fromJson(json);
}
