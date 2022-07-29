import 'package:engine/engine.dart';

abstract class ResponseModel extends GameModel {
  final ResponseCode responseCode;

  ResponseModel(String gameId, String owner, String desc, this.responseCode) : super(gameId, owner, desc);

  @override
  Map<String, dynamic> toJson() {
    var ret = super.toJson();
    ret['responseCode'] = responseCode.toString().stripClassName();
    return ret;
  }

  ResponseModel.fromJson(Map<String, dynamic> json)
      : responseCode =
            ResponseCode.values.firstWhere((e) => e.toString() == 'ResponseCode.${json['responseCode'] as String/*!*/}'),
        super.fromJson(json);
}
