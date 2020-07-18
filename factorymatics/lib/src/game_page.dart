import 'package:engine/engine.dart';
import 'package:factorymatics/src/game_page_model.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:factorymatics/src/part_widget.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final String title = 'Factorymatics';

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  GamePageModel model;

  @override
  void initState() {
    super.initState();

    model = GamePageModel('wheee');
    model.init();
  }

  Widget _makePartList(List<Part> parts) {
    var widgets = <Widget>[];
    for (var part in parts) {
      widgets.add(PartWidget(part));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: StreamBuilder<void>(
            stream: model.notifier,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return Text('loading...');
              return Column(
                // Column is also a layout widget. It takes a list of children and
                // arranges them vertically. By default, it sizes itself to fit its
                // children horizontally, and tries to be as tall as its parent.
                //
                // Invoke "debug painting" (press "p" in the console, choose the
                // "Toggle Debug Paint" action from the Flutter Inspector in Android
                // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
                // to see the wireframe for each widget.
                //
                // Column has various properties to control how it sizes itself and
                // how it positions its children. Here we use mainAxisAlignment to
                // center the children vertically; the main axis here is the vertical
                // axis because Columns are vertical (the cross axis would be
                // horizontal).
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _makePartList(model.game.saleParts[2].list),
                  _makePartList(model.game.saleParts[1].list),
                  _makePartList(model.game.saleParts[0].list),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      RaisedButton.icon(
                        icon: Icon(actionToIcon(ActionType.store)),
                        onPressed: model.isActionSelection && model.canStore
                            ? () {
                                _actionButtonPressed(ActionType.store);
                              }
                            : null,
                        label: Text('Store'),
                      ),
                      RaisedButton.icon(
                        icon: Icon(actionToIcon(ActionType.acquire)),
                        onPressed: model.isActionSelection && model.canAcquire
                            ? () {
                                _actionButtonPressed(ActionType.acquire);
                              }
                            : null,
                        label: Text('Aquire'),
                      ),
                      RaisedButton.icon(
                        icon: Icon(actionToIcon(ActionType.construct)),
                        onPressed: model.isActionSelection
                            ? () {
                                _actionButtonPressed(ActionType.construct);
                              }
                            : null,
                        label: Text('Construct'),
                      ),
                      RaisedButton.icon(
                        icon: Icon(actionToIcon(ActionType.search)),
                        onPressed: model.isActionSelection
                            ? () {
                                _actionButtonPressed(ActionType.search);
                              }
                            : null,
                        label: Text('Search'),
                      ),
                    ],
                  ),
                ],
              );
            }),
      ),
    );
  }

  void _actionButtonPressed(ActionType actionType) {
    model.selectAction(actionType);
  }
}
