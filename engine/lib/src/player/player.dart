import 'local_player.dart';

enum PlayerType { local, network }

abstract class Player {
  final String/*!*/ name;
  final String/*!*/ playerId;
  PlayerType get playerType;

  Player(this.name, this.playerId);

  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'type': PlayerType.values.indexOf(playerType), 'playerId': playerId};

  Player.fromJson(Map<String, dynamic> json)
      : name = json['name'] as String,
        playerId = json['playerId'] as String;
}

Player playerFromJson(Map<String, dynamic> json) {
  var typeVal = json['type'] as int;
  var type = PlayerType.values[typeVal];
  switch (type) {
    case PlayerType.local:
      return LocalPlayer.fromJson(json);
    case PlayerType.network:
      throw UnimplementedError('network not implemented yet');
    default:
      throw UnimplementedError('No handler for player type $type');
  }
}
