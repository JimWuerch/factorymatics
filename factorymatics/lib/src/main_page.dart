import 'package:engine/engine.dart';
import 'package:factorymatics/src/game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_page_model.dart';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  final String title = 'Factorymatics';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainPageModel model;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    model = MainPageModel(context);
    model.init();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: StreamBuilder<Object>(
        stream: model.notifier,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: Text('loading...'));
          } else {
            return Scaffold(
              appBar: AppBar(
                // Here we take the value from the MyHomePage object that was created by
                // the App.build method, and use it to set our appbar title.
                title: Text(widget.title),
                // actions: <Widget>[
                //   TextButton(
                //     //textColor: Colors.white,
                //     style: TextButton.styleFrom(
                //       primary: Colors.white, // foreground
                //     ),
                //     onPressed: model.canUndo ? _onUndoTapped : null,
                //     child: Text("Undo"),
                //     //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                //   ),
                //   TextButton(
                //     //textColor: Colors.white,
                //     style: TextButton.styleFrom(
                //       primary: Colors.white, // foreground
                //     ),

                //     onPressed: model.canEndTurn ? _onEndTurnTapped : null,
                //     child: Text("End Turn"),
                //     //shape: CircleBorder(side: BorderSide(color: Colors.transparent)),
                //   ),
                // ],
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Container(
                    color: Colors.white,
                    child: ElevatedButton(
                      child: Text('Start Game'),
                      onPressed: () {
                        Navigator.push<void>(
                          context,
                          MaterialPageRoute(builder: (context) => GamePage()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
