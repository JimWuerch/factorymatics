import 'package:engine/engine.dart';

export 'action_request.dart';
export 'action_response.dart';
export 'create_game_request.dart';
export 'create_game_response.dart';
export 'create_lobby_request.dart';
export 'create_lobby_response.dart';
export 'join_game_request.dart';
export 'join_game_response.dart';
export 'join_lobby_request.dart';
export 'join_lobby_response.dart';
export 'response_model.dart';

enum GameModelType {
  createGameRequest,
  createGameResponse,
  actionRequest,
  actionResponse,
  joinGameRequest,
  joinGameResponse,
  createLobbyRequest,
  createLobbyResponse,
  joinLobbyRequest,
  joinLobbyResponse
}
enum ResponseCode { ok, error, failedValidation }

abstract class GameModel {
  final String _gameId;
  String get gameId => _gameId;
  final String _description;
  String get description => _description;
  final String _ownerId;
  String get ownerId => _ownerId;

  GameModelType get modelType;

  GameModel(String gameId, String owner, String desc)
      : _gameId = gameId,
        _description = desc,
        _ownerId = owner;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': GameModelType.values.indexOf(modelType),
        'gameId': gameId,
        'desc': description,
        'owner': ownerId,
      };

  GameModel.fromJson(Map<String, dynamic> json) : this(json['gameId'] as String, json['owner'] as String, json['desc'] as String);
}

String gameIdFromJson(Map<String, dynamic> json) {
  return json['gameId'] as String;
}

GameModelType gameModelTypeFromJson(Map<String, dynamic> json) {
  return GameModelType.values[json['type'] as int];
}

GameModel gameModelFromJson(Game game, Map<String, dynamic> json) {
  var type = gameModelTypeFromJson(json);
  switch (type) {
    case GameModelType.createGameRequest:
      return CreateGameRequest.fromJson(json);
    case GameModelType.createGameResponse:
      return CreateGameResponse.fromJson(json);
    case GameModelType.actionRequest:
      return ActionRequest.fromJson(game, json);
    case GameModelType.actionResponse:
      return ActionResponse.fromJson(game, json);
    case GameModelType.createLobbyRequest:
      return CreateLobbyRequest.fromJson(json);
    case GameModelType.createLobbyResponse:
      return CreateLobbyResponse.fromJson(json);
    case GameModelType.joinGameRequest:
      return JoinGameRequest.fromJson(json);
    case GameModelType.joinGameResponse:
      return JoinGameResponse.fromJson(game, json);
    case GameModelType.joinLobbyRequest:
      return JoinLobbyRequest.fromJson(json);
    case GameModelType.joinLobbyResponse:
      return JoinLobbyResponse.fromJson(json);
    default:
      throw InvalidOperationError('Unknown model type $type');
  }
}
