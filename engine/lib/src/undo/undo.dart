// cloned from:  https://github.com/rodydavis/undo
// see LICENSE file in this dir
//
// We are customizing the ChangeStack class for our usage

library undo;

import 'dart:async';
import 'dart:collection';

import 'package:engine/engine.dart';

part 'src/undo_stack.dart';
part 'src/changes.dart';
