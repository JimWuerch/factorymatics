import 'package:engine/engine.dart';
import 'package:factorymatics/src/game_page.dart';
import 'package:factorymatics/src/part_test_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'main_page_model.dart';

String version = '1.0';

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);
  final String title = 'Factorymatics $version';

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainPageModel model;
  TextEditingController _textEditController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(debugLabel: 'player names form');
  final RegExp _validPlayerNames = RegExp(r'^[a-zA-Z0-9_\-\^]+$');
  int _numPlayers;

  @override
  void initState() {
    super.initState();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);

    model = MainPageModel(context);
    model.init();
    _textEditController = TextEditingController();
    _textEditController.text = model.numPlayers.toString();
    _numPlayers = model.numPlayers;
  }

  @override
  void dispose() {
    _textEditController.dispose();
    super.dispose();
  }

  List<Widget> _buildNameEntry() {
    var list = <Widget>[];
    for (var index = 0; index < model.numPlayers; index++) {
      list.add(
        TextFormField(
          enabled: index < model.numPlayers,
          autocorrect: false,
          initialValue: model.players[index],
          onSaved: (value) {
            model.players[index] = value;
          },
          decoration: const InputDecoration(
            icon: Icon(Icons.person),
            //hintText: 'Enter your email',
            border: OutlineInputBorder(),
          ),
          // validator: (value) {
          //   // if (value == null || value.isEmpty) {
          //   //   return 'Please enter some text';
          //   // }
          //   if (value != null && !_validPlayerNames.hasMatch(value)) {
          //     return 'Invalid chars in name';
          //   }
          //   return null;
          // },
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.allow(_validPlayerNames),
          ],
        ),
        // TextField(
        //   controller: _textEditController,
        //   inputFormatters: <TextInputFormatter>[
        //     FilteringTextInputFormatter.allow(RegExp(r'\w')),
        //   ],
        //   onSubmitted: (value) {
        //     model.players[index] = value;
        //   },
        //),
      );
    }
    return list;
  }

  // Widget _buildPanel() {
  //   return ExpansionPanelList(
  //     expansionCallback: (index, isExpanded) {
  //       setState(() {
  //         model.isLocalGame = isExpanded;
  //       });
  //     },
  //     children: [
  //       ExpansionPanel(
  //         headerBuilder: (context, isExpanded) {
  //           return ListTile(
  //             title: Text('Players'),
  //           );
  //         },
  //         body: Form(
  //           key: _formKey,
  //           child: Column(
  //             children: _buildNameEntry(),
  //           ),
  //         ),
  //         isExpanded: model.isLocalGame,
  //       ),
  //     ],
  //   );
  // }

  Form _buildPanel() {
    return Form(
      key: _formKey,
      child: Column(
        children: _buildNameEntry(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child:
          // StreamBuilder<Object>(
          //   stream: model.notifier,
          //   builder: (context, snapshot) {
          //     if (!snapshot.hasData) {
          //       return Center(child: Text('loading...'));
          //     } else {
          // return
          Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              color: Colors.white,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 400,
                child: Column(
                  children: [
                    SwitchListTile(
                        title: const Text('Local Game'),
                        value: model.isLocalGame,
                        onChanged: (value) {
                          setState(() {
                            model.isLocalGame = value;
                          });
                        }),
                    Slider(
                      value: _numPlayers.toDouble(),
                      min: 1,
                      max: 4,
                      divisions: 3,
                      label: _numPlayers.toString(),
                      onChanged: (value) {
                        setState(() {
                          _numPlayers = value.toInt();
                        });
                      },
                      onChangeEnd: (value) {
                        setState(() {
                          model.numPlayers = value.toInt();
                        });
                      },
                    ),
                    // TextField(
                    //   autocorrect: false,
                    //   //initialValue: model.numPlayers.toString(),
                    //   controller: _textEditController,
                    //   decoration: const InputDecoration(
                    //     prefixText: 'Number of Players: ',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   inputFormatters: <TextInputFormatter>[
                    //     FilteringTextInputFormatter.allow(RegExp(r'[1234]')),
                    //   ],
                    //   onSubmitted: (value) {
                    //     setState(() {
                    //       model.numPlayers = int.parse(value);
                    //     });
                    //   },
                    // ),
                    _buildPanel(),
                    Text('Start player name with AI to create an AI player.'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        child: Text('Start Game'),
                        onPressed: () async {
                          _formKey.currentState?.save();
                          await model.createLocalGame();
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute(builder: (context) => GamePage(model.gameInfoModel)),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                        child: Text('Part Test'),
                        onPressed: () async {
                          Navigator.push<void>(
                            context,
                            MaterialPageRoute(builder: (context) => PartTestWidget(parts: createParts())),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      //}
      // }, // else in streambuilder
      //), // streambuilder
    );
  }
}
