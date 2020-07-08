import 'dart:collection';

import 'package:engine/engine.dart';
import 'package:engine/src/player/player_service.dart';
import 'package:uuid/uuid.dart';

class Game {
  List<PlayerData> players;
  List<Part> level1Parts;
  List<Part> level2Parts;
  List<Part> level3Parts;
  List<ResourceType> well;
  String gameId;
  int _nextObjectId = 0;
  ChangeStack changeStack;
  Uuid uuidGen;
  PlayerService playerService;
  Map<String, Part> allParts;

  Queue<ResourceType> availableResources;
  List<Part> level1Sale;
  List<Part> level2Sale;
  List<Part> level3Sale;

  Game(this.playerService, this.gameId) {
    uuidGen = Uuid();
    players = <PlayerData>[];
    for (var p in playerService.players) {
      players.add(PlayerData(this, p));
    }

    _createGame();
  }

  String getUuid() {
    return uuidGen.v4();
  }

  void _createGame() {
    // set player order
    players.shuffle();

    createParts(this);
    _fillWell();

    // make the initial resources available
    availableResources = Queue<ResourceType>();
    for (var i = 0; i < 6; i++) {
      availableResources.addLast(getFromWell());
    }

    // give players their starting parts
    for (var player in players) {
      var startingPart = SimplePart(
          this, nextObjectId(), 0, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.none, 0);
      allParts[startingPart.id] = startingPart;
      player.buyPart(startingPart, <ResourceType>[]);
    }

    // set up the starting market
    level1Sale = List<Part>(4);
    level2Sale = List<Part>(3);
    level3Sale = List<Part>(2);
    for (var i = 0; i < 4; i++) {
      level1Sale[i] = level1Parts.removeLast();
    }
    for (var i = 0; i < 3; i++) {
      level2Sale[i] = level2Parts.removeLast();
    }
    for (var i = 0; i < 2; i++) {
      level3Sale[i] = level3Parts.removeLast();
    }
  }

  void _fillWell() {
    well = <ResourceType>[];
    for (var i = 0; i < 13; i++) {
      well.add(ResourceType.heart);
      well.add(ResourceType.diamond);
      well.add(ResourceType.club);
      well.add(ResourceType.spade);
    }
    well.shuffle();
  }

  ResourceType getFromWell() {
    return well.removeLast();
  }

  String nextObjectId() {
    var ret = _nextObjectId.toString();
    _nextObjectId++;
    return ret;
  }

  bool applyAction(GameAction action) {
    return false;
  }
}