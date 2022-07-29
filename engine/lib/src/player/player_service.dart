import 'local_player.dart';
import 'player.dart';

class PlayerService {
  late List<Player> players;

  PlayerService._() {
    players = <Player>[];
  }

  factory PlayerService.createService() {
    return PlayerService._();
  }

  PlayerService.of(PlayerService src) {
    players = <Player>[];
    for (var player in src.players) {
      addPlayer(player.name, player.playerId);
    }
  }

  Player addPlayer(String name, String id) {
    var player = LocalPlayer(name, id);
    players.add(player);
    return player;
  }

  Player getPlayer(String playerId) {
    return players.firstWhere((element) => element.playerId == playerId);
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'players': players.map<Map<String, dynamic>>((e) => e.toJson()).toList(),
      };

  void loadFromJson(Map<String, dynamic> json) {
    // the service should already exist
    var item = json['players'] as List<dynamic>;
    players = item.map<Player>((dynamic json) => playerFromJson(json as Map<String, dynamic>)).toList();
  }
}
