import 'dart:math';

import 'package:engine/engine.dart';
import 'package:engine/src/ai/ai_player.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

export 'turn.dart';

Map<String, Part> allParts = _createAllParts();

Map<String, Part> _createAllParts() {
  var ret = <String, Part>{};
  var parts = createParts();
  for (var part in parts) {
    ret[part.id] = part;
  }
  return ret;
}

class Game {
  static const int availableResourceCount = 6;
  static const int level1MarketSize = 4;
  static const int level2MarketSize = 3;
  static const int level3MarketSize = 2;

  bool testMode = false;

  List<PlayerData> players;

  String tmpName;

  String gameId;
  int nextObjectId = 0;
  Uuid uuidGen;
  PlayerService playerService;
  //Map<String, Part> allParts;
  Random random = Random();

  ListState<ResourceType> availableResources;

  List<ListState<Part>> partDecks;
  List<int> partsRemaining; // this is maintained for the client to query
  ListState<ResourceType> well;
  List<ListState<Part>> saleParts;
  CalcResources calcResources;
  Turn currentTurn;
  int round = 0;
  bool gameEndTriggered = false;

  int _currentPlayerIndex = 0;
  PlayerData get currentPlayer => players[_currentPlayerIndex];

  ChangeStack changeStack;

  // set true if GameController is saving the game
  bool isAuthoritativeSave = false;

  // this is only set for the client, it is not used or accurate for the server
  bool canUndo;

  // if the ai is simulating a game, this is true
  bool inSimulation = false;

  Game(List<String> playerNames, this.playerService, this.gameId) {
    _initialize();

    changeStack = ChangeStack(); // we'll throw this away
    for (var p in playerNames) {
      var playerId = playerService != null ? playerService.getPlayer(p).playerId : p;
      players.add(PlayerData(this, playerId));
    }
    changeStack.clear();

    _createGame();
    _giveStartingParts();
  }

  Game._fromSerialize(this.gameId, this.playerService) {
    _initialize();
    _createGame();
  }

  void _initialize() {
    //allParts = <String, Part>{};
    uuidGen = Uuid();
    players = <PlayerData>[];
    calcResources = CalcResources();
  }

  String getUuid() {
    return uuidGen.v4();
  }

  void _giveStartingParts() {
    // give players their starting parts
    for (var player in players) {
      player.buyPart(allParts[Part.startingPartId]);
    }
  }

  void _createGame() {
    // we'll discard this changeStack
    changeStack = ChangeStack();

    partDecks = List<ListState<Part>>.filled(3, null);
    partsRemaining = List<int>.filled(3, 0);
    well = ListState<ResourceType>(this, 'well');
    availableResources = ListState(this, 'availableResources');
    saleParts = List<ListState<Part>>.filled(3, null);
    for (var i = 0; i < 3; ++i) {
      saleParts[i] = ListState<Part>(this, 'lvl${i}Sale');
    }
    // var parts = createParts(this);
    // for (var part in parts) {
    //   allParts[part.id] = part;
    // }
  }

  void assignStartingDecks(List<List<Part>> decks) {
    for (var i = 0; i < 3; ++i) {
      partDecks[i] = ListState<Part>(this, 'lvl${i}Deck', starting: decks[i]);
      partsRemaining[i] = partDecks[i].length;
    }
  }

  void _fillWell() {
    for (var i = 0; i < 13; i++) {
      well.add(ResourceType.heart);
      well.add(ResourceType.diamond);
      well.add(ResourceType.club);
      well.add(ResourceType.spade);
    }
  }

  ResourceType getFromWell() {
    return well.removeAt(random.nextInt(well.length));
  }

  void addToWell(ResourceType resource) {
    well.add(resource);
  }

  void refillResources() {
    for (var i = availableResources.length; i < Game.availableResourceCount; i++) {
      availableResources.add(getFromWell());
    }
  }

  PlayerData getPartOwner(Part part) {
    for (var player in players) {
      for (var p in player.parts[part.partType]) {
        if (p.id == part.id) {
          return player;
        }
      }
      for (var p in player.savedParts) {
        if (p.id == part.id) {
          return player;
        }
      }
    }
    return null;
  }

