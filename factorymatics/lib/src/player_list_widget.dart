import 'package:engine/engine.dart';
import 'package:factorymatics/src/icons.dart';
import 'package:flutter/material.dart';

import 'game_page_model.dart';
import 'part_helpers.dart';

class PlayerListWidget extends StatefulWidget {
  PlayerListWidget({Key key, this.model, this.onTap}) : super(key: key);

  final GamePageModel model;
  final void Function(String playerId) onTap;

  @override
  State<PlayerListWidget> createState() => _PlayerListWidgetState();
}

class _PlayerListWidgetState extends State<PlayerListWidget> {
  List<Widget> _buildPlayerCards() {
    var items = <Widget>[];
    for (var player in widget.model.game.players) {
      items.add(
        Card(
          color: widget.model.game.currentPlayer.id != player.id ? Colors.grey : null,
          child: ListTile(
            //leading: widget.model.game.currentPlayer.id == player.id ? FlutterLogo(size: 28.0) : null,
            title: Text(player.id),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('${player.score}', style: TextStyle(fontSize: widget.model.displaySizes.cardTextStyle.fontSize)),
                Icon(productTypeToIcon(ProductType.vp)),
                Text(' ${player.partCount}',
                    style: TextStyle(fontSize: widget.model.displaySizes.cardTextStyle.fontSize)),
                Icon(partIcon(), color: Colors.black),
              ],
            ),
            //trailing: Icon(Icons.more_vert),
            trailing: widget.model.displayPlayer.id == player.id ? Icon(iconArrowRightBold) : null,
            selected: widget.model.game.currentPlayer.id == player.id,
            onTap: widget.onTap == null
                ? null
                : () {
                    widget.onTap(player.id);
                  },
          ),
        ),
      );
    }
    return items;
  }

  // Widget _buildList() {
  //   var items = <Widget>[];
  //   for (var player in widget.model.game.players) {
  //     items.add(
  //       InkWell(
  //         onTap: widget.onTap == null
  //             ? null
  //             : () {
  //                 widget.onTap(player.id);
  //               },
  //         child: Row(
  //           children: [
  //             Tooltip(
  //               child: Text(
  //                 '${player.id} VP:${player.score} Parts:${player.partCount}',
  //                 style: widget.model.game.currentPlayer.id == player.id
  //                     ? TextStyle(backgroundColor: Colors.blue[300])
  //                     : null,
  //               ),
  //               message: 'Select to switch view to this player',
  //               waitDuration: Duration(milliseconds: 500),
  //             ),
  //           ],
  //         ),
  //       ),
  //     );
  //   }

  //   return Column(
  //     children: items,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.model.displaySizes.partWidth),
      child: Column(
        children: _buildPlayerCards(),
      ),
    );
    // return Container(
    //   child: _buildList(),
    // );
  }
}
