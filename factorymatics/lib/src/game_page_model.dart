import 'package:engine/engine.dart';

class GamePageModel {
  Game game;
  PlayerService playerService;
  String gameId;

  GamePageModel(this.playerService, this.gameId);

  void init() {
    game = Game(playerService, gameId);
  }

  bool get isActionSelection => game.currentTurn?.isActionSelected ?? false;

  Future<void> selectAction(ActionType actionType) async {
    switch (actionType) {
      case ActionType.store:
        await _doStore();
        break;
      case ActionType.acquire:
        await _doAcquire();
        break;
      case ActionType.construct:
        await _doConstruct();
        break;
      case ActionType.search:
        await _doSearch();
        break;
      default:
        throw ArgumentError('Unknown type: ${actionType.toString()}');
    }
  }

  bool get canStore => game.currentTurn?.player?.hasPartStorageSpace ?? false;

  bool get canAcquire => game.currentTurn?.player?.hasResourceStorageSpace ?? false;

  Future<void> _doStore() async {}

  Future<void> _doAcquire() async {}

  Future<void> _doConstruct() async {}

  Future<void> _doSearch() async {}
}