  Part drawPart(int level) {
    Part ret;
    ret = partDecks[level].removeLast();
    partsRemaining[level] = partDecks[level].length;
    return ret;
  }

  /// Puts [part] back on the bottom of its deck
  void returnPart(Part part) {
    partDecks[part.level].insert(part, 0);
    partsRemaining[part.level] = partDecks[part.level].length;
  }

  void refillMarket() {
    for (var i = saleParts[0].length; i < Game.level1MarketSize; i++) {
      if (!partDecks[0].isEmpty) {
        saleParts[0].add(drawPart(0));
      }
    }
    for (var i = saleParts[1].length; i < Game.level2MarketSize; i++) {
      if (!partDecks[1].isEmpty) {
        saleParts[1].add(drawPart(1));
      }
    }
    for (var i = saleParts[2].length; i < Game.level3MarketSize; i++) {
      if (!partDecks[2].isEmpty) {
        saleParts[2].add(drawPart(2));
      }
    }
  }

  Tuple2<ValidateResponseCode, GameAction> applyAction(GameAction action) {
    if (action is GameModeAction && action.mode == GameModeType.doAiTurn) {
      var ai = AiPlayer(getPlayerFromId(action.owner));
      ai.takeTurn(this);
      return Tuple2<ValidateResponseCode, GameAction>(ValidateResponseCode.ok, null);
    }
    return currentTurn.processAction(action);
  }

  PlayerData getNextPlayer() {
    _currentPlayerIndex = ++_currentPlayerIndex % players.length;
    return currentPlayer;
  }

  PlayerData getPlayerFromId(String id) {
    return players.firstWhere((element) => element.id == id, orElse: () => null);
  }

  PlayerData getWinner() {
    var firstPass = <PlayerData>[];
    var secondPass = <PlayerData>[];
    var thirdPass = <PlayerData>[];

    // first get the high score
    var _highScore = -1;
    for (var player in players) {
      if (player.score > _highScore) {
        firstPass.clear();
        firstPass.add(player);
        _highScore = player.score;
      } else if (player.score == _highScore) {
        firstPass.add(player);
      }
    }
    if (firstPass.length == 1) {
      // only 1 winner
      return firstPass.first;
    } else {
      var parts = 0;
      for (var player in firstPass) {
        if (player.partCount >= parts) {
          secondPass.add(player);
          parts = player.partCount;
        }
      }
      if (secondPass.length == 1) {
        // found a winner
        return secondPass.first;
      } else {
        var resources = -1;
        for (var player in secondPass) {
          if (player.resourceCount() >= resources) {
            thirdPass.add(player);
            resources = player.resourceCount();
          }
        }
        // if there's still more than 1 player left,
        // the last tiebreaker is whoever went later in turn order, which will be the last player in the list
        return thirdPass.last;
      }
    }
  }

  Turn startNextTurn() {
    if (currentTurn?.gameEnded == true) {
      return currentTurn;
    }

    changeStack = ChangeStack();
    refillMarket();
    refillResources();
    changeStack.clear();

    if (inSimulation) {
      currentTurn = Turn(this, currentPlayer);
      round++;
    } else {
      currentTurn = Turn(this, getNextPlayer());
      if (_currentPlayerIndex == 0) {
        round++;
      }
    }
    currentTurn.startTurn();

    return currentTurn;
  }

  void endTurn() {
    // check for game end at end of round
    if (gameEndTriggered && ((_currentPlayerIndex == players.length - 1) || inSimulation)) {
      // if (currentTurn.isGameEndTriggered && (_currentPlayerIndex == players.length - 1)) {
      currentTurn.setGameComplete();
    } else {
      // if game not over, next turn
      startNextTurn();
    }
  }

  void createGame() {
    // do one-time stuff here
    _fillWell();
  }

  void startGame() {
    _currentPlayerIndex = -1; // so we can call get next
  }

  bool isInDeck(Part part) {
    return partDecks[part.level].contains(part);
  }

  bool isForSale(Part part) {
    return saleParts[part.level].contains(part);
  }

  /// Remove [part] from either the sale list or a deck.
  bool removePart(Part part) {
    if (isInDeck(part)) {
      return partDecks[part.level].remove(part);
    } else if (isForSale(part)) {
      return saleParts[part.level].remove(part);
    }
    return false;
  }

