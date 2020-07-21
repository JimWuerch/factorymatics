import 'dart:math';

import 'package:engine/engine.dart';
import 'package:engine/src/player/player_service.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import 'turn.dart';

export 'turn.dart';

class Game {
  static const int availableResourceCount = 6;
  static const int level1MarketSize = 4;
  static const int level2MarketSize = 3;
  static const int level3MarketSize = 2;

  List<PlayerData> players;

  String tmpName;

  String gameId;
  int _nextObjectId = 0;
  Uuid uuidGen;
  PlayerService playerService;
  Map<String, Part> allParts;
  Random random = Random();

  ListState<ResourceType> availableResources;

  List<ListState<Part>> partDecks;
  // ListState<Part> level2Parts;
  // ListState<Part> level3Parts;
  ListState<ResourceType> well;

  List<ListState<Part>> saleParts;
  // ListState<Part> level2Sale;
  // ListState<Part> level3Sale;

  //List<Turn> gameTurns;

  //int _currentTurn;
  Turn currentTurn; // => _currentTurn != null ? gameTurns[_currentTurn] : null;

  int _currentPlayerIndex = 0;
  PlayerData get currentPlayer => players[_currentPlayerIndex];

  ChangeStack changeStack;

  Game(List<String> playerNames, this.playerService, this.gameId) {
    uuidGen = Uuid();
    players = <PlayerData>[];
    for (var p in playerNames) {
      var playerId = playerService != null ? playerService.getPlayer(p).playerId : p;
      players.add(PlayerData(this, playerId));
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

    partDecks = List<ListState<Part>>(3);
    well = ListState<ResourceType>(this, 'well');
    availableResources = ListState(this, 'availableResources');
    saleParts = List<ListState<Part>>(3);
    for (var i = 0; i < 3; ++i) {
      saleParts[i] = ListState<Part>(this, 'lvl${i}Sale');
    }
    createParts(this);

    // give players their starting parts
    for (var player in players) {
      var startingPart = SimplePart(
          this, "0", -1, PartType.storage, 0, [StoreTrigger()], [MysteryMeatProduct()], ResourceType.none, 0);
      //allParts[startingPart.id] = startingPart;
      player.buyPart(startingPart, <ResourceType>[]);
    }
  }

  void assignStartingDecks(List<List<Part>> decks) {
    for (var i = 0; i < 3; ++i) {
      partDecks[i] = ListState<Part>(this, 'lvl${i}Deck', starting: decks[i]);
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

  Part drawPart(int level) {
    return partDecks[level].removeLast();
  }

  /// Puts [part] back on the bottom of its deck
  void returnPart(Part part) {
    partDecks[part.level].insert(part, 0);
  }

  void refillMarket() {
    for (var i = saleParts[0].length; i < Game.level1MarketSize; i++) {
      saleParts[0].add(drawPart(0));
    }
    for (var i = saleParts[1].length; i < Game.level2MarketSize; i++) {
      saleParts[1].add(drawPart(1));
    }
    for (var i = saleParts[2].length; i < Game.level3MarketSize; i++) {
      saleParts[2].add(drawPart(2));
    }
  }

  String nextObjectId() {
    var ret = _nextObjectId.toString();
    _nextObjectId++;
    return ret;
  }

  Tuple2<ValidateResponseCode, GameAction> applyAction(GameAction action) {
    return currentTurn.processAction(action);
  }

  PlayerData getNextPlayer() {
    _currentPlayerIndex = ++_currentPlayerIndex % players.length;
    return currentPlayer;
  }

  PlayerData getPlayerFromId(String id) {
    return players.firstWhere((element) => element.id == id, orElse: () => null);
  }

  Turn startNextTurn() {
    changeStack = ChangeStack();
    refillMarket();
    refillResources();
    changeStack.clear();

    currentTurn = Turn(this, getNextPlayer());
    //gameTurns.add(turn);
    //_currentTurn++;

    //turn.startTurn();

    return currentTurn;
  }

  void endTurn() {
    // check for game end

    // if game not over, next turn
    startNextTurn();
  }

  void createGame() {
    // do one-time stuff here
    _fillWell();
  }

  void startGame() {
    _currentPlayerIndex = -1; // so we can call get next
    // _currentTurn = -1;
    // gameTurns = <Turn>[];
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

    if (currentTurn != null) {
      ret['turn'] = currentTurn.toJson();
    }

    return ret;
  }

  factory Game.fromJson(List<String> players, PlayerService playerService, Map<String, dynamic> json) {
    var gameId = json['gameId'] as String;

    var game = Game(players, playerService, gameId);
    game.changeStack = ChangeStack(); // we'll discard this
    partStringToList(json['s1'] as String, (part) => game.saleParts[0].add(part), game.allParts);
    partStringToList(json['s2'] as String, (part) => game.saleParts[1].add(part), game.allParts);
    partStringToList(json['s3'] as String, (part) => game.saleParts[2].add(part), game.allParts);
    stringToResourceListState(json['res'] as String, game.availableResources);

    game._currentPlayerIndex = json['cp'] as int;

    if (json.containsKey('turn')) {
      game.currentTurn = Turn.fromJson(game, game.currentPlayer, json['turn'] as Map<String, dynamic>);
    } else {
      game.currentTurn = Turn(game, game.currentPlayer);
    }

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
