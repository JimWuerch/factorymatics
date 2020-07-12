import 'package:engine/engine.dart';

class JoinGameResponse extends ResponseModel {
  final List<Turn> turns;

  JoinGameResponse(Game game, String owner, String desc, this.turns, ResponseCode code)
      : super(game, owner, 'joinGame response', code);

  @override
  GameModelType get modelType => GameModelType.joinGameResponse;

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['turns'] = turns.map<Map<String, dynamic>>((e) => e.toJson()).toList();
    return ret;
  }

  JoinGameResponse._fromJsonHelper(this.turns, Map<String, dynamic> json) : super.fromJson(json);

  factory JoinGameResponse.fromJson(Game game, Map<String, dynamic> json) {
    var item = json['turns'] as List<dynamic>;
    var turns = item.map<Turn>((dynamic json) => Turn.fromJson(game, json as Map<String, dynamic>)).toList();
    return JoinGameResponse._fromJsonHelper(turns, json);
  }
}
