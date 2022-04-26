import 'dart:async';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';
import 'package:factorymatics/src/game_info_model.dart';
import 'package:flutter/cupertino.dart';

class MainPageModel {
  Game game;
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  final BuildContext context;
  bool isLocalGame = true;
  List<String> players = <String>['Player1', 'AI1', 'AI2', 'AI3'];
  int numPlayers = 4;
  GameInfoModel gameInfoModel;

  MainPageModel(this.context);

  Future<void> init() async {
    // Future.delayed(Duration(milliseconds: 100), () {
    //   _notifierController.add(1);
    // });
  }

  Future<void> createLocalGame() async {
    PlayerService playerService;
    LocalClient client;
    String gameId;

    playerService = PlayerService.createService();
    client = LocalClient(players.take(numPlayers).toList());
    var response = await client.postRequest(CreateLobbyRequest(players[0], 'game_name', players[0], ''));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    gameId = (response as CreateLobbyResponse).gameId;
    for (var index = 1; index < numPlayers; ++index) {
      response = await client.postRequest(JoinLobbyRequest(players[index], gameId, players[index], ''));
      if (response.responseCode != ResponseCode.ok) {
        _notifierController.addError(null);
      }
    }
    response = await client.postRequest(CreateGameRequest(gameId, players[0]));
    if (response.responseCode != ResponseCode.ok) {
      _notifierController.addError(null);
    }
    var createGameResponse = response as CreateGameResponse;
    if (createGameResponse != null) {
      players = createGameResponse.players;
      for (var player in createGameResponse.players) {
        playerService.addPlayer(player, player);
      }
    }
    gameInfoModel = GameInfoModel(client, playerService, gameId);
  }
}