  /// Returns playerIds unless non-authoritative, in which case player names are returned
  List<String> getPlayerIds() {
    var ret = <String>[];
    for (var player in players) {
      ret.add(playerService != null ? playerService.getPlayer(player.id).name : player.id);
    }

    return ret;
  }

  List<String> getPlayerNames() {
    var ret = <String>[];
    for (var player in players) {
      ret.add(playerService.getPlayer(player.id).name);
    }
    return ret;
  }

  ResourceType acquireResource(int index) {
    var ret = availableResources.removeAt(index);
    availableResources.add(getFromWell());
    return ret;
  }

  // List<String> _playerDataToStringList(List<PlayerData> players) {
  //   var ret = <String>[];
  //   for (var player in players) {
  //     ret.add(playerService.getPlayer(player.id).name);
  //   }
  // }

  // List<PlayerData> _playerDataFromStringList(Game game, List<String> names) {
  //   var ret = <PlayerData>[];
  //   for (var name in names) {
  //     ret.add(PlayerData(game, game.playerService.getPlayer(playerId)));
  //   }
  // }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{};
    ret['gameId'] = gameId;
    ret['res'] = resourceListToString(availableResources.toList());
    ret['s1'] = partListToString(saleParts[0].toList());
    ret['s2'] = partListToString(saleParts[1].toList());
    ret['s3'] = partListToString(saleParts[2].toList());
    ret['cp'] = _currentPlayerIndex;
    ret['players'] = players.map<Map<String, dynamic>>((e) => e.toJson()).toList();
    ret['pr'] = partsRemaining;
    ret['rd'] = round;
    ret['end'] = gameEndTriggered;

    if (!isAuthoritativeSave) {
      // only the client uses this value, it's not saved/restored on the server
      ret['canUndo'] = changeStack.canUndo;
    }

    if (currentTurn != null) {
      ret['turn'] = currentTurn.toJson();
    }

    return ret;
  }

  factory Game.fromJson(PlayerService playerService, Map<String, dynamic> json) {
    var gameId = json['gameId'] as String;

    var game = Game._fromSerialize(gameId, playerService);
    var changeStack = ChangeStack(); // we'll discard this
    game.changeStack = changeStack;
    partStringToList(json['s1'] as String, (part) => game.saleParts[0].add(part), allParts);
    partStringToList(json['s2'] as String, (part) => game.saleParts[1].add(part), allParts);
    partStringToList(json['s3'] as String, (part) => game.saleParts[2].add(part), allParts);
    stringToResourceListState(json['res'] as String, game.availableResources);

    game.partsRemaining = listFromJson<int>(json['pr']);

    game._currentPlayerIndex = json['cp'] as int;
    game.round = json['rd'] as int;
    game.gameEndTriggered = json['end'] as bool;

    var item = json['players'] as List<dynamic>;
    game.players =
        item.map<PlayerData>((dynamic json) => PlayerData.fromJson(game, json as Map<String, dynamic>)).toList();

    if (json.containsKey('turn')) {
      game.currentTurn = Turn.fromJson(game, game.currentPlayer, json['turn'] as Map<String, dynamic>);
    } else {
      game.currentTurn = Turn(game, game.currentPlayer);
    }

    if (json.containsKey('canUndo')) {
      game.canUndo = json['canUndo'] as bool;
    }

    // game.changeStack will be pointed at turn.changeStack, so we can clear our local copy
    changeStack.clear();

    return game;
  }
}

String partListToString(List<Part> parts) {
  var buf = StringBuffer();
  for (var part in parts) {
    var i = int.parse(part.id);
    buf.write(i.toRadixString(16).padLeft(2, "0"));
  }
  return buf.toString();
}

void partStringToList(String src, void Function(Part) addFn, Map<String, Part> allParts) {
  for (var i = 0; i <= src.length - 2; i += 2) {
    var hex = src.substring(i, i + 2);
    var partId = int.parse(hex, radix: 16).toString();
    addFn(allParts[partId]);
  }
}

void stringToResourceListState(String src, ListState<ResourceType> list) {
  var resources = stringToResourceList(src);
  for (var resource in resources) {
    list.add(resource);
  }
}
