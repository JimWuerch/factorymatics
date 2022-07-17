import 'dart:isolate';

import 'package:engine/engine.dart';
import 'package:engine/src/ai/monte_carlo_tree_search.dart';
import 'package:tuple/tuple.dart';

class AiPlayer {
  //final Game srcGame;
  final PlayerData aiPlayer;
  //GameController gc = GameController();
  //Stopwatch stopwatch = Stopwatch()..start();

  AiPlayer(this.aiPlayer);
  //int gameCount = 0;
  static Game _duplicateGame(Game game) {
    var gc = GameController();
    gc.game = game;
    var g = gc.gameFromJson(game.playerService, gc.toJson());
    gc.game = null;
    g.inSimulation = true;
    //g.nextObjectId = ++gameCount;
    return g;
  }

  void takeTurn(Game game) {
    var best = _takeTurnInternal(game);
    // rehome action to this game
    if (best != null) {
      var srcAction = actionFromJson(game, best.action.toJson());
      _finishTurn(game, best.selectedAction, srcAction);
    } else {
      _finishTurn(game, ActionType.gameMode, null); // gameMode is a placeholder
    }
  }

  Future<void> takeTurnAsync(Game game) async {
    final p = ReceivePort();
    var gc = GameController();
    gc.game = game;
    await Isolate.spawn(_takeTurnIsolate, Tuple3(p.sendPort, gc.toJson(), game.playerService.toJson()));
    var json = await p.first as Map<String, dynamic>;
    if (json != null) {
      var srcAction = actionFromJson(game, json['action'] as Map<String, dynamic>);
      var selectedAction = ActionType.values[json['selected'] as int];
      _finishTurn(game, selectedAction, srcAction);
    } else {
      _finishTurn(game, ActionType.gameMode, null); // gameMode is a placeholder
    }
  }

  void _finishTurn(Game game, ActionType selectedAction, GameAction srcAction) {
    if (srcAction != null) {
      _takeSelectActionAction(game, selectedAction);
      // re-home action to this game, as internal bits point to other game objects
      var action = actionFromJson(game, srcAction.toJson());
      _processAction(game, action);
      _doTriggers(game);
    }
    _processAction(game, GameModeAction(game.currentPlayer.id, GameModeType.endTurn));
  }

  Future<void> _takeTurnIsolate(Tuple3<SendPort, Map<String, dynamic>, Map<String, dynamic>> input) async {
    var port = input.item1;
    var gc = GameController();
    var playerService = PlayerService.createService();
    playerService.loadFromJson(input.item3);
    var startGame = gc.gameFromJson(playerService, input.item2);
    var best = _takeTurnInternal(startGame);
    Isolate.exit(port, best != null ? best.toJson() : null);
  }

