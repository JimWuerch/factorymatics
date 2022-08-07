import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

List<Widget> _getOptions(BuildContext context, Game game) {
  var items = <Widget>[];
  items.add(Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text('You have a search depth of ${game.currentPlayer.search}'),
    ],
  ));
  for (var level = 0; level < 3; level++) {
    items.add(SimpleDialogOption(
        onPressed: () {
          Navigator.pop(context, level);
        },
        child: Text('Level ${level + 1} Deck. ${game.partsRemaining[level]} parts remaining.')));
  }
  return items;
}

Future<int?> showAskSearchDeckDialog(BuildContext context, Game game) async {
  return await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Choose Deck to Search (Search depth ${game.currentPlayer.search})'),
          children: _getOptions(context, game),
        );
      });
}
