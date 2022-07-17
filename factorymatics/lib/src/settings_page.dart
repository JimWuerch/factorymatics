import 'package:card_settings/card_settings.dart';
import 'package:engine/engine.dart';
import 'package:factorymatics/src/settings.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage(this.fmSettings, {Key key}) : super(key: key);

  final FMSettings fmSettings;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        final form = _formKey.currentState;
        if (form.validate()) {
          form.save();
          widget.fmSettings.saveToPrefs();
          return Future.value(true);
        } else {
          showErrors(context);
        }

        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Form(
          key: _formKey,
          child: CardSettings(
            labelWidth: 400,
            contentAlign: TextAlign.right,
            children: <CardSettingsSection>[
              CardSettingsSection(
                header: CardSettingsHeader(
                  label: 'Ai Player',
                ),
                children: <CardSettingsWidget>[
                  // CardSettingsInstructions(
                  //   text:
                  //       'Controls how long the AI will spend figuring out the different combinations to produce the max resources of each type',
                  // ),
                  CardSettingsInt(
                    label: 'maxTimeCalcResourcesAi (ms)',
                    initialValue: gameSettings.maxTimeCalcResourcesAi,
                    validator: (value) {
                      if (value < 25) return 'Min value is 25';
                      return null;
                    },
                    onSaved: (value) => gameSettings.maxTimeCalcResourcesAi = value,
                  ),
                  CardSettingsInt(
                    label: 'maxAiRolloutConverters',
                    initialValue: gameSettings.maxAiRolloutConverters,
                    validator: (value) {
                      if (value < 4) return 'Min value is 4';
                      return null;
                    },
                    onSaved: (value) => gameSettings.maxAiRolloutConverters = value,
                  ),
                  CardSettingsInt(
                    label: 'aiTurnIterations',
                    initialValue: gameSettings.aiTurnIterations,
                    validator: (value) {
                      if (value < 500) return 'Min value is 500';
                      return null;
                    },
                    onSaved: (value) => gameSettings.aiTurnIterations = value,
                  ),
                  CardSettingsInt(
                    label: 'aiTurnTime (ms)',
                    initialValue: gameSettings.aiTurnTime,
                    validator: (value) {
                      if (value < 3000) return 'Min value is 3000';
                      return null;
                    },
                    onSaved: (value) => gameSettings.aiTurnTime = value,
                  ),
                  CardSettingsInt(
                    label: 'aiMinVisits',
                    initialValue: gameSettings.aiMinVisits,
                    validator: (value) {
                      if (value < 10) return 'Min value is 10';
                      return null;
                    },
                    onSaved: (value) => gameSettings.aiMinVisits = value,
                  ),
                  CardSettingsInt(
                    label: 'aiTurnTimeCutoff (ms)',
                    initialValue: gameSettings.aiTurnTimeCutoff,
                    validator: (value) {
                      if (value < 3000) return 'Min value is 3000';
                      return null;
                    },
                    onSaved: (value) => gameSettings.aiTurnTimeCutoff = value,
                  ),
                  CardSettingsInt(
                    label: 'maxAiRolloutTime (ms)',
                    initialValue: gameSettings.maxAiRolloutTime,
                    validator: (value) {
                      if (value < 25) return 'Min value is 50';
                      return null;
                    },
                    onSaved: (value) => gameSettings.maxAiRolloutTime = value,
                  ),
                ],
              ),
              // CardSettingsSection(
              //   header: CardSettingsHeader(
              //     label: 'Actions',
              //   ),
              //   children: <CardSettingsWidget>[
              //     CardSettingsButton(
              //       label: 'Save',
              //       //backgroundColor: Colors.green,
              //       onPressed: savePressed,
              //     ),
              //     CardSettingsButton(
              //       label: 'Reset',
              //       //backgroundColor: Colors.green,
              //       onPressed: savePressed,
              //     ),
              //   ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future savePressed() async {
    final form = _formKey.currentState;

    if (form.validate()) {
      form.save();
    } else {
      showErrors(context);
    }
  }

  void resetPressed() {
    _formKey.currentState.reset();
  }

  void showErrors(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Form has validation errors'),
          content: const Text('Please fix all errors before submitting the form.'),
          actions: <Widget>[
            TextButton(
              child: const Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