  /// Take the turn of game.currentPlayer
  MCTSNode _takeTurnInternal(Game startGame) {
    // now calculate the best action
    var ts = MCTreeSearch(startGame);

    var stopwatch = Stopwatch()..start();
    var count = 0;
    for (var loop = 0; loop < gameSettings.aiTurnIterations; ++loop) {
      count = loop;
      // if (loop % 1000 == 0) {
      //   print('loop $loop');
      // }
      //if (stopwatch.elapsedMilliseconds > 10000) break;
      var node = ts.root;
      // find leaf node
      while (node.visits != 0) {
        if (node.children.isEmpty) {
          break;
        }
        node = node.getBestChild();
      }
      if (stopwatch.elapsedMilliseconds > gameSettings.aiTurnTime &&
          ts.root.getMostVistedChild().visits >= gameSettings.aiMinVisits) break;
      if (stopwatch.elapsedMilliseconds > gameSettings.aiTurnTimeCutoff) break;
      if (node.game.currentTurn.gameEnded) {
        _backPropagate(node, _gameScore(node.game, 0));
        continue;
      }
      // we are at a leaf, so generate new child nodes for every action
      var actions = node.game.currentTurn.getAvailableActions(isAi: true);
      if (actions.length == 1) {
        //var newNode = MCTSNode(node, _duplicateGame(node.game));
        //newNode.visits++;
        //node.visits++;
        _backPropagate(node, 0.0);
        continue;
      }
      // force the AI to construct early game if it can, otherwise, prioritize storing one of the 4 acquire after build parts
      List<GameAction> forceStore;
      if (node.game.round <= 8) {
        // if we can construct, we must.
        var forceConstruct = <GameAction>[];
        for (var action in actions) {
          if (action is SelectActionAction && action.selectedAction == ActionType.construct) {
            forceConstruct.add(action);
          }
        }
        if (forceConstruct.isNotEmpty) {
          actions = forceConstruct;
        } else if (node.game.currentPlayer.hasPartStorageSpace && node.game.currentPlayer.canStore) {
          forceStore = <GameAction>[];
          for (var part in node.game.saleParts[0]) {
            if (part.id == '4' || part.id == '16' || part.id == '17' || part.id == '18') {
              forceStore.add(StoreAction(node.game.currentPlayer.id, part, null));
            }
          }
          if (forceStore.isNotEmpty) {
            actions = <GameAction>[SelectActionAction(node.game.currentPlayer.id, ActionType.store)];
          } else {
            forceStore = null;
          }
        }
      }
      if (node.game.currentPlayer.maxResources == null) {
        node.game.currentPlayer.updateMaxResources(node.game.currentTurn);
      }
      for (var action in actions) {
        var tmpGame = _duplicateGame(node.game);
        var a = action as SelectActionAction;
        _takeSelectActionAction(tmpGame, a.selectedAction);
        switch (a.selectedAction) {
          case ActionType.construct:
            var constructActions = tmpGame.currentTurn.getAvailableActions(isAi: true);
            for (var a2 in constructActions) {
              var newNode = MCTSNode(node, _duplicateGame(tmpGame));
              if (newNode.parent == ts.root) {
                newNode.action = a2;
              }
              newNode.selectedAction = a.selectedAction;
              _constructPart(newNode.game, (a2 as ConstructAction).part, node: newNode);
              _doTriggers(newNode.game);
              _processAction(newNode.game, GameModeAction(node.game.currentPlayer.id, GameModeType.endTurn));
            }
            break;

          case ActionType.acquire:
            // create a leaf for picking each resource type available
            for (var rt in ResourceType.values) {
              var i = tmpGame.availableResources.indexOf(rt);
              if (i != -1) {
                var newNode = MCTSNode(node, _duplicateGame(tmpGame));
                var a2 = AcquireAction(node.game.currentPlayer.id, i, null);
                if (newNode.parent == ts.root) {
                  newNode.action = a2;
                }
                newNode.selectedAction = a.selectedAction;
                _processAction(newNode.game, a2);
                _doTriggers(newNode.game);
                _processAction(newNode.game, GameModeAction(node.game.currentPlayer.id, GameModeType.endTurn));
              }
            }
            break;

          case ActionType.store:
            {
              List<GameAction> storeActions;
              if (forceStore != null) {
                storeActions = forceStore;
              } else {
                storeActions = tmpGame.currentTurn.getAvailableActions(isAi: true);
              }
              for (var a2 in storeActions) {
                if (a2 is StoreAction && tmpGame.round <= 5 && a2.part.cost > 3) {
                  continue;
                }
                var newNode = MCTSNode(node, _duplicateGame(tmpGame));
                if (newNode.parent == ts.root) {
                  newNode.action = a2;
                }
                newNode.selectedAction = a.selectedAction;
                _processAction(newNode.game, a2);
                _doTriggers(newNode.game);
                _processAction(newNode.game, GameModeAction(node.game.currentPlayer.id, GameModeType.endTurn));
              }
            }
            break;

          case ActionType.search:
            {
              // game = _duplicateGame(game);
              // _takeSelectActionAction(ActionType.search);

            }
            break;

          default:
            break;
        }
        tmpGame = null;
      }
      if (node.children.isEmpty) {
        print('bad juju');
      }

      // now rollout from the first child
      var rGame = _rollout(node.children.first.game);
      var score = _gameScore(rGame, node.children.first.game.currentPlayer.resourceCount() / 2.0);
      _backPropagate(node.children.first, score);
    }
    var best = ts.root.getMostVistedChild();
    if (best != null) {
      print(
          '${best.action.owner} took action (${startGame.round}): ${best.action.actionType} score:${best.score}/${best.score - ts.root.getExplorationScore(best)} avg:${best.score / best.visits} visits:${best.visits}/$count time:${stopwatch.elapsedMilliseconds}');
    } else {
      print('${aiPlayer.id} skipped (${startGame.round})');
    }
    return best;
  }

  void _backPropagate(MCTSNode node, double score) {
    while (node != null) {
      node.score += score;
      node.visits++;
      node = node.parent;
    }
  }

