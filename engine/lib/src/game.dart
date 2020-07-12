import 'dart:math';

import 'package:engine/engine.dart';
import 'package:engine/src/player/player_service.dart';
import 'package:uuid/uuid.dart';

import 'turn.dart';

export 'turn.dart';

class Game {
  static const int availableResourceCount = 6;
  static const int level1MarketSize = 4;
  static const int level2MarketSize = 3;
  static const int level3MarketSize = 2;

  Random random;

  List<PlayerData> players;

  String gameId;
  int _nextObjectId = 0;
  Uuid uuidGen;
  PlayerService playerService;
  Map<String, Part> allParts;
  List<ResourceType> availableResources;

  ListState<Part> level1Parts;
  ListState<Part> level2Parts;
  ListState<Part> level3Parts;
  ListState<ResourceType> well;

  ListState<Part> level1Sale;
  ListState<Part> level2Sale;
  ListState<Part> level3Sale;

  List<Turn> gameTurns;

  int _currentTurn;
  Turn get currentTurn => _currentTurn != null ? gameTurns[_currentTurn] : null;

  int _currentPlayerIndex = 0;
  PlayerData get currentPlayer => players[_currentPlayerIndex];

  ChangeStack changeStack;

  Game(this.playerService, this.gameId) {
    random = Random();
    uuidGen = Uuid();
    players = <PlayerData>[];
    for (var p in playerService.players) {
      players.add(PlayerData(this, p));
    }

    allParts = <String, Part>{};

    _createGame();
  }

  String getUuid() {
    return uuidGen.v4();
  }

  void _createGame() {
    // we'll discard this changeStack
    changeStack = ChangeStack();

    // set player order
    players.shuffle();

    createParts(this);
    _fillWell();

    // make the initial resources available
    availableResources = <ResourceType>[];
    for (var i = 0; i < availableResourceCount; i++) {
      availableResources.add(getFromWell());
    }

    // give players their starting parts
    for (var player in players) {
      var startingPart = SimplePart(
          this, nextObjectId(), 0, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.none, 0);
      allParts[startingPart.id] = startingPart;
      player.buyPart(startingPart, <ResourceType>[]);
    }

    // set up the starting market
    level1Sale = ListState<Part>(this, 'lvl1Sale');
    level2Sale = ListState<Part>(this, 'lvl2Sale');
    level3Sale = ListState<Part>(this, 'lvl3Sale');
    refillMarket();
  }

  void _fillWell() {
    well = ListState<ResourceType>(this, 'well');
    for (var i = 0; i < 13; i++) {
      well.add(ResourceType.heart);
      well.add(ResourceType.diamond);
      well.add(ResourceType.club);
      well.add(ResourceType.spade);
    }
  }

  void refillMarket() {
    for (var i = level1Sale.length; i < level1MarketSize; i++) {
      level1Sale.add(level1Parts.removeAt(random.nextInt(level1Parts.length)));
    }
    for (var i = level2Sale.length; i < level2MarketSize; i++) {
      level2Sale.add(level2Parts.removeAt(random.nextInt(level2Parts.length)));
    }
    for (var i = level3Sale.length; i < level3MarketSize; i++) {
      level3Sale.add(level3Parts.removeAt(random.nextInt(level3Parts.length)));
    }
  }

  ResourceType getFromWell() {
    return well.removeAt(random.nextInt(well.length));
  }

  String nextObjectId() {
    var ret = _nextObjectId.toString();
    _nextObjectId++;
    return ret;
  }

  bool applyAction(GameAction action) {
    return false;
  }

  PlayerData getNextPlayer() {
    _currentPlayerIndex = ++_currentPlayerIndex % players.length;
    return currentPlayer;
  }

  PlayerData getPlayerFromId(String id) {
    return players.firstWhere((element) => element.id == id, orElse: () => null);
  }

  Turn startNextTurn() {
    var turn = Turn(this, getNextPlayer());
    gameTurns.add(turn);
    _currentTurn++;

    turn.startTurn();

    return currentTurn;
  }

  void endTurn() {}

  void startGame() {
    // set player order
    players.shuffle();
    _currentPlayerIndex = -1; // so we can call get next
    _currentTurn = 0;
    gameTurns = <Turn>[];

    startNextTurn();
  }

  bool isInDeck(Part part) {
    switch (part.level) {
      case 1:
        return level1Parts.contains(part);
      case 2:
        return level2Parts.contains(part);
      case 3:
        return level3Parts.contains(part);
      default:
        return false;
    }
  }

  /// Remove [part] from either the sale list or a deck.
  void removePart(Part part) {
    if (isInDeck(part)) {
      switch (part.level) {
        case 1:
          level1Parts.remove(part);
          break;
        case 2:
          level2Parts.remove(part);
          break;
        case 3:
          level3Parts.remove(part);
          break;
        default:
          break; // shouldn't be possible
      }
    } else {
      switch (part.level) {
        case 1:
          level1Sale.remove(part);
          break;
        case 2:
          level2Sale.remove(part);
          break;
        case 3:
          level3Sale.remove(part);
          break;
        default:
          throw InvalidOperationError('Invalid part level');
      }
    }
  }

  ResourceType acquireResource(int index) {
    var ret = availableResources.removeAt(index);
    availableResources.add(getFromWell());
    return ret;
  }

  List<Turn> getTurns(int startIndex) {
    if (startIndex < -1 || startIndex > gameTurns.length - 2) {
      return <Turn>[];
    }

    return gameTurns.getRange(startIndex, gameTurns.length).toList();
  }

  bool replayTurns(List<Turn> turns) {
    // validate we are ready
    if (currentTurn.selectedAction != null) {
      // shouldn't be replaying a turn that already has actions
      return false;
    }

    for (var turn in turns) {
      if (turn.player != currentTurn.player) {
        // should match
        return false;
      }
      for (var action in turn.actions) {
        if (ValidateResponseCode.ok != turn.processAction(action)) {
          // something went wrong
          return false;
        }
      }
    }

    return true;
  }
}
