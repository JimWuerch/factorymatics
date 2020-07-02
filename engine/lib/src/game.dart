import 'dart:collection';

import 'package:engine/engine.dart';

class Game {
  List<Player> players;
  List<Part> level1Parts;
  List<Part> level2Parts;
  List<Part> level3Parts;
  List<ResourceType> well;
  String gameId;
  Queue<ResourceType> availableResources;
  int _nextObjectId = 0;

  Game(this.players, this.gameId) {
    _createGame();
  }

  void _createGame() {
    // set player order
    players.shuffle();

    //loadParts();
    _fillWell();

    // make the initial resources available
    availableResources = Queue<ResourceType>();
    for (var i = 0; i < 6; i++) {
      availableResources.addLast(getFromWell());
    }

    // give players their starting parts
    for (var player in players) {
      var startingPart = SimplePart(
          nextObjectId(), 0, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.none, 0);
      player.buyPart(startingPart, <ResourceType>[]);
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
}
