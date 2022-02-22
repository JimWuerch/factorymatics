import 'package:engine/engine.dart';
import 'package:test/test.dart';

Game game;

String player = 'p1';

void _createGame() {
  game = Game(<String>[player], null, '1');
  game.tmpName = 'test';
  game.createGame();
  var startingPartDecks = List<List<Part>>.filled(3, null);
  for (var i = 0; i < 3; ++i) {
    startingPartDecks[i] = <Part>[];
  }
  for (var part in game.allParts.values) {
    if (part.level != -1) {
      // initial part is lvl -1
      startingPartDecks[part.level].add(part);
    }
  }
  for (var i = 0; i < 3; ++i) {
    startingPartDecks[i].shuffle();
  }
  game.assignStartingDecks(startingPartDecks);
  game.startGame();
  game.startNextTurn();
  game.testMode = true;
}

Part _getPart(int id) {
  return game.allParts[id.toString()];
}

void main() {
  group('parts', () {
    setUp(_createGame);

    test('Test 73', () {
      // 1 vp on store
      game.currentPlayer.buyPart(_getPart(73));
      expect(game.currentTurn.processAction(StoreAction(player, game.saleParts[0][0], null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentPlayer.vpChits, 1);
    });
    test('Test 77', () {
      // store action on build black/red
      game.currentPlayer.buyPart(_getPart(77));
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(3), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      expect(game.currentTurn.processAction(_getPart(77).products.first.produce(game, player)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.storeRequested);
      expect(game.currentTurn.getAvailableActions().last.actionType, ActionType.store);
    });

    test('Test 79', () {
      // discount on lvl2 construct
      game.currentPlayer.buyPart(_getPart(79));
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentPlayer.constructLevel2Discount, 1);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(48), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 82', () {
      // search action on build black/red
      game.currentPlayer.buyPart(_getPart(82));
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(3), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      expect(game.currentTurn.processAction(_getPart(82).products.first.produce(game, player)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.searchRequested);
      game.currentTurn.processAction(SearchAction(player, 0)).item2 as SearchActionResult;
      expect(game.currentTurn.getAvailableActions().last.actionType, ActionType.searchDeclined);
      expect(
          game.currentTurn
              .processAction(StoreAction(player, game.currentTurn.searchedParts[0], _getPart(82).products.first))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 83', () {
      // double acquire after builing lvl2
      game.currentPlayer.buyPart(_getPart(83));
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.storeResource(ResourceType.heart);
      // first see if the product works
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(
                  ConstructAction(player, _getPart(48), [ResourceType.heart, ResourceType.heart], null, null))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      // now construct something else and make sure the part wasn't triggered
      expect(game.currentTurn.processAction(GameModeAction(player, GameModeType.undo)).item1, ValidateResponseCode.ok);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(3), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, false);
    });

    test('Test 87', () {
      // 2 VP for building from storage
      game.currentPlayer.buyPart(_getPart(87));
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.savePart(_getPart(3));
      // first test the part
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(3), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.vpChits, 2);
      // now make sure it doesn't activate when it shouldn't
      expect(game.currentTurn.processAction(GameModeAction(player, GameModeType.undo)).item1, ValidateResponseCode.ok);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(10), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.vpChits, 0);
    });

    test('Test 90', () {
      // Free lvl1 construct after constructing yellow/red
      game.currentPlayer.buyPart(_getPart(90));
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(
                  ConstructAction(player, _getPart(58), [ResourceType.heart, ResourceType.heart], null, null))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      expect(game.currentTurn.processAction(_getPart(90).products.first.produce(game, player)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.constructL1Requested);
      var actions = game.currentTurn.getAvailableActions();
      expect(actions.where((element) => element is ConstructAction && element.part.level == 0).length,
          4); // should be the 4 level 1's
      expect(game.currentPlayer.resourceCount(), 0);
      // game.currentTurn.processAction(
      //     ConstructAction(player, game.saleParts[0].first, [game.saleParts[0].first.resource], null, null));
      expect(
          game.currentTurn
              .processAction(
                  ConstructAction(player, game.saleParts[0].first, [game.saleParts[0].first.resource], null, null))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 91', () {
      // Multi doubler
      game.currentPlayer.buyPart(_getPart(91));
      _getPart(91).ready.value = true;
      game.currentPlayer.storeResource(ResourceType.spade);
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.updateMaxResources();
      var resources = game.currentPlayer.maxResources;
      expect(resources.count(ResourceType.spade), 2);
      expect(resources.count(ResourceType.heart), 2);
    });

    test('Test 93', () {
      // X > X converter
      game.currentPlayer.buyPart(_getPart(93));
      _getPart(93).ready.value = true;
      game.currentPlayer.storeResource(ResourceType.spade);
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.updateMaxResources();
      var resources = game.currentPlayer.maxResources;
      expect(resources.count(ResourceType.spade), 2);
      expect(resources.count(ResourceType.heart), 2);
      expect(resources.count(ResourceType.club), 1);
      expect(resources.count(ResourceType.diamond), 1);
      expect(resources.count(ResourceType.any), 2);
    });

    test('Test 97', () {
      // discount on lvl2 construct
      game.currentPlayer.buyPart(_getPart(97));
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentPlayer.constructFromStoreDiscount, 1);
      game.currentPlayer.savePart(_getPart(48));
      expect(game.currentTurn.processAction(SelectActionAction(player, ActionType.construct)).item1,
          ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(48), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 99', () {
      // VP doubler
      game.currentPlayer.buyPart(_getPart(99));
      expect(game.currentPlayer.score, 0);
      game.currentPlayer.buyPart(_getPart(3));
      expect(game.currentPlayer.score, 1);
      game.currentPlayer.giveVpChit();
      expect(game.currentPlayer.score, 3);
      game.currentPlayer.giveVpChit();
      expect(game.currentPlayer.score, 5);
      expect(_getPart(99).vp, 2);
    });

    test('Test 101', () {
      // VP for resources
      game.currentPlayer.buyPart(_getPart(101));
      expect(game.currentPlayer.score, 0);
      game.currentPlayer.buyPart(_getPart(3));
      expect(game.currentPlayer.score, 1);
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentPlayer.score, 2);
      game.currentPlayer.storeResource(ResourceType.spade);
      expect(game.currentPlayer.score, 3);
      game.currentPlayer.storeResource(ResourceType.club);
      expect(game.currentPlayer.score, 4);
      game.currentPlayer.storeResource(ResourceType.diamond);
      expect(game.currentPlayer.score, 5);
      expect(_getPart(101).vp, 4);
    });

    test('Test 103', () {
      // discount on construct from search
      game.currentPlayer.buyPart(_getPart(103));
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(game.currentPlayer.constructFromSearchDiscount, 1);
      game.currentTurn.searchedParts.add(_getPart(48));
      game.currentTurn.turnState.value = TurnState.searchSelected;
      expect(
          game.currentTurn.processAction(ConstructAction(player, _getPart(48), [ResourceType.heart], null, null)).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 105', () {
      // disallow store
      game.currentPlayer.buyPart(_getPart(105));
      var actions = game.currentTurn.getAvailableActions();
      expect(
          actions
              .where((element) => element is SelectActionAction && element.selectedAction == ActionType.store)
              .length,
          0);

      game.currentPlayer.buyPart(_getPart(78));
      _getPart(78).ready.value = true;
      game.currentTurn.turnState.value = TurnState.selectedActionCompleted;
      actions = game.currentTurn.getAvailableActions();
      expect(actions.whereType<RequestStoreAction>().length, 0);
      // check to make sure we can store if we don't have the part
      game.currentPlayer.removePart(_getPart(105));
      actions = game.currentTurn.getAvailableActions();
      expect(actions.whereType<RequestStoreAction>().length, 1);
    });
    test('Test 107', () {
      // disallow search
      game.currentPlayer.buyPart(_getPart(107));
      var actions = game.currentTurn.getAvailableActions();
      expect(
          actions
              .where((element) => element is SelectActionAction && element.selectedAction == ActionType.search)
              .length,
          0);

      game.currentPlayer.buyPart(_getPart(81));
      _getPart(81).ready.value = true;
      game.currentTurn.turnState.value = TurnState.selectedActionCompleted;
      actions = game.currentTurn.getAvailableActions();
      expect(actions.whereType<RequestSearchAction>().length, 0);
      // check to make sure we can search if we don't have the part
      game.currentPlayer.removePart(_getPart(107));
      actions = game.currentTurn.getAvailableActions();
      expect(actions.whereType<RequestSearchAction>().length, 1);
    });
  });
}
