import 'package:engine/engine.dart';
import 'package:factorymatics/src/game_page_model.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:factorymatics/src/part_widget.dart';
import 'package:factorymatics/src/resource_picker.dart';
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
    var enabledParts = model.getEnabledParts();
    for (var part in parts) {
      widgets.add(PartWidget(part: part, enabled: enabledParts.contains(part.id), onTap: _onPartTapped));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: widgets,
    );
  }

  Widget _makeActionButton(ActionType actionType, bool isEnabled, String label) {
    return SizedBox(
      width: 200,
      child: RaisedButton.icon(
        icon: Icon(actionToIcon(actionType)),
        onPressed: model.isActionSelection && isEnabled
            ? () {
                _actionButtonPressed(actionType);
              }
            : null,
        label: Text(label),
      ),
    );
  }

  Column _makeColumn(int index) {
    var children = <Widget>[];
    switch (index) {
      case 0:
        children.add(RaisedButton(
          onPressed: null,
        ));
        for (var part in model.game.currentPlayer.parts[PartType.enhancement]) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
      case 1:
        children.add(_makeActionButton(ActionType.convert, false, ''));
        for (var part in model.game.currentPlayer.parts[PartType.converter]) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
      case 2:
        children.add(_makeActionButton(ActionType.store, model.canStore, 'Store'));
        for (var part in model.game.currentPlayer.parts[PartType.storage]) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
      case 3:
        children.add(_makeActionButton(ActionType.acquire, model.canAcquire, 'Acquire'));
        for (var part in model.game.currentPlayer.parts[PartType.acquire]) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
      case 4:
        children.add(_makeActionButton(ActionType.construct, true, 'Construct'));
        for (var part in model.game.currentPlayer.parts[PartType.construct]) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
      case 5:
        children.add(_makeActionButton(ActionType.search, true, ''));
        for (var part in model.game.currentPlayer.savedParts) {
          children.add(PartWidget(
            part: part,
            enabled: false,
          ));
        }
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
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
        child: StreamBuilder<int>(
            stream: model.notifier,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Text('loading...');
              } else {
                return Container(
                  color: Colors.white,
                  child: Column(
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
                      ResourcePicker(
                        resources: model.game.availableResources.toList(),
                        enabled: model.isResourcePickerEnabled,
                        onTap: _onResourceTapped,
                      ),
                      _makePartList(model.game.saleParts[2].list),
                      _makePartList(model.game.saleParts[1].list),
                      _makePartList(model.game.saleParts[0].list),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(child: Text('Undo'), onPressed: model.canUndo ? _onUndoTapped : null),
                          RaisedButton(child: Text('End Turn'), onPressed: model.canEndTurn ? _onEndTurnTapped : null),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        children: <Widget>[
                          _makeColumn(0),
                          _makeColumn(1),
                          _makeColumn(2),
                          _makeColumn(3),
                          _makeColumn(4),
                          _makeColumn(5),
                        ],
                      )
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: <Widget>[
                      //     RaisedButton.icon(
                      //       icon: Icon(actionToIcon(ActionType.store)),
                      //       onPressed: model.isActionSelection && model.canStore
                      //           ? () {
                      //               _actionButtonPressed(ActionType.store);
                      //             }
                      //           : null,
                      //       label: Text('Store'),
                      //     ),
                      //     RaisedButton.icon(
                      //       icon: Icon(actionToIcon(ActionType.acquire)),
                      //       onPressed: model.isActionSelection && model.canAcquire
                      //           ? () {
                      //               _actionButtonPressed(ActionType.acquire);
                      //             }
                      //           : null,
                      //       label: Text('Aquire'),
                      //     ),
                      //     RaisedButton.icon(
                      //       icon: Icon(actionToIcon(ActionType.construct)),
                      //       onPressed: model.isActionSelection
                      //           ? () {
                      //               _actionButtonPressed(ActionType.construct);
                      //             }
                      //           : null,
                      //       label: Text('Construct'),
                      //     ),
                      //     RaisedButton.icon(
                      //       icon: Icon(actionToIcon(ActionType.search)),
                      //       onPressed: model.isActionSelection
                      //           ? () {
                      //               _actionButtonPressed(ActionType.search);
                      //             }
                      //           : null,
                      //       label: Text('Search'),
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }

  void _actionButtonPressed(ActionType actionType) {
    model.selectAction(actionType);
  }

  Future<void> _onResourceTapped(int index) async {
    print('Tapped $index');
    model.resourceSelected(index);
  }

  Future<void> _onPartTapped(Part part) async {
    print('Tapped part ${part.id}');
    model.partTapped(part);
  }

  Future<void> _onUndoTapped() async {
    model.doUndo();
  }

  Future<void> _onEndTurnTapped() async {
    model.doEndTurn();
  }
}
