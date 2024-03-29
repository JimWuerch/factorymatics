import 'dart:math' as math;

import 'package:engine/engine.dart';

class MCTSNode {
  final MCTSNode parent;
  Game game;
  List<MCTSNode> children;
  ActionType selectedAction;
  GameAction action;
  double score;
  int visits;
  // ignore: non_constant_identifier_names
  double _UCB;

  MCTSNode(this.parent, this.game) {
    children = <MCTSNode>[];
    score = 0.0;
    visits = 0;
    if (parent != null) {
      parent.addChild(this);
    }
  }

  Map<String, dynamic> toJson() {
    var ret = <String, dynamic>{
      'selected': ActionType.values.indexOf(selectedAction),
      'action': action.toJson(),
    };

    return ret;
  }

  double getExplorationScore(MCTSNode child) {
    const c = 1.414; //15; //1.414;
    return c * math.sqrt(math.log(visits) / child.visits);
  }

  MCTSNode getBestChild() {
    for (var child in children) {
      if (child.visits == 0) {
        return child;
      }
      // var a = child.score / child.visits;
      // var b = math.sqrt(math.log(visits) / child.visits);
      // print('child: ${child.score}/${child.visits}=$a visits=$visits b=$b');
      child._UCB = (child.score / child.visits) + getExplorationScore(child);
    }
    // if we got here, our children all have run, so we don't need our game info any more
    game = null;
    var ret = children.first;
    for (var child in children) {
      //if (child._UCB > ret._UCB && !child.game.currentTurn.gameEnded) ret = child;
      if (child._UCB > ret._UCB) ret = child;
    }
    return ret;
  }

  MCTSNode getMostVistedChild() {
    if (children.isEmpty) {
      return null;
    }
    var ret = children.first;
    for (var child in children) {
      if (child.visits > ret.visits) {
        ret = child;
      }
    }
    return ret;
  }

  void addChild(MCTSNode child) {
    children.add(child);
  }

  void deleteChildren() {
    for (var child in children) {
      child.deleteChildren();
    }
    children.clear();
    game = null;
  }
}

class MCTreeSearch {
  MCTSNode root;

  MCTreeSearch(Game game) {
    root = MCTSNode(null, game);
  }
}
