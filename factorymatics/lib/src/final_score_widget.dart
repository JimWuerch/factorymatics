import 'package:engine/engine.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:flutter/material.dart';

class FinalScoreWidget extends StatefulWidget {
  FinalScoreWidget({Key key, this.players}) : super(key: key);

  final List<PlayerData>/*!*/ players;

  @override
  State<FinalScoreWidget> createState() => _FinalScoreWidgetState();
}

class _FinalScoreWidgetState extends State<FinalScoreWidget> {
  bool _usedTieBreakers = false;

  Widget _buildList() {
    var items = <Widget>[];
    for (var player in widget.players) {
      items.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('${player.id}  ${player.score}'),
            Icon(productTypeToIcon(ProductType.vp)),
            Text('  ${player.partCount}'),
            Icon(partIcon(), color: Colors.black),
            Text('  ${player.resourceCount()}'),
            resourceToIcon(ResourceType.any, Colors.black),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items,
    );
  }

  PlayerData _getWinner() {
    var firstPass = <PlayerData>[];
    var secondPass = <PlayerData>[];
    var thirdPass = <PlayerData>[];

    // first get the high score
    var _highScore = -1;
    for (var player in widget.players) {
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
      _usedTieBreakers = true;
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

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Game Over',
            style: TextStyle(
              fontSize: 48,
            ),
          ),
          Text(''),
          Text('Final Scores:'),
          _buildList(),
          Text(''),
          Tooltip(
            message: 'Tie breaker order is active parts, total resources, reverse player order',
            waitDuration: Duration(milliseconds: 500),
            child: Text('The winner is ${_getWinner().id}! ${_usedTieBreakers ? '(used tiebreakers)' : ''}'),
          ),
        ],
      ),
    );
  }
}
