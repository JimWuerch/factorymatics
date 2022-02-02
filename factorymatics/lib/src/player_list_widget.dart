import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

class PlayerListWidget extends StatefulWidget {
  PlayerListWidget({Key key, this.game, this.onTap}) : super(key: key);

  final Game game;
  final void Function(PlayerData player) onTap;

  @override
  State<PlayerListWidget> createState() => _PlayerListWidgetState();
}

class _PlayerListWidgetState extends State<PlayerListWidget> {
  Widget _buildList() {
    var items = <Widget>[];
    for (var player in widget.game.players) {
      items.add(
        InkWell(
          onTap: () {
            widget.onTap(player);
          },
          child: Row(
            children: [
              Text('$player VP:${player.score} Parts:${player.partCount}'),
            ],
          ),
        ),
      );
    }

    return Column(
      children: items,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _buildList(),
    );
  }
}
