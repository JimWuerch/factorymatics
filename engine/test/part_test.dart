import 'package:engine/engine.dart';
import 'package:test/test.dart';

Game game;

Game _createGame() {
  game = Game(<String>['p1'], null, '1');
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
  //startingPartDecks[2].removeRange(16, startingPartDecks[2].length);
  game.assignStartingDecks(startingPartDecks);

  game.startGame();
  game.startNextTurn();
  game.testMode = true;
  return game;
}

void main() {
  group('parts', () {
    setUp(() {
      game = _createGame();
    });

    test('Test 73', () {
      // 1 vp on store
      game.currentPlayer.buyPart(game.allParts['73']);
      game.currentTurn.processAction(StoreAction('1', game.saleParts[0][0], null));
      expect(game.currentPlayer.vpChits, 1);
    });
    test('Test 77', () {
      // store action on build black/red
      game.currentPlayer.buyPart(game.allParts['77']);
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(
          game.currentTurn.processAction(SelectActionAction('1', ActionType.construct)).item1, ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(ConstructAction('1', game.allParts['3'], [ResourceType.heart], null, [], true))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      expect(game.currentTurn.processAction(game.allParts['77'].products.first.produce(game, '1')).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.storeRequested);
      expect(game.currentTurn.getAvailableActions().last.actionType, ActionType.store);
    });

    test('Test 79', () {
      // discount on lvl2 construct
      game.currentPlayer.buyPart(game.allParts['79']);
      expect(game.currentPlayer.constructLevel2Discount, 1);
    });

    test('Test 82', () {
      // search action on build black/red
      game.currentPlayer.buyPart(game.allParts['82']);
      game.currentPlayer.storeResource(ResourceType.heart);
      expect(
          game.currentTurn.processAction(SelectActionAction('1', ActionType.construct)).item1, ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(ConstructAction('1', game.allParts['3'], [ResourceType.heart], null, [], true))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      expect(game.currentTurn.processAction(game.allParts['82'].products.first.produce(game, '1')).item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.searchRequested);
      game.currentTurn.processAction(SearchAction('1', 0)).item2 as SearchActionResult;
      expect(game.currentTurn.getAvailableActions().last.actionType, ActionType.searchDeclined);
      expect(
          game.currentTurn
              .processAction(StoreAction('1', game.currentTurn.searchedParts[0], game.allParts['82'].products.first))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
    });

    test('Test 83', () {
      // double acquire after builing lvl2
      game.currentPlayer.buyPart(game.allParts['83']);
      game.currentPlayer.storeResource(ResourceType.heart);
      game.currentPlayer.storeResource(ResourceType.heart);
      // first see if the product works
      expect(
          game.currentTurn.processAction(SelectActionAction('1', ActionType.construct)).item1, ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(
                  ConstructAction('1', game.allParts['48'], [ResourceType.heart, ResourceType.heart], null, null, true))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, true);
      // now construct something else and make sure the part wasn't triggered
      expect(game.currentTurn.processAction(GameModeAction('1', GameModeType.undo)).item1, ValidateResponseCode.ok);
      expect(
          game.currentTurn.processAction(SelectActionAction('1', ActionType.construct)).item1, ValidateResponseCode.ok);
      expect(
          game.currentTurn
              .processAction(ConstructAction('1', game.allParts['3'], [ResourceType.heart], null, null, true))
              .item1,
          ValidateResponseCode.ok);
      expect(game.currentTurn.turnState.value, TurnState.selectedActionCompleted);
      expect(game.currentPlayer.parts[PartType.construct].first.ready.value, false);
    });
  });
}
