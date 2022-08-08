import 'package:engine/engine.dart';
import 'package:factorymatics/src/final_score_widget.dart';
import 'package:factorymatics/src/game_info_model.dart';
import 'package:factorymatics/src/game_page_model.dart';
import 'package:factorymatics/src/part_helpers.dart';
import 'package:factorymatics/src/part_widget.dart';
import 'package:factorymatics/src/player_list_widget.dart';
import 'package:factorymatics/src/resource_picker.dart';
import 'package:factorymatics/src/resource_storage_widget.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final String title = 'Factorymatics';
  final GameInfoModel gameInfoModel;

  GamePage(this.gameInfoModel);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late GamePageModel model;

  @override
  void initState() {
    super.initState();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.landscapeRight,
    //   DeviceOrientation.landscapeLeft,
    // ]);

    model = GamePageModel(widget.gameInfoModel, context);
    model.init();
  }

  Widget _makePartList(List<Part> parts) {
    var widgets = <Widget>[];
    var enabledParts = model.getEnabledParts();
    for (var part in parts) {
      widgets.add(PartWidget(
        part: part,
        enabled: enabledParts.contains(part.id),
        onTap: _onPartTapped,
        onProductTap: null,
        isResourcePickerEnabled: model.isResourcePickerEnabled,
        gamePageModel: model,
        displaySizes: model.displaySizes,
      ));
    }
    if (widgets.length <= 4) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: widgets,
      );
    } else {
      var rowsSrc = <List<Widget>>[];
      for (var i = 0; i < widgets.length; ++i) {
        if (i % 4 == 0) {
          rowsSrc.add(<Widget>[]);
        }
        rowsSrc[i ~/ 4].add(widgets[i]);
      }
      var rows = <Row>[];
      for (var item in rowsSrc) {
        rows.add(Row(
          children: item,
        ));
      }
      return Column(
        children: rows,
      );
    }
  }

  Widget _makeActionButton(ActionType actionType, bool isEnabled, String label) {
    return SizedBox(
      width: model.displaySizes.partWidth,
      child: ElevatedButton.icon(
        icon: Icon(actionToIcon(actionType)),
        onPressed: model.isActionSelection && isEnabled && model.isActivePlayer
            ? () {
                _actionButtonPressed(actionType);
              }
            : null,
        label: Text(label),
      ),
    );
  }

  List<Widget> _makeStorage() {
    var enabledParts = model.getEnabledParts();
    var items = <Widget>[];
    items.add(Card(
      child: ListTile(
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(partTypeToIcon(PartType.storage)),
            //Text('Storage', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(' Storage'),
          ],
        ),
      ),
    ));
    for (var part in model.displayPlayer!.savedParts) {
      items.add(PartWidget(
        part: part,
        enabled: enabledParts.contains(part.id),
        onTap: _onPartTapped,
        onProductTap: null,
        isResourcePickerEnabled: model.isResourcePickerEnabled,
        gamePageModel: model,
        displaySizes: model.displaySizes,
      ));
    }
    return items;
  }

  Column _makeColumn(int index) {
    var children = <Widget>[];
    var enabledParts = model.getEnabledParts();
    switch (index) {
      case 0:
        children.add(_makeActionButton(ActionType.search, model.canSearch, 'Search'));
        children.add(SizedBox(height: 4));
        children.add(SizedBox(
          width: model.displaySizes.partWidth,
          child: ElevatedButton(
            onPressed: null,
            child: Row(
              children: [
                Icon(partTypeToIcon(PartType.enhancement)),
                Text(' '),
                Icon(partTypeToIcon(PartType.acquire)),
                Text(':${model.displayPlayer!.resourceStorage} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(partTypeToIcon(PartType.storage)),
                Text(':${model.displayPlayer!.partStorage} ', style: const TextStyle(fontWeight: FontWeight.bold)),
                Icon(actionToIcon(ActionType.search)),
                Text(':${model.displayPlayer!.search}', style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ));
        for (var part in model.displayPlayer!.parts[PartType.enhancement]!) {
          children.add(PartWidget(
            part: part,
            enabled: false,
            isResourcePickerEnabled: model.isResourcePickerEnabled,
            gamePageModel: model,
            displaySizes: model.displaySizes,
          ));
        }
        break;
      case 1:
        children.add(_makeActionButton(ActionType.convert, false, ''));
        for (var part in model.displayPlayer!.parts[PartType.converter]!) {
          children.add(PartWidget(
            part: part,
            enabled: false,
            isResourcePickerEnabled: model.isResourcePickerEnabled,
            gamePageModel: model,
            displaySizes: model.displaySizes,
          ));
        }
        break;
      case 2:
        children.add(_makeActionButton(ActionType.store, model.canStore, 'Store'));
        for (var part in model.displayPlayer!.parts[PartType.storage]!) {
          children.add(PartWidget(
            part: part,
            enabled: false,
            onProductTap: _onProductTapped,
            isResourcePickerEnabled: model.isResourcePickerEnabled,
            gamePageModel: model,
            displaySizes: model.displaySizes,
          ));
        }
        break;
      case 3:
        children.add(_makeActionButton(ActionType.acquire, model.canAcquire, 'Acquire'));
        for (var part in model.displayPlayer!.parts[PartType.acquire]!) {
          children.add(PartWidget(
            part: part,
            enabled: false,
            onProductTap: _onProductTapped,
            isResourcePickerEnabled: model.isResourcePickerEnabled,
            gamePageModel: model,
            displaySizes: model.displaySizes,
          ));
        }
        break;
      case 4:
        children.add(_makeActionButton(ActionType.construct, model.canConstruct, 'Construct'));
        for (var part in model.displayPlayer!.parts[PartType.construct]!) {
          children.add(PartWidget(
            part: part,
            enabled: false,
            onProductTap: _onProductTapped,
            isResourcePickerEnabled: model.isResourcePickerEnabled,
            gamePageModel: model,
            displaySizes: model.displaySizes,
          ));
        }
        break;
      // case 5:
      //   children.add(_makeActionButton(ActionType.search, true, 'Search'));
      //   for (var part in model.displayPlayer.savedParts) {
      //     children.add(PartWidget(
      //       part: part,
      //       enabled: enabledParts.contains(part.id),
      //       onTap: _onPartTapped,
      //       onProductTap: null,
      //       isResourcePickerEnabled: model.isResourcePickerEnabled,
      //       gamePageModel: model,
      //       displaySizes: model.displaySizes,
      //     ));
      //   }
      //   break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildCardArea(BuildContext context) {
    if (!model.inSearch) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _makePartList(model.game.saleParts[2].list),
          _makePartList(model.game.saleParts[1].list),
          _makePartList(model.game.saleParts[0].list),
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _makePartList(model.searchedParts),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Tooltip(
                message: 'Skip storing or constructing.',
                child: ElevatedButton(
                  onPressed: model.searchExecutionOption == SearchExecutionOptions.unselected
                      ? () {
                          model.onSearchActionTapped(SearchExecutionOptions.doNothing);
                        }
                      : null,
                  child: Text('Skip'),
                ),
              ),
              ElevatedButton.icon(
                onPressed: model.searchExecutionOption == SearchExecutionOptions.unselected && model.canConstruct
                    ? () {
                        model.onSearchActionTapped(SearchExecutionOptions.construct);
                      }
                    : null,
                icon: Icon(partTypeToIcon(PartType.construct)),
                label: Text('Construct'),
              ),
              ElevatedButton.icon(
                onPressed: model.searchExecutionOption == SearchExecutionOptions.unselected && model.canStore
                    ? () {
                        model.onSearchActionTapped(SearchExecutionOptions.store);
                      }
                    : null,
                icon: Icon(partTypeToIcon(PartType.storage)),
                label: Text('Store'),
              ),
            ],
          ),
        ],
      );
    }
  }

  Widget _displayWait() {
    var items = <Widget>[];
    if (model.showWait) {
      items.add(Text('Waiting for other players...', style: model.displaySizes.cardTextStyle));
      //items.add(CircularProgressIndicator());
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: items,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<Object>(
          stream: model.notifier,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return Center(child: Text('loading...'));
            } else {
              return WillPopScope(
                onWillPop: (() => showDialog<bool>(
                      context: context,
                      builder: (c) => AlertDialog(
                        title: Text('Warning'),
                        content: Text('Exiting will quit the game. Continue?'),
                        actions: [
                          TextButton(
                            child: Text('Yes'),
                            onPressed: () => Navigator.pop(c, true),
                          ),
                          TextButton(
                            child: Text('No'),
                            onPressed: () => Navigator.pop(c, false),
                          ),
                        ],
                      ),
                    ).then((value) => value!)) as Future<bool> Function()?,
                child: Scaffold(
                  backgroundColor: Colors.yellow.shade100,
                  appBar: AppBar(
                    // Here we take the value from the MyHomePage object that was created by
                    // the App.build method, and use it to set our appbar title.
                    title: Text('Round:${model.game.round}, ${model.displayPlayer!.id}\'s Turn'),
                    actions: model.isGameEnded
                        ? <Widget>[]
                        : <Widget>[
                            // TextButton(
                            //   //textColor: Colors.white,
                            //   style: TextButton.styleFrom(
                            //     primary: Colors.white, // foreground
                            //   ),
                            //   onPressed: model.isActivePlayer && model.game.currentPlayer.id.startsWith('AI')
                            //       ? () async => await model.onDoAiTurn()
                            //       : null,
                            //   child: Text("Ai Turn"),
                            // ),
                            TextButton(
                              //textColor: Colors.white,
                              style: TextButton.styleFrom(
                                primary: Colors.white, // foreground
                              ),
                              onPressed: model.canUndo && model.isActivePlayer ? _onUndoTapped : null,
                              child: Text("Undo"),
                              //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                            ),
                            TextButton(
                              //textColor: Colors.white,
                              style: TextButton.styleFrom(
                                primary: Colors.white, // foreground
                              ),

                              onPressed: model.canEndTurn && model.isActivePlayer ? _onEndTurnTapped : null,
                              child: Text("End Turn"),
                              //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                            ),
                          ],
                  ),
                  body: SafeArea(
                    child: model.isGameEnded
                        ? FinalScoreWidget(players: model.game.players)
                        : SingleChildScrollView(
                            child: Container(
                              //color: Colors.yellow.shade100,
                              child: Center(
                                child: Column(
                                  children: <Widget>[
                                    _displayWait(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Column(
                                              children: [
                                                PlayerListWidget(
                                                  model: model,
                                                  onTap: (model.game.currentTurn.turnState.value == TurnState.started ||
                                                          model.game.currentTurn.turnState.value ==
                                                              TurnState.selectedActionCompleted)
                                                      ? model.playerNameTapped
                                                      : null,
                                                ),
                                                SizedBox(
                                                  width: model.displaySizes.partWidth,
                                                  child: Column(
                                                    children: _makeStorage(),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                            Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 5,
                                                          color: model.isResourcePickerEnabled
                                                              ? Colors.orange
                                                              : Colors.blue),
                                                      borderRadius: BorderRadius.all(Radius.circular(20))),
                                                  padding: EdgeInsets.only(left: 10, right: 10),
                                                  width: model.displaySizes.resourcePickerWidth,
                                                  child: ResourcePicker(
                                                    resources: model.game.availableResources.toList(),
                                                    enabled: model.isResourcePickerEnabled,
                                                    onTap: _onResourceTapped,
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                ConstrainedBox(
                                                  constraints:
                                                      BoxConstraints(minWidth: model.displaySizes.cardAreaMinWidth),
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        border: Border.all(width: 5, color: Colors.blue),
                                                        borderRadius: BorderRadius.all(Radius.circular(20))),
                                                    padding: EdgeInsets.all(10),
                                                    child: _buildCardArea(context),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    ResourceStorageWidget(resources: model.getAvailableResources()),
                                                    Text(
                                                      '  ${model.displayPlayer!.vpChits}',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black,
                                                        fontSize: 24,
                                                      ),
                                                    ),
                                                    Icon(productTypeToIcon(ProductType.vp)),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: 10),
                                          ],
                                        ),
                                        // SizedBox(
                                        //   width: 200,
                                        //   child: Column(
                                        //     children: _makeStorage(),
                                        //   ),
                                        // ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.baseline,
                                      textBaseline: TextBaseline.alphabetic,
                                      children: <Widget>[
                                        _makeColumn(0),
                                        _makeColumn(1),
                                        _makeColumn(2),
                                        _makeColumn(3),
                                        _makeColumn(4),
                                        //_makeColumn(5),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
              );
            }
          }),
    );
  }

  void _actionButtonPressed(ActionType actionType) {
    model.selectAction(actionType);
  }

  Future<void> _onResourceTapped(int index) async {
    model.resourceSelected(index);
  }

  Future<void> _onPartTapped(Part part) async {
    model.partTapped(part);
  }

  Future<void> _onProductTapped(Product product) async {
    model.productTapped(product);
  }

  Future<void> _onUndoTapped() async {
    model.doUndo();
  }

  Future<void> _onEndTurnTapped() async {
    var unused = model.unusedProducts();
    if (unused > 0) {
      if (true !=
          await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('End Turn'),
                content: Text('You have $unused unused products.  Do you want to end your turn?'),
                actions: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('OK'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          )) {
        return;
      }
    }

    model.showWait = true;
    model.requestUpdate();

    await Future<Object?>.delayed(Duration(milliseconds: 20));
    await model.doEndTurn();
  }
}