  static double _gameScore(Game game, double resources) {
    var score = (game.currentPlayer.score + resources) / (game.round);
    if (game.round > 28 || score < 0.0) {
      //if (score < 0.0) {
      return 0;
    } else {
      return score;
    }

    // var score = game.currentPlayer.score - (game.round - 20) * 3;
    // if (score > 0) {
    //   return score.toDouble();
    // } else {
    //   return 0.0;
    // }

    // var bonus = (25 - game.round) * 4;
    // if (bonus < 0) {
    //   bonus = 0;
    // }
    // if (game.round < 25) {
    //   //return (game.currentPlayer.score.toDouble() + bonus) / game.round.toDouble();
    //   return game.currentPlayer.score.toDouble() + bonus;
    // } else {
    //   return 0.0;
    // }
  }

  Game _rollout(Game srcGame) {
    var stopWatch = Stopwatch()..start();
    var game = _duplicateGame(srcGame);
    gameSettings.maxTimeCalcResources = gameSettings.maxTimeCalcResourcesAi;
    try {
      while (!game.currentTurn.gameEnded &&
          game.round <= 32 &&
          stopWatch.elapsedMilliseconds < gameSettings.maxAiRolloutTime) {
        //rounds++;
        if (game.currentTurn.turnState == TurnState.notStarted) {
          _processAction(game, GameModeAction(game.currentPlayer.id, GameModeType.startTurn));
        }

        var selectedActions = game.currentTurn.getAvailableActions(isAi: true);
        if (selectedActions.isEmpty) {
          // can't do anything, just end turn
          _processAction(game, GameModeAction(game.currentPlayer.id, GameModeType.endTurn));
          continue;
        }

        // var i = selectedActions
        //     .indexWhere((element) => (element as SelectActionAction).selectedAction == ActionType.construct);
        // if (i != -1) {
        //   // do construct if we can
        //   _processAction(game, selectedActions[i]);
        //   takeConstructTurn(game);
        // } else {
        //   // make a list of what we'd like to do
        //   var wanted = <SelectActionAction>[];
        //   var i = selectedActions
        //       .indexWhere((element) => (element as SelectActionAction).selectedAction == ActionType.acquire);
        //   if (i != -1) {
        //     wanted.add(selectedActions[i] as SelectActionAction);
        //   }
        //   i = selectedActions.indexWhere((element) => (element as SelectActionAction).selectedAction == ActionType.store);
        //   if (i != -1) {
        //     wanted.add(selectedActions[i] as SelectActionAction);
        //   }
        //   if (wanted.isEmpty) {
        //     // the only action we can do is to search
        //     _processAction(game, selectedActions.first);
        //     takeSearchTurn(game);
        //   } else {
        //     var i = game.random.nextInt(wanted.length);
        //     _processAction(game, wanted[i]);
        //     if (wanted[i].selectedAction == ActionType.acquire) {
        //       takeAcquireTurn(game);
        //     } else {
        //       takeStoreTurn(game);
        //     }
        //   }
        // }

        if (stopWatch.elapsedMilliseconds < gameSettings.maxAiRolloutTime) {
          var i = game.random.nextInt(selectedActions.length);
          _processAction(game, selectedActions[i]);
          if ((selectedActions[i] as SelectActionAction).selectedAction == ActionType.acquire) {
            takeAcquireTurn(game);
          } else if ((selectedActions[i] as SelectActionAction).selectedAction == ActionType.construct) {
            takeConstructTurn(game);
          } else if ((selectedActions[i] as SelectActionAction).selectedAction == ActionType.store) {
            takeStoreTurn(game);
          } else if ((selectedActions[i] as SelectActionAction).selectedAction == ActionType.search) {
            takeSearchTurn(game);
          } else {
            throw InvalidOperationError('shouldnt get here, unknown action');
          }

          if (stopWatch.elapsedMilliseconds < gameSettings.maxAiRolloutTime) {
            _doTriggers(game);
            _processAction(game, GameModeAction(game.currentPlayer.id, GameModeType.endTurn));
          }
        }
      }
    } on TimeoutCalcResources {
      game.currentPlayer.invalidateMaxResources();
      //print('rollout timeout: ${stopWatch.elapsedMilliseconds}');
    }
    gameSettings.maxTimeCalcResources = 0;
    return game;
  }

