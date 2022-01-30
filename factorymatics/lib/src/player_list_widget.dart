import 'package:engine/engine.dart';
import 'package:flutter/material.dart';

class PlayerListWidget extends StatefulWidget {
  PlayerListWidget({Key key, this.game}) : super(key: key);

  final Game game;

  @override
  State<PlayerListWidget> createState() => _PlayerListWidgetState();
}

class _PlayerListWidgetState extends State<PlayerListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
