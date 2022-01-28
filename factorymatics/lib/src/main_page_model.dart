import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:engine/engine.dart';
import 'package:factorymatics/src/client.dart';
import 'package:flutter/cupertino.dart';

class MainPageModel {
  Game game;
  final StreamController<int> _notifierController = StreamController<int>.broadcast();
  Stream<int> get notifier => _notifierController.stream;
  final BuildContext context;

  MainPageModel(this.context);

  Future<void> init() async {
    Future.delayed(Duration(milliseconds: 100), () {
      _notifierController.add(1);
    });
  }
}
