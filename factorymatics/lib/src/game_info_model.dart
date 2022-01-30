import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';

/// GameInfoModel holds the connected/created game info
class GameInfoModel {
  final String gameId;
  final PlayerService playerService;
  final Client client;

  GameInfoModel(this.client, this.playerService, this.gameId);
}
