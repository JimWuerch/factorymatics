import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

class PlayerListWidget extends StatefulWidget {
  PlayerListWidget({Key key, this.game, this.onTap}) : super(key: key);

  final Game game;
  final void Function(String playerId) onTap;

  @override
  State<PlayerListWidget> createState() => _PlayerListWidgetState();
}

class _PlayerListWidgetState extends State<PlayerListWidget> {
  Widget _buildList() {
    var items = <Widget>[];
    for (var player in widget.game.players) {
      items.add(
        InkWell(
          onTap: widget.onTap == null
              ? null
              : () {
                  widget.onTap(player.id);
                },
          child: Row(
            children: [
              Tooltip(
                child: Text(
                  '${player.id} VP:${player.score} Parts:${player.partCount}',
                  style: widget.game.currentPlayer.id == player.id ? TextStyle(backgroundColor: Colors.blue[300]) : null,
                ),
                message: 'Select to switch view to this player',
                waitDuration: Duration(milliseconds: 500),
              ),
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