  static int _optimalResource(Game game) {
    // we want to pick a resource that we can use.  So first, we want one that matches our part in storage
    if (game.currentPlayer.savedParts.isNotEmpty) {
      var i = game.availableResources.list.indexOf(game.currentPlayer.savedParts.first.resource);
      if (i != -1) {
        return i;
      }
    }
    // next try to pick a resource that matches one of our converters, if we don't already have one
    for (var part in game.currentPlayer.parts[PartType.converter]) {
      var i = game.availableResources.list.indexOf((part.products[0] as ConverterBaseProduct).sourceResource);
      if (i != -1 && game.currentPlayer.resources[game.availableResources[i]].value == 0) {
        return i;
      }
    }
    // next try to pick one of a color we already have more than 1 of
    // for (var rt in ResourceType.values) {
    //   if (rt == ResourceType.any || rt == ResourceType.none) continue;
    //   if (game.currentPlayer.resources[rt].value > 1) {
    //     var i = game.availableResources.list.indexOf(rt);
    //     if (i != -1) {
    //       return i;
    //     }
    //   }
    // }

    // try to pick one that we can use next turn
    var level = 0;
    while (game.saleParts[level].isEmpty) {
      level++;
      if (level == 3) {
        // should never happen
        throw InvalidOperationError('No items in store (ai player turn, trying to get optimal resource to take');
      }
    }
    var i = game.availableResources.list
        .indexOf(game.saleParts[level][game.random.nextInt(game.saleParts[level].length)].resource);
    if (i != -1) {
      return i;
    }

    // ok, just take a random one
    return game.random.nextInt(game.availableResources.length);
  }

  static bool _processAction(Game game, GameAction action) {
    var ret = game.currentTurn.processAction(action).item1;
    if (ret != ValidateResponseCode.ok) {
      throw InvalidOperationError('bad action $ret');
    }
    return ret == ValidateResponseCode.ok;
  }

  void _takeSelectActionAction(Game game, ActionType actionType) {
    if (!_processAction(game, SelectActionAction(game.currentPlayer.id, actionType))) {
      // error of some sort
      return;
    }
  }

  static void takeStoreTurn(Game game) {
    var actions = game.currentTurn.getAvailableActions(isAi: true);
    var choices = <StoreAction>[];
    StoreAction selected;
    if (game.currentPlayer.maxResources == null) {
      game.currentPlayer.updateMaxResources(game.currentTurn);
    }
    if (game.currentPlayer.maxResources != null) {
      for (var action in actions) {
        var a = action as StoreAction;
        // we're going to pick a part that is no more than 1 resource more than we can afford
        if (a != null && a.part.cost <= game.currentPlayer.maxResources.count(a.part.resource) + 1) {
          // also make sure we don't pick a converter if we already have 5
          if (game.currentPlayer.parts[PartType.converter].length < 5 || a.part.partType != PartType.converter) {
            choices.add(a);
          }
        }
      }
    }
    if (choices.isEmpty) {
      // just pick one, all the choices suck
      selected = actions[game.random.nextInt(actions.length)] as StoreAction;
    } else {
      selected = choices[game.random.nextInt(choices.length)];
    }
    if (!_processAction(game, selected)) {
      // something's gone wrong
    }
  }

  static void _constructPart(Game game, Part part, {MCTSNode node}) {
    var discount = game.currentTurn.partDiscount(part);
    if (part.cost - discount == 0 || game.currentTurn.turnState.value == TurnState.constructL1Requested) {
      // it's free, just build it
      if (!_processAction(game, ConstructAction(game.currentPlayer.id, part, [], null, null))) {
        // something went wrong
      }
      return;
    }

    // get a random payment method
    var paths = game.currentPlayer.getPayments(part, discount, game.currentTurn, firstAvailable: true);
    //var index = game.random.nextInt(paths.length);
    var index = 0; // first is maybe shortest?
    var convertersUsed = <GameAction>[];
    for (var used in paths[index].history) {
      if (used.product.productType != ProductType.spend) {
        var action = used.product.produce(game.currentPlayer.id);
        // need to look up the original product, as this is a copy
        action.producedBy = allParts[action.producedBy.part.id].products[action.producedBy.prodIndex];
        convertersUsed.add(action);
      }
    }
    List<ResourceType> payment;
    if (part.resource == ResourceType.any) {
      //payment = paths[index].getCost().toList();
      payment = paths[index].getOutput().toList();
    } else {
      payment = List<ResourceType>.filled(part.cost - discount, part.resource);
    }
    var constructAction =
        ConstructAction(game.currentPlayer.id, part, payment, null, convertersUsed.isNotEmpty ? convertersUsed : null);
    if (!_processAction(game, constructAction)) {
      // something's gone wrong
    }
    if (node != null) {
      node.action = constructAction;
    }
  }

  static void takeConstructTurn(Game game) {
    var actions = game.currentTurn.getAvailableActions(isAi: true);
    Part part;
    // build from storage first
    if (game.currentPlayer.savedParts.isNotEmpty) {
      for (var action in actions) {
        var a = action as ConstructAction;
        if (a != null && game.currentPlayer.savedParts.contains(a.part)) {
          part = a.part;
        }
      }
    }
    // prevent turns from taking forever by keeping rollout plays from building more than
    // 5 converters, unless that's all there is
    if (game.currentPlayer.parts[PartType.converter].length >= 5) {
      // remove any action that is constructing a converter
      var fixedActions = <GameAction>[];
      for (var action in actions) {
        if ((action as ConstructAction).part.partType != PartType.converter) {
          fixedActions.add(action);
        }
      }
      if (fixedActions.isNotEmpty) {
        actions = fixedActions;
      }
    }
    if (part == null) {
      part = (actions[game.random.nextInt(actions.length)] as ConstructAction).part;
    }
    _constructPart(game, part);
    if (game.currentTurn.turnState.value != TurnState.selectedActionCompleted) {
      throw InvalidOperationError('its broken!');
    }
    return;
  }

  static void takeAcquireTurn(Game game) {
    // var resource = game.random.nextInt(game.availableResources.length);
    // // if we have saved a part, try to acquire the matching resource
    // if (player.savedParts.isNotEmpty) {
    //   var i = game.availableResources.list.indexOf(player.savedParts.first.resource);
    //   if (i != -1) {
    //     resource = i;
    //   }
    // }
    if (!_processAction(game, AcquireAction(game.currentPlayer.id, _optimalResource(game), null))) {
      // something's wrong
    }
  }

  static void takeSearchTurn(Game game) {
    if (game.currentPlayer.maxResources == null) {
      game.currentPlayer.updateMaxResources(game.currentTurn);
    }
    var level = 0;
    if (game.currentPlayer.maxResources != null) {
      if (game.currentPlayer.maxResources.count(ResourceType.any) > 6 ||
          game.currentPlayer.maxResources.count(ResourceType.club) > 4 ||
          game.currentPlayer.maxResources.count(ResourceType.heart) > 4 ||
          game.currentPlayer.maxResources.count(ResourceType.spade) > 4 ||
          game.currentPlayer.maxResources.count(ResourceType.diamond) > 4) {
        level = 2;
      } else if (game.currentPlayer.maxResources.count(ResourceType.club) > 2 ||
          game.currentPlayer.maxResources.count(ResourceType.heart) > 2 ||
          game.currentPlayer.maxResources.count(ResourceType.spade) > 2 ||
          game.currentPlayer.maxResources.count(ResourceType.diamond) > 2) {
        level = 1;
      }
    }
    var actions = game.currentTurn.getAvailableActions(isAi: true);
    var processed = false;
    for (var action in actions) {
      if (action is SearchAction && action.level == level) {
        if (!_processAction(game, action)) {
          // something bad happened
        }
        processed = true;
        break;
      }
    }
    if (!processed) {
      // if we got here, we couldn't search our desired level, so search the lowest left
      if (!_processAction(game, actions.first)) {
        // something bad happened
      }
    }

    actions = game.currentTurn.getAvailableActions(isAi: true);
    // should be store/construct actions. we will take the first construct action we can
    for (var action in actions) {
      if (action is ConstructAction) {
        _constructPart(game, action.part);
        return;
      }
    }
    // ok, try store next
    for (var action in actions) {
      if (action is StoreAction) {
        if (!_processAction(game, StoreAction(game.currentPlayer.id, action.part, null))) {
          // error!
        }
        return;
      }
    }
    // if we get here, all we can do is decline, which should be the only action
    if (!_processAction(game, actions.first)) {
      // error!
    }
  }

  static void _doTriggers(Game game) {
    List<GameAction> actions;
    do {
      actions = game.currentTurn.getAvailableActions(isAi: true);
      if (actions.isNotEmpty) {
        // we'll prioritize acquire first, in case our resource storage fills up
        var action =
            actions.firstWhere((element) => element.actionType == ActionType.requestAcquire, orElse: () => null);
        if (action == null) {
          action = actions.first;
        }
        _processAction(game, action);
        switch (action.actionType) {
          case ActionType.mysteryMeat:
            break;
          case ActionType.requestAcquire:
            //_processAction(action);
            takeAcquireTurn(game);
            break;
          case ActionType.requestSearch:
            //_processAction(action);
            takeSearchTurn(game);
            break;
          case ActionType.requestConstructL1:
            //_processAction(action);
            takeConstructTurn(game);
            break;
          case ActionType.requestStore:
            //_processAction(action);
            takeStoreTurn(game);
            break;
          default:
            // log something here
            break;
        }
      }
    } while (actions.isNotEmpty);
  }
}
